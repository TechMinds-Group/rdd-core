#!/usr/bin/env node
// get-knowledge-metrics-v2.mjs — Auditor do PAR de métricas de conhecimento (P-09)
// do runtime OpenCode: hit rate de conhecimento + tokens de conhecimento por
// tarefa, em MODO DEGRADADO (heurística de globs — denominadores são PROXY).
//
// Fonte: ~/.local/share/opencode/opencode.db — schema v2:
//   session_v2 (id, directory, title, agent, model TEXT-JSON, tokens_*, time_*)
//   session_message (id, session_id, type, seq, time_created, data JSON)
//     data do assistant: { time:{created,completed}, agent, model:{id,providerID},
//       content: [ {type:'tool', id, name, state:{status, input:{path,...}}} ... ] }
//   Tool calls NÃO têm tabela própria — vivem como blocos content[].type='tool'
//   dentro do data das mensagens assistant (schema descoberta em 2026-10-21).
// Acesso via node:sqlite (DatabaseSync) com { readOnly: true } — requer
// Node >= 22.5. O CLI `opencode db` foi removido no v2.0.26.
//
// MODO DEGRADADO — declaração PROXY (obrigatória em todo relatório):
//   - "Sessão que PRECISAVA de conhecimento" = sessão com >= 1 tool call de
//     leitura (read/grep/glob, status completed) em artefato T4 de engenharia:
//     segmento specs/, analysis/ ou delivery/, ou arquivo REQUIREMENTS.md.
//   - "Hit de conhecimento" = tool call de leitura com path em knowledge/
//     (T1), patterns/INDEX.md ou **/PATTERN.md (T2), rules/**.md (T3).
//     LIMITE: acionamento do bloco routing em prosa NÃO é observável.
//   - "Tokens de conhecimento por tarefa" = soma aproximada (bytes/4) dos
//     arquivos de conhecimento LIDOS (read) por sessão / sessões que
//     precisavam — tamanho no disco HOJE; leitura parcial conta como inteira.
//   Calibração Jev = Fase 5 futura (D12/D15/D17 do plano v5) — fora do escopo.
//
// DISCIPLINA (obrigatória — rdd-knowledge-auditor):
//   - Read-only ABSOLUTO no banco: DatabaseSync { readOnly: true }; nenhum
//     INSERT/UPDATE/DELETE/DDL — nunca adicionar.
//   - Nunca inventar números: sem dados / erro => contadores zerados
//     explicitos + metricas N/A ("sem dados"); nunca estimativa disfarçada.
//   - Dedupe de blocos tool por assinatura t_created|block_id (forks copiam
//     rows com ids novos — IMP-062, análogo).
//   - Só tool calls com state.status='completed' contam (running/error fora).
//   - Modo de erro warn: DB ausente/schema incompatível => relatório "sem
//     dados" + nenhum merge no METRICS.md; nunca bloquear a sessão.
//   - Sem paths de máquina hardcoded (IMP-016); saída UTF-8 sem BOM.
//
// Uso:
//   node get-knowledge-metrics-v2.mjs [--days 7] [--db <path>]
//        [--out-file <path>] [--report-file <path>|none]
//        [--metrics-file <path>|none]
//   Defaults: --db ~/.local/share/opencode/opencode.db;
//             --out-file <tmp>/knowledge-metrics-v2.json;
//             --report-file <pack metrics>/KNOWLEDGE_AUDIT_<ts>.md
//             (pack resolvido de AGENTS.md: pack_ativo; fallback default-pack);
//             --metrics-file <pack metrics>/METRICS.md.
// Exit codes: 0 = sucesso (inclusive "sem dados"/erro declarado) | 1 = uso.
//
// Formato de commit:
//   docs(metrics): knowledge audit <yyyy-MM-dd HH:mm> — hit rate <X>% (<veredito>)

import { DatabaseSync } from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';

// ---------- args ----------
function usage() {
  console.error('Uso: node get-knowledge-metrics-v2.mjs [--days 7] [--db <path>] [--out-file <path>] [--report-file <path>|none] [--metrics-file <path>|none]');
}
function parseArgs(argv) {
  const o = { days: 7, db: '', outFile: '', reportFile: '', metricsFile: '' };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--days') o.days = parseInt(argv[++i], 10);
    else if (a === '--db') o.db = argv[++i];
    else if (a === '--out-file') o.outFile = argv[++i];
    else if (a === '--report-file') o.reportFile = argv[++i];
    else if (a === '--metrics-file') o.metricsFile = argv[++i];
    else if (a === '--help' || a === '-h') { usage(); process.exit(0); }
    else { console.error(`Argumento desconhecido: ${a}`); usage(); process.exit(1); }
  }
  if (!Number.isInteger(o.days) || o.days < 1 || o.days > 36500) { console.error('ERRO: --days invalido (1..36500).'); process.exit(1); }
  if (!o.db) o.db = path.join(os.homedir(), '.local', 'share', 'opencode', 'opencode.db');
  if (!o.outFile) o.outFile = path.join(os.tmpdir(), 'knowledge-metrics-v2.json');
  return o;
}
const opts = parseArgs(process.argv.slice(2));
const CUTOFF = Date.now() - opts.days * 86400000;

// ---------- resolução do pack (destino padrão dos artefatos) ----------
function resolveMetricsDir() {
  try {
    const agentsPath = path.join(os.homedir(), '.config', 'opencode', 'AGENTS.md');
    const txt = fs.readFileSync(agentsPath, 'utf8');
    const m = txt.match(/pack_ativo:\s*([\w.-]+)/);
    if (m) return path.join(os.homedir(), '.config', 'opencode', 'packs', m[1], 'accumulation', 'metrics');
  } catch { /* fallback abaixo */ }
  return path.join(os.homedir(), '.config', 'opencode', 'packs', 'default-pack', 'accumulation', 'metrics');
}
const METRICS_DIR = resolveMetricsDir();
const reportFile = !opts.reportFile ? path.join(METRICS_DIR, `KNOWLEDGE_AUDIT_${tsFilename()}.md`)
  : (opts.reportFile === 'none' ? null : opts.reportFile);
const metricsFile = !opts.metricsFile ? path.join(METRICS_DIR, 'METRICS.md')
  : (opts.metricsFile === 'none' ? null : opts.metricsFile);

