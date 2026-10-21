#!/usr/bin/env node
// get-perf-metrics-v2.mjs — Métricas de performance do runtime OpenCode
// (schema v2 do opencode.db — read-only absoluto).
//
// Fonte: ~/.local/share/opencode/opencode.db — schema v2:
//   session_v2 (id, directory, title, agent, model, tokens_input/output,
//               time_created, time_updated)
//   session_message (session_id, type 'user'|'assistant', time_created,
//                    data JSON — data.time.created/completed,
//                    data.tokens.input/output, data.agent, data.model)
// O CLI `opencode db` foi REMOVIDO no OpenCode v2.0.26 (breaking change —
// IMP-104); a leitura é feita via node:sqlite (DatabaseSync) com
// { readOnly: true } — requer Node >= 22.5 (node:sqlite).
//
// DISCIPLINA (obrigatória — rdd-perf-auditor):
//   - Read-only ABSOLUTO: DatabaseSync { readOnly: true }; nenhum comando
//     de escrita (INSERT/DELETE/DDL) existe neste script — nunca adicionar.
//   - Percentis nearest-rank (índice = ceil(p/100 × N), 1-based).
//   - Turnos sem data.time.completed (em andamento) filtrados.
//   - Dedupe de turnos duplicados por forks de sessão: assinatura temporal
//     t_created|t_completed|type (IMP-062).
//   - Context bloat só em sessões com >= 4 turnos concluídos.
//   - IMP-099: sessões não mapeadas são contadas (rollup_099.unmapped) —
//     nunca atribuídas a feature por chute.
//   - Turno com turn_ms > 10 min: etiquetado wall-clock (suspenção de
//     máquina/tools/humano), não latência de modelo.
//   - `session_v2.agent` é mutável — data.agent da mensagem tem precedência
//     quando presente.
//   - Banco schema v1 (tabela `message`, sem `session_v2`) → exit 2 com
//     orientação para o fallback scripts/get-perf-metrics.ps1 (OpenCode v1,
//     via `opencode db`; detectar versão com `opencode --version`).
//   - Sem paths de máquina hardcoded (IMP-016); saída UTF-8 sem BOM.
//
// Uso:
//   node get-perf-metrics-v2.mjs [--days 7] [--top-slow 10]
//        [--runaway-tok-in 200000] [--out-file <path>]
//   Default --out-file: <os.tmpdir()>/perf-metrics-v2.json (%TEMP% no Windows).
//
// Exit codes: 0 = sucesso (inclusive janela vazia) | 1 = falha | 2 = banco
// schema v1 detectado.

import { DatabaseSync } from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';

function usage() {
  console.error('Uso: node get-perf-metrics-v2.mjs [--days 7] [--top-slow 10] [--runaway-tok-in 200000] [--out-file <path>]');
}

function parseArgs(argv) {
  const o = { days: 7, topSlow: 10, runawayTokIn: 200000, outFile: '' };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--days') o.days = parseInt(argv[++i], 10);
    else if (a === '--top-slow') o.topSlow = parseInt(argv[++i], 10);
    else if (a === '--runaway-tok-in') o.runawayTokIn = parseInt(argv[++i], 10);
    else if (a === '--out-file') o.outFile = argv[++i];
    else if (a === '--help' || a === '-h') { usage(); process.exit(0); }
    else { console.error(`Argumento desconhecido: ${a}`); usage(); process.exit(1); }
  }
  if (!Number.isInteger(o.days) || o.days < 1 || o.days > 3650) { console.error('ERRO: --days inválido (1..3650).'); process.exit(1); }
  if (!Number.isInteger(o.topSlow) || o.topSlow < 1 || o.topSlow > 100) { console.error('ERRO: --top-slow inválido (1..100).'); process.exit(1); }
  if (!Number.isInteger(o.runawayTokIn) || o.runawayTokIn < 1000) { console.error('ERRO: --runaway-tok-in inválido (>= 1000).'); process.exit(1); }
  if (!o.outFile) o.outFile = path.join(os.tmpdir(), 'perf-metrics-v2.json'); // %TEMP% → fallback os.tmpdir()
  return o;
}

