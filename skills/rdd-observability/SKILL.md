---
name: rdd-observability
description: >-
  Configura verificação de saúde e alertas para APIs em VPS — healthcheck
  do Docker Compose (healthcheck + start_period), endpoint /health, logging
  com rotação (cloudflared/journalctl/docker logs) e alertas no canal do
  perfil (`alert_channel`: telegram | slack | email; receita Telegram
  validada no pack `rules/<pack-da-organizacao>.md` §infra-observability — IMP-105).
  Modo guiado — o operador executa na VPS. Escopo mínimo KISS: nada de
  stack de observabilidade (Prometheus/Grafana) sem demanda validada. Use
  quando o usuário pedir "healthcheck", "monitorar API", "alerta quando
  cai", "uptime", "logs centralizados", "notificação de container" ou
  "observabilidade da VPS".
---
# rdd-observability — Saúde, Logs e Alertas (APIs em VPS)

Configura o mínimo viável de observabilidade para uma API hospedada em VPS
da organização: o container **sabe** que está doente (healthcheck), o
operador **fica sabendo** (alerta no canal do perfil via cron) e consegue
**investigar** (logs com rotação). **Receita validada do canal de alerta:
pack `rules/<pack-da-organizacao>.md` §infra-observability** (IMP-105) — healthcheck
validado em produção e watchdog Telegram do perfil Acme
(`alert_channel: telegram`); para outro canal (slack/email), adapte o
delivery do watchdog mantendo a lógica de transição. Canal
(`alert_channel`), registry (`ghcr_registry`) e domínio (`dns_domain`) vêm
do `rules/client-profile.md` (IMP-103).

## Diferenciação

| Skill | Escopo |
|-------|--------|
| `rdd-observability` (esta) | Configurar saúde/logs/alertas — **antes** do incidente |
| `rdd-vps-troubleshoot` | Diagnosticar sintoma ativo — **durante** o incidente |
| `rdd-vps-setup` | Setup inicial da VPS (inclui logging do cloudflared §9 e backup + canal de alerta §11 do pack §infra-vps-setup) |
| `rdd-known-error` | Formalizar erro recorrente já diagnosticado em KNOWN_ERRORS.md |

## Lê (upstream)

- `rules/client-profile.md` (IMP-103/IMP-105) — `alert_channel`,
  `ghcr_registry`, `dns_domain`
- Pack da organização (`rules/<pack-da-organizacao>.md` §infra-observability;
  IMP-105) — receitas validadas de healthcheck, script de watchdog e
  alerta no canal configurado
- `docker-compose.prod.yml` e `scripts/` do repo alvo — para adaptar porta,
  nome de serviço e endpoint de saúde reais da API

## Gera (downstream)

- Bloco `healthcheck` para o `docker-compose.prod.yml` (diff mostrado antes
  de editar; edição local no repo só com confirmação)
- `scripts/watchdog.sh` (check do endpoint + notificação no canal do
  perfil) e entrada de cron — arquivos criados no repo com confirmação;
  ativação na VPS é orientada ao operador (modo guiado)
- Relatório final: itens OK / pendentes / ⚠️

## Fluxo de Trabalho

1. **Contexto (uma `question` agrupada):** repo/projeto, porta e endpoint de
   saúde da API (ex: `/health`), hostname público (`<dns_domain>` do
   perfil), canal de alerta (`alert_channel`; para Telegram, chat_id
   existente — o token NUNCA é pedido no chat — reusar o configurado no
   backup do pack §infra-vps-setup item 11).
2. **Healthcheck no compose** — gerar bloco (pack §infra-observability
   item 1), dry-run do diff, gravar com confirmação. Orientar
   `docker compose up -d` para aplicar e validar `docker ps` → `(healthy)`.
3. **Watchdog + cron** — gerar `scripts/watchdog.sh` (pack
   §infra-observability item 2; receita do canal no mesmo pack): curl no
   endpoint (timeout curto, N retries) → falha → mensagem no canal com
   hostname+container+timestamp; estado anti-spam (não re-alertar enquanto
   continuar caindo). Agenda via cron a cada 5 min.
4. **Logs** — verificar rotação existente (cloudflared, pack
   §infra-vps-setup item 9); orientar `docker logs --since` / `journalctl`
   como prática de investigação; sugerir retenção no logrotate se ausente.
5. **Validação ponta a ponta** — parar o container em teste (com o
   operador), confirmar alerta no canal, religar e confirmar recuperação.

## Nunca edita

- Config da VPS remotamente — modo guiado: sugere, operador executa
- Token/segredo do canal de alerta no chat ou em arquivo versionado — lê da
  VPS (config do backup) ou env; identificadores não-secretos (ex.:
  `CHAT_ID` do Telegram) podem ser versionados, token não
- Stack de métricas (Prometheus, Grafana, APM) — fora do escopo KISS sem
  demanda explícita validada

## Tools disponíveis

- `read`, `glob`, `grep` — ler compose, scripts e o pack da organização
- `write`/`edit` — healthcheck no compose, watchdog.sh, entrada de cron documentada
- `bash` — local apenas (validar sintaxe do script gerado, `bash -n`)
- `question` — contexto e confirmações

## Modo de erro

- Repo sem `docker-compose.prod.yml` → perguntar como a API roda na VPS
  antes de gerar healthcheck (pode ser systemd direto — aí o watchdog checa
  o endpoint, não o container)
- API sem endpoint de saúde → propor adicionar `/health` mínimo (200 OK) no
  repo — encaminhar implementação ao `rdd-dev` se necessário
- Canal de alerta não configurado na VPS → encaminhar o item 11 do pack
  §infra-vps-setup (setup de backup + canal)

## Casos de borda

- Múltiplos containers no compose → healthcheck por serviço; watchdog cobre
  o serviço exposto ao público (os demais herdam do compose)
- Container reiniciando em loop (unhealthy → restart) → alerta cobre, mas o
  diagnóstico é da `rdd-vps-troubleshoot`
- Falso positivo por cold start → `start_period` generoso e retries no watchdog
- Cron em VPS sem cronie → `sudo yum install -y cronie` (pack
  §infra-vps-setup item 11)
- Organização sem pack → derive a receita do watchdog para o canal do
  perfil (telegram | slack | email) mantendo a lógica de transição;
  receitas novas de canal devem nascer no pack da org

## Formato de commit

`ops(<repo>): adiciona healthcheck e watchdog com alerta <alert_channel>`