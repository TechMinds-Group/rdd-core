---
project: BLOQUEIOS-SANITARIO
module: requisitos
audience: [tecnica, negocio]
status: draft
---

# Bloqueios Sanitários — Controle de bloqueios de produtores rurais

> **REDMINE:** #402
> **Última atualização:** 20/09/2026
> **Objetivo:** Controlar bloqueios sanitários de produtores rurais, com integração ao emissor de GTA (Guia de Trânsito Animal).

---

## 1. Escopo

- Aplicação de bloqueios a produtores
- Consulta de bloqueios
- Encerramento de bloqueios
- Histórico de eventos de bloqueio
- Exposição de status de bloqueio para o emissor de GTA

> Fora do escopo:
> - Emissão da GTA em si (o sistema apenas expõe o status de bloqueio ao emissor)

---

## 2. Atores e Permissões

| Papel | Pode fazer | Não pode fazer |
|---|---|---|
| Operador defesa agropecuária | Aplicar e encerrar bloqueios | — |
| Coordinator sanitário (PO) | Acompanhar bloqueios | — |
| Consultores regionais | Consultar bloqueios | Aplicar/encerrar bloqueios |

---

## 3. Estrutura da Aplicação

Sistema de controle de bloqueios sanitários com registro de eventos
(aplicação e encerramento) em histórico unificado e integração de consulta
com o emissor de GTA.

---

## 4. Conceitos de Domínio

| Termo | API | Descrição |
|---|---|---|
| Bloqueio | BLOQUEIO | Restrição sanitária aplicada a um produtor rural |
| GTA | — | Guia de Trânsito Animal, emitida por sistema externo |
| Histórico de eventos | HIST_BLOQUEIO | Registro unificado de criação e encerramento de bloqueios |
| BLOQ_DUPLICADO | — | Erro retornado ao tentar aplicar bloqueio sobre bloqueio ativo |

---

## 5. Regras de Negócio

### Gestão de Bloqueios

- **RN-001** `[confirmado]` (20/09/2026) — `[evento]` Quando um bloqueio for aplicado a um produtor, o sistema registra data, hora e usuário responsável.
- **RN-002** `[confirmado]` (20/09/2026) — `[indesejado]` Se o produtor já possui bloqueio ativo, o sistema rejeita novo bloqueio com erro BLOQ_DUPLICADO.

---

## 6. Dados e Campos

### Bloqueio (RN-001)

| Campo | Obrigatório | Formato | Comportamento |
|---|---|---|---|
| Produtor | Sim | — | Produtor alvo do bloqueio |
| Data do evento | Sim | Data/hora | Registrado automaticamente na aplicação |
| Usuário responsável | Sim | — | Registrado automaticamente na aplicação |

---

## 7. Casos de Uso / Fluxos

1. Operador aplica bloqueio a um produtor informando os dados do evento (RN-001).
2. Sistema valida se o produtor já possui bloqueio ativo; se positivo, rejeita com BLOQ_DUPLICADO (RN-002).
3. Eventos de criação e encerramento são registrados no histórico unificado (ADR-001).

---

## 8. Saídas e Integrações

- Status de bloqueio exposto ao emissor de GTA.

---

## 9. Persistência e Auditoria

| Entidade | Tabela | Finalidade | Rastreabilidade |
|---|---|---|---|
| Eventos de bloqueio | HIST_BLOQUEIO | Histórico unificado de criação e encerramento | ADR-001 |

---

## 10. Decisões e Fora do Escopo

| Item | Decisão | Motivo |
|---|---|---|
| Histórico de eventos | Tabela única HIST_BLOQUEIO (ADR-001) | Consulta histórica unificada; tabelas separadas fragmentam a consulta |

---

> **Regra de idioma:** Requisitos em português brasileiro (PT-BR). Títulos de seção, descrições de RNs, UCs e campos em PT-BR. Apenas notação EARS (shall, must, should), identificadores (RN-001, UC-001) e termos técnicos do domínio permanecem no original.

## 11. Pendências e Dúvidas em Aberto

- **PEND-001** (20/09/2026) — Prazo máximo de bloqueio indefinido. Follow-ups: (1) Qual o prazo máximo de um bloqueio ativo? (2) Expirado o prazo, o bloqueio encerra automaticamente ou exige ação do Operador?