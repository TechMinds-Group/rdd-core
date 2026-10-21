---
project: BLOQUEIOS-SANITARIO
module: requisitos-cliente
audience: [negocio]
status: proposta
---

# Requisitos do Sistema — Visão do Cliente

> **Última sincronização:** 21/09/2026

## Objetivo de negócio

Dar à defesa agropecuária controle confiável sobre bloqueios sanitários de
produtores, impedindo a circulação de animais de produtores com pendência
sanitária.

## O que o sistema faz

- Registra o bloqueio de um produtor com toda a informação de auditoria:
  quando foi aplicado e por quem
- Não deixa aplicar um segundo bloqueio enquanto já existir um em vigor —
  o sistema avisa e recusa a operação
- Impede a emissão da Guia de Trânsito Animal para produtor bloqueado e
  volta a permitir quando o bloqueio é encerrado
- Registra o encerramento do bloqueio com o motivo informado, guardando
  tudo no histórico do bloqueio

## Quem usa o sistema

| Ator | O que pode fazer |
|---|---|
| Operador | Aplicar, consultar e encerrar bloqueios |
| Consultor | Apenas consultar bloqueios e a situação de GTA |

## Fluxos de uso

- **Aplicar bloqueio:** o operador escolhe o produtor, informa o motivo e
  confirma. Se já houver bloqueio em vigor, o sistema avisa e não permite.
- **Consultar bloqueios:** listagem com situação (em vigor ou encerrado) e
  indicação de se o produtor pode emitir GTA.
- **Encerrar bloqueio:** o operador informa o motivo do encerramento e
  confirma; o histórico do bloqueio é atualizado.

## Garantias de registro

Cada aplicação e cada encerramento ficam gravados com data, hora e usuário
responsável, e o histórico completo do bloqueio é preservado sem alterações.

## Pendências para o cliente

- Definir o prazo máximo de duração de um bloqueio e o comportamento ao
  expirar (em análise pelo jurídico)

## Resumo de mudanças

- Primeira versão deste documento, sincronizada com os requisitos
  confirmados em 20/09/2026.
