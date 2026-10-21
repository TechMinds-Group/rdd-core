# Runbook — Diagnóstico de VPS (por sintoma)

> Base de conhecimento da skill `rdd-vps-troubleshoot` — sintomas genéricos
> de deploy em VPS. Lições de produção e valores da organização (OS, domínio,
> registry, canal) no pack `rules/<pack-da-organizacao>.md` (IMP-105). Setup inicial de
> VPS nova: pack §infra-vps-setup (ex-runbook da skill irmã `rdd-vps-setup`).

## S1 — Container não fica `healthy` após o deploy

Sintoma: `docker ps` mostra `(unhealthy)` ou o `deploy.sh` expira
esperando o healthcheck (`💔 Container is not healthy`) e faz rollback,
mesmo com a aplicação subindo sem erro nos logs.

Ordem de verificação:

```bash
docker logs -f nome_do_container
```
Primeiro passo sempre — confirma se a aplicação terminou de subir
(`Application started`) ou travou/crashou antes.

```bash
docker ps
```
Verifica a porta em que o container de fato escuta (coluna PORTS) —
comparar com a porta do `healthcheck` do `docker-compose.prod.yml`. É
comum a env (`URLS`, `ASPNETCORE_URLS`, `HTTP_PORTS`) sobrescrever a porta
padrão da imagem e divergir do healthcheck.

```bash
curl -i http://localhost:<porta>/health
```
**Sempre com `-i`** para ver o status HTTP:
- `404 Not Found` → conectou, mas a rota não existe na app (conferir
  `MapHealthChecks`/`AddHealthChecks`, ou variações `/healthz`,
  `/api/health`).
- `connection refused` → porta do healthcheck errada.

## S2 — GHCR: `denied` / `unauthorized` no pull

```bash
echo SEU_TOKEN | docker login ghcr.io -u SEU_USUARIO_GITHUB --password-stdin
docker compose -f docker-compose.prod.yml pull     # validar antes do up
```

- PAT com `read:packages` (classic) ou leitura de Packages (fine-grained).
- Pacote privado mas repo público? **Visibilidade do pacote é
  independente da visibilidade do repo** — `github.com/orgs/<org>/packages`
  → `<pacote>` → Package settings → Manage access.

## S3 — `fatal: could not read Username for 'https://github.com': No such device or address`

Causa: remote em HTTPS; `deploy.sh` roda `git pull` dentro de Action sem
terminal interativo.

```bash
git remote -v                                            # https:// = causa
git remote set-url origin git@github.com:ORG/REPO.git    # DOIS-PONTOS
```

Depois de `github.com` é `:` — `git@github.com/ORG/REPO.git` é inválido e
dá `does not appear to be a git repository`.

Deploy key cadastrada no repo (Settings → Deploy keys, leitura basta).
Testar: `ssh -T git@github.com` e `git pull` manual.

## S4 — `ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain`

appleboy/ssh-action. Esta chave é a que a Action usa para entrar na VPS —
diferente da Deploy Key do git. Ordem de verificação:

