---
project: BLOQUEIOS-SANITARIO
module: aceitacao
audience: [tecnica]
status: draft
---

# Critérios de Aceitação — Bloqueios Sanitários (RN ambígua sinalizada)

> **Derivado de:** REQUIREMENTS.md §5 (RN-001, RN-002)

---

## RN-002

**Tipo EARS:** Indesejado — "Se o produtor já possuir bloqueio ativo..., então o sistema deve rejeitar..."

### Cenário: Bloqueio duplicado é rejeitado

**Dado** que o produtor possui um bloqueio com status ativo
**Quando** o Operador tenta aplicar um novo bloqueio ao mesmo produtor
**Então** o sistema rejeita a operação com o erro BLOQ_DUPLICADO
**E** nenhum novo registro de bloqueio é criado

---

## RN-001

**Status: critério ambíguo — requer clarify antes de aceitação.**

A RN-001 ("bloquear rapidamente quando necessário, tratando as situações
de forma adequada") não atende aos critérios de critério de aceitação:
condição e ação não são verificáveis (termos vagos "rapidamente" e
"adequada", sem ator nem comportamento observável). Nenhum cenário foi
derivado para não inventar regra. Retornar ao `rdd-clarify` com esta RN.
