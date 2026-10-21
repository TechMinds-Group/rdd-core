═══ rdd-vps-setup — PLANO GUIADO (modo não-interativo — eval baseline) ═══

Servidor: nimbus | Projeto: Nimbus-API (Acme-Group) | Hostname: nimbus.acme.example
Arquitetura: x86_64 | Tunnel: nimbus-server (EXCLUSIVO deste servidor)
Porta local da API: 8080

Plano de setup em 12 fases — comandos sugeridos; o operador executa na VPS
e cola o output para validação de cada fase.

── Fase 1 — Setup inicial do sistema ──

1. `sudo yum update -y` (AL2023: usar `dnf` se `yum` não existir)
2. `sudo yum install -y git wget nano unzip` → confirmar `git --version`
3. **Caveat curl-minimal (AL2023):** NÃO instalar o pacote `curl` — o
   `curl-minimal` pré-instalado basta (fornece o mesmo binário); instalar o
   completo gera conflito de dependências
   (`conflicts with curl provided by...`). Se realmente necessário:
   `sudo yum install -y curl --allowerasing`. Critério: `curl --version` OK.
4. `git config --global user.name "nimbus"` +
   `git config --global user.email "deploy@acme.example"`
5. Chave SSH de deploy (SEM passphrase — script automatizado não tem
   terminal interativo):
   `ssh-keygen -t ed25519 -C "deploy@acme.example"`
   `cat ~/.ssh/id_ed25519.pub` → cadastrar como Deploy Key no repo
   Nimbus-API (Fase 5). Chave separada da que o GitHub Actions usar.

── Fase 2 — Docker, Compose plugin e Buildx ──

1. `sudo yum install -y docker` → `sudo systemctl enable --now docker` →
   `sudo systemctl status docker` (active (running)) → `docker --version`
2. Grupo docker: `sudo usermod -aG docker $USER` + `newgrp docker` →
   `groups` deve listar `docker`
3. Compose plugin (arquitetura x86_64 → `linux-x86_64`):
   ```bash
   mkdir -p ~/.docker/cli-plugins
   COMPOSE_URL=$(curl -s https://api.github.com/repos/docker/compose/releases/latest \
     | grep "browser_download_url" | grep "linux-x86_64\"" | cut -d '"' -f 4)
   curl -SL "$COMPOSE_URL" -o ~/.docker/cli-plugins/docker-compose
   chmod +x ~/.docker/cli-plugins/docker-compose
   ```
   Critério: `docker compose version` OK (sintaxe `docker compose`, sem hífen)
4. Buildx (mesmo padrão, `linux-amd64`):
   ```bash
   BUILDX_URL=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest \
     | grep "browser_download_url" | grep "linux-amd64\"" | cut -d '"' -f 4)
   curl -SL "$BUILDX_URL" -o ~/.docker/cli-plugins/docker-buildx
   chmod +x ~/.docker/cli-plugins/docker-buildx
   ```
   Critério: `docker buildx version` OK

── Fase 3 — Permissões de scripts ──

`chmod +x scripts/deploy.sh` (recursivo:
`find scripts/ -type f -name "*.sh" -exec chmod +x {} \;`)
Critério: `test -x scripts/deploy.sh && echo OK`.
`ls -Z scripts/deploy.sh` com `user_home_t` é normal (SELinux não bloqueia).

── Fase 4 — Autenticação GHCR (ghcr.io) ──

1. No terminal da VPS (NUNCA no chat): `echo <PAT> | docker login ghcr.io -u <usuario> --password-stdin`
   (PAT classic com escopo `read:packages`; fine-grained: permissão de
   leitura em Packages)
2. Validar antes do up: `docker compose -f docker-compose.prod.yml pull`
3. Pacote privado dando erro mesmo com repo público? Visibilidade do
   **pacote** é independente da visibilidade do repo
   (`github.com/orgs/Acme-Group/packages` → Package settings →
   Manage access)

── Fase 5 — Git via SSH (deploy keys) ──

1. `git remote -v` — se `https://github.com/...`:
   `git remote set-url origin git@github.com:Acme-Group/Nimbus-API.git`
   (**dois-pontos** depois de github.com, não barra)
2. Deploy Key: pública da Fase 1 em Settings → Deploy keys (leitura basta)
3. Testar: `ssh -T git@github.com` e `git pull` manual antes do pipeline

── Fase 6 — Chave SSH do GitHub Actions (appleboy/ssh-action) ──

1. Chave DEDICADA (≠ deploy key da Fase 5):
   `ssh-keygen -t ed25519 -f ~/.ssh/deploy_action_key`
2. `deploy_action_key.pub` em `~/.ssh/authorized_keys`; privada no secret
   do workflow (`SSH_PRIVATE_KEY`/`INPUT_KEY`)
3. `chmod 700 ~/.ssh` + `chmod 600 ~/.ssh/authorized_keys`
4. Teste manual: `ssh -i ~/.ssh/deploy_action_key <usuario>@<IP>` —
   conecta na mão mas falha no Action → secret colado errado (gerar chave
   nova em vez de debugar o secret)

── Fase 7 — Tunnel Cloudflare EXCLUSIVO por servidor ⛔ regra strict ──

> LIÇÃO APRENDIDA: NUNCA compartilhar o mesmo tunnel entre servidores —
> o Cloudflare balanceia entre todos os conectores do tunnel e requisições
> caem no servidor errado (causou indisponibilidade em produção).
> Tunnel `nimbus-server` exclusivo, sempre.

1. `cloudflared tunnel login` (gera `~/.cloudflared/cert.pem`)
2. `cloudflared tunnel create nimbus-server`
3. `~/.cloudflared/config.yml` — ingress:
   ```yaml
   ingress:
     - hostname: nimbus.acme.example
       service: http://localhost:8080
     - service: http_status:404
   ```
4. `cloudflared tunnel route dns nimbus-server nimbus.acme.example`
5. Teste: `cloudflared tunnel run nimbus-server` →
   `curl -I https://nimbus.acme.example/health`

── Fase 8 — Tunnels como serviço systemd (autostart) ──

1. **Antes de rodar** `./scripts/setup-cloudflare-autostart.sh`: revisar
   as variáveis no topo (hostname do túnel TCP do banco) — hostname errado
   só aparece depois no `ExecStart` do `systemctl status`
2. Rodar o script → cria services (tunnel HTTP + túnel TCP do banco) com
   `enable` + `restart`. O nome exibido no resumo final é o nome REAL do
   service (ex: `nimbus-cloudflare-tunnel.service`,
   `nimbus-cloudflare-database.service`)
3. Validar: `sudo systemctl status <service>`

── Fase 9 — Logging do cloudflared com rotação ──

`sudo ./scripts/setup-cloudflared-logging.sh` — **precisa de `sudo`**
(edita `ExecStart` em `/etc/systemd/system/`; `chmod +x` no script não
resolve — o problema é permissão de ESCRITA em pasta do sistema).
Atenção: auxiliares vão em `~/scripts/` (home), não na pasta `scripts/`
do repo — `mkdir -p ~/scripts` se o script não criar.

── Fase 10 — Validação do pipeline de deploy ──

Fluxo alvo (zero comandos manuais depois de configurado):

```
push main → deploy.yml dispara → build da imagem → push pro ghcr.io
           → deploy via SSH (appleboy/ssh-action) → scripts/deploy.sh roda
             na VPS (git pull + docker compose pull/up)
```

Validar com push de teste: run do Action verde + `docker ps` com
`(healthy)`.

── Fase 11 — Backup automatizado (RClone + cronie + Telegram) ──

1. `sudo yum install -y cronie` → `sudo systemctl enable crond` →
   `sudo systemctl start crond` (Amazon Linux não vem com cron)
2. RClone configurado como root? Copiar e ajustar dono:
   ```bash
   mkdir -p ~/.config/rclone
   sudo cp /root/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf
   sudo chown ec2-user:ec2-user ~/.config/rclone/rclone.conf
   ```
3. `./scripts/setup-backup.sh` — **SEM `sudo`** (≠ Fase 9): instala RClone,
   configura remote `gdrive` (OAuth), valida Telegram, agenda cron diário
   (03:00)
4. Testar: `rclone lsd gdrive:` + `./scripts/backup_db.sh` manual antes de
   confiar no cron

── Fase 12 — Relatório final ──

Checklist preenchido conforme o operador confirma cada fase (✅/⚠️), com
nomes reais dos services systemd, hostname/tunnel e pendências. Falha em
produção depois? → `rdd-vps-troubleshoot`.

⚠️ Pendências: nenhuma no plano — validação por fase aguarda execução do
operador na VPS.
Próximo passo: Fase 1 (`sudo yum update -y`) e colar o output aqui.
