---
project: BLOQUEIOS-SANITARIO
module: glossario-dev
audience: [tecnica]
status: draft
---

# DEV Glossary — Bloqueios Sanitários

> Termos técnicos para desenvolvedores. Identificadores em MAIÚSCULAS.

| Termo | Definição |
|---|---|
| BLOQUEIO | Tabela principal de bloqueios de produtores (COD_BLOQUEIO PK via SEQ_BLOQUEIO) |
| HIST_BLOQUEIO | Tabela de eventos append-only do ciclo de vida do bloqueio (DEC-001) |
| TIP_EVENTO | Discriminador do evento: `CRIADO` ou `ENCERRADO` (check constraint) |
| FLG_ATIVO | Flag S/N do bloqueio ativo; base da validação de duplicidade |
| BLOQ_DUPLICADO | Código de erro 409 — produtor já possui bloqueio ativo (RN-002) |
| SEQ_BLOQUEIO | Sequence geradora da PK de BLOQUEIO |
| CTR_* | Colunas de auditoria (CTR_DTH_INC, CTR_USU_INC, ...) preenchidas em toda escrita |
| gta-status | Endpoint GET /bloqueios/gta-status/{idProdutor} consumido pelo emissor de GTA |
