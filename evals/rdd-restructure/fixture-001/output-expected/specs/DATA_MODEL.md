---
project: BLOQUEIOS-EVAL
module: data-model
audience: [tecnica]
status: final
---

# Modelo de Dados — Bloqueios (eval)

## Tabela BLOQUEIO_PERIODO

| Coluna | Tipo | Constraints |
|---|---|---|
| ID | NUMBER(10) | PK |
| PRODUTOR_ID | NUMBER(10) | FK → PRODUTOR |
| DATA_INICIO | DATE | NOT NULL |
| DATA_FIM | DATE | NOT NULL |
| MOTIVO | VARCHAR2(500) | NOT NULL |
