# Catálogo

Catálogo de produtos da Acme. API .NET 8 com EF Core 8.

## Banco de dados

- PostgreSQL 16 local, porta 5432, database `catalogo_db`
- Usado para consultas de diagnóstico e evolução de schema durante o desenvolvimento

<!-- postgres-mcp -->
PostgreSQL via MCP (@microsoft/postgres-mcp):

- Profile: `catalogo-local` → `catalogo_db` em `localhost:5432`, user `postgres`, access_mode: ro
- Senha NUNCA em arquivo — configurar via keyring (`set-password`)
- Use `postgres_mcp_query` para SELECT/EXPLAIN e outras consultas read-only
- Use `postgres_mcp_db_context` para inspecionar schema (tabelas, índices, funções)
- `postgres_mcp_modify` (DDL/DML) requer confirmação explícita do usuário
<!-- /postgres-mcp -->
