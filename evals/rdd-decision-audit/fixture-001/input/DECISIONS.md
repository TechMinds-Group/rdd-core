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

## DEC-002 — Histórico segmentado por tipo de evento

| Campo | Valor |
|---|---|
| Data | 21/09/2026 |
| Decisor | Marcos (PO) |
| Status | Ativa |
| Origem | Reunião de detalhamento |

**Decisão:** Criar tabelas separadas `HIST_CRIACAO` e `HIST_ENCERRAMENTO`
para os eventos de bloqueio, otimizando cada fluxo.

**Impacto:** modelo de dados (2 tabelas de histórico), duplicação de insert nos fluxos.

## DEC-003 — Prazo máximo de bloqueio

| Campo | Valor |
|---|---|
| Data | 21/09/2026 |
| Decisor | Jurídico |
| Status | Proposta |

**Decisão:** Bloqueios expiram automaticamente em 90 dias, conforme
regulamentação a ser confirmada na RN-999.

**Impacto:** nova rotina de expiração; dependência de RN-999.
