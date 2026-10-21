---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [tecnica]
status: draft
---

# RN-011 — Aplicar bloqueio

> Gerado por rdd-task-spec em 22/09/2026. Edite para revisar.
> Após revisão, use o workflow de issues para criar as tarefas no sistema de tracking.

> **Aviso — documentos técnicos ausentes:**
> - `specs/DATA_MODEL.md` ausente → tasks marcadas "sujeitas a revisão" (tabelas de referência incompletas)
> - `specs/UI_SPEC.md` ausente → nenhuma task frontend gerada
> - `PROJECT_CHARTER.md` ausente → milestone e tracking a definir

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[a definir] RN-011 — Aplicar bloqueio` |
| Tracking ID | a definir |
| Módulo | Bloqueios |
| Milestone | a definir |
| Repositório | a definir |

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-011-1 | Backend | Bloqueios.API | Criar endpoint POST /bloqueios |

---

### RN-011-1. [Bloqueios.API] Criar endpoint POST /bloqueios (sujeito a revisão)

| Campo | Valor |
|---|---|
| **Título** | `[Bloqueios.API] RN-011-1 — Criar endpoint de aplicação de bloqueio` |
| **Activity** | Development |
| **RNs** | RN-011 |

**Descrição:**
Endpoint para aplicar bloqueio a um produtor, registrando o motivo.

**Contrato:**
```
POST /bloqueios
Request: { "idProdutor": 1, "motivo": "Descumprimento de prazo" }
Response 201: { "id": 1, "status": "criado" }
```

**Tabelas de referência:**
| Tabela | Coluna alvo | Uso |
|---|---|---|
| a definir (DATA_MODEL.md ausente) | a definir | Insert de bloqueio |

**Validações / Erros:**
- idProdutor inexistente → 404
- motivo vazio ou acima de 500 caracteres → 400

**Critério de Aceitação:**
- Dado produtor existente, Quando POST /bloqueios com dados válidos, Então retorna 201 com id e status "criado"
- Dado idProdutor inexistente, Quando POST /bloqueios, Então retorna 404

**Dependências:** RN-010-1 (padronização de resposta de listagem)

**Notas técnicas:**
- RN-011 prevê também registro em histórico (tabela HIST_BLOQUEIO em REQUIREMENTS.md §9) — detalhar quando DATA_MODEL.md existir
