---
project: PRJ-EVAL
module: multas
audience: [tecnica]
status: confirmed
---

# RN-030 — Emissão de multas

> Gerado por rdd-task-spec em 08/10/2026. Edite para revisar.
> Análise: ../../analysis/RN-030 — Emissão de multas/

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[SDA] RN-030 — Emissão de multas` |
| Tracking ID | a definir |
| Módulo | Multas |
| Milestone | Sprint 42 |
| Repositórios | SDA.API, SDA.MFE |

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-030-1 | Backend | SDA.API | Criar endpoint POST /multas |
| RN-030-2 | Frontend | SDA.MFE | Criar tela de emissão de multa |

## Ordem de Execução

**Wave 1 — Backend:**
RN-030-1

**Wave 2 — Frontend (depende do contrato):**
RN-030-2

---

### RN-030-1. [SDA.API] Criar endpoint POST /multas

| Campo | Valor |
|---|---|
| **Título** | `[SDA.API] RN-030-1 — Criar endpoint de emissão de multa` |
| **Activity** | Development |
| **RNs** | RN-030 |

**Descrição:**
Endpoint que registra a emissão de multa para um produtor, com valor e motivo
obrigatórios.

**Contrato:**
```
POST /multas
Request: { "idProdutor": 1, "valor": 250.0, "motivo": "Atraso de entrega" }
Response 201: { "id": 9, "status": "emitida" }
```

**Validações / Erros:**
- valor menor ou igual a zero → 400
- idProdutor inexistente → 404

**Critério de Aceitação:**
- Dado dados válidos, Quando POST /multas, Então 201 com id e status "emitida"

**Dependências:** — (primeira task)

---

### RN-030-2. [SDA.MFE] Criar tela de emissão de multa

| Campo | Valor |
|---|---|
| **Título** | `[SDA.MFE] RN-030-2 — Criar tela de emissão de multa` |
| **Activity** | Development |
| **RNs** | RN-030 |

**Descrição:**
Formulário de emissão de multa (produtor, valor, motivo) consumindo o endpoint
POST /multas.

**Critério de Aceitação:**
- Dado formulário válido, Quando confirmar, Então multa emitida com confirmação

**Dependências:** RN-030-1 (contrato da API)
