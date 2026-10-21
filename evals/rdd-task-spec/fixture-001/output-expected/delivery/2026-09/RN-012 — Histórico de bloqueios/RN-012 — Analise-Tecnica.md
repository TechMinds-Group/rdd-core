---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [tecnica]
status: draft
---

# RN-012 — Histórico de bloqueios

> Gerado por rdd-task-spec em 22/09/2026. Edite para revisar.
> Após revisão, use o workflow de issues para criar as tarefas no sistema de tracking.

> **Aviso — documentos técnicos ausentes:**
> - `specs/DATA_MODEL.md` ausente → tasks marcadas "sujeitas a revisão" (tabelas de referência incompletas)
> - `specs/UI_SPEC.md` ausente → nenhuma task frontend gerada
> - `PROJECT_CHARTER.md` ausente → milestone e tracking a definir

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[a definir] RN-012 — Histórico de bloqueios` |
| Tracking ID | a definir |
| Módulo | Bloqueios |
| Milestone | a definir |
| Repositório | a definir |

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-012-1 | Backend | Bloqueios.API | Criar endpoint GET /bloqueios/historico |

---

### RN-012-1. [Bloqueios.API] Criar endpoint GET /bloqueios/historico (sujeito a revisão)

| Campo | Valor |
|---|---|
| **Título** | `[Bloqueios.API] RN-012-1 — Criar endpoint de histórico de bloqueios` |
| **Activity** | Development |
| **RNs** | RN-012 |

**Descrição:**
Endpoint de consulta do histórico de bloqueios por período.

**Query params:**
| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| dataInicio | date | sim | Início do período |
| dataFim | date | sim | Fim do período |

**Contrato:**
```
GET /bloqueios/historico
Request: vazio (query params acima)
Response 200: { "historico": [{ "id": 1, "acao": "criado", "data": "2024-01-01" }] }
```

**Tabelas de referência:**
| Tabela | Coluna alvo | Uso |
|---|---|---|
| a definir (DATA_MODEL.md ausente) | a definir | Consulta de histórico |

**Validações / Erros:**
- dataInicio > dataFim → 400

**Critério de Aceitação:**
- Dado período válido, Quando GET /bloqueios/historico, Então retorna 200 com eventos do período
- Dado dataInicio posterior a dataFim, Quando GET /bloqueios/historico, Então retorna 400

**Dependências:** nenhuma

**Notas técnicas:**
- Período fechado (inclusive nas duas extremidades)
