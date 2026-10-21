---
project: BLOQUEIOS-SANITARIO
module: decisoes
status: ativo
---

# DECISIONS — Bloqueios Sanitários

## DEC-001 — Histórico unificado de eventos de bloqueio

| Campo | Valor |
|---|---|
| Data | 20/09/2026 |
| Decisor | Victor Souza |
| Status | Ativa |
| Origem | Reunião de abertura (checkpoint 2026-09-20-01) |

**Decisão:** Eventos de bloqueio (criação e encerramento) serão registrados
em uma única tabela `HIST_BLOQUEIO`, diferenciados por `TIP_EVENTO`.

**Alternativas consideradas:**
- Tabelas separadas por tipo de evento (rejeitada — fragmenta consulta histórica)

**Impacto:** modelo de dados (1 tabela de histórico), API de consulta de histórico unificada.
