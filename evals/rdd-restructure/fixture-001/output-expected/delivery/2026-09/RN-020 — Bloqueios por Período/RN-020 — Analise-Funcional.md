---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [negocio]
status: draft
---

# RN-020 — Bloqueios por Período — Análise Funcional

> Gerado por rdd-restructure em 25/09/2026 a partir de REQUIREMENTS.md (RN-020).

## O que esta entrega faz

Permite bloquear um produtor por um período definido — por exemplo, durante
férias ou suspensão — deixando registrado o motivo e quem fez o bloqueio.

## Comportamento esperado

- O usuário informa o produtor, as datas de início e fim do bloqueio e o
  motivo, e confirma.
- O sistema aceita o registro somente quando o período é coerente (o fim não
  vem antes do início) e o motivo está preenchido.
- O produtor informado precisa existir no cadastro.
- O registro guarda quem aplicou o bloqueio e quando.

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | O período informado precisa ser coerente: a data final nunca é anterior à inicial. |
| 2 | O motivo é obrigatório no bloqueio por período. |
| 3 | Só é possível bloquear produtor existente no cadastro. |
| 4 | Cada bloqueio registra o responsável pela aplicação e o momento. |
