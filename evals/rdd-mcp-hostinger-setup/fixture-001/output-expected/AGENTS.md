# AGENTS.md — <Org> Infra

<!-- hostinger-mcp -->
MCP Hostinger (remote OAuth global — opencode mcp list deve mostrar
✓ hostinger connected):
- hostinger_search({ query }) — encontra operação; o inputSchema retornado é autoritativo
- hostinger_execute({ operation, params }) — roda 1 operação da API (~410 ops em 13 grupos: vps, hosting, domains, dns, billing, mail, wordpress...)
- hostinger_multi-execute({ steps }) — até 20 operações em cadeia com $steps.<i>.<path>
Nunca pedir API token no chat — autenticação é OAuth pelo TUI /mcps.
<!-- /hostinger-mcp -->
