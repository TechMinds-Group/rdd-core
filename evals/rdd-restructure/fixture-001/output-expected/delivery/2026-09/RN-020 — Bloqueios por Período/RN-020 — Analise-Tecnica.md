---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [tecnica]
status: draft
---

# RN-020 — Bloqueios por Período

> Gerado por rdd-task-spec em 22/09/2026. Edite para revisar.
> Após revisão, use o workflow de issues para criar as tarefas no sistema de tracking.
> **Migrado em 25/09/2026 para estrutura de pasta por feature — IMP-040.**

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[a definir] RN-020 — Bloqueios por Período` |
| Tracking ID | a definir |
| Módulo | Bloqueios |
| Milestone | a definir |
| Repositórios | a definir |

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-020-1 | Backend | Bloqueios.API | Criar endpoint POST /bloqueios-periodo |
| RN-020-2 | Frontend | Bloqueios.MFE | Criar tela de bloqueio por período |

---

### RN-020-1. [Bloqueios.API] Criar endpoint POST /bloqueios-periodo (sujeito a revisão)

| Campo | Valor |
|---|---|
| **Título** | `[Bloqueios.API] RN-020-1 — Criar endpoint de bloqueio por período` |
| **Activity** | Development |
| **RNs** | RN-020 |

**Descrição:**
Endpoint para registrar bloqueio de produtor por período, com motivo
obrigatório e auditoria de quem aplicou.

**Contrato:**
```
POST /bloqueios-periodo
Request: { "idProdutor": 1, "dataInicio": "2026-10-01", "dataFim": "2026-10-05", "motivo": "Férias" }
Response 201: { "id": 1, "status": "ativo" }
```

**Validações / Erros:**
- dataFim anterior a dataInicio → 400
- motivo vazio → 400
- idProdutor inexistente → 404

**Critério de Aceitação:**
- Dado período válido, Quando POST, Então 201 com o bloqueio ativo
- Dado dataFim menor que dataInicio, Quando POST, Então 400

**Dependências:** nenhuma

**Notas técnicas:**
- Auditoria com usuário e timestamp da aplicação
