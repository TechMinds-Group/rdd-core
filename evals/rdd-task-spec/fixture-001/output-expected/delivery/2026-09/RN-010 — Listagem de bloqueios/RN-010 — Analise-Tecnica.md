---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [tecnica]
status: draft
---

# RN-010 — Listagem de bloqueios

> Gerado por rdd-task-spec em 22/09/2026. Edite para revisar.
> Após revisão, use o workflow de issues para criar as tarefas no sistema de tracking.

> **Aviso — documentos técnicos ausentes:**
> - `specs/DATA_MODEL.md` ausente → tasks marcadas "sujeitas a revisão" (tabelas de referência incompletas)
> - `specs/UI_SPEC.md` ausente → nenhuma task frontend gerada
> - `PROJECT_CHARTER.md` ausente → milestone e tracking a definir

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[a definir] RN-010 — Listagem de bloqueios` |
| Tracking ID | a definir |
| Módulo | Bloqueios |
| Milestone | a definir |
| Repositório | a definir |

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-010-1 | Backend | Bloqueios.API | Criar endpoint GET /bloqueios |

---

### RN-010-1. [Bloqueios.API] Criar endpoint GET /bloqueios (sujeito a revisão)

| Campo | Valor |
|---|---|
| **Título** | `[Bloqueios.API] RN-010-1 — Criar endpoint de listagem de bloqueios` |
| **Activity** | Development |
| **RNs** | RN-010 |

**Descrição:**
Endpoint de listagem paginada de bloqueios com filtro opcional por nome do
produtor. Primeiro entregável do módulo — sem dependências.

**Query params:**
| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| filtroNome | string (100) | não | Filtro por nome do produtor |
| pagina | number | sim | Número da página |

**Contrato:**
```
GET /bloqueios
Request: vazio (query params acima)
Response 200: { "bloqueios": [{ "id": 1, "produtor": "João", "data": "2024-01-01" }] }
```

**Tabelas de referência:**
| Tabela | Coluna alvo | Uso |
|---|---|---|
| a definir (DATA_MODEL.md ausente) | a definir | Consulta de bloqueios |

**Validações / Erros:**
- pagina inválida (não numérica) → 400

**Critério de Aceitação:**
- Dado que existem bloqueios cadastrados, Quando GET /bloqueios sem filtros, Então retorna 200 com lista paginada
- Dado filtroNome informado, Quando GET /bloqueios?filtroNome=João, Então retorna apenas bloqueios de produtores cujo nome contém "João"

**Dependências:** nenhuma

**Notas técnicas:**
- Paginação por número de página; tamanho de página a definir com o time
