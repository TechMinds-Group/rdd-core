---
project: BLOQUEIOS-EVAL
module: data-model
audience: [tecnica]
status: final
---

# Modelo de Dados — Bloqueios (eval idempotência)

## Tabela BLOQUEIO_ATIVO

| Coluna | Tipo | Constraints |
|---|---|---|
| ID | NUMBER(10) | PK |
| PRODUTOR_ID | NUMBER(10) | FK → PRODUTOR |
| DATA | DATE | NOT NULL |
