---
project: BLOQUEIOS-SANITARIO
module: task-spec
audience: [negocio]
status: draft
---

# RN-001 — Aplicação de bloqueio — Análise Funcional

> Gerado por rdd-task-spec em 21/09/2026 a partir de REQUIREMENTS.md (RN-001, RN-002).

## O que esta entrega faz

Permite que o usuário aplique um bloqueio a um produtor pela tela do sistema,
com registro do motivo, controle de repetição e histórico de quem fez a
operação.

## Comportamento esperado

- O usuário preenche o produtor e o motivo na tela e confirma o bloqueio.
- O sistema registra quem aplicou o bloqueio e quando (auditoria).
- Se o produtor já tiver um bloqueio ativo, o sistema recusa o novo registro
  e explica o motivo da recusa.
- A tela valida o preenchimento e mostra mensagens de erro claras, inclusive
  quando o bloqueio está duplicado.

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | Produtor com bloqueio ativo não recebe outro: a tentativa repetida é recusada com explicação. |
| 2 | Todo bloqueio aplicado registra quem executou a operação e quando. |
| 3 | O motivo é obrigatório e tem limite de tamanho validado tanto na tela quanto no registro. |
