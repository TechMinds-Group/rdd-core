---
name: rdd-cicd-workflow
description: >-
  Cria e mantém o pipeline de deploy GitHub Actions dos repos de produto da
  organização (deploy.yml): build da imagem → push para o registry do perfil
  (ex.: ghcr.io/<org>) → deploy via appleboy/ssh-action → scripts/deploy.sh
  na VPS (git pull + docker compose pull/up). Dois modos: gerar workflow novo
  para repo sem CI/CD e auditar/diagnosticar workflow existente com sintomas
  conhecidos (secret SSH errado, chave deploy_action_key trocada com a Deploy
  Key, registry denied no push, nome de secret case-sensitive, workflow
  silenciosamente não disparando). Base de conhecimento validada: pack da
  organização em `rules/<pack-da-organizacao>.md` §infra-cicd (IMP-105). Use quando o
  usuário pedir "criar pipeline de deploy", "deploy.yml", "github actions
  de deploy", "workflow de deploy", "CI/CD do repo", "pipeline não dispara"
  ou "auditar workflow de deploy".
---
# rdd-cicd-workflow — Pipeline de Deploy GitHub Actions

Cria o `deploy.yml` padrão da organização em repos de produto
(`<PROJETO>-API`, `-FE`, etc., branch `main`) e audita workflows existentes
contra os padrões validados em produção. **Base de conhecimento validada:
pack `rules/<pack-da-organizacao>.md` §infra-cicd** (IMP-105) — template do deploy.yml,
tabela de secrets e matriz de diagnóstico por sintoma. Org/registry/hostnames
vêm do `rules/client-profile.md` (`org_github`, `ghcr_registry`); para outra
organização, derive os valores do perfil da org.

## Diferenciação

| Skill | Escopo |
|-------|--------|
| `rdd-cicd-workflow` (esta) | O arquivo de workflow no **repo** (deploy.yml, secrets do GitHub, gatilhos, audit) |
| `rdd-vps-setup` | A infra **na VPS** que o workflow consome (deploy key, chave SSH da action, registry login, tunnel) |
| `rdd-vps-troubleshoot` | Sintomas **na VPS** depois que o deploy rodou (unhealthy, porta, banco vazio) |
| `rdd-gh-setup` | gh CLI na máquina local — autenticação, não workflows |

Regra de fronteira: se o workflow nem disparou ou falhou no build/push/SSH,
é esta skill; se o deploy.sh rodou e o container ficou doente na VPS, é a
`rdd-vps-troubleshoot`.

## Lê (upstream)

- `rules/client-profile.md` (IMP-103/IMP-105) — `org_github`,
  `ghcr_registry`, `dns_domain` (hostnames de validação)
- Pack da organização (`rules/<pack-da-organizacao>.md` §infra-cicd; IMP-105) —
  template validado do workflow, tabela de secrets e matriz de
  diagnóstico por sintoma
- O repo alvo (local): existência de `Dockerfile`, `docker-compose.prod.yml`,
  `scripts/deploy.sh`, estrutura do projeto — para adaptar o template
- `gh` CLI para secrets existentes: `gh secret list -R <org>/<repo>`
  (lista NOMES apenas — nunca valor)

## Gera (downstream)

- `.github/workflows/deploy.yml` no repo alvo (escrito com confirmação prévia
  do operador — dry-run mostrando o YAML antes de gravar)
- Checklist de secrets a cadastrar no GitHub (nomes + onde obter o valor —
  nunca o valor em si no chat)
- Relatório de auditoria (modo diagnóstico): causa raiz + correção por sintoma

## Fluxo de Trabalho

### Modo 1 — Gerar workflow novo

1. **Inventário do repo:** confirmar Dockerfile, compose de produção e
   `scripts/deploy.sh` (executável na VPS). Se deploy.sh não existir,
   orientar criação seguindo o padrão do pack §infra-cicd item 3
   (git pull + compose pull/up) ANTES do workflow — o workflow assume
   deploy.sh presente.
2. **Coletar contexto (uma `question` agrupada):** org/repo (`org_github`
   do perfil como default), servidor VPS de destino (host, user, porta),
   nome do serviço no compose, branch de deploy (padrão `main`),
   registry de imagens (`ghcr_registry` do perfil; ex.: `ghcr.io/<org>`).
3. **Gerar deploy.yml** a partir do template do pack (§infra-cicd item 1)
   — tags da imagem `<ghcr_registry>/<projeto>:latest` — dry-run: mostrar
   o YAML completo e o checklist de secrets (`SSH_HOST`, `SSH_USERNAME`,
   `SSH_PRIVATE_KEY`, token do registry com `write:packages`).
4. **Confirmar** → gravar `.github/workflows/deploy.yml`.
5. **Validar ponta a ponta:** push de teste → rodada da Action → `docker ps`
   na VPS mostrando o container `(healthy)` (o operador cola o output).

### Modo 2 — Auditar workflow existente

1. Ler o `deploy.yml` do repo e `gh secret list` (nomes apenas).
2. Triar pela matriz de sintomas do pack (§infra-cicd item 5):
   - Action nem dispara → trigger/path/filial errada ou workflow desabilitado
   - Falha no SSH (handshake, ParsePrivateKey) → secret `SSH_PRIVATE_KEY`
     truncado ou sem BEGIN/END; chave trocada com a Deploy Key da VPS
   - Conecta na mão mas falha no workflow → secret colado errado, não a VPS
   - `denied` no push do registry → token sem `write:packages` / permissão
     do pacote
   - Deploy roda mas nada muda → deploy.sh não executável ou compose errado
3. Corretivas que alteram o workflow ou secrets: mostrar diff/explicação e
   confirmar antes de aplicar.

## Nunca edita

- `scripts/deploy.sh` na VPS (remoto) — orientar o operador; edição local de
  deploy.sh no repo só com confirmação explícita
- Valor de secrets — nunca imprimir, logar ou commitar token/chave privada
- Workflows de outros repos fora do alvo confirmado

## Tools disponíveis

- `read`, `glob`, `grep` — inventário do repo, leitura de workflows e do pack
- `write`/`edit` — criar/atualizar `.github/workflows/deploy.yml` (com confirmação)
- `bash` — apenas `gh` local de leitura (`gh secret list`, `gh run list`)
- `question` — coleta de contexto e confirmações
- `websearch`/`webfetch` — versões de actions (appleboy/ssh-action) quando necessário

## Modo de erro

- Repo sem Dockerfile → ABORTAR modo 1 com orientação (workflow sem imagem
  para build não faz sentido; sugerir rdd-dev para criar o Dockerfile)
- `gh` não autenticado → encaminhar `rdd-gh-setup` e parar
- Servidor de destino indefinido → não gerar workflow com placeholder de host
- Perfil sem `ghcr_registry`/`org_github` → pergunte ao operador (uma
  `question` agrupada) antes de gerar o workflow — nunca assuma org

## Casos de borda

- Repo FE sem Docker (build estático) → workflow de build+deploy de artefatos
  só se houver padrão validado no pack §infra-cicd; senão sinalizar como gap
- Monorepo multi-serviço → um job de deploy por serviço, secrets compartilhados
- Operador pede deploy em push de tag → aceitável, documentar no workflow
- Workflow com actions de terceiros desconhecidas → auditar pinning por SHA
  e sinalizar, não reescrever por gosto
- Organização sem pack (`rules/<pack-da-organizacao>.md` ausente) → derive o template
  do §infra-cicd adaptando registry/org para o perfil; lições de produção
  novas devem nascer no pack da org (proponha criá-lo via rdd-workflow-builder)

## Formato de commit

`ci(<repo>): adiciona/ajusta pipeline de deploy (build → registry → ssh-action)`