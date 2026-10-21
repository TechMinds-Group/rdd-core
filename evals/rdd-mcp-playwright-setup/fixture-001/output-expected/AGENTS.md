# Storefront

E-commerce B2C. Next.js 15 + API .NET 8.

## Testes

- Testes E2E com Playwright (`npm run test:e2e`).

<!-- playwright-mcp -->
Playwright via MCP (@playwright/mcp):

- Browser: Chromium (padrão), mode headless
- Server `playwright` no escopo do projeto (`.opencode/opencode.json`) — NUNCA global
- Use `playwright_browser_navigate` para navegar para URLs
- Use `playwright_browser_snapshot` para capturar o estado acessível da página
- Use `playwright_browser_click` / `playwright_browser_type` para interagir com formulários
- Use `playwright_browser_take_screenshot` para evidência visual
- Config não é hot-reloaded: reinicie o OpenCode após mudanças
<!-- /playwright-mcp -->
