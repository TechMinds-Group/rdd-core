---
project: BLOQUEIOS-SANITARIO
module: contratos-api
audience: [tecnica]
status: draft
---

# API Contracts — Bloqueios Sanitários

> **Derivado de:** specs/DATA_MODEL.md (BLOQUEIO, HIST_BLOQUEIO), REQUIREMENTS.md §5/§7 (RN-001, RN-002, RN-003, RN-004)
> **API de destino:** Bloqueios.API

---

## Endpoints

### POST /bloqueios

Aplica bloqueio a um produtor, com validação de duplicidade e auditoria.
Implementa UC-01 (RN-001, RN-002).

Request:
```json
{
  "idProdutor": 1,
  "motivo": "Descumprimento de prazo sanitário"
}
```

Response 201:
```json
{
  "id": 1,
  "idProdutor": 1,
  "motivo": "Descumprimento de prazo sanitário",
  "status": "ativo",
  "dataInicio": "2026-09-20",
  "registradoPor": 1234
}
```

Erros:

| Código | HTTP | Condição | RN |
|---|---|---|---|
| BLOQ_DUPLICADO | 409 | Produtor já possui bloqueio ativo | RN-002 |
| PRODUTOR_INEXISTENTE | 404 | idProdutor não encontrado | RN-001 |
| VALIDACAO_CAMPO | 400 | motivo vazio ou acima de 500 caracteres | RN-001 |

Tabelas: `BLOQUEIO` (INSERT), `HIST_BLOQUEIO` (INSERT, evento CRIADO).

### GET /bloqueios

Lista bloqueios com filtros. Implementa UC-02 (RN-003 — consulta).

Query params:

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| idProdutor | number | não | Filtra por produtor |
| status | string | não | `ativo` ou `encerrado` |

Response 200:
```json
{
  "bloqueios": [
    { "id": 1, "idProdutor": 1, "motivo": "...", "status": "ativo", "dataInicio": "2026-09-20" }
  ]
}
```

Tabelas: `BLOQUEIO` (SELECT).

### GET /bloqueios/gta-status/{idProdutor}

Status de bloqueio para o emissor de GTA. Integração de saída (RN-003).

Path params:

| Parâmetro | Tipo | Descrição |
|---|---|---|
| idProdutor | number (path) | ID do produtor |

Response 200:
```json
{ "idProdutor": 1, "bloqueado": true, "idBloqueioAtivo": 1 }
```

Tabelas: `BLOQUEIO` (SELECT).

### POST /bloqueios/{id}/encerramento

Encerra um bloqueio ativo, registrando motivo no histórico.
Implementa UC-03 (RN-004).

Path params:

| Parâmetro | Tipo | Descrição |
|---|---|---|
| id | number (path) | ID do bloqueio |

Request:
```json
{ "motivoFim": "Regularização concluída" }
```

Response 200:
```json
{ "id": 1, "status": "encerrado", "dataFim": "2026-09-25" }
```

Erros:

| Código | HTTP | Condição | RN |
|---|---|---|---|
| BLOQUEIO_INEXISTENTE | 404 | id não encontrado | RN-004 |
| BLOQUEIO_JA_ENCERRADO | 409 | Bloqueio já está encerrado | RN-004 |
| VALIDACAO_CAMPO | 400 | motivoFim vazio ou acima de 500 caracteres | RN-004 |

Tabelas: `BLOQUEIO` (UPDATE), `HIST_BLOQUEIO` (INSERT, evento ENCERRADO).
