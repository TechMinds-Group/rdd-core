# API Contracts — Contatos

## 9. Campanhas de Coleta

### 9.6 Excluir campanha de coleta

```
DELETE /api/campanhas/{id:guid}
```

**RNs:** RN-026 — remove campanha e leads; 409 se em andamento.
