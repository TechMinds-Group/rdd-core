═══ rdd-vps-troubleshoot — DIAGNÓSTICO (modo não-interativo — eval baseline) ═══

Sintoma: deploy da AcmeHub-API falhou — `deploy.sh` exibiu
`💔 Container is not healthy`, fez rollback; `docker ps` mostra o container
`(unhealthy)`. Logs da aplicação mostram `Application started` sem erro.
Healthcheck do `docker-compose.prod.yml` testa `http://localhost:8080/health`,
porém `ASPNETCORE_URLS` da app aponta para a porta 8082.

── Triagem ──

Match exato na tabela de sintomas: **S1** — Container `(unhealthy)` /
deploy.sh expira com `💔 Container is not healthy`.
Causa provável: porta do healthcheck divergente da porta real da app
(variável de ambiente sobrescreve a porta padrão da imagem).

── Diagnóstico (ordem de verificação do runbook S1) ──

1. `docker logs -f acmehub-api` — PRIMEIRO passo sempre.
   Resultado esperado aqui: `Application started` sem erro → a app subiu;
   o problema NÃO é a aplicação, é o healthcheck.

2. `docker ps` — conferir a coluna `PORTS`: em qual porta o container está
   DE FATO escutando? Comparar com a porta que o `healthcheck` do
   `docker-compose.prod.yml` testa. É comum a variável de ambiente
   (`URLS`, `ASPNETCORE_URLS`, `HTTP_PORTS`) sobrescrever a porta padrão
   da imagem e ficar divergente do healthcheck configurado.
   Aqui: app escuta **8082** (ASPNETCORE_URLS), healthcheck testa **8080**
   → DIVERGÊNCIA confirmada.

3. `curl -i http://localhost:8082/health` — SEMPRE com `-i` para ver o
   STATUS HTTP, não só se conectou:
   - `200` → app saudável na porta certa; healthcheck é que aponta errado
   - `404` (conectou, rota não existe) → problema DIFERENTE: rota de
     health não mapeada na aplicação (conferir
     `MapHealthChecks`/`AddHealthChecks`, ou variações `/healthz`,
     `/api/health`)
   - `connection refused` → porta errada mesmo
   Resultado esperado aqui: `HTTP/1.1 200 OK` na porta 8082 → causa raiz
   confirmada: **divergência porta real (8082) × porta do healthcheck (8080)**.

── Correção (uma por vez, com confirmação antes de aplicar) ──

Alinhar o healthcheck do `docker-compose.prod.yml` à porta real da app:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8082/health"]
  # ... interval/start_period/retries inalterados
```

Alternativa equivalente: fixar a app na porta que o healthcheck espera
(ajustar `ASPNETCORE_URLS`/`HTTP_PORTS`) — escolher UMA direção e manter
compose, variáveis e healthcheck coerentes. Nunca sugerir duas correções
ao mesmo tempo.

⚠️ Atenção: qualquer porta hardcoded em scripts (`deploy.sh`,
`setup-cloudflare-autostart.sh`, `config.yml` do tunnel) precisa acompanhar
a mudança — hostname/porta divergente em script só aparece depois no
`ExecStart` do `systemctl status`.

── Verificação ──

1. Re-executar deploy (ou `docker compose -f docker-compose.prod.yml up -d`)
2. `docker ps` → container `(healthy)` (não `(unhealthy)`/`(starting)`)
3. De fora, ponta a ponta: `curl -I https://<hostname>.acme.example/health`

```
═══ rdd-vps-troubleshoot — RELATÓRIO ═══

Sintoma: container (unhealthy), rollback no deploy.sh (💔)
Causa raiz: healthcheck testa porta 8080; app escuta 8082
            (ASPNETCORE_URLS sobrescreve a porta padrão da imagem)
Correção: alinhar healthcheck do docker-compose.prod.yml à porta 8082
          (ou fixar a app em 8080 — uma direção, nunca as duas soltas)
Verificação: docker ps (healthy) + curl -i local 200 +
             curl -I público via tunnel OK
Lição: env (URLS/HTTP_PORTS) sobrescreve a porta da imagem — ao mudar
       porta, reconciliar healthcheck + scripts + tunnel config na mesma
       mudança. Padrão já catalogado (S1) — sem registro novo.
```