function tsFilename() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}-${p(d.getHours())}${p(d.getMinutes())}`;
}
function nowIso() { return new Date().toISOString(); }
function todayBr() {
  const d = new Date(); const p = (n) => String(n).padStart(2, '0');
  return `${p(d.getDate())}/${p(d.getMonth() + 1)}/${d.getFullYear()}`;
}
function fmt1(n) { return n == null ? 'N/A' : (Math.round(n * 10) / 10).toLocaleString('en-US', { maximumFractionDigits: 1 }); }

// ---------- heurística PROXY (classificação de paths) ----------
const norm = (p) => String(p || '').replace(/\\/g, '/');
const RE_T4 = /(^|\/)(specs|analysis|delivery)(\/|$)/i;
const RE_REQ = /(^|\/)REQUIREMENTS\.md$/i;
const RE_T1 = /(^|\/)knowledge\//i;
const RE_T2 = /(^|\/)patterns\/INDEX\.md$|(^|\/)PATTERN\.md$/i;
const RE_T3 = /(^|\/)rules\/.+\.md$/i;
const READ_TOOLS = new Set(['read', 'grep', 'glob']);
// prioridade T1 > T2 > T3 em sobreposição (raro; documento no relatório)
function classifyStore(p) {
  if (RE_T1.test(p)) return 'T1';
  if (RE_T2.test(p)) return 'T2';
  if (RE_T3.test(p)) return 'T3';
  return null;
}
function isNeededPath(p) { return RE_T4.test(p) || RE_REQ.test(p); }

// ---------- coleta ----------
function openDb() {
  if (!fs.existsSync(opts.db)) return { error: 'DB_MISSING', detail: `opencode.db não encontrado em ${opts.db}` };
  let db;
  try { db = new DatabaseSync(opts.db, { readOnly: true }); } // NUNCA sem readOnly
  catch (err) { return { error: 'DB_UNOPENABLE', detail: err.message }; }
  const tables = new Set(db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all().map((r) => r.name));
  if (!tables.has('session_v2') || !tables.has('session_message')) {
    const v1 = tables.has('message');
    return { error: v1 ? 'SCHEMA_V1' : 'SCHEMA_UNKNOWN', detail: v1 ? 'banco em schema v1 (tabela message, sem session_v2) — este coletor atende o schema v2' : 'banco sem tabelas conhecidas (session_v2/session_message)' };
  }
  return { db };
}

function normalizeModel(m, fallback) {
  let v = m ?? fallback ?? null;
  if (v == null || v === '') return 'desconhecido';
  if (typeof v === 'string') {
    const t = v.trim();
    if (t.startsWith('{')) { try { return normalizeModel(JSON.parse(t), null); } catch { return t; } }
    return t;
  }
  if (typeof v === 'object') return String(v.modelID || v.id || 'desconhecido');
  return 'desconhecido';
}

function collect() {
  const opened = openDb();
  if (opened.error) return { error: opened.error, detail: opened.detail };
  const db = opened.db;

  // metadados de sessão (modelo como fallback — o do turno tem precedência)
  const sessRows = db.prepare('SELECT id, directory, title, agent, model, time_created FROM session_v2').all();
  const sessById = new Map(sessRows.map((s) => [s.id, s]));

  // apenas mensagens assistant têm blocos tool
  const msgRows = db.prepare("SELECT id, session_id, time_created, data FROM session_message WHERE type='assistant' AND time_created >= ? ORDER BY session_id, time_created").all(CUTOFF);

  const callsBySession = new Map(); // sid -> [{ tool, path, store, needed, tCreated }]
  const seen = new Set();           // dedupe forks: t_created|block_id (IMP-062 análogo)
  let unclassified_paths = 0;
  let blocks_skipped_status = 0;

  for (const r of msgRows) {
    let d; try { d = JSON.parse(r.data); } catch { continue; }
    const tCreated = Number(d?.time?.created ?? r.time_created);
    if (!Number.isFinite(tCreated) || tCreated < CUTOFF) continue;
    const blocks = Array.isArray(d?.content) ? d.content : (Array.isArray(d?.parts) ? d.parts : []);
    for (const b of blocks) {
      if (!b || b.type !== 'tool' || !READ_TOOLS.has(String(b.name || ''))) continue;
      const key = `${tCreated}|${b.id || ''}`;
      if (seen.has(key)) continue;
      seen.add(key);
      if ((b.state?.status || '') !== 'completed') { blocks_skipped_status++; continue; }
      const input = b.state?.input || {};
      const rawPath = typeof input.path === 'string' ? input.path : '';
      if (!rawPath) { unclassified_paths++; continue; } // grep/glob sem path — não classificável (contado, nunca inventado)
      const p = norm(rawPath);
      const call = { tool: String(b.name), path: p, store: classifyStore(p), needed: isNeededPath(p), tCreated };
      if (!callsBySession.has(r.session_id)) callsBySession.set(r.session_id, []);
      callsBySession.get(r.session_id).push(call);
    }
  }
  return { sessById, callsBySession, unclassified_paths, blocks_skipped_status };
}

// tokens aproximados (bytes/4) — tamanho NO DISCO HOJE (proxy declarado)
function tokensOfReadFile(p) {
  try { return Math.round((fs.statSync(p).size / 4) * 10) / 10; } catch { return null; } // null = arquivo não statável (contado, custo 0)
}

function aggregate() {
  const res = collect();
  if (res.error) return res;

  const perSession = new Map(); // sid -> { needed, hit, tokens, models:Set, calls }
  for (const [sid, calls] of res.callsBySession) {
    const s = { needed: false, hit: false, tokens: 0, models: new Set(), calls, readKnowledgePaths: new Set(), unstatable: 0 };
    const meta = res.sessById.get(sid) || {};
    const fallbackModel = meta.model;
    for (const c of calls) {
      if (c.needed) s.needed = true;
      if (c.store) s.hit = true;
    }
    // tokens: só chamadas read com store (custo de carga integral — proxy)
    for (const c of calls) {
      if (c.tool !== 'read' || !c.store) continue;
      if (s.readKnowledgePaths.has(c.path)) continue; // 1ª leitura por sessão+arquivo (conservador)
      s.readKnowledgePaths.add(c.path);
      const t = tokensOfReadFile(c.path);
      if (t == null) s.unstatable++;
      else s.tokens += t;
    }
    // modelo: n/a por call aqui — resolvido abaixo por sessão via msg mais recente;
    // simplificação: usa session_v2.model (sessões longas multi-modelo são limite declarado)
    s.model = normalizeModel(fallbackModel, null);
    perSession.set(sid, s);
  }

  const sessions = [...perSession.entries()].map(([sid, s]) => ({ sid: String(sid), ...s }));
  const observable = sessions.length;
  const neededSessions = sessions.filter((s) => s.needed);
  const needed = neededSessions.length;
  const hitNeeded = neededSessions.filter((s) => s.hit);
  const hitOutside = sessions.filter((s) => !s.needed && s.hit);

  const hitsTotal = sessions.reduce((acc, s) => acc + s.calls.filter((c) => c.store).length, 0);
  const hitsByStore = { T1: 0, T2: 0, T3: 0 };
  const storeSessions = { T1: new Set(), T2: new Set(), T3: new Set() };
  const hitsByTool = { read: 0, grep: 0, glob: 0 };
  let knowledgeReads = 0, readsT4 = 0;
  const byDay = new Map();
  for (const s of sessions) {
    for (const c of s.calls) {
      const day = new Date(c.tCreated).toISOString().slice(0, 10);
      if (!byDay.has(day)) byDay.set(day, { day, hits: 0, reads_t4: 0 });
      const d = byDay.get(day);
      if (c.store) { hitsByStore[c.store]++; hitsByTool[c.tool]++; d.hits++; storeSessions[c.store].add(s.sid); }
      if (c.tool === 'read' && c.store) knowledgeReads++;
      if (c.needed) { readsT4++; d.reads_t4++; }
    }
  }
  const tokensTotal = Math.round(sessions.reduce((a, s) => a + s.tokens, 0) * 10) / 10;
  const unstatable = sessions.reduce((a, s) => a + s.unstatable, 0);

  // por modelo (P-11): apenas sessões observáveis; rate N/A quando needed=0
  const byModelMap = new Map();
  for (const s of sessions) {
    if (!byModelMap.has(s.model)) byModelMap.set(s.model, { model: s.model, sessions_observable: 0, sessions_needed: 0, sessions_hit: 0, tokens: 0 });
    const m = byModelMap.get(s.model);
    m.sessions_observable++;
    if (s.needed) m.sessions_needed++;
    if (s.needed && s.hit) m.sessions_hit++;
    m.tokens = Math.round((m.tokens + s.tokens) * 10) / 10;
  }
  const byModel = [...byModelMap.values()].map((m) => ({
    ...m,
    hit_rate: m.sessions_needed ? Math.round((m.sessions_hit / m.sessions_needed) * 1000) / 10 : null,
    tokens_per_task: m.sessions_needed ? Math.round((m.tokens / m.sessions_needed) * 10) / 10 : null,
  })).sort((a, b) => b.sessions_needed - a.sessions_needed || b.sessions_observable - a.sessions_observable);

  const hitRateGlobal = needed ? Math.round((hitNeeded.length / needed) * 1000) / 10 : null;
  const tokensPerTask = needed ? Math.round((tokensTotal / needed) * 10) / 10 : null;

  return {
    has_data: observable > 0,
    error: null,
    counters: {
      sessions_observable: observable,
      sessions_needed: needed,
      sessions_hit_needed: hitNeeded.length,
      sessions_hit_outside: hitOutside.length,
      hits_total: hitsTotal,
      hits_by_store: hitsByStore,
      hits_by_tool: hitsByTool,
      knowledge_reads: knowledgeReads,
      reads_t4: readsT4,
      unclassified_paths: res.unclassified_paths,
      blocks_skipped_status: res.blocks_skipped_status,
      files_unstatable: unstatable,
    },
    hit_rate_global: hitRateGlobal,
    tokens_total: tokensTotal,
    tokens_per_task: tokensPerTask,
    by_store: ['T1', 'T2', 'T3'].map((k) => ({ store: k, hits: hitsByStore[k], sessions: storeSessions[k].size })),
    by_model: byModel,
    by_day: [...byDay.values()].sort((a, b) => a.day.localeCompare(b.day)),
    hit_outside_sessions: hitOutside.map((s) => s.sid.slice(0, 12)),
  };
}

// ---------- relatório ----------
const PROXY_BLOCK = [
  '## Declaração PROXY (obrigatória — modo degradado)',
  '',
  '- **"Sessão que precisava de conhecimento"** = sessão com >= 1 tool call de leitura (read/grep/glob) em artefato T4 de engenharia (`specs/**`, `analysis/**`, `delivery/**`, `REQUIREMENTS.md`) — **PROXY** (heurística de globs), não medida calibrada.',
  '- **"Hit de conhecimento"** = tool call de leitura com path em `knowledge/**` (T1), `patterns/INDEX.md` ou `**/PATTERN.md` (T2), `rules/**.md` (T3) — **PROXY**. Limite declarado: acionamento do bloco `knowledge-routing` em prosa NÃO é observável no db.',
  '- **"Tokens de conhecimento por tarefa"** = soma aproximada (bytes/4, ASCII) dos arquivos de conhecimento LIDOS (tool read) por sessão dividido pelas sessões que precisavam — **PROXY**: tamanho no disco HOJE; leitura parcial (offset/limit) conta como arquivo inteiro; 1ª leitura por sessão+arquivo apenas.',
  '- Calibração Jev (classificadores Noul/relevância) = Fase 5 futura — D12/D15/D17 do plano v5. Este modo degradado é o caminho primário e é o baseline (P-09: instrumentação antes de decisão de infra).',
];

function renderReport(a) {
  const head = [
    '---',
    'project: WORKFLOW_RUNTIME',
    'module: knowledge-audit',
    'audience: [governanca, tecnica]',
    'status: draft',
    `generated_at: "${nowIso()}"`,
    `window_days: ${opts.days}`,
    'mode: degradado-proxy',
    '---',
    '',
    '# Knowledge Audit — Hit Rate + Tokens de Conhecimento (MODO DEGRADADO)',
    '',
    `> **Gerado em:** ${todayBr()}  `,
    `> **Janela: últimos ${opts.days} dias**  `,
    `> **Fonte:** opencode.db v2 (session_v2 + session_message, read-only)  `,
    '> **Modo:** DEGRADADO — denominadores são PROXY (heurística de globs), não medida calibrada (P-09; plano v5 D8/D12/D15/D17).',
    '',
    ...PROXY_BLOCK,
    '',
  ];

  if (a.error) {
    // contadores ZERADOS explícitos — nunca números inventados; nenhum "%" neste relatório
    return [...head,
      '## Status: sem dados',
      '',
      `**Erro declarado:** ${a.error} — ${a.detail || ''}`,
      '',
      'Sem dados na janela configurada: as métricas abaixo ficam **N/A** e os contadores, **zerados**. Nenhum número foi estimado ou inventado.',
      '',
      '## Contadores zerados',
      '',
      '| Contador | Valor |',
      '|----------|-------|',
      '| Sessões observáveis (>= 1 read/grep/glob concluído) | 0 |',
      '| Sessões que precisavam (T4 — proxy) | 0 |',
      '| Sessões com hit de conhecimento | 0 |',
      '| Hits de conhecimento | 0 |',
      '| Tokens de conhecimento | 0 |',
      '',
      '| Métrica | Valor |',
      '|---------|-------|',
      '| Hit rate: N/A | |',
      '| Tokens de conhecimento por tarefa: N/A | |',
      '',
      '## Metodologia e Limitações',
      '',
      '- Fonte: opencode.db (SQLite local, leitura exclusivamente read-only via node:sqlite — Node >= 22.5).',
      '- O modo de erro é `warn`: banco ausente ou schema incompatível geram este relatório com erro declarado; nenhum merge é feito no METRICS.md.',
      '- Nenhum merge no METRICS.md ocorre em relatório sem dados.',
      '',
    ].join('\n');
  }

  const c = a.counters;
  const pct = (v) => (v == null ? 'N/A' : `${fmt1(v)}%`);
  const lines = [...head,
    '## Contadores brutos',
    '',
    '| Contador | Valor |',
    '|----------|-------|',
    `| Sessões observáveis (>= 1 read/grep/glob concluído) | ${c.sessions_observable} |`,
    `| Sessões que precisavam (T4 — PROXY) | ${c.sessions_needed} |`,
    `| Sessões que precisavam E tiveram hit | ${c.sessions_hit_needed} |`,
    `| Sessões com hit FORA de contexto que precisava | ${c.sessions_hit_outside} |`,
    `| Hits de conhecimento (tool calls) | ${c.hits_total} |`,
    `| Leituras T4 (calls que marcaram necessidade) | ${c.reads_t4} |`,
    `| Leituras read em conhecimento (custo de tokens) | ${c.knowledge_reads} |`,
    `| Calls grep/glob sem path (não classificáveis — contados, nunca inventados) | ${c.unclassified_paths} |`,
    `| Blocos tool ignorados por status (running/error) | ${c.blocks_skipped_status} |`,
    `| Arquivos de conhecimento não statáveis no disco (custo 0) | ${c.files_unstatable} |`,
    '',
    '## Hit Rate Global',
    '',
    '| Métrica | Valor |',
    '|---------|-------|',
    `| Hit rate global | ${pct(a.hit_rate_global)} (${c.sessions_hit_needed}/${c.sessions_needed}) |`,
    `| Tokens de conhecimento por tarefa (média) | ${fmt1(a.tokens_per_task)} |`,
    `| Tokens de conhecimento (total da janela) | ${fmt1(a.tokens_total)} |`,
    '',
    '## Hit Rate por Store',
    '',
    '| Store | Local | Hits | Sessões com hit |',
    '|-------|-------|------|-----------------|',
    '| T1 | knowledge/** (bases de domínio + nuances do pack) | ' + `${a.by_store[0].hits} | ${a.by_store[0].sessions} |`,
    '| T2 | patterns/INDEX.md + **/PATTERN.md (acúmulo da org) | ' + `${a.by_store[1].hits} | ${a.by_store[1].sessions} |`,
    '| T3 | rules/**.md (rules lazy) | ' + `${a.by_store[2].hits} | ${a.by_store[2].sessions} |`,
    '',
    `Hits por tool: read = ${a.counters.hits_by_tool.read} · grep = ${a.counters.hits_by_tool.grep} · glob = ${a.counters.hits_by_tool.glob}`,
    '',
    '## Hit Rate por Modelo (P-11)',
    '',
    '| Modelo | Sessões que precisavam | Sessões com hit | Hit rate | Tokens conhecimento | Tokens/tarefa |',
    '|--------|------------------------|-----------------|----------|---------------------|---------------|',
    ...a.by_model.map((m) => `| ${m.model} | ${m.sessions_needed} | ${m.sessions_hit} | ${pct(m.hit_rate)} | ${fmt1(m.tokens)} | ${fmt1(m.tokens_per_task)} |`),
    '',
    '## Tokens de Conhecimento por Tarefa (P-09)',
    '',
    `- Média da janela: **${fmt1(a.tokens_per_task)}** tokens de conhecimento por tarefa que precisava (PROXY bytes/4).`,
    `- Sessões com hit fora de contexto que precisava: ${c.sessions_hit_outside}${a.hit_outside_sessions.length ? ` (${a.hit_outside_sessions.join(', ')})` : ''} — roteamento acionado sem demanda T4 observável.`,
    '',
    '## Janela por Dia',
    '',
    '| Dia | Hits | Leituras T4 |',
    '|-----|------|-------------|',
    ...(a.by_day.length ? a.by_day.map((d) => `| ${d.day} | ${d.hits} | ${d.reads_t4} |`) : ['| (sem dias com atividade) | 0 | 0 |']),
    '',
    '## Metodologia e Limitações',
    '',
    '- Fonte: opencode.db v2 — tool calls vivem como blocos `content[].type=\'tool\'` no `data` das mensagens assistant (sem tabela própria; schema descoberta 2026-10-21).',
    '- Só tool calls `read`/`grep`/`glob` com `state.status = \'completed\'` contam; running/error ignorados (contados).',
    '- Dedupe de forks pela assinatura `t_created|block_id` (análogo IMP-062).',
    '- Modelo por sessão: `session_v2.model` (normalizado `{providerID}/{id}` para `id`); sessões multi-modelo são um limite declarado.',
    '- `rules/*.yaml` (ex.: stack-templates.yaml) e invocações da tool `skill` NÃO contam como hit — limite declarado.',
    '- Sobreposição rara de stores resolve por prioridade T1 > T2 > T3.',
    '- Leitura exclusivamente read-only; nenhum dado é gravado no opencode.db.',
    '- **Interpretação:** hit rate baixo com store existente = biblioteca morta (AP-11) ou gatilho otimista para o modelo em uso (AP-13/P-11). Rodar >= 2 ciclos antes de qualquer decisão de infra (D17).',
    '',
  ];
  return lines.join('\n');
}

