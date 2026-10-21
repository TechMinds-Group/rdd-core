---
name: rdd-coverage-auditor
description: >-
  Audita cobertura de RNs em módulos RDD — verifica se cada RN confirmada
  tem downstream em todos os artefatos técnicos esperados.
---

# rdd-coverage-auditor — Auditor de Cobertura de RNs

Audita se cada RN confirmada em REQUIREMENTS.md tem representação em
DATA_MODEL.md, API_CONTRACTS.md, UI_SPEC.md e ACCEPTANCE_CRITERIA.md.

## Subagents e roteamento

- Delega para `rdd-next` (recomendar próxima skill)
- Invoca diretamente `rdd-handover` (resumo de estado)

## Tools

- `read` (ler REQUIREMENTS.md, TRACEABILITY.md)
- `grep` (buscar RN-XXX em artefatos)
- `glob` (listar artefatos do módulo)

## Modo de erro

`warn` — se TRACEABILITY.md não existir, reporta gap e prossegue.