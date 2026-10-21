---
project: BLOQUEIOS-SANITARIO
module: catalogo-erros
audience: [tecnica]
status: draft
---

# Catálogo de Erros — Bloqueios Sanitários

> **Derivado de:** API_CONTRACTS.md, REQUIREMENTS.md §5 (RN-001, RN-002, RN-004)

---

## Erros de Negócio

### BLOQ_DUPLICADO

| Campo | Valor |
|---|---|
| HTTP | 409 Conflict |
| Mensagem amigável | Este produtor já possui um bloqueio ativo. |
| Origem | POST /bloqueios |
| RN | RN-002 |
| Ação sugerida | Consulte os bloqueios ativos do produtor antes de aplicar novo bloqueio. |

### PRODUTOR_INEXISTENTE

| Campo | Valor |
|---|---|
| HTTP | 404 Not Found |
| Mensagem amigável | Produtor não encontrado. |
| Origem | POST /bloqueios |
| RN | RN-001 |
| Ação sugerida | Verifique o código do produtor. |

### BLOQUEIO_INEXISTENTE

| Campo | Valor |
|---|---|
| HTTP | 404 Not Found |
| Mensagem amigável | Bloqueio não encontrado. |
| Origem | POST /bloqueios/{id}/encerramento |
| RN | RN-004 |
| Ação sugerida | Verifique o código do bloqueio. |

### BLOQUEIO_JA_ENCERRADO

| Campo | Valor |
|---|---|
| HTTP | 409 Conflict |
| Mensagem amigável | Este bloqueio já foi encerrado. |
| Origem | POST /bloqueios/{id}/encerramento |
| RN | RN-004 |
| Ação sugerida | Consulte o histórico do bloqueio. |

## Erros de Validação

### VALIDACAO_CAMPO

| Campo | Valor |
|---|---|
| HTTP | 400 Bad Request |
| Mensagem amigável | Verifique os campos informados. |
| Origem | POST /bloqueios, POST /bloqueios/{id}/encerramento |
| RN | RN-001, RN-004 |
| Detalhe | Campo obrigatório ausente ou acima do tamanho (motivo/motivoFim: até 500 caracteres). |
