---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [negocio]
status: draft
---

# RN-012 — Histórico de bloqueios — Análise Funcional

> Gerado por rdd-task-spec em 22/09/2026 a partir de REQUIREMENTS.md (RN-012).

## O que esta entrega faz

Permite consultar o histórico de bloqueios já encerrados, com os dados de
cada registro para consulta e acompanhamento.

## Comportamento esperado

- O usuário abre o histórico e vê os bloqueios passados organizados em lista.
- Cada item do histórico mostra o produtor, o período e o motivo do bloqueio.

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | O histórico reúne os bloqueios encerrados e permite consultar os dados de cada registro. |
