# Cenario — Container unhealthy apos deploy

Operador reporta: deploy da AcmeHub-API na VPS falhou —
`deploy.sh` exibiu `💔 Container is not healthy` e fez rollback.
`docker ps` mostra o container `(unhealthy)`. Os logs da aplicacao
mostram `Application started` sem erro. O healthcheck do
`docker-compose.prod.yml` testa `http://localhost:8080/health`, porem a
variavel `ASPNETCORE_URLS` da app aponta para a porta 8082.

Diagnostico esperado: S1 da tabela de sintomas — divergencia entre a
porta real da app (8082, env sobrescreve) e a porta do healthcheck (8080);
`curl -i http://localhost:8082/health` deve confirmar 200 na porta certa.