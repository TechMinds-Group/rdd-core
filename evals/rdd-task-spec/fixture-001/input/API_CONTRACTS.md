# API_CONTRACTS — Contratos de API (fixture task-spec)

## Endpoints

### GET /bloqueios

Response 200:
```json
{
  "bloqueios": [{ "id": 1, "produtor": "João", "data": "2024-01-01" }]
}
```

### POST /bloqueios

Request:
```json
{ "idProdutor": 1, "motivo": "Descumprimento de prazo" }
```

Response 201:
```json
{ "id": 1, "status": "criado" }
```

### GET /bloqueios/historico

Response 200:
```json
{ "historico": [{ "id": 1, "acao": "criado", "data": "2024-01-01" }] }
```

## Repositórios

- Backend: `Bloqueios.API`