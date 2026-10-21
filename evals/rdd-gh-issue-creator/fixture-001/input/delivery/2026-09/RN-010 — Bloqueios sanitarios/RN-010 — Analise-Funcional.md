---
project: BLOQUEIOS
module: delivery
audience: [negocio, gestao]
status: draft
---

# RN-010 — Bloqueios sanitários

## O que esta entrega faz

Permitir que o sistema registre, consulte e acompanhe bloqueios sanitários
aplicados a produtores, mantendo o histórico completo das alterações.

## Comportamento esperado

- O usuário consulta a lista de bloqueios em tela paginada, filtrando pelo
  nome do produtor.
- Cada bloqueio registra quem o aplicou, quando e por qual motivo.
- Toda alteração de bloqueio gera automaticamente um registro no histórico.

## Regras de negócio

| # | Regra |
|---|-------|
| 1 | RN-010 — A listagem de bloqueios deve ser paginada e filtrável pelo nome do produtor. |
| 2 | RN-011 — Aplicar um bloqueio exige motivo preenchido e identificação do responsável. |
| 3 | RN-012 — Toda alteração de bloqueio registra histórico com data e autor da mudança. |

## O que fica de fora

- Cancelamento automático de bloqueios por prazo.
- Notificações ao produtor sobre bloqueios aplicados.
