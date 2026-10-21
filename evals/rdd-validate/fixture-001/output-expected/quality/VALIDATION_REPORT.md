---
project: BLOQUEIOS-SANITARIO
module: validacao
audience: [tecnica]
status: draft
---

# Relatório de Validação — Bloqueios Sanitários

> **Executado em:** 20/09/2026
> **Escopo:** grafo de documentos do módulo (REQUIREMENTS.md, specs/DATA_MODEL.md, quality/TRACEABILITY.md)

---

## 1. RN sem downstream esperado

| RN | DATA_MODEL | API_CONTRACTS | UI_SPEC | Status |
|---|---|---|---|---|
| RN-001 | ✅ BLOQUEIO | ⚠️ arquivo ausente | ⚠️ arquivo ausente | parcial |
| RN-002 | ✅ BLOQUEIO | ⚠️ arquivo ausente | ⚠️ arquivo ausente | parcial |
| RN-003 | ❌ não referenciada | ❌ sem entrada | ❌ sem entrada | **LACUNA** |
| RN-004 | ✅ BLOQUEIO, HIST_BLOQUEIO | ⚠️ arquivo ausente | ⚠️ arquivo ausente | parcial |

### Detalhes

**RN-003 — lacuna de downstream (warning alto):**
A RN-003 envolve integração (exposição de status de bloqueio ao emissor de
GTA, conforme REQUIREMENTS.md §8) e não possui entrada em nenhum downstream.
O TRACEABILITY.md confirma a lacuna (⬜ em DATA_MODEL, API_CONTRACTS e
UI_SPEC para RN-003). Como a RN exige um endpoint de consulta de status
para o emissor de GTA, a ausência de API_CONTRACTS.md é o gap mais crítico.

**API_CONTRACTS.md ausente (warning de módulo):**
RNs com potencial downstream de API (RN-001, RN-002, RN-003, RN-004) não
têm o contrato verificável porque o arquivo não existe no módulo.
Recomendação: executar `rdd-api-contracts`.

**UI_SPEC.md ausente (warning de módulo):**
Casos de uso UC-01..UC-03 sugerem interface; downstream de UI não
verificável. Recomendação: executar `rdd-ui-spec`.

**DATA_MODEL.md não cita RN-003 (info):**
A tabela BLOQUEIO cobre o dado lido pela RN-003, mas a seção de derivação
não referencia a RN. Baixo impacto — rastreabilidade documental.

## 2. IDs quebrados

Nenhum. RN-001..RN-004 são sequenciais e consistentes entre
REQUIREMENTS.md, DATA_MODEL.md e TRACEABILITY.md.

## 3. CRs aprovados sem reflexo

Nenhum CR registrado no módulo (support/CHANGE_REQUESTS.md ausente).

---

## Resumo

| Severidade | Quantidade | Itens |
|---|---|---|
| Warning alto | 1 | RN-003 sem downstream |
| Warning de módulo | 2 | API_CONTRACTS.md e UI_SPEC.md ausentes |
| Info | 1 | DATA_MODEL não cita RN-003 |

**Ação recomendada:** executar `rdd-api-contracts` e `rdd-ui-spec`,
garantindo entrada para RN-003 (endpoint de status GTA) antes de avançar
para tasks.
