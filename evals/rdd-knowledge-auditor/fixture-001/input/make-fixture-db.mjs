#!/usr/bin/env node
// make-fixture-db.mjs — gera o db sintético + arquivos sandbox da fixture-001
// do rdd-knowledge-auditor. Rodar DEPOIS de clonar/alterar o sandbox:
//   node make-fixture-db.mjs
// Cria (sempre regenera): knowledge-audit-fixture.db + sandbox/ com arquivos
// de conhecimento de tamanhos EXATOS (tokens = bytes/4).
import { DatabaseSync } from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const sb = path.join(here, 'sandbox');
fs.rmSync(sb, { recursive: true, force: true });

// ---- arquivos sandbox com tamanhos exatos (ASCII => 1 byte/char) ----
function writeExact(rel, head, totalBytes) {
  const p = path.join(sb, rel);
  fs.mkdirSync(path.dirname(p), { recursive: true });
  let txt = head;
  if (txt.length > totalBytes) throw new Error(`${rel}: head maior que o total`);
  txt += 'x'.repeat(totalBytes - txt.length);
  fs.writeFileSync(p, txt, 'utf8');
  if (Buffer.byteLength(txt, 'utf8') !== totalBytes) throw new Error(`${rel}: tamanho fora`);
  return p;
}
const K1 = writeExact('knowledge/demo/KNOWLEDGE.md', '# KNOWLEDGE - demo (400B = 100 tokens)\n', 400);
const R1 = writeExact('rules/context7.md', '# RULE - context7 (200B = 50 tokens)\n', 200);
const I1 = writeExact('patterns/INDEX.md', '# PATTERNS INDEX (120B = 30 tokens)\n', 120);
const P1 = writeExact('patterns/demo/PATTERN.md', '# PATTERN demo (80B = 20 tokens)\n', 80);
const REQ = writeExact('proj/REQUIREMENTS.md', '# REQUIREMENTS demo\n', 60);
const ANA = writeExact('proj/analysis/RN-001 — Demo/RN-001 — Analise-Funcional.md', '# Analise Funcional demo\n', 70);
const DEL = writeExact('proj/delivery/2026-10/RN-001 — Demo — Feature.md', '# Feature demo\n', 50);
const SRC = writeExact('proj/src/app.ts', 'export const demo = 1;\n', 40);
writeExact('proj/specs/DATA_MODEL.md', '# DATA MODEL demo\n', 55);

// ---- db sintético ----
const dbPath = path.join(here, 'knowledge-audit-fixture.db');
fs.rmSync(dbPath, { force: true });
const db = new DatabaseSync(dbPath);
db.exec(`CREATE TABLE session_v2 (id TEXT PRIMARY KEY, directory TEXT, title TEXT, version TEXT, agent TEXT, model TEXT, tokens_input INTEGER, tokens_output INTEGER, time_created INTEGER, time_updated INTEGER);
CREATE TABLE session_message (id TEXT PRIMARY KEY, session_id TEXT, type TEXT, seq INTEGER, time_created INTEGER, time_updated INTEGER, data TEXT);`);

const now = Date.now();
const H = 3600 * 1000;
const model = (id) => JSON.stringify({ id, providerID: 'test', variant: 'max' });
const sessions = [
  ['ses_aaaa1111', 'proj', 'S1 — precisa e acerta (read T1)', 'modelA'],
  ['ses_bbbb2222', 'proj', 'S2 — precisa e NAO acerta', 'modelB'],
  ['ses_cccc3333', 'outro', 'S3 — hit fora de contexto (T2)', 'modelA'],
  ['ses_dddd4444', 'proj', 'S4 — so codigo', 'modelC'],
  ['ses_eeee5555', 'outro', 'S5 — glob T1 fora de contexto', 'modelB'],
];
for (const [id, dir, title, m] of sessions) {
  db.prepare('INSERT INTO session_v2 (id, directory, title, agent, model, tokens_input, tokens_output, time_created, time_updated) VALUES (?,?,?,?,?,?,?,?,?)')
    .run(id, `C:/sandbox/${dir}`, title, 'test-agent', model(m), 1000, 500, now - 2 * H, now - H);
}

function toolMsg(sid, n, t, blocks) {
  db.prepare('INSERT INTO session_message (id, session_id, type, seq, time_created, time_updated, data) VALUES (?,?,?,?,?,?,?)')
    .run(`msg_${sid}_${n}`, sid, 'assistant', n, t, t, JSON.stringify({ time: { created: t, completed: t + 1000 }, agent: 'test-agent', model: JSON.parse(model('x')), content: blocks }));
}
const call = (id, name, status, input) => ({ type: 'tool', id, name, executed: true, state: { status, input } });

// S1 (modelA): read REQUIREMENTS.md (T4) + read knowledge/demo/KNOWLEDGE.md (T1, 100 tok)
toolMsg('ses_aaaa1111', 1, now - 90 * 60000, [
  call('c1a', 'read', 'completed', { path: REQ }),
  call('c1b', 'read', 'completed', { path: K1 }),
]);
// S2 (modelB): read analysis (T4) + grep delivery (T4) — nenhum hit
toolMsg('ses_bbbb2222', 1, now - 80 * 60000, [
  call('c2a', 'read', 'completed', { path: ANA }),
  call('c2b', 'grep', 'completed', { path: path.dirname(DEL), pattern: 'RN-001' }),
]);
// S3 (modelA): read patterns/INDEX.md + patterns/demo/PATTERN.md (T2, 50 tok) — sem T4
toolMsg('ses_cccc3333', 1, now - 70 * 60000, [
  call('c3a', 'read', 'completed', { path: I1 }),
  call('c3b', 'read', 'completed', { path: P1 }),
]);
// S4 (modelC): read src (nada) + read conhecimento com status running (NÃO conta)
toolMsg('ses_dddd4444', 1, now - 60 * 60000, [
  call('c4a', 'read', 'completed', { path: SRC }),
  call('c4b', 'read', 'running', { path: K1 }),
]);
// S5 (modelB): glob com path raiz em knowledge (T1 via glob — sem custo de tokens)
toolMsg('ses_eeee5555', 1, now - 50 * 60000, [
  call('c5a', 'glob', 'completed', { path: path.dirname(K1), pattern: '**/*.md' }),
]);
// fork duplicado da leitura de S1 (block id e t_created iguais — dedupe IMP-062)
db.prepare('INSERT INTO session_message (id, session_id, type, seq, time_created, time_updated, data) VALUES (?,?,?,?,?,?,?)')
  .run('msg_fork_1', 'ses_aaaa1111', 'assistant', 2, now - 90 * 60000, now - 90 * 60000,
    JSON.stringify({ time: { created: now - 90 * 60000, completed: now - 90 * 60000 + 1000 }, agent: 'test-agent', model: JSON.parse(model('x')), content: [call('c1b', 'read', 'completed', { path: K1 })] }));

db.close();
console.log('fixture db + sandbox gerados em', here);
