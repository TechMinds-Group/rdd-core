---
project: PRJ-EVAL
module: multas
audience: [negocio]
status: confirmed
---

# RN-030 — Emissão de multas — Análise Funcional

> Gerado por rdd-task-spec em 08/10/2026 a partir de REQUIREMENTS.md (RN-030).

## O que esta entrega faz

Permite ao fiscal emitir multas para produtores, informando valor e motivo,
com registro de quem emitiu e quando.

## Comportamento esperado

- O fiscal preenche produtor, valor e motivo no formulário de multa.
- A multa emitida recebe um número e fica registrada para consulta futura.

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | Valor e motivo são obrigatórios para emitir a multa. |
| 2 | A multa só é emitida para produtores cadastrados. |

## O que fica de fora

Cobrança e pagamento da multa não fazem parte desta entrega.
