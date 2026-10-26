# fixture-002 — caso de erro: db ausente (modo warn)

Sem banco: o caminho `sem-banco.db` não existe. O coletor deve emitir
`DB_MISSING`, gerar relatório "sem dados" (contadores zerados, métricas N/A,
nenhum percentual) e NÃO fazer merge no METRICS.md.

Regeneração do golden:

    node ~/.config/opencode/skills/rdd-knowledge-auditor/scripts/get-knowledge-metrics-v2.mjs --days 7 --db input/sem-banco.db --out-file <tmp>/golden-km-002.json --report-file output-expected/KNOWLEDGE_AUDIT_golden-erro.md --metrics-file none
