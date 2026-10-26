# Estoque Local

App desktop de controle de estoque. Armazenamento em arquivo SQLite único
(`estoque.db`), acesso direto pelo time em inspeções de dados.

<!-- sqlite-mcp -->
SQLite via MCP (rusq/mcp-sqlite — binário nativo):

- Server `sqlite` habilitado no escopo do projeto (`.opencode/opencode.json`)
- Sem banco fixo no startup — abrir o `.db` da sessão com `open_database`
  (o arquivo deve existir antes: a tool não cria arquivo)
- Tools disponíveis: `open_database`, `get_schema`, `query` (read-only),
  `execute` (escrita/DDL) — todas com bind params `?`
- Ajustar somente o bloco `sqlite` do config — não tocar nos demais servers MCP
<!-- /sqlite-mcp -->