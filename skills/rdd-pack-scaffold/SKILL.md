---
name: rdd-pack-scaffold
description: >-
  Onboarding de uma NOVA organização no RDD open core — cria o esqueleto
  completo do pack dela a partir APENAS do contrato `PACK_SCHEMA.md`
  (pack.yaml, regra da org, acúmulo vazio, README), faz o primeiro commit
  no repo do pack, roteia a criação do repo remoto privado (`gh repo
  create`), o registro no perfil (`packs:`/`pack_repos` — sob confirmação)
  e a instalação no runtime (cópia de `provides`, `.rdd/sources.yaml`,
  `.gitignore`). Fluxo interativo com perguntas agrupadas (IMP-043). Use
  quando o usuário pedir "onboarding de empresa no open core", "criar
  pack", "scaffold de pack", "nova empresa no rdd" ou "onboarding de pack".
---

# rdd-pack-scaffold — Scaffold de pack de organização

Onboarding de uma nova organização no open core: a partir **apenas** do
contrato (`PACK_SCHEMA.md`), cria o esqueleto completo do pack — nada do
template assume uma org específica. Passos de efeito externo (repo remoto,
perfil, instalação no runtime) só acontecem com confirmação explícita.

## Lê (upstream)

- `PACK_SCHEMA.md` — contrato do `pack.yaml` (v1): campos, no-override, lockfile, `.gitignore` gerado
- `registry.yaml` + `BREAKING-CHANGES.md` — versão local do core e faixa compatível (`requires-core`)
- `rules/client-profile.md` — `org_github` e packs já registrados (`packs:`/`pack_repos`)
- `skills/rdd-pack-update/SKILL.md` e `skills/rdd-setup/SKILL.md` (Passo 6b) — referência de estilo do installer/updater

## Gera (downstream)

- Esqueleto do pack em `packs/<id>/` (NOVO):
  - `pack.yaml` (v0.1.0) — `provides[]`/`acumulo[]` derivados das respostas
  - regra da org (default `rules/packs/<id>.md`) com seções-guia a preencher
  - `acumulo/patterns/README.md`, `acumulo/metrics/README.md`, `acumulo/reverses/README.md`
  - `README.md` do pack
- Primeiro commit no repo do pack (`git init -b main`)
- Repo remoto privado — `gh repo create <org-github>/<repo> --private` + remote + push (só com confirmação)
- Entrada no `rules/client-profile.md` — `packs: [<id>@<faixa>]` + `pack_repos` (sob confirmação explícita)
- Instalação no runtime — cópia dos `provides`, pin em `.rdd/sources.yaml`, seção gerada no `.gitignore`

## Nunca edita

- Paths já existentes do core — no-override vale também na criação
- Packs de outras organizações (`packs/<outro-id>/`)
- `acumulo/` com conteúdo real — só cria esqueleto vazio com README
- Sem confirmação explícita: não cria repo remoto, não atualiza perfil, não faz push

## Tools

- `read`/`glob`/`grep`: **allow** — contrato, registry, perfil, packs existentes
- `question`: **allow** — perguntas agrupadas (uma chamada por bloco de decisão, IMP-043)
- `bash`: **ask** — `git init`/`commit`/`push`, `gh repo create`, cópia de arquivos
- `edit`/`write`: **apenas** `packs/<id>/**` (NOVO), `.rdd/sources.yaml`, `.gitignore` (seção gerada), `rules/client-profile.md` (com confirmação)

## Modo de erro

- **Id de pack já existente** (pasta em `packs/` ou entrada no perfil) → **ABORTA** com orientação: o pack existe, use `rdd-pack-update` para atualizar/reinstalar.
- **`requires-core` incompatível** com a versão local do core → aborta apontando `BREAKING-CHANGES.md` (o que mudou no major e como migrar).
- **Sem `gh` autenticado** → cria o repo local completo e registra pendência do remote (`gh repo create` + push) no relatório.
- **Usuário recusa qualquer confirmação** → entrega o esqueleto local mesmo assim e lista as pendências (remote, perfil, instalação).

## Workflow

1. **Coleta (UMA `question` agrupada):**
   - nome da organização/empresa
   - id do pack (`lowercase-hyphen`)
   - org GitHub (`<org-github>`; default: a do perfil, se houver)
   - nome do repo (default `<org>.RDD.PACK.<ID-MAIÚSCULO>` — valide com o operador)
   - visibilidade (default `private`)
   - nome da regra (default `rules/packs/<id>.md`)
2. **Valida:** unicidade do id (`packs/<id>/` livre + ausente do perfil), ausência de colisão da regra com path do core e compat da faixa `requires-core` proposta contra `registry.yaml` + `BREAKING-CHANGES.md`.
3. **Cria o esqueleto** em `packs/<id>/`:
   - `pack.yaml` v0.1.0: `id`, `name`, `version: 0.1.0`, `requires-core` derivado da versão local do core, `provides: [<regra da org>]`, `acumulo: [acumulo/patterns/, acumulo/metrics/, acumulo/reverses/]`
   - `<regra da org>` com seções-guia a preencher: identidade, infra validada, runbooks
   - `acumulo/{patterns,metrics,reverses}/README.md` + `README.md` do pack
4. **Primeiro commit:** `git init -b main` + commit inicial no repo do pack (anote o SHA para o pin).
5. **Pergunta — repo remoto:** confirmado → `gh repo create <org-github>/<repo> --private` + `git remote add` + `git push -u origin main`.
6. **Pergunta — perfil:** confirmado → adicionar `<id>@<faixa>` em `packs:` e `<id>` → URL em `pack_repos` no `rules/client-profile.md`.
7. **Pergunta — instalar agora:** confirmado → valide no-override (nenhum `provides` colide com path do core), copie os `provides` para o runtime, grave `.rdd/sources.yaml` (version/commit/paths — pin do commit inicial) e gere a seção do `.gitignore`.
8. **Relatório final:** o que foi criado (arquivos, commit, remote, instalação) e o que ficou pendente (⚠️).

## Casos de borda

- **Id com caractere inválido** (espaço, maiúscula, `_`) → normalize para `lowercase-hyphen`; recuse se não houver forma inequívoca.
- **Organização sem org GitHub no perfil** → pergunte a org na coleta (não assuma).
- **Máquina sem bash/WSL** → execute os equivalentes em PowerShell (`Copy-Item`, `git`, `gh`).
- **Regra `rules/packs/<id>.md` colide com arquivo existente no core** → aborta (no-override vale também na criação).
