---
project: TAXAS-PEDAGIO
module: requisitos
status: confirmado
---

# REQUIREMENTS — Taxas de Pedágio

> RNs induzidas de engenharia reversa (quality/REVERSE_REPORT_2026-10-12-0800.md) —
> tags de confiança no corpo conforme IMP-096.

## 5. Regras de Negócio

### RN-001 [confirmado] 🟢
Quando o veículo passar pela praça, então o sistema deve registrar o evento de passagem com data, hora e placa.

**Confiança:** Alta (evidência direta — TollService.java:120-128)

### RN-002 [confirmado] 🟡
Se a tag do veículo estiver ativa, então o sistema deve aplicar o desconto de assinante no pedágio.

**Confiança:** Média (inferida do padrão de nomes — classe DiscountPolicy)

### RN-003 [confirmado] 🟢
Quando a passagem for registrada, então o sistema deve emitir o extrato consolidado diário por placa.

**Confiança:** Alta (evidência direta — StatementJob.java:44-51)

### RN-004 [pendente] 🔴
Se a passagem ocorrer em horário de pico, então o sistema deve aplicar a tarifa majorada.

**Confiança:** Baixa (comportamento não determinável — método applyPeakRate sem uso claro) — não validada por humano; não ancora feature (IMP-094).

## 6. Dados e Campos

### RN-003 — Extrato diário (🟢)

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| placa | Texto (7) | Sim | Placa do veículo |
| dataExtrato | Data | Sim | Dia de referência do extrato |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **PASSAGEM** — eventos de passagem (INSERT, SELECT)
- **TARIFA** — tarifas por horário (SELECT)

### Rastreabilidade

- RN-001 → PASSAGEM (INSERT)
- RN-002 → TARIFA (SELECT)
- RN-003 → PASSAGEM (SELECT)
- RN-004 → TARIFA (SELECT)

## 11. Pendências (PENDs)

### PEND-001 — Tarifa majorada em horário de pico (origem: RN-004 — Confiança Baixa, IMP-094)

1. A tarifa majorada em horário de pico é comportamento real ou código morto?
2. Qual o percentual de majoração aplicado?

Responsável: Operador Taxas (validação humana pendente).
