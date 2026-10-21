---
project: BLOQUEIOS-SANITARIO
module: requisitos
status: draft
---

# REQUIREMENTS — Bloqueios Sanitários

> **Gerado a partir de:** meetings/2026-09-20-01.md (checkpoint clarify), PROJECT_CHARTER.md (REDMINE #402)

## 1. Escopo

Controle de bloqueios sanitários de produtores rurais, com integração ao
emissor de GTA. Primeira entrega: aplicação de bloqueio com registro de
responsabilidade e rejeição de duplicidade.

## 2. Atores e Permissões

| Ator | Permissões |
|---|---|
| Operador | Aplicar bloqueios, registrar responsabilidade |

## 5. Regras de Negócio

### RN-001 [confirmado]
Quando um bloqueio for aplicado a um produtor em razão de problema sanitário, então o sistema deve registrar data, hora e o usuário responsável pelo bloqueio.

### RN-002 [confirmado]
Se o produtor já possuir bloqueio ativo, então o sistema deve recusar o novo bloqueio com mensagem de erro (a definir na spec de API).

## 6. Dados e Campos

### RN-001 — Aplicação de bloqueio

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| produtor | Referência | Sim | Produtor a bloquear |
| dataHora | Data/Hora | Sim | Momento do bloqueio (registro automático) |
| usuario | Referência | Sim | Usuário responsável (registro automático) |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **BLOQUEIO** — bloqueios de produtores (INSERT, SELECT)

### Rastreabilidade

- RN-001 → BLOQUEIO (INSERT)
- RN-002 → BLOQUEIO (SELECT)

## PENDs

### PEND-001 — Expiração de bloqueio (origem: C3 do clarify, score 40)

1. Qual o prazo máximo de um bloqueio ativo?
2. Expirado o prazo, o bloqueio encerra automaticamente ou exige ação do Operador?

Responsável: PO sanitário (depende de definição do jurídico).
