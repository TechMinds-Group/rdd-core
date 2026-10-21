---
project: BLOQUEIOS-SANITARIO
module: rastreabilidade
audience: [tecnica]
status: draft
---

# Traceability — Bloqueios Sanitários

> **Matriz RN → downstreams.** Gerada após tradução técnica completa.

| RN | DATA_MODEL | API_CONTRACTS | UI_SPEC | ACCEPTANCE_CRITERIA |
|---|---|---|---|---|
| RN-001 | ✅ BLOQUEIO (INSERT) | ✅ POST /bloqueios | ✅ Tela Aplicar bloqueio | ✅ Cenário auditoria |
| RN-002 | ✅ BLOQUEIO (SELECT) | ✅ POST /bloqueios (409 BLOQ_DUPLICADO) | ✅ Mensagem de duplicado | ✅ Cenários duplicado/re-bloqueio |
| RN-003 | ✅ BLOQUEIO (SELECT) | ✅ GET /bloqueios/gta-status/{idProdutor} | ✅ Badge GTA Impedida/Liberada | ✅ Cenários GTA impedida/liberada |
| RN-004 | ✅ BLOQUEIO (UPDATE), HIST_BLOQUEIO (INSERT) | ✅ POST /bloqueios/{id}/encerramento | ✅ Modal de encerramento | ✅ Cenários encerramento/motivo |

## Erros de API por RN

| RN | Códigos |
|---|---|
| RN-001 | PRODUTOR_INEXISTENTE (404), VALIDACAO_CAMPO (400) |
| RN-002 | BLOQ_DUPLICADO (409) |
| RN-004 | BLOQUEIO_INEXISTENTE (404), BLOQUEIO_JA_ENCERRADO (409), VALIDACAO_CAMPO (400) |

## Cobertura

| Métrica | Valor |
|---|---|
| RNs rastreadas | 4/4 (100%) |
| RNs com downstream completo | 4/4 (100%) |
| Erros de catálogo mapeados a RN | 5/5 |
