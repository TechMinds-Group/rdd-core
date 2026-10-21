---
name: rdd-coverage-audit
description: >-
  Audita cobertura de RNs em módulos RDD — verifica se cada RN confirmada
  tem downstream em DATA_MODEL, API_CONTRACTS, UI_SPEC e ACCEPTANCE_CRITERIA.
---

# rdd-coverage-audit — Auditor de Cobertura de RNs

Audita se cada RN confirmada em REQUIREMENTS.md tem representação em
DATA_MODEL.md, API_CONTRACTS.md, UI_SPEC.md e ACCEPTANCE_CRITERIA.md.

## Lê (upstream)

- `<module-root>/REQUIREMENTS.md` (RNs confirmadas)
- `<module-root>/quality/TRACEABILITY.md` (matriz existente)

## Gera (downstream)

- Relatório textual de cobertura (exibido ao usuário)

## Nunca edita

- Nenhum artefato de módulo. Read-only.

## Tools

- `read` (ler REQUIREMENTS.md, TRACEABILITY.md)
- `grep` (buscar RN-XXX em artefatos)
- `glob` (listar artefatos do módulo)

## Modo de erro

`warn` — se TRACEABILITY.md não existir, reporta gap e prossegue.