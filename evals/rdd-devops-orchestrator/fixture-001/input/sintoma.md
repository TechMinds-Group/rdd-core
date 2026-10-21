# Sintoma reportado

Servidor: VPS api-vendas-01 (Amazon Linux, ja configurada)
Projeto: TM.Vendas-API (hostname api-vendas.acme.example, porta 8080)
Sintoma: docker compose ps mostra o container da API em estado "unhealthy (health check exceeded timeout)" apos o deploy de ontem; a rota publica responde 502 intermitentemente.
Deploy ocorreu via GitHub Actions (ssh-action) - pipeline rodou sem erro.