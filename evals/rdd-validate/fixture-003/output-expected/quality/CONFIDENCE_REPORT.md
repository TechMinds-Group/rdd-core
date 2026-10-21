---
project: TAXAS-PEDAGIO
module: confianca
audience: [tecnica]
status: draft
---

# Relatório de Confiança — Taxas de Pedágio

> **Gerado em:** 14/10/2026 · rdd-validate (IMP-096)
> **Fórmula do percentual geral:** (🟢 + 0,5×🟡)/total — Alta (🟢) vale 1, Média (🟡) vale 0,5, Baixa (🔴) vale 0.

## 1. Contagem por documento

| Artefato | 🟢 | 🟡 | 🔴 | Percentual geral |
|---|---|---|---|---|
| REQUIREMENTS.md | 3 | 1 | 1 | (3 + 0,5×1)/5 = 70% |
| specs/DATA_MODEL.md | 1 | 1 | 0 | (1 + 0,5×1)/2 = 75% |

## 2. Itens 🔴 / confiança Baixa

| Item | Documento | Evidência | Ação |
|---|---|---|---|
| RN-004 — tarifa majorada em horário de pico (🔴, **Confiança:** Baixa) | REQUIREMENTS.md | comportamento não determinável (applyPeakRate) | PEND-001 — validar com o operador (IMP-094: RN Baixa não validada por humano nunca ancora feature) |

## 3. Observações

- Auditoria anti-🟢 disfarçado (Jev): não aplicada nesta execução (camada opcional — Jev indisponível); coluna de sugestão omitida conforme IMP-096.
- Nenhuma afirmação 🟢 apresentou linguagem de inferência na leitura manual.
