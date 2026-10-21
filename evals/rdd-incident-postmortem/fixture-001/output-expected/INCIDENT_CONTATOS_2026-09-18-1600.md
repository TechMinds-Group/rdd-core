---
project: CONTATOS
module: incident-postmortem
audience: [suporte, tecnica]
status: draft
incident_date: "2026-09-18"
severity: alta
duration: 1h 40min
---

# Post-Mortem — Indisponibilidade da exclusão de campanhas

> **Data do incidente:** 18/09/2026 14:20
> **Severidade:** Alta
> **Módulo afetado:** CONTATOS
> **Duração total:** 1h 40min (detecção → resolução)
> **Status:** Resolvido

---

## 1. Resumo Executivo

A exclusão de campanhas passou a remover os leads de apenas uma campanha por
requisição após a RN-026, deixando leads órfãos visíveis na listagem. Corrigido
com remoção explícita dos leads antes da remoção da campanha.

---

## 2. Timeline do Incidente

| Hora | Evento | Responsável |
|------|--------|-------------|
| 14:20 | Detecção — usuários reportam leads órfãos após exclusão | Suporte |
| 14:35 | Contenção — exclusão de campanha suspensa via feature flag | Victor Souza |
| 15:10 | Diagnóstico — cascade não aplicava (DDL sem FK) | Victor Souza |
| 15:40 | Resolução — remoção explícita dos leads no controller | Victor Souza |
| 16:00 | Verificação — exclusão de teste com 60 leads sem órfãos | Victor Souza |

---

## 3. Impacto

**Usuários afetados:**
- Usuários do módulo Contatos que excluíram campanhas no período

**Funcionalidades impactadas:**
- Exclusão de campanha de coleta (RN-026)

**Período de impacto:**
- De 14:20 até 16:00 (total: 1h 40min)

**Dados afetados:**
- Leads órfãos remanescentes em listagem (sem perda de dados)