const opts = parseArgs(process.argv.slice(2));
const DB_PATH = path.join(os.homedir(), '.local', 'share', 'opencode', 'opencode.db');

let db;
try {
  db = new DatabaseSync(DB_PATH, { readOnly: true }); // NUNCA abrir sem readOnly
} catch (err) {
  console.error(`ERRO: não foi possível abrir o opencode.db em modo leitura (${DB_PATH}): ${err.message}`);
  console.error('Verifique se o OpenCode foi executado ao menos uma vez nesta máquina.');
  process.exit(1);
}

// ---------- detecção de schema (v1 vs v2) ----------
const tableRows = db.prepare("SELECT name FROM sqlite_master WHERE type = 'table' AND name IN ('session_v2', 'message')").all();
const tableNames = new Set(tableRows.map((r) => r.name));
if (!tableNames.has('session_v2')) {
  if (tableNames.has('message')) {
    console.error('ERRO: banco em schema v1 detectado (tabela `message`, sem `session_v2`).');
    console.error('Este coletor atende o OpenCode v2 — para v1 use scripts/get-perf-metrics.ps1 (via `opencode db`; detectar versão com `opencode --version`).');
    process.exit(2);
  }
  console.error(`ERRO: opencode.db sem tabelas conhecidas (nem session_v2 nem message) em ${DB_PATH}.`);
  process.exit(1);
}

const cutoff = Date.now() - opts.days * 86400000;

// ---------- coleta (SELECT apenas) ----------
const sessRows = db.prepare('SELECT id, directory, title, agent, model, tokens_input, tokens_output, time_created, time_updated FROM session_v2').all();
const sessById = new Map(sessRows.map((s) => [s.id, s]));

const msgRows = db.prepare("SELECT session_id, type, time_created, data FROM session_message WHERE type IN ('user', 'assistant') AND time_created >= ? ORDER BY session_id, time_created").all(cutoff);

const sessions = new Map(); // sid -> { userTimes: [], turns: [], dir, title, sessAgent }

function sessionOf(sid) {
  let s = sessions.get(sid);
  if (!s) {
    const meta = sessById.get(sid) || {};
    s = { userTimes: [], turns: [], dir: meta.directory || '', title: meta.title || '', sessAgent: meta.agent || '' };
    sessions.set(sid, s);
  }
  return s;
}

// Dedupe IMP-062: forks copiam mensagens com ids novos — a chave efetiva é a
// assinatura temporal t_created|t_completed|type.
const seen = new Set();
for (const r of msgRows) {
  let d;
  try { d = JSON.parse(r.data); } catch { continue; }
  const tCreated = Number(d?.time?.created ?? r.time_created);
  if (!Number.isFinite(tCreated) || tCreated <= 0) continue;
  const rawCompleted = r.type === 'assistant' ? d?.time?.completed : null;
  const tCompleted = rawCompleted == null ? null : Number(rawCompleted);
  const key = `${tCreated}|${tCompleted ?? ''}|${r.type}`;
  if (seen.has(key)) continue;
  seen.add(key);

  const s = sessionOf(r.session_id);
  if (r.type === 'user') { s.userTimes.push(tCreated); continue; }
  if (tCompleted == null || !Number.isFinite(tCompleted)) continue; // turno em andamento — filtrar
  const turnMs = tCompleted - tCreated;
  if (turnMs < 0) continue;

  const agent = (typeof d?.agent === 'string' && d.agent) || s.sessAgent || 'desconhecido';
  let model = 'desconhecido';
  const dm = d?.model;
  if (typeof dm === 'string' && dm) model = dm;
  else if (dm && typeof dm === 'object') model = dm.modelID || dm.id || model;
  else if (typeof d?.modelID === 'string' && d.modelID) model = d.modelID;

  s.turns.push({
    session: r.session_id,
    agent, model,
    day: new Date(tCreated).toISOString().slice(0, 10),
    tok_in: d?.tokens?.input ?? 0,
    tok_out: d?.tokens?.output ?? 0,
    turn_ms: turnMs,
    t_created: tCreated,
    t_completed: tCompleted,
  });
}

const turns = [];
for (const s of sessions.values()) turns.push(...s.turns);

// ---------- percentis nearest-rank ----------
function pct(values, p) {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const idx = Math.max(0, Math.ceil((p / 100) * sorted.length) - 1);
  return sorted[idx];
}

function verdictOf(p95) {
  if (p95 == null) return 'N/A';
  if (p95 > 120000) return 'CRITICO';
  if (p95 > 30000) return 'WARNING';
  return 'OK';
}

function groupBy(keyFn, fieldName) {
  const groups = new Map();
  for (const t of turns) {
    const k = keyFn(t);
    if (!groups.has(k)) groups.set(k, []);
    groups.get(k).push(t.turn_ms);
  }
  return [...groups.entries()].map(([k, ms]) => {
    const p50 = pct(ms, 50);
    const p95 = pct(ms, 95);
    return {
      [fieldName]: k,
      turns: ms.length,
      p50_ms: p50,
      p95_ms: p95,
      max_ms: ms.length ? Math.max(...ms) : null,
      verdict: verdictOf(p95),
    };
  });
}

// ---------- agregações globais ----------
const allMs = turns.map((t) => t.turn_ms);
const p50 = pct(allMs, 50);
const p95 = pct(allMs, 95);
const maxMs = allMs.length ? Math.max(...allMs) : null;

// ---------- interação user → resposta ----------
// IMP-104: "1ª resposta" = latência até a CONCLUSÃO da 1ª resposta —
// primeiro assistant concluído com t_completed >= user.created — não o
// marcador de início do turno (métrica sem valor, descartada no emergencial).
const firstResp = [];
const conclusion = [];
for (const s of sessions.values()) {
  const ut = [...s.userTimes].sort((a, b) => a - b);
  const at = [...s.turns].sort((a, b) => a.t_completed - b.t_completed);
  for (const u of ut) {
    const first = at.find((t) => t.t_completed >= u);
    if (first) firstResp.push(first.t_completed - u);
    const nextUser = ut.find((x) => x > u);
    const before = at.filter((t) => t.t_completed >= u && (!nextUser || t.t_completed < nextUser));
    if (before.length) conclusion.push(before[before.length - 1].t_completed - u);
  }
}

// ---------- context bloat por sessão (>= 4 turnos) ----------
const bloat = [];
let insufficient = 0;
for (const [sid, s] of sessions) {
  if (s.turns.length < 4) { insufficient++; continue; }
  const sorted = [...s.turns].sort((a, b) => a.t_created - b.t_created);
  const firstTok = sorted[0].tok_in;
  const lastTok = sorted[sorted.length - 1].tok_in;
  const ratio = firstTok > 0 ? Math.round((lastTok / firstTok) * 100) / 100 : null;
  const half = Math.floor(sorted.length / 2);
  const p95a = pct(sorted.slice(0, half).map((t) => t.turn_ms), 95);
  const p95b = pct(sorted.slice(half).map((t) => t.turn_ms), 95);
  const latencyGrew = p95a != null && p95b != null && p95a > 0 && p95b > 2 * p95a;
  let flag = '';
  if (ratio != null && ratio > 3 && latencyGrew) flag = 'CONTEXT BLOAT';
  else if (latencyGrew && ratio == null) flag = 'LATENCIA CRESCENTA (tok N/A)';
  if (flag) {
    bloat.push({
      session: String(sid).slice(0, 12),
      turns: sorted.length,
      tok_in_first: firstTok,
      tok_in_last: lastTok,
      ratio,
      p95_early_ms: p95a,
      p95_late_ms: p95b,
      flag,
    });
  }
}

// ---------- contexto runaway (tamanho absoluto — IMP-042) ----------
const runaway = [];
for (const [sid, s] of sessions) {
  const over = s.turns.filter((t) => t.tok_in > opts.runawayTokIn);
  if (over.length) {
    runaway.push({
      session: String(sid).slice(0, 12),
      agent: over[0].agent,
      turns: s.turns.length,
      turns_over: over.length,
      max_tok_in: Math.max(...over.map((t) => t.tok_in)),
      flag: 'RUNAWAY CONTEXT',
    });
  }
}

