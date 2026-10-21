---
project: BLOQUEIOS-SANITARIO
module: requisitos
status: misto
---

# REQUIREMENTS — Bloqueios Sanitários (RN ambígua + RN clara)

## 5. Regras de Negócio

### RN-001 [pendente]
O sistema deve bloquear o produtor rapidamente quando necessário, tratando as situações de forma adequada.

### RN-002 [confirmado]
Se o produtor já possuir bloqueio ativo, então o sistema deve rejeitar o novo bloqueio com o erro BLOQ_DUPLICADO.
