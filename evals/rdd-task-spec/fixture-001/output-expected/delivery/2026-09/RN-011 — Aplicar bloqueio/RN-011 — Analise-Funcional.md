---
project: BLOQUEIOS-EVAL
module: task-spec
audience: [negocio]
status: draft
---

# RN-011 — Aplicar bloqueio — Análise Funcional

> Gerado por rdd-task-spec em 22/09/2026 a partir de REQUIREMENTS.md (RN-011).

## O que esta entrega faz

Permite registrar um bloqueio para um produtor, guardando o motivo do
registro para consulta futura.

## Comportamento esperado

- O usuário informa o produtor e o motivo do bloqueio e confirma o registro.
- O sistema confere se o produtor informado existe antes de registrar.
- O motivo informado fica guardado junto do bloqueio.

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | O bloqueio só é registrado para um produtor existente; produtor desconhecido é rejeitado. |
| 2 | O motivo é obrigatório e tem limite de tamanho; fora disso o registro é recusado. |
| 3 | Todo bloqueio registrado fica disponível para consulta no histórico. |