// ---------- top-N turnos mais lentos (outlier > 10 min = wall-clock) ----------
const topSlow = [...turns]
  .sort((a, b) => b.turn_ms - a.turn_ms)
  .slice(0, opts.topSlow)
  .map((t) => ({
    session: String(t.session).slice(0, 12),
    agent: t.agent,
    model: t.model,
    day: t.day,
    tok_in: t.tok_in,
    turn_ms: t.turn_ms,
    ...(t.turn_ms > 600000
      ? { wall_clock: true, label: 'wall-clock inflado — verificar causa (suspenção/tools/humano)' }
      : {}),
  }));

// ---------- roll-up heurístico por feature (IMP-099) ----------
const featureMap = {};
let unmapped = 0;
for (const s of sessions.values()) {
  if (!s.turns.length) continue;
  const hay = `${s.dir} ${s.title}`;
  const rn = hay.match(/RN[- ]?(\d{3})/i);
  const dirSeg = (s.dir || '').split(/[\\/]/).filter(Boolean).pop() || '';
  const key = rn ? `RN-${rn[1]}` : (dirSeg && dirSeg.length > 2 ? dirSeg : null);
  if (!key) { unmapped++; continue; }
  const f = (featureMap[key] = featureMap[key] || { sessions: 0, turns: 0, sum_ms: 0, sum_tokens: 0, ms: [] });
  f.sessions++;
  f.turns += s.turns.length;
  for (const t of s.turns) {
    f.sum_ms += t.turn_ms;
    f.sum_tokens += t.tok_in + t.tok_out;
    f.ms.push(t.turn_ms);
  }
}
for (const k of Object.keys(featureMap)) {
  const f = featureMap[k];
  f.p95_ms = pct(f.ms, 95);
  delete f.ms;
}

function writeOut(obj) {
  const json = JSON.stringify(obj, null, 1) + '\n';
  fs.writeFileSync(opts.outFile, json, 'utf8'); // UTF-8 sem BOM (padrão do Node)
  console.log(JSON.stringify(obj.summary));
  console.log('by_day:', JSON.stringify(obj.by_day));
  console.log('interaction:', JSON.stringify(obj.interaction));
  if (obj.rollup_099) console.log('rollup unmapped:', obj.rollup_099.unmapped, '| features:', Object.keys(obj.rollup_099.features).length);
  console.log('out-file:', opts.outFile);
}

if (!turns.length) {
  writeOut({
    generated_at: new Date().toISOString(),
    days: opts.days,
    cutoff_ms: cutoff,
    source: 'opencode.db v2 (session_v2 + session_message via node:sqlite, read-only)',
    has_data: false,
    message: 'sem dados na janela — aumente --days ou verifique o opencode.db',
    summary: null,
    by_day: [],
    by_agent: [],
    by_model: [],
    top_slow: [],
    context_bloat: [],
    context_runaway: [],
    interaction: null,
    rollup_099: { features: {}, unmapped: 0 },
  });
  process.exit(0);
}

writeOut({
  generated_at: new Date().toISOString(),
  days: opts.days,
  cutoff_ms: cutoff,
  source: 'opencode.db v2 (session_v2 + session_message via node:sqlite, read-only)',
  has_data: true,
  summary: {
    turns: turns.length,
    sessions: new Set(turns.map((t) => t.session)).size,
    p50_ms: p50,
    p95_ms: p95,
    max_ms: maxMs,
    verdict: verdictOf(p95),
    bloat_sessions: bloat.length,
    runaway_sessions: runaway.length,
    insufficient_sessions: insufficient,
  },
  by_day: groupBy((t) => t.day, 'day').sort((a, b) => String(a.day).localeCompare(String(b.day))),
  by_agent: groupBy((t) => t.agent, 'agent').sort((a, b) => b.turns - a.turns),
  by_model: groupBy((t) => t.model, 'model').sort((a, b) => b.turns - a.turns).slice(0, 12),
  top_slow: topSlow,
  context_bloat: bloat,
  context_runaway: runaway,
  interaction: {
    samples_first: firstResp.length,
    p50_first_ms: pct(firstResp, 50),
    p95_first_ms: pct(firstResp, 95),
    samples_interaction: conclusion.length,
    p50_interaction_ms: pct(conclusion, 50),
    p95_interaction_ms: pct(conclusion, 95),
  },
  rollup_099: { features: featureMap, unmapped },
});
