---
project: BLOQUEIOS-SANITARIO
module: rastreabilidade
audience: [tecnica]
status: draft
---

# Traceability — Bloqueios Sanitários

> Matriz RN → downstreams. Gerada após tradução técnica parcial.

| RN | DATA_MODEL | API_CONTRACTS | UI_SPEC | ACCEPTANCE_CRITERIA |
|---|---|---|---|---|
| RN-001 | ✅ BLOQUEIO | ✅ POST /bloqueios | ⬜ | ✅ |
| RN-002 | ✅ BLOQUEIO | ✅ POST /bloqueios (409) | ✅ Tela aplicação | ✅ |
| RN-003 | ⬜ | ⬜ | ⬜ | ✅ |
| RN-004 | ✅ HIST_BLOQUEIO | ✅ POST /bloqueios/{id}/encerramento | ✅ Tela encerramento | ✅ |

## Observações

- RN-003 (status de GTA) ainda sem downstream de API — integração com
  emissor de GTA pendente de definição
- UI_SPEC parcial — tela de consulta (UC-02) não especificada
