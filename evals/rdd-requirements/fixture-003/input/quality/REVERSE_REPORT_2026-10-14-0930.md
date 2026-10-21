---
project: LEGACYBENCH
tipo: relatorio-reverse
gerado_por: @rdd-reverse-orchestrator
data: 2026-10-14 09:30
---

# Relatório de Engenharia Reversa — LegacyBench (2026-10-14 09:30)

> Fonte: repositorio/LegacyBench.OS (código Java, sem docs).

## Candidatas a RN

### RN-c1 — Registro de conclusão de ordem (evidência direta)

Regra: quando uma ordem é concluída, o sistema registra data e usuário
responsável da conclusão.

- Evidência: direta — OrderService.java:88-92 (setConclusionDate + auditoria)
- Grau de confiança: **Alta**

### RN-c2 — Numeração sequencial de ordens (inferida)

Regra: toda ordem nova recebe número sequencial único.

- Evidência: inferida de padrão de nomes (coluna SEQ_ORDER, classe OrderNumberGenerator)
- Grau de confiança: **Média**

### RN-c3 — Recálculo de prioridade (não determinável)

Regra: aparente recálculo de prioridade ao reabrir uma ordem.

- Evidência: comportamento não determinável (método recalcPriority sem uso claro)
- Grau de confiança: **Baixa** — dúvida a esclarecer com o operador (candidata a PEND)

## Propostas de ID

- RN-c1 → proposta RN-001
- RN-c2 → proposta RN-002
- RN-c3 → proposta RN-003 (condicionada a validação humana)
