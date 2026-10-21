---
project: LEGACYBENCH
module: requisitos
status: confirmado
---

# REQUIREMENTS — LegacyBench

> **Gerado a partir de:** meetings/2026-10-14-01.md (checkpoint clarify),
> quality/REVERSE_REPORT_2026-10-14-0930.md (engenharia reversa), PROJECT_CHARTER.md (REDMINE #512)
> **RNs induzidas de engenharia reversa** — cada RN carrega no corpo a tag de confiança da análise reversa (IMP-096).

## 1. Escopo

Documentar os requisitos do bench de ordens de serviço (LegacyBench.OS)
via engenharia reversa. RNs induzidas carregam tag de confiança; RN de
confiança Baixa não validada por humano vira PEND (IMP-094).

## 2. Atores e Permissões

| Ator | Permissões |
|---|---|
| Operador | Concluir ordens e auditar conclusões |

## 5. Regras de Negócio

### RN-001 [confirmado]
Quando uma ordem for concluída, então o sistema deve registrar a data e o usuário responsável pela conclusão.

**Confiança:** Alta (evidência direta — OrderService.java:88-92; ver quality/REVERSE_REPORT_2026-10-14-0930.md)

### RN-002 [confirmado]
Toda ordem nova deve receber um número sequencial único.

**Confiança:** Média (inferida de padrão de nomes — coluna SEQ_ORDER, classe OrderNumberGenerator; ver quality/REVERSE_REPORT_2026-10-14-0930.md)

## 6. Dados e Campos

### RN-001 — Conclusão de ordem

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| dataConclusao | Data/Hora | Sim | Momento da conclusão (registro automático) |
| usuario | Referência | Sim | Usuário responsável (registro automático) |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **ORDEN** — ordens de serviço (SELECT, UPDATE)
- **SEQ_ORDER** — numeração sequencial de ordens (SELECT, UPDATE)

### Rastreabilidade

- RN-001 → ORDEN (UPDATE), auditoria de conclusão
- RN-002 → SEQ_ORDER (SELECT, UPDATE)

## 11. Pendências (PENDs)

### PEND-001 — Recálculo de prioridade ao reabrir ordem (origem: RN-c3 do relatório reverse — proposta RN-003, confiança Baixa)

RN induzida de confiança Baixa não validada por humano NUNCA ancora feature — registrada como PEND conforme IMP-094 (IMP-096).

1. O recálculo de prioridade ao reabrir uma ordem é comportamento intencional?
2. Em caso afirmativo, qual a fórmula de prioridade aplicada?

Responsável: Operador LegacyBench (validação humana pendente).
