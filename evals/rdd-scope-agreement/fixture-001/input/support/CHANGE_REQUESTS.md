---
project: BLOQUEIOS-SANITARIO
module: mudancas
status: ativo
---

# CHANGE REQUESTS — Bloqueios Sanitários

> Mudanças em requisitos confirmados passam obrigatoriamente por este registro.
> A alteração só é refletida em REQUIREMENTS.md após aprovação.

---

## CR-001 — RN-002: rejeição de duplicidade vale apenas para bloqueio ativo

| Campo | Valor |
|---|---|
| Data | 20/09/2026 |
| Status | pending |
| Origem | Reunião com PO sanitário (meetings/2026-09-20-02.md) |
| RN afetada | RN-002 |
| Urgência | Alta — auditoria externa em 30 dias |

### Descrição da mudança

Deixar explícito na redação da RN-002 que a rejeição de bloqueio duplicado
se aplica **apenas quando o produtor possuir bloqueio ativo**, e que
bloqueios encerrados não podem impedir a aplicação de um novo bloqueio.

**Redação atual (RN-002):**
> Se o produtor já possuir bloqueio ativo, então o sistema deve rejeitar o
> novo bloqueio com o erro BLOQ_DUPLICADO.

**Redação proposta (RN-002):**
> Se o produtor possuir bloqueio com status ativo, então o sistema deve
> rejeitar o novo bloqueio com o erro BLOQ_DUPLICADO. Bloqueios com status
> encerrado não impedem a aplicação de um novo bloqueio.

### Justificativa

O jurídico entende que a regra atual, na redação vigente, pode ser
interpretada como restrição permanente ao re-bloqueio. A mudança elimina a
ambiguidade antes da auditoria externa.

### Impacto em downstreams

| Downstream | Impacto |
|---|---|
| specs/API_CONTRACTS.md | POST /bloqueios — condição do erro 409 BLOQ_DUPLICADO deve citar "bloqueio com status ativo" |
| specs/UI_SPEC.md | Mensagem exibida na tela de aplicação de bloqueio deve refletir a condição "bloqueio ativo" |
| specs/ACCEPTANCE_CRITERIA.md | Cenário de duplicidade deve ser condicionado a status ativo; cenário de re-bloqueio após encerramento deve ser explícito |

### Downstreams existentes no módulo

No momento do registro, API_CONTRACTS.md e UI_SPEC.md ainda não existem no
módulo (ver VALIDATION_REPORT). O reflexo da mudança nestes artefatos deve
ser garantido na primeira geração deles, além do ajuste no
ACCEPTANCE_CRITERIA.md quando existente.

### Decisão

Aguardando aprovação do PO sanitário. Após aprovação: atualizar RN-002 em
REQUIREMENTS.md e propagar o delta nos downstreams listados.
