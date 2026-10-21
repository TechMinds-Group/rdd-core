---
project: BLOQUEIOS-SANITARIO
module: catalogo-erros
audience: [tecnica]
status: draft
---

# Catálogo de Erros — Bloqueios Sanitários

> **Derivado de:** API_CONTRACTS.md

## Erros de Validação

### VALIDACAO_CAMPO

| Campo | Valor |
|---|---|
| HTTP | 400 Bad Request |
| Mensagem amigável | Verifique os campos informados. |
| Origem | GET /bloqueios |
| RN | RN-001 |
| Detalhe | idProdutor obrigatório para a consulta. |
