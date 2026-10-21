---
project: BLOQUEIOS-SANITARIO
module: decision-audit
audience: [requirements, governanca]
status: draft
generated_at: "2026-09-27T17:15:00Z"
decisions_analyzed: 3
---

# Decision Audit — bloqueios-sanitario

> **Gerado em:** 27/09/2026 17:15
> **Decisões analisadas:** 3 (0 ativas ADR, 0 superseded, 3 legadas DEC-XXX)
> **Resultado Geral:** ❌ Erros encontrados

---

## Resumo

| Categoria | Erros | Warnings | Info |
|-----------|-------|----------|------|
| 1. Sequência de IDs | 0 | 0 | 0 |
| 2. Status consistente | 1 | 0 | — |
| 3. Conflitos semânticos | 1 | 0 | — |
| 4. Referências quebradas | 1 | 0 | — |
| 5. Decisões sem impacto | — | 0 | — |
| 6. Decisões órfãs | — | 4 | 0 |
| 7. Decisões obsoletas | 0 | 0 | — |
| 8. Legado (DEC-XXX) | — | — | 3 |
| **Total** | **3** | **4** | **3** |

---

## 1. Sequência de IDs

✅ Sem ADRs ativas — sequência ADR N/A (o módulo contém apenas entradas
legadas DEC-XXX, que não entram na sequência ADR).

---

## 2. Status Consistente

- ❌ **DEC-003** — Status `Proposta` fora dos valores válidos do esquema
  legado (`active` | `superseded by DEC-YYY`). Entradas legadas não suportam
  status de proposta; regularizar como `active` ou remover a entrada.
- ℹ️ DEC-001 e DEC-002 usam `Ativa` (PT-BR) — interpretado como `active`.

---

## 3. Conflitos Semânticos

### CONFLITO: DEC-001 × DEC-002

**DEC-001:** Eventos de bloqueio (criação e encerramento) registrados em uma
única tabela `HIST_BLOQUEIO`, diferenciados por `TIP_EVENTO`.
**DEC-002:** Criar tabelas separadas `HIST_CRIACAO` e `HIST_ENCERRAMENTO`
para os eventos de bloqueio, otimizando cada fluxo.
**Conflito:** Ambas as decisões estão ativas e prescrevem armazenamentos
distintos e incompatíveis para o mesmo conjunto de eventos de bloqueio.
**Recomendação:** Revogar uma das duas decisões (campo Status) antes do
modelo de dados avançar. DEC-001 é anterior e DEC-002 não menciona revogação
— confirmar com os decisores qual prevalece.

---

## 4. Referências Quebradas

| ADR | Referência | Tipo | Status |
|-----|-----------|------|--------|
| DEC-003 | RN-999 | RN | ❌ Não existe |

REQUIREMENTS.md contém apenas RN-001..RN-004. A referência correta
provavelmente é uma pendência de expiração de bloqueio (a ser registrada
como PEND-XXX junto ao jurídico).

---

## 5. Decisões sem Impacto

✅ Todas as decisões têm impacto mapeado.

---

## 6. Decisões Órfãs (RNs sem DEC)

| RN | Título | Observação |
|----|--------|------------|
| RN-001 | Registro de dados na aplicação de bloqueio | Nenhuma decisão referencia esta RN |
| RN-002 | Rejeição de bloqueio duplicado | Nenhuma decisão referencia esta RN |
| RN-003 | Impedimento de emissão de GTA | Nenhuma decisão referencia esta RN |
| RN-004 | Registro do motivo de encerramento | Nenhuma decisão referencia esta RN |

---

## 7. Decisões Obsoletas

✅ Nenhuma decisão obsoleta detectada (entradas de 20-21/09/2026, menos de
90 dias).

---

## 8. Legado (DEC-XXX)

Entradas pré-migração no esquema DEC-XXX — **imutáveis**, listadas apenas
para inventário. Não geram erro nem warning.

| ID legado | Título | Observação |
|-----------|--------|------------|
| DEC-001 | Histórico unificado de eventos de bloqueio | Em conflito com DEC-002 |
| DEC-002 | Histórico segmentado por tipo de evento | Em conflito com DEC-001 |
| DEC-003 | Prazo máximo de bloqueio | Referencia RN-999 inexistente |

---

## Recomendações

| Prioridade | Ação | Decisão afetada |
|-----------|------|-----------------|
| ❌ Alta | Revogar/atualizar uma das decisões conflitantes antes do DATA_MODEL | DEC-001 / DEC-002 |
| ❌ Alta | Corrigir referência RN-999 (registrar PEND-XXX de expiração) | DEC-003 |
| ⚠️ Média | Regularizar status `Proposta` para valor válido do esquema legado | DEC-003 |
| ℹ️ Baixa | Vincular explicitamente as RN-001..004 a decisões (hoje órfãs) | — |

---

*Camada Jev: não executada (API indisponível na execução).*