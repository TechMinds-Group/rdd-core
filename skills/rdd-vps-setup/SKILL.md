---
name: rdd-vps-setup
description: >-
  Wizard guiado de setup de VPS nova (OS do perfil — ex.: Amazon Linux)
  para hospedar uma API — atualização do sistema, Docker + Compose + buildx,
  permissões de arquivos, autenticação no registry do perfil (ex.: ghcr.io),
  git via SSH (deploy keys), chave SSH dedicada do GitHub Actions
  (appleboy/ssh-action), tunnel Cloudflare EXCLUSIVO por servidor + route
  DNS (domínio do perfil), tunnels como serviço systemd (autostart), logging
  do cloudflared com rotação, pipeline completo de deploy (push main → build
  → registry → ssh-action → deploy.sh) e backup automatizado (RClone +
  cronie + canal de alerta do perfil). Base de conhecimento validada: pack da
  organização em `rules/<pack-da-organizacao>.md` §infra-vps-setup (IMP-105). Modo
  guiado — sugere comandos com explicação; o operador executa na VPS. Use
  quando o usuário pedir "setup de VPS", "configurar VPS nova", "preparar
  servidor para deploy", "tunnel cloudflare", "ghcr", "deploy key",
  "backup rclone", "docker compose na vps" ou "pipeline de deploy na VPS".
---
# rdd-vps-setup — Wizard de Setup de VPS

Assiste o setup completo de uma VPS **nova** (OS do perfil — `infra_os`;
ex.: Amazon Linux 2/2023) para hospedar uma API da organização, do zero até
o pipeline de deploy funcionando e backup agendado. **Base de conhecimento
validada: pack `rules/<pack-da-organizacao>.md` §infra-vps-setup** (IMP-105) — comandos
validados por tema e lições aprendidas. OS (`infra_os`), e-mail de deploy
(`deploy_email`), domínio DNS (`dns_domain`), canal de alerta
(`alert_channel`) e registry (`ghcr_registry`) vêm do
`rules/client-profile.md` (IMP-103); para outra organização, derive os
valores do perfil da org. Dois modos de execução (seção abaixo): **guiado**
(default — a skill sugere cada comando com explicação e o operador executa
na VPS) e **SSH** (opcional — a skill executa os comandos direto na VPS via
MCP `ssh-manager`, sempre com confirmação por fase).

## Diferenciação

| Skill | Escopo |
|-------|--------|
| `rdd-vps-setup` (esta) | Setup **inicial** de VPS nova — infra de deploy (Docker, registry, SSH, tunnel, systemd, backup) |
| `rdd-vps-troubleshoot` | Diagnóstico **por sintoma** em VPS já configurada (unhealthy, SSH action falhando, tunnel, banco vazio) |
| `rdd-setup` | Config da máquina **local** do operador (AGENTS.md, opencode.jsonc) — não toca em VPS |
| `rdd-gh-setup` | gh CLI na máquina **local** — não cobre deploy keys/SSH da VPS |

## Lê (upstream)

- `rules/client-profile.md` (IMP-103/IMP-105) — `infra_os`, `deploy_email`,
  `dns_domain`, `alert_channel`, `ghcr_registry`
- Pack da organização (`rules/<pack-da-organizacao>.md` §infra-vps-setup; IMP-105) —
  base de conhecimento: comandos validados, causas e lições aprendidas por
  tema
- Repos do projeto quando existirem localmente (`scripts/deploy.sh`,
  `scripts/setup-cloudflare-autostart.sh`, `docker-compose.prod.yml`) —
  para adaptar nomes de serviços, portas e hostnames ao projeto alvo

## Gera (downstream)

- Checklist de setup contextualizado ao servidor/projeto, apresentado no
  chat (a skill não escreve arquivos)
- Relatório final de conclusão com itens OK / pendentes / ⚠️

## Modos de execução

| Modo | Como ativa | Comportamento |
|------|-----------|---------------|
| **Guiado** (default) | — | Comandos sugeridos com explicação; operador executa na VPS e cola o output; skill valida contra o critério da fase |
| **SSH** (opcional) | Operador pede "executar via SSH" no início (ou por fase) | Skill usa o MCP `ssh-manager` (sessão persistente via `ssh_session_start`, execução de comandos na sessão, `ssh_upload` para scripts locais, `ssh_health_check`/`ssh_service_status` para diagnósticos) |

