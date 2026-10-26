# fixture-001 — par de métricas de db sintético (modo degradado)

Input: `knowledge-audit-fixture.db` (5 sessões sintéticas) + `sandbox/`
(arquivos de conhecimento/projeto de tamanhos EXATOS — tokens = bytes/4) +
`metrics/METRICS.md` (base mínima para o merge).

Regeneração (obrigatória se o sandbox mudar — os paths do db são absolutos):

    node input/make-fixture-db.mjs
    node ~/.config/opencode/skills/rdd-knowledge-auditor/scripts/get-knowledge-metrics-v2.mjs --days 3650 --db input/knowledge-audit-fixture.db --out-file <tmp>/golden-km-001.json --report-file output-expected/KNOWLEDGE_AUDIT_golden.md --metrics-file output-expected/METRICS.md

Esperado: sessões=5 · precisavam=2 · hit=1 · rate=50% · tokens/tarefa=75.
--days 3650 garante que a janela cobre os timestamps da fixture em qualquer data de execução.
