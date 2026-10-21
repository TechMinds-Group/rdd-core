---
name: rdd-gh-setup
description: >-
  Wizard de configuração da GitHub CLI (gh) para o workflow RDD — verifica
  instalação, autentica via gh auth login e valida o acesso à org GitHub do
  perfil (`org_github` em `rules/client-profile.md` — IMP-103/IMP-105).
  Idempotente e executado por demanda; delegado pelo
  rdd-setup. Use quando o usuário pedir "configurar gh", "setup do gh",
  "autenticar github cli", "instalar gh" ou "onboarding github".
---
# rdd-gh-setup — Wizard de Configuração da GitHub CLI

Setup da `gh` CLI numa máquina: garante instalação, autenticação e
acesso à org GitHub do perfil (`org_github`). Pré-condição das skills `rdd-gh-issue-creator`
e `rdd-gh-pr-creator` (e do `@rdd-github-orchestrator`). Idempotente —
pode ser reexecutado; passos já completos são pulados.

## Contexto do problema que resolve

O ecossistema GitHub do RDD depende da `gh` CLI instalada e autenticada,
mas não havia skill de setup: o `rdd-gh-issue-creator`/`rdd-gh-pr-creator`
apenas abortavam com "orientar `gh auth login`", e o `rdd-setup` não
validava `gh` no Passo 6 nem delegava para um setup de GitHub.

## Lê (upstream)

- Saída de `gh --version` — instalação presente?
- Saída de `gh auth status` — autenticação ativa? org atual?

## Gera (downstream)

- Relatório textual de validação (não persiste arquivo)
- Estado autenticado da `gh` CLI (efeito colateral: `gh auth login`)

## Nunca edita

- Agentes e skills versionados (`agents/rdd-*.md`, `skills/rdd-*/SKILL.md`)
- Artefatos de módulo RDD (REQUIREMENTS, TASKS, etc.)
- `AGENTS.md` / `opencode.jsonc` — este setup não toca a config do OpenCode
- Remote — nunca commita nem push

## Tools

- `bash` (validação: `gh --version`, `gh auth status`; `gh auth login` é interativo)
- `question` (perguntar se deseja instalar/autenticar quando ausente)
- `read` (opcional: ler bloco `<!-- repositorios -->` no AGENTS.md para contexto de org)

## Modo de erro

`warn` — validações que falharem não bloqueiam a conclusão do wizard:
entram no relatório como ⚠️ com orientação de correção. Só é `strict`
na validação final mínima (sem `gh` instalada, reporta falha clara e
orienta instalação antes de encerrar).

## Formato de commit

Nenhum — este wizard não edita artefatos versionados e nunca commita.

## Algoritmo

### Fluxo síncrono (obrigatório)

```
Passo 1 → Passo 2 → Passo 3 → Passo 4 → Passo 5
              ↓           ↓           ↓
           [pular]     [pular]     [pular]
```

### Passo 1 — Detectar estado atual

```bash
gh --version 2>&1
gh auth status 2>&1
```

Monte o diagnóstico:

| Item | Fonte | Estado esperado |
|------|-------|----------------|
| `gh` instalada | `gh --version` | versão >= 2.x exibida |
| Autenticada | `gh auth status` | `Logged in to github.com` |
| Org/acesso | `gh auth status` / `gh api user` | acesso à org `org_github` do perfil |

Exiba o diagnóstico antes de alterar qualquer coisa.

### Passo 2 — Instalação (se ausente)

Se `gh --version` falhar:

- **Windows:** `winget install --id GitHub.cli -e`
- **macOS:** `brew install gh`
- **Linux (Debian/Ubuntu):** seguir docs oficiais (`apt` repo do GitHub CLI)

Após instalar, peça confirmação para revalidar (`gh --version`). Se ainda
ausente (PATH não atualizado), oriente reiniciar o terminal/sessão e
registre ⚠️ no relatório.

### Passo 3 — Autenticação (se ausente)

Se `gh auth status` falhar:

```bash
gh auth login --web
```

Fluxo preferido: **GitHub.com → HTTPS → Login with a web browser**.
O `gh` exibirá um one-time code e abrirá o browser — o wizard orienta o
usuário a concluir lá. Aguarde a conclusão e revalide com `gh auth status`.

### Passo 4 — Validar a org do perfil (`org_github`)

```bash
gh api user --jq .login
gh api orgs/<org_github do perfil> --jq .login 2>&1
```

- Se a org responder 200 → acesso OK.
- Se 404/403 → o usuário autenticado não tem acesso à org
  `<org_github>` do perfil; oriente solicitar acesso ao admin da org e
  registre ⚠️.
- Fonte da org: `rules/client-profile.md` (`org_github`, IMP-103/IMP-105) —
  a skill apenas valida, não altera config global do `gh`. Sem perfil,
  pergunte a org ao operador (question agrupada).

### Passo 5 — Relatório final

```text
═══ rdd-gh-setup — <RESULTADO> ═══

✅ gh instalada: <versão>
✅ Autenticada: <login> @ github.com
✅ Org <org_github do perfil>: acesso confirmado | ⚠️ Sem acesso — solicite ao admin

🔍 Validação:
| Verificação | Estado | Observação |

Próximo passo sugerido: @rdd-github-orchestrator para issues/PRs,
ou continue o rdd-setup (Passo 6 — validação de ambiente).
```

## Casos de borda

- **Re-execução (idempotente):** itens já OK são pulados; nada é refeito.
- **`gh` instalada mas desatualizada:** reporte a versão; upgrade é opcional
  (`gh upgrade`) — não bloqueia.
- **Múltiplas contas logadas:** `gh auth status` pode listar várias —
  valide que ao menos uma tem acesso à org do perfil; não troca conta sem pedido.
- **Ambiente sem browser (SSH/headless):** `gh auth login --web` pode
  falhar — oriente `gh auth login` com token PAT (scope `repo`, `read:org`)
  como alternativa.
- **winget/brew indisponível:** oriente instalação manual via página de
  releases do `cli/cli` no GitHub.
- **Delegado pelo rdd-setup:** ao concluir, retorne o relatório para o
  wizard pai seguir ao Passo 6 (validação de ambiente).