**Regras do modo SSH (obrigatórias):**
- Confirmação **por fase** — apresente os comandos da fase e espere o OK do
  operador antes de executar (nunca encadeie fases sem aprovação)
- Correções destrutivas (`kill -9`, `docker compose down`, remoção de
  service systemd) exigem confirmação explícita MESMO no modo SSH
- **Segredos**: nunca passar PAT/chave privada/token por comando com eco no
  output — preferir `--password-stdin` via stdin e orientar o operador
- Antes de executar: listar servers configurados (`ssh_list_servers`) e
  confirmar qual server/VPS é o alvo — nunca assumir por omissão
- Saída de cada comando é validada contra o critério da fase antes de
  avançar (mesma validação do modo guiado, sem colar output manual)
- Se o `ssh-manager` não tiver o server configurado, oriente o cadastro e
  **caia para o modo guiado** — a skill não edita a config do MCP

## Nunca edita

- Qualquer arquivo na VPS no modo guiado (default) — comandos são apenas
  sugeridos; no modo SSH, executar EXCLUSIVAMENTE comandos aprovados pelo
  operador fase a fase (nunca scripts de mutação em massa)
- Artefatos de módulo RDD (REQUIREMENTS, DATA_MODEL, etc.)
- Config do OpenCode (`~/.config/opencode/**`) — isso é papel do `rdd-setup`
- Segredos: nunca pedir/solicitar que o operador cole PAT, chave privada
  ou token no chat — orientar uso de `--password-stdin`, secrets do GitHub
  e arquivos locais

## Tools

- `read` (pack da org, scripts do repo do projeto)
- `glob` / `grep` (localizar scripts e compose do projeto no repo local)
- `question` (coletar contexto do servidor e confirmar cada fase)
- `bash` (apenas leitura local — verificar existência de scripts)
- MCP `ssh-manager` (APENAS no modo SSH opcional — sessão/comandos na VPS
  com confirmação por fase; ver seção "Modos de execução")

## Modo de erro

`warn` — fase que não pôde ser confirmada (comando falhou, output não
disponível) não bloqueia as seguintes: fica marcada ⚠️ no checklist e no
relatório final, com orientação de correção. Só é `strict` na regra de
segurança: **tunnel Cloudflare exclusivo por servidor** — se o operador
propuser reaproveitar tunnel existente de outro servidor, aborte a fase
com explicação da lição aprendida (balanceamento entre conectores cai no
servidor errado).

## Formato de commit

```
docs(opencode): atualiza pack de infra da organização
```

## Algoritmo (fases sequenciais)

Contexto: pergunte **uma vez** (question agrupada, IMP-043) no início:
nome do servidor, projeto/repo da API, hostname público desejado
(`<algo>.<dns_domain do perfil>`), porta local da API e arquitetura
(x86_64/amd64 ou ARM/aarch64-Graviton). Depois, execute as fases em ordem,
confirmando a conclusão de cada uma antes de seguir (o operador cola o
output; a skill valida contra o critério da fase).

### Fase 1 — Setup inicial do sistema

1. `sudo yum update -y` (AL2023 sem yum → `sudo dnf update -y`; adapte ao
   `infra_os` do perfil — Amazon Linux, Debian/Ubuntu, etc. seguem o
   equivalente do pack §infra-vps-setup)
2. `sudo yum install -y git wget nano unzip` + confirmar `git --version`
3. **Caveat curl-minimal (AL2023):** NÃO instalar o pacote `curl` — o
   `curl-minimal` pré-instalado basta e instalar o completo gera conflito
   de dependências. Se realmente precisar do completo:
   `sudo yum install -y curl --allowerasing`. Critério: `curl --version` OK.
4. Git config: `git config --global user.name "<Nome do Servidor>"` e
   `user.email "<deploy_email do perfil>"` (ex.: `deploy@<dns_domain do perfil>`).
5. Chave SSH de deploy: `ssh-keygen -t ed25519 -C "<deploy_email do perfil>"`
   **sem passphrase** (script automatizado não tem terminal interativo).
   Se a VPS já tem chave para outro fim (ex: SSH-action), gerar chave
   **separada** — GitHub não aceita a mesma pública em dois lugares.

### Fase 2 — Docker, Compose plugin e Buildx

1. `sudo yum install -y docker` → `sudo systemctl enable --now docker` →
   confirmar `active (running)` e `docker --version`.
2. Grupo docker: `sudo usermod -aG docker $USER` + `newgrp docker` →
   `groups` deve listar `docker`.
3. Compose plugin: `mkdir -p ~/.docker/cli-plugins`, resolver URL do
   release mais recente via API do GitHub (nunca link fixo), baixar
   `docker-compose` (binário `linux-x86_64` ou `linux-aarch64` conforme a
   arquitetura), `chmod +x`. Critério: `docker compose version` OK
   (sintaxe `docker compose`, sem hífen).
4. Buildx: mesmo padrão (`docker-buildx` no cli-plugins). Critério:
   `docker buildx version` OK.

### Fase 3 — Permissões de scripts

`chmod +x scripts/deploy.sh` (ou recursivo:
`find scripts/ -type f -name "*.sh" -exec chmod +x {} \;`). Critério:
`test -x scripts/deploy.sh && echo OK`. `ls -Z` com `user_home_t` é normal
(SELinux não bloqueia execução nesse contexto).

### Fase 4 — Autenticação no registry do perfil (ex.: ghcr.io)

1. `echo <PAT> | docker login <ghcr_registry> -u <usuario> --password-stdin`
   (PAT com escopo `read:packages` no classic; permissão de leitura de
   Packages no fine-grained). O token é colado direto no terminal da VPS —
   **nunca** no chat.
2. Validar com `docker compose -f docker-compose.prod.yml pull` antes do `up`.
3. Pacote privado dando erro mesmo com repo público? Checar a
   **visibilidade do pacote** separadamente da visibilidade do repo
   (`github.com/orgs/<org>/packages` → Package settings → Manage access) —
   são configurações independentes.

### Fase 5 — Git via SSH (deploy keys)

1. `git remote -v` — se `https://github.com/...`, trocar:
   `git remote set-url origin git@github.com:<ORG>/<REPO>.git`
   (**dois-pontos** depois de `github.com`, não barra).
2. Cadastrar a pública da Fase 1 como **Deploy Key** do repo
   (Settings → Deploy keys → acesso somente leitura basta para `git pull`).
3. Testar: `ssh -T git@github.com` e `git pull` manual ANTES de depender
   do script automatizado.

### Fase 6 — Chave SSH do GitHub Actions (appleboy/ssh-action)

1. Gerar chave **dedicada** (diferente da deploy key da Fase 5):
   `ssh-keygen -t ed25519 -f ~/.ssh/deploy_action_key`.
2. Pública (`deploy_action_key.pub`) em `~/.ssh/authorized_keys` da VPS;
   privada no secret do workflow (`SSH_PRIVATE_KEY`/`INPUT_KEY`).
3. Permissões: `chmod 700 ~/.ssh` e `chmod 600 ~/.ssh/authorized_keys`.
4. Testar manualmente fora do Action:
   `ssh -i <chave> <usuario>@<IP_DA_VPS>` — conecta na mão mas falha no
   workflow → problema no secret (colado errado), não na VPS.

### Fase 7 — Tunnel Cloudflare EXCLUSIVO por servidor

> **Lição aprendida (regra strict desta skill):** NUNCA compartilhar o
> mesmo tunnel entre servidores — o Cloudflare balanceia entre todos os
> conectores do tunnel e requisições caem no servidor errado (causou
> indisponibilidade em produção). Um tunnel por servidor, sempre.

1. `cloudflared tunnel login` (uma vez por servidor; gera
   `~/.cloudflared/cert.pem`).
2. `cloudflared tunnel create <nome-do-servidor>`.
3. Editar `~/.cloudflared/config.yml`: um `ingress` por hostname apontando
   para o serviço local correto (ex: `http://localhost:8082`); SEMPRE
   terminar com `- service: http_status:404` (catch-all).
4. `cloudflared tunnel route dns <nome-do-servidor> <hostname>.<dns_domain
   do perfil>` (uma vez por hostname).
5. Teste manual: `cloudflared tunnel run <nome-do-servidor>` antes de
   virar serviço. Critério: `curl -I https://<hostname>.<dns_domain do
   perfil>/health` responde.

### Fase 8 — Tunnels como serviço systemd (autostart)

1. **Antes de rodar** `./scripts/setup-cloudflare-autostart.sh`: revisar
   as variáveis no topo do script (hostname do túnel TCP do banco etc.) —
   hostname errado só é percebido depois no `ExecStart` do
   `systemctl status`.
2. Rodar o script. Ele cria os services (tunnel HTTP + túnel TCP do
   banco), `enable` + `restart`. **O nome exibido no resumo final é o nome
   real do service** — usar exatamente esse valor.
3. Validar: `sudo systemctl status <service>` ativo.

### Fase 9 — Logging do cloudflared com rotação

`sudo ./scripts/setup-cloudflared-logging.sh` — **precisa de `sudo`**
(edita `ExecStart` em `/etc/systemd/system/`; `chmod +x` no script não
resolve — o problema é permissão de escrita em pasta do sistema). Atenção:
o script instala auxiliares em `~/scripts/` (home do usuário), que é
diferente da pasta `scripts/` do repositório do projeto — criar
`mkdir -p ~/scripts` se o script não fizer isso sozinho.

### Fase 10 — Validação do pipeline de deploy

Fluxo alvo (nenhum comando manual depois de configurado):

```
push main → deploy.yml dispara → build da imagem → push pro registry do perfil
           → deploy via SSH (appleboy/ssh-action) → scripts/deploy.sh roda
             na VPS (git pull + docker compose pull/up)
```

Validar com um push de teste e acompanhar: run do Action verde +
`docker ps` mostrando o container `(healthy)`.

### Fase 11 — Backup automatizado (RClone + cronie + canal de alerta do perfil)

1. `sudo yum install -y cronie` → `systemctl enable crond` → `start crond`
   (Amazon Linux não vem com cron por padrão).
2. Se o RClone foi configurado como `root`: copiar
   `/root/.config/rclone/rclone.conf` para `~/.config/rclone/` e
   `chown <usuario>` — os scripts de backup rodam como o usuário de deploy
   via cron do usuário, senão o remote não é enxergado.
3. `./scripts/setup-backup.sh` — **sem `sudo`** (diferente do script de
   logging da Fase 9): instala RClone, configura remote (OAuth),
   valida o canal de alerta (`alert_channel` do perfil — receita Telegram
   validada no pack §infra-vps-setup item 11), agenda cron diário (03:00).
4. Testar: `rclone lsd <remote>:` (autenticação) e `./scripts/backup_db.sh`
   (execução manual ponta a ponta) antes de confiar no cron.

### Fase 12 — Relatório final

Checklist das 11 fases com estado ✅/⚠️, os nomes reais dos services
systemd criados, o hostname/tunnel configurado e pendências. Se algo
falhou em produção depois, rotear para `rdd-vps-troubleshoot`.

## Template de saída

```text
═══ rdd-vps-setup — <RESULTADO> ═══

Servidor: <nome> | Projeto: <repo> | Hostname: <algo>.<dns_domain do perfil>
Arquitetura: x86_64 | Tunnel: <nome-do-tunnel> (exclusivo)

| Fase | Item | Estado |
|------|------|--------|
| 1 | yum update + git + curl-minimal OK | ✅ |
| 2 | Docker 24.x + compose + buildx | ✅ |
...

⚠️ Pendências: <lista ou nenhuma>
Próximo passo: push de teste para validar o pipeline (Fase 10).
```

## Casos de Borda

- **VPS já partially configurada**: pule fases confirmadas (idempotente
  no diagnóstico — valide o critério antes de sugerir o comando).
- **ARM/Graviton**: trocar `linux-x86_64`/`linux-amd64` por
  `linux-aarch64`/`linux-arm64` nos downloads de compose/buildx.
- **AL2023 sem yum**: usar `dnf` equivalente.
- **Operador propõe reaproveitar tunnel de outro servidor**: abortar a
  Fase 7 com a lição aprendida (regra strict) — criar tunnel novo.
- **Re-execução do autostart script** (correção de nome/hostname): o
  script cria o service novo mas NÃO remove o antigo — seguir com a
  seção de services duplicados do `rdd-vps-troubleshoot`.
- **Secret do Action com chave colada errada**: gerar chave nova dedicada
  em vez de debugar o secret antigo (mais rápido e mais seguro).
- **Organização sem pack (`rules/<pack-da-organizacao>.md` ausente)**: as fases são
  neutras — derive OS/registry/domínio/canal do perfil; lições novas de
  produção devem nascer no pack da org (proponha criá-lo via
  rdd-workflow-builder).
- **Novo sintoma/lição em produção**: registrar no pack da organização
  (`rules/<pack-da-organizacao>.md` §infra — com confirmação do operador) ou via
  `rdd-workflow-improver`.