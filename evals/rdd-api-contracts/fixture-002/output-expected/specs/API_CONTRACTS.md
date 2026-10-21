---
project: BLOQUEIOS-SANITARIO
module: contratos-api
audience: [tecnica]
status: draft
---

# API Contracts — Bloqueios Sanitários (consulta sujeita a revisão)

> **Derivado de:** specs/DATA_MODEL.md (BLOQUEIO), REQUIREMENTS.md (RN-001)
> **API de destino:** Bloqueios.API

---

## Endpoints

### GET /bloqueios (sujeito a revisão)

Consulta de bloqueios por produtor (RN-001). **Campos de resposta ainda
não definidos pelo PO** — contrato parcial: apenas o filtro é derivável
do requisito; a estrutura de resposta aguarda definição (não inventada).

Query params:

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| idProdutor | number | sim | Produtor consultado |

Response 200: **a definir — sujeito a revisão** (aguardar campos da RN-001).

Tabelas: `BLOQUEIO` (SELECT).

---

