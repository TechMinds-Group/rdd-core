---
project: BLOQUEIOS-SANITARIO
module: requisitos
status: confirmado
---

# REQUIREMENTS — Bloqueios Sanitários

> **Atualizado em:** 21/09/2026 · merge do checkpoint 2026-09-21-01

## 1. Escopo

Controle de bloqueios sanitários de produtores rurais, com integração ao
emissor de GTA. Inclui expiração automática de bloqueios (90 dias).

## 2. Atores e Permissões

| Ator | Permissões |
|---|---|
| Operador | Aplicar bloqueios, registrar responsabilidade |
| Sistema | Expirar bloqueios automaticamente |

## 5. Regras de Negócio

### RN-001 [confirmado]
Quando um bloqueio for aplicado a um produtor em razão de problema sanitário, então o sistema deve registrar data, hora e o usuário responsável pelo bloqueio.

### RN-002 [confirmado]
Se o produtor já possuir bloqueio ativo, então o sistema deve recusar o novo bloqueio com mensagem de erro (a definir na spec de API).

### RN-003 [confirmado]
Quando um bloqueio ativo completar 90 dias corridos, então o sistema deve alterar seu status para encerrado e registrar evento de expiração no histórico, sem intervenção do Operador.

## 6. Dados e Campos

### RN-001 — Aplicação de bloqueio

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| produtor | Referência | Sim | Produtor a bloquear |
| dataHora | Data/Hora | Sim | Momento do bloqueio (registro automático) |
| usuario | Referência | Sim | Usuário responsável (registro automático) |

### RN-003 — Expiração de bloqueio

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| prazoDias | Número | Sim | Prazo de expiração: 90 dias corridos (fixo) |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **BLOQUEIO** — bloqueios de produtores (INSERT, SELECT, UPDATE)
- **HIST_BLOQUEIO** — eventos de bloqueio (INSERT, evento EXPIRADO)

### Rastreabilidade

- RN-001 → BLOQUEIO (INSERT)
- RN-002 → BLOQUEIO (SELECT)
- RN-003 → BLOQUEIO (UPDATE status), HIST_BLOQUEIO (INSERT)

## PENDs

### Resolvidas

- ~~PEND-001 — Expiração de bloqueio~~ → **RESOLVIDA em 21/09/2026**, convertida em RN-003 (prazo 90 dias, expiração automática). Ver checkpoint 2026-09-21-01.