// ---------- merge no METRICS.md (nunca sobrescrever histórico) ----------
function mergeMetrics(a) {
  if (!metricsFile) return;
  if (!a.has_data) return; // erro/sem dados: nenhum merge
  const c = a.counters;
  const rate = a.hit_rate_global == null ? 'N/A' : `${fmt1(a.hit_rate_global)}%`;
  const tpt = a.tokens_per_task == null ? 'N/A' : fmt1(a.tokens_per_task);
  const row = `| ${todayBr()} | ${opts.days} | ${c.sessions_needed} | ${c.sessions_hit_needed} | ${rate} | ${c.sessions_hit_outside} | ${tpt} | ${a.by_model.length} |`;
  let txt = '';
  try { txt = fs.readFileSync(metricsFile, 'utf8'); } catch { txt = ''; }
  const header = '## Knowledge Hit Rate';
  const tableHead = [
    header,
    '',
    '> Fonte: `rdd-knowledge-auditor` (modo degradado — denominadores PROXY; P-09/D8). Hit rate = sessões que precisavam E tiveram hit ÷ sessões que precisavam.',
    '',
    '| Data | Janela (dias) | Sessões que precisavam | Sessões com hit | Hit rate global | Hits fora de contexto | Tokens conhecimento/tarefa | Modelos |',
    '|------|---------------|------------------------|-----------------|-----------------|-----------------------|----------------------------|---------|',
  ];
  if (!txt.includes(header)) {
    const base = txt.endsWith('\n') || txt === '' ? txt : txt + '\n';
    txt = base + '\n---\n\n' + [...tableHead, row, ''].join('\n');
  } else {
    const lines = txt.split('\n');
    const start = lines.findIndex((l) => l.trim() === header);
    let lastRow = start;
    for (let i = start + 1; i < lines.length; i++) {
      const t = lines[i].trim();
      if (t.startsWith('## ')) break; // próxima seção
      if (t.startsWith('|') && !t.includes('|---') && !t.startsWith('| Data')) lastRow = i;
    }
    lines.splice(lastRow + 1, 0, row);
    txt = lines.join('\n');
  }
  fs.mkdirSync(path.dirname(metricsFile), { recursive: true });
  fs.writeFileSync(metricsFile, txt, 'utf8'); // UTF-8 sem BOM
}

// ---------- main ----------
const result = aggregate();
const report = renderReport(result);
if (reportFile) {
  fs.mkdirSync(path.dirname(reportFile), { recursive: true });
  fs.writeFileSync(reportFile, report, 'utf8');
}
mergeMetrics(result);
fs.writeFileSync(opts.outFile, JSON.stringify({
  generated_at: nowIso(), days: opts.days, cutoff_ms: CUTOFF,
  db: opts.db, source: 'opencode.db v2 (session_v2 + session_message via node:sqlite, read-only)',
  proxy: true, mode: 'degradado',
  ...result,
}, null, 1) + '\n', 'utf8');
if (result.error) {
  console.error(`AVISO (warn — não bloqueia): ${result.error} — ${result.detail || ''}`);
  console.log('sem dados — relatório com erro declarado e contadores zerados' + (reportFile ? ` em ${reportFile}` : ''));
} else {
  const c = result.counters;
  console.log(`sessões=${c.sessions_observable} precisavam=${c.sessions_needed} hit=${c.sessions_hit_needed} rate=${result.hit_rate_global == null ? 'N/A' : result.hit_rate_global + '%'} tokens/tarefa=${result.tokens_per_task}`);
  console.log('out-file:', opts.outFile);
  if (reportFile) console.log('report:', reportFile);
  if (metricsFile && result.has_data) console.log('metrics merge:', metricsFile);
}
