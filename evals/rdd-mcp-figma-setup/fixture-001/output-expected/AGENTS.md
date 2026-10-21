# Portal do Fornecedor

Portal web para gestão de pedidos de fornecedores. Angular 18 + .NET 8.

## Design

- Protótipo das telas mantido no Figma pelo time de design.
- Insumo do pipeline RDD via skills `rdd-figma-prompt` / `rdd-figma-tasks`.

<!-- figma-mcp -->
Figma via MCP (figma-developer-mcp / Framelink):

- Server `figma` habilitado no escopo do projeto (`.opencode/opencode.json`)
- Autenticação pela env var de usuário `FIGMA_API_KEY` — o token NUNCA é
  escrito em arquivo de config, `.env`, log ou commit
- Tools disponíveis: `figma_get_metadata`, `figma_get_code`,
  `figma_get_screenshot`, `figma_get_variable_defs`
- Ajustar somente o bloco `figma` do config — não tocar nos demais servers MCP
<!-- /figma-mcp -->
