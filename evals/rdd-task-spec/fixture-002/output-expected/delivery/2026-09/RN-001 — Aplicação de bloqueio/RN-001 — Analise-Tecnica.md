---
project: BLOQUEIOS-SANITARIO
module: task-spec
audience: [tecnica]
status: draft
---

# RN-001 — Aplicação de bloqueio

> Gerado por rdd-task-spec em 21/09/2026. Edite para revisar.

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[a definir] RN-001 — Fluxo de aplicação com interface e API` |
| Tracking ID | a definir |
| Módulo | Bloqueios |
| Milestone | a definir |
| Repositório | a definir |

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-001-1 | Backend | Bloqueios.API | Criar endpoint POST /bloqueios com duplicidade |
| RN-001-2 | Frontend | Bloqueios.MFE | Criar tela de aplicação de bloqueio |

---

### RN-001-1. [Bloqueios.API] Criar endpoint POST /bloqueios (sujeito a revisão)

| Campo | Valor |
|---|---|
| **Título** | `[Bloqueios.API] RN-001-1 — Criar endpoint de aplicação de bloqueio` |
| **Activity** | Development |
| **RNs** | RN-001, RN-002 |

**Descrição:**
Endpoint que aplica bloqueio a produtor com auditoria (RN-001) e validação
de duplicidade (RN-002). Backend apenas — sem trabalho de UI nesta task.

**Contrato:**
```
POST /bloqueios
Request: { "idProdutor": 1, "motivo": "Descumprimento de prazo" }
Response 201: { "id": 1, "status": "ativo", "dataInicio": "2026-09-21" }
```

**Validações / Erros:**
- duplicidade de bloqueio ativo → 409
- motivo vazio ou acima do limite → 400

**Critério de Aceitação:**
- Dado produtor sem bloqueio ativo, Quando POST válido, Então 201 com auditoria
- Dado produtor com bloqueio ativo, Quando POST, Então 409

**Dependências:** nenhuma

---

### RN-001-2. [Bloqueios.MFE] Criar tela de aplicação de bloqueio (sujeito a revisão)

| Campo | Valor |
|---|---|
| **Título** | `[Bloqueios.MFE] RN-001-2 — Criar tela de aplicação de bloqueio` |
| **Activity** | Development |
| **RNs** | RN-001, RN-002 |

**Descrição:**
Formulário de aplicação de bloqueio (produtor + motivo) consumindo o
endpoint POST /bloqueios. Frontend apenas — consome o contrato da Task 1.

**Validações de frontend:**
- motivo obrigatório, limite de caracteres
- mensagem de erro amigável no 409 (bloqueio duplicado)

**Critério de Aceitação:**
- Dado formulário válido, Quando confirmar, Então chamada ao endpoint e mensagem de sucesso
- Dado retorno 409, Quando resposta recebida, Então mensagem de bloqueio duplicado exibida

**Dependências:** RN-001-1 (contrato da API)