```bash
cat ~/.ssh/authorized_keys
```
Confirma se a pública correspondente ao secret `INPUT_KEY`/
`SSH_PRIVATE_KEY` ainda está autorizada.

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```
Permissões erradas em `~/.ssh` derrubam a autenticação por chave.

```bash
ssh -i caminho/da/chave_privada usuario@IP_DA_VPS
```
Conecta na mão mas falha no workflow → problema no secret (colado errado),
não na VPS.

## S5 — `ssh.ParsePrivateKey: ssh: no key found`

O conteúdo do secret não é chave privada válida:
- Secret tem `-----BEGIN ... PRIVATE KEY-----` e `-----END ...` completos,
  sem espaços/linhas extras.
- Nome do secret no workflow (`${{ secrets.NOME }}`) bate exatamente com o
  cadastrado (case-sensitive).
- Em dúvida, gerar chave nova dedicada:
  `ssh-keygen -t ed25519 -f ~/.ssh/deploy_action_key` → privada no secret,
  `.pub` no `authorized_keys`.

## S6 — Services systemd duplicados/errados (cloudflared)

Cenário típico: re-execução do `setup-cloudflare-autostart.sh` após
correção de nome/hostname — cria o service novo mas NÃO remove o antigo;
os dois brigam pela mesma função (`activating (auto-restart)`).

```bash
systemctl list-units --all | grep -i cloudflare
```
Lista todos — achar duplicatas com nomes divergentes.

```bash
sudo systemctl stop <service1> <service2>
sudo systemctl disable <service1> <service2>
sudo rm -f /etc/systemd/system/<service1>
sudo rm -f /etc/systemd/system/<service2>
sudo systemctl daemon-reload
sudo systemctl reset-failed
```

**Rodar um comando por vez** — colar a explicação junto com o comando
(crases, "e depois") quebra o shell.

```bash
ps aux | grep cloudflared
```
Confirma que não sobrou processo `cloudflared` órfão fora do systemd.

## S7 — Requisições caindo no servidor errado

> **Lição aprendida:** NÃO compartilhar o mesmo tunnel entre servidores —
> o Cloudflare balanceia entre todos os conectores do mesmo tunnel; com
> apps diferentes no `config.yml` de cada servidor, requisições caem
> aleatoriamente no servidor errado (causou indisponibilidade).

Correção: tunnel **exclusivo por servidor** (`cloudflared tunnel create
<nome-do-servidor>` + route dns por hostname) — Fase 7 da
`rdd-vps-setup`. Migrar os hostnames do servidor para o tunnel novo.

## S8 — Conflito de porta / processo órfão / diagnóstico genérico

```bash
sudo lsof -i :5432
```
Acha o processo ocupando a porta (caso real: `cloudflared` travado
brigando com o Postgres do Docker).

```bash
kill <PID>
sudo kill -9 <PID>        # força, se o primeiro não resolver
```

Ciclo de vida do compose (atenção à ordem dos argumentos — `-d` é flag do
`up`, não do `docker compose`):

```bash
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml stop
docker compose -f docker-compose.prod.yml down    # remove containers+rede, mantém volumes
docker ps                                          # primeiro comando quando algo não sobe
```

Diagnóstico de conectividade (isolar camada app vs tunnel vs DNS):

```bash
curl -i http://localhost:<porta>/health                    # dentro: isola o tunnel
curl -I https://<hostname>.<dns_domain do perfil>/health     # fora: ponta a ponta
sudo ss -tlnp | grep <porta>                               # algo escutando?
nc -zv localhost <porta>
```

## S9 — Banco vazio / migrations não aplicadas

```bash
docker exec <projeto>_postgres_prod psql -U admin -d <db> -c "\dt"
```

`Did not find any relations` = banco subiu vazio e as **migrations não
foram aplicadas** — comum logo após o primeiro deploy com volume novo. O
Compose só garante o Postgres no ar, não o schema: verificar se a app roda
migrations no startup (`dotnet ef database update` embutido no
`Program.cs` ou equivalente) ou rodá-las manualmente.

## S10 — Backup/cron não roda

```bash
sudo systemctl status crond          # cronie instalado e ativo?
rclone lsd gdrive:                   # autenticação visível para o USUÁRIO?
```

RClone configurado como root → config em `/root/.config/rclone/`; os
scripts de backup rodam como `ec2-user` (cron do usuário). Corrigir:

```bash
mkdir -p ~/.config/rclone
sudo cp /root/.config/rclone/rclone.conf ~/.config/rclone/rclone.conf
sudo chown ec2-user:ec2-user ~/.config/rclone/rclone.conf
```

Teste manual antes do agendamento: `./scripts/backup_db.sh`.

## S11 — Logs (todas as causas)

```bash
sudo journalctl -u <service> -f                # tempo real; precheck status=pass = túnel saudável
sudo journalctl -u <service> -f -n 100
sudo journalctl -u <service> -t
sudo journalctl -u <service> --since "1 hour ago"
sudo journalctl -u <service1> -u <service2> -f

docker logs -f nome_do_container
docker logs -f --tail 100 nome_do_container
docker logs --since 2026-09-02T20:00:00 --until 2026-09-02T20:30:00 nome_do_container
```

Logging do cloudflared com rotação: `sudo ./scripts/setup-cloudflared-logging.sh`
(precisa de `sudo` — edita `ExecStart` em `/etc/systemd/system/`; auxiliares
vão para `~/scripts/`, home do usuário, não a pasta `scripts/` do repo).