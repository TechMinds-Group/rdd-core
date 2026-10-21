---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [negocio]
status: draft
---

# RN-010 — Listagem de bloqueios — Análise Funcional

> Gerado por rdd-task-spec em 22/09/2026 a partir de REQUIREMENTS.md (RN-010).

## O que esta entrega faz

Permite ao usuário consultar os bloqueios já registrados, em lista organizada
página a página, com a possibilidade de procurar pelo nome do produtor.

## Comportamento esperado

- O usuário abre a lista de bloqueios e vê os registros organizados por página.
- O usuário pode digitar parte do nome do produtor para ver apenas os
  bloqueios dele.
- Cada registro da lista mostra o produtor e a data do bloqueio.

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | A lista é apresentada página a página, e a página informada precisa ser um número válido. |
| 2 | A busca por nome traz apenas os bloqueios de produtores cujo nome contém o texto pesquisado. |
