---
project: BLOQUEIOS-SANITARIO
module: escopo
audience: [negocio]
status: proposta
---

# Acordo de Escopo — Bloqueios Sanitários

> **Data:** 21/09/2026 · **Status:** proposta (aguardando aprovação do patrocinador)

## 1. Objetivo

Controlar os bloqueios sanitários de produtores rurais, garantindo que
animais de produtores bloqueados não emitam Guia de Trânsito Animal (GTA)
até a regularização.

## 2. O que está incluído

- Registro de bloqueio com data, hora e responsável
- Proteção contra bloqueio duplicado: enquanto existir bloqueio em vigor,
  o sistema não permite aplicar outro ao mesmo produtor
- Consulta de bloqueios ativos e encerrados, com indicação clara da
  situação perante a emissão de GTA
- Encerramento de bloqueio com registro obrigatório do motivo
- Histórico completo de cada bloqueio (criação e encerramento)

## 3. Atores e permissões

| Ator | O que pode fazer |
|---|---|
| Operador | Aplicar, consultar e encerrar bloqueios |
| Consultor | Apenas consultar |
| Emissor de GTA | Consultar a situação do produtor antes de emitir |

## 4. Garantias de registro

- Todo bloqueio e todo encerramento ficam registrados com autor, data e hora
- O histórico de eventos é permanente — nada é apagado ou reescrito

## 5. Pendências de negócio

- Prazo máximo de duração de um bloqueio e o que acontece ao expirar —
  em definição pelo jurídico (sem impacto na primeira entrega)

## 6. Mudanças solicitadas

| Mudança | Situação |
|---|---|
| Deixar explícito que a proteção contra duplicidade vale apenas enquanto o bloqueio está em vigor | Aguardando aprovação |

## 7. Rastreamento interno

| Seção | Referências |
|---|---|
| Registro de bloqueio | RN-001 |
| Proteção duplicidade | RN-002 |
| Situação GTA | RN-003 |
| Encerramento com motivo | RN-004 |
| Mudança solicitada | CR-001 |
| Pendência de negócio | PEND-001 |
