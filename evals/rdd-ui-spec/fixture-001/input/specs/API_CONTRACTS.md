---
project: BLOQUEIOS-SANITARIO
module: contratos-api
audience: [tecnica]
status: draft
---

# API Contracts — Bloqueios Sanitários

> **Derivado de:** DATA_MODEL.md (BLOQUEIO, HIST_BLOQUEIO), REQUIREMENTS.md (RN-001, RN-002, RN-003, RN-004)

---

## Endpoints

### POST /bloqueios

Aplica bloqueio a produtor (RN-001, RN-002).

Request:
```json
{ "idProdutor": 1, "motivo": "Descumprimento de prazo" }
```

Response 201:
```json
{ "id": 1, "status": "ativo", "dataInicio": "2026-09-20" }
```

Erros:
- 409 `BLOQ_DUPLICADO` — produtor já possui bloqueio ativo (RN-002)
- 404 `PRODUTOR_INEXISTENTE` — idProdutor não encontrado
- 400 `VALIDACAO_CAMPO` — motivo vazio ou acima de 500 caracteres

### GET /bloqueios

Lista bloqueios com filtro por status (RN-003 — consulta usada pela UC-02).

Query params:
| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| idProdutor | number | não | Filtra por produtor |
| status | string | não | `ativo` ou `encerrado` |

Response 200:
```json
{ "bloqueios": [{ "id": 1, "idProdutor": 1, "motivo": "...", "status": "ativo", "dataInicio": "2026-09-20" }] }
```

### GET /bloqueios/gta-status/{idProdutor}

Status de bloqueio para o emissor de GTA (RN-003).

Response 200:
```json
{ "idProdutor": 1, "bloqueado": true, "idBloqueioAtivo": 1 }
```

### POST /bloqueios/{id}/encerramento

Encerra bloqueio (RN-004).

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
- 404 `BLOQUEIO_INEXISTENTE`
- 409 `BLOQUEIO_JA_ENCERRADO`
