---
name: rdd-core-update
description: >-
  Atualiza a config local do workflow RDD via git pull no repositório
  remoto da config (~/.config/opencode/). Verifica o working
  tree antes de aplicar — se houver WIP local, aborta e lista os arquivos
  sujos, nunca sobrescreve trabalho. Use quando o usuário pedir "atualizar o
  rdd", "dar git pull no rdd", "update do rdd", "sincronizar a config do
  opencode" ou "self-update do workflow".
---

# rdd-core-update — Auto-atualização segura da config RDD

Responde "como trazer a config RDD local para a versão mais recente do
repositório?" — diferente do `@rdd-workflow-improver` (corrige workflow) e
do `@rdd-workflow-builder` (cria componentes). Esta skill apenas **aplica
atualização já publicada no remote**, com garantia de nunca destruir
trabalho local.

## Contexto do repositório

- **Repo alvo:** `~/.config/opencode/` (é o próprio diretório
  (~ = path da config local do OpenCode na SUA máquina — se a sua instalação usar outro local, confirme no bloco local do AGENTS.md via rdd-setup)
  de config do OpenCode — contém `.git/`)
- **Remote (origin):** derivado do próprio repo — `git -C $HOME/.config/opencode remote get-url origin` (IMP-105: zero hardcode de org/repo; exemplos ilustrativos podem citar a org do operador).
- **Branch:** `main`
- **Escopo do pull:** o `.gitignore` do repo versiona apenas `agents/rdd-*.md`,
  `skills/rdd-*/SKILL.md`, `ARCHITECTURE-*.md` e `WORKFLOW_IMPROVEMENTS.md`.
  **O pull nunca toca** `opencode.jsonc`, `AGENTS.md`, `settings.json`,
  `hooks/`, `plugins/`, `command/*` — estes não são versionados.

## Lê (upstream)

- Estado do working tree via `git status --porcelain` (repo alvo)
- `HEAD` local vs `origin/main` (via `git fetch` + comparação de refs)

## Gera (downstream)

- Saída textual na sessão: status (atualizado/atualizável/abortado), delta
  de commits (`git log`) e orientações. **Não persiste arquivos.**

## Nunca edita

- **Nunca** sobrescreve, mescla ou descarta arquivos locais não commitados.
- **Nunca** commita, faz push, cria branch ou tag.
- **Nunca** edita artefatos de módulo de projeto (REQUIREMENTS.md etc.).
- **Nunca** toca arquivos não versionados da config (opencode.jsonc,
  AGENTS.md, plugins/, hooks/, settings.json).

## Tools

- `bash` — exclusivamente para comandos `git` no repo alvo:
  `git -C $HOME/.config/opencode status --porcelain`,
  `git -C ... fetch origin`, `git -C ... rev-parse HEAD`,
  `git -C ... rev-parse origin/main`, `git -C ... pull --ff-only`,
  `git -C ... log --oneline <base>..HEAD`
- `read` (para inspecionar arquivos sujos listados, se necessário)

## Modo de erro

`abort` — qualquer condição de risco (WIP local, rede indisponível, pull
não fast-forward) **aborta a operação inteira** com mensagem clara. A skill
nunca força, nunca faz merge automático, nunca resolve conflito sozinha.

## Algoritmo

### Passo 1 — Verificar working tree (guarda principal)

```bash
git -C $HOME/.config/opencode status --porcelain
```

- Se **não vazio** → **ABORTA**. Liste os arquivos sujos (com status
  `M`/`A`/`D`/`??`/`R`/`C`) e explique: *"Há WIP local na config — não vou
  sobrescrever. Opções: (a) commitar/pushar o WIP e rodar de novo, (b)
  resolver manualmente depois de um `git stash`, (c) inspecionar os arquivos
  abaixo antes de decidir."* Encerre sem tocar em nada.
- Se **vazio** → prossiga.

### Passo 2 — Comparar com o remote

```bash
git -C $HOME/.config/opencode fetch origin
git -C $HOME/.config/opencode rev-parse HEAD
git -C $HOME/.config/opencode rev-parse origin/main
```

- **HEAD == origin/main** → informe *"RDD atualizado — já está na versão
  mais recente (HEAD `af832335...`)"* e encerre.
- **HEAD != origin/main** → prossiga para o Passo 3.

### Passo 3 — Aplicar pull fast-forward only

```bash
git -C $HOME/.config/opencode pull --ff-only
```

- Sucesso → **Passo 4**.
- Falha (mensagem de não-fast-forward) → **ABORTA** e orienta: *"A branch
  local divergiu do remote (pull não é fast-forward). Isso indica commit
  local que não está no origin. Resolva manualmente: `git -C ... log
  origin/main..HEAD` para ver seus commits locais e decida entre rebase ou
  merge — depois rode rdd-core-update de novo."*

### Passo 4 — Mostrar o delta

```bash
git -C $HOME/.config/opencode log --oneline <commit-anterior>..HEAD
```

- `<commit-anterior>` = o valor de `HEAD` lido no Passo 2 (antes do pull).
- Exiba os commits trazidos, agrupados por tipo quando possível (ex.:
  skills novas, correções, arquitetura).

### Passo 4b — Verificar integridade (MANIFEST.sha256 — IMP-103)

1. Se `MANIFEST.sha256` existir na raiz do repo: para cada linha `<sha256>  <path>`, recalcule o sha256 do arquivo em disco e compare.
2. Divergência = **warning explícito** listando os arquivos divergentes: pode ser edição local legítima (não versionada pelo pull) ou tampering — o operador decide. **NUNCA sobrescrever, restaurar ou `git checkout` automaticamente.**
3. Arquivo listado no MANIFEST ausente em disco = warning (mesmo tratamento).
4. `MANIFEST.sha256` ausente = aviso informativo (repo publicado antes do IMP-103) — não bloqueia.

### Passo 5 — Avisar reinício

Informe: *"Config não é hot-reloaded — **reinicie o OpenCode** para que as
skills/agents atualizados passem a valer. A sessão atual segue com a config
já carregada."*

## Formato de saída

```text
═══ rdd-core-update — <RESULTADO> ═══

📦 Repo: ~/.config/opencode/ (remote origin @ main)

✅ JÁ ATUALIZADO
   HEAD == origin/main (af832335...)
   Nada a fazer.

── ou ──

🔄 ATUALIZADO COM SUCESSO
   Antes:  <commit-anterior>  (af832335...)
   Depois: <commit-novo>      (b3c9f2e...)
   Delta (N commits):
     - b3c9f2e feat: rdd-core-update nova skill
     - a11bcc0 fix: rdd-data-model seção §6

⚠️ Reinicie o OpenCode para a nova config valer.

── ou ──

⛔ ABORTADO — working tree sujo
   Arquivos locais não commitados (não sobrescrevi):
     - M skills/rdd-figma-prompt/SKILL.md
     - ?? skills/rdd-experimento/SKILL.md
   Resolva o WIP (commit, stash ou descarte consciente) e rode de novo.
```

## Workflow

1. `git status --porcelain` no repo alvo → vazio? (senão, aborta no Passo 1).
2. `git fetch origin` + compara HEAD vs origin/main (Passo 2).
3. Se divergir: `git pull --ff-only` (Passo 3).
4. `git log --oneline` do delta (Passo 4).
4b. Verifica sha256 dos arquivos versionados contra `MANIFEST.sha256` (Passo 4b, IMP-103) — divergêáncia de hash é warning listado, nunca auto-corrigida.
5. Aviso de reinício do OpenCode (Passo 5).
6. Exiba o resultado no formato acima.

## Casos de Borda

### Repo sem remote configurado

`git fetch origin` falha → informe: *"O repo `~/.config/opencode` não tem
remote origin. Verifique `git -C ... remote -v` e configure
  `git remote add origin <URL do repo da config>` (URL da org do operador)."*

### Rede indisponível / autenticação

`git fetch` falha por rede ou credencial → **ABORTA** com mensagem: *"Não
foi possível contatar o remote (rede/credencial). O estado local não foi
alterado. Tente novamente mais tarde."* Nunca tente `pull` sem fetch bem-sucedido.

### WIP local (guarda principal)

Nunca sobrescrever. Abortar e listar (Passo 1). Se o usuário insistir,
nunca oferecer `git reset --hard`/`checkout -- .` automaticamente — apenas
documentar as opções e deixar a decisão explícita do usuário.

### Branch divergente (pull --ff-only falha)

Orientar resolução manual (Passo 3): `git log origin/main..HEAD` para
identificar commits locais; decidir entre `git rebase origin/main` (histórico
linear) ou `git merge origin/main` (commit de merge); depois re-executar.

### AGENTS.md saiu do versionamento (IMP-105 — pull deletou o arquivo local)

O AGENTS.md foi untracked (IMP-105: ele nasce do `AGENTS.template.md` +
client-profile em cada máquina). Se uma máquina antiga ainda tinha o
AGENTS.md versionado, o `pull --ff-only` pode **deletar o AGENTS.md local**
(trazido como remoção do remote). Nesse caso: informe explicitamente
*"AGENTS.md saiu do versionamento — execute o `rdd-setup` para recriar o
local a partir de `AGENTS.template.md` + client-profile"* e registre ⚠️.
Nunca recrie o AGENTS.md por conta própria (isso é papel do rdd-setup).

### Pull com conflito

Com `--ff-only`, conflito só ocorre se a branch divergiu (caso acima).
Se mesmo assim aparecer conflito (ex.: WIP entrou entre status e pull), o
git deixa os arquivos em conflito — **ABORTA** e orienta: *"O pull deixou
arquivos em conflito no working tree. Resolva os conflitos manualmente e
finalize com `git commit` — não vou resolver por você."*


### AGENTS.md deletado pelo pull (IMP-105)

Ver `caso "AGENTS.md saiu do versionamento"` acima — orientar `rdd-setup`.

### Divergência do MANIFEST.sha256 (IMP-103)

Após o pull, arquivos cujo sha256 difere do MANIFEST geram **warning
explícito com a lista** — nunca correção automática. Opções do operador:
(a) se é edição local legítima, commitar ou registrar a decisão;
(b) se suspeita de tampering, restaurar o arquivo manualmente
(`git checkout -- <arquivo>`) após verificar o histórico. A skill nunca
escolhe por ele.

### Remote atualizado entre fetch e pull

`pull --ff-only` re-fetcha — é seguro e idempotente; em caso de divergência
apenas recém-criada, aplica a orientação do caso "branch divergente".

### Git não disponível / não é repo

`git status` falha → verifique se o diretório é repo (`.git` existe) e se o
git está no PATH; informe sem alterar nada.

## Formato de commit

N/A — a skill **não commita**. O `git pull` traz commits do remote; o
histórico local é atualizado automaticamente pelo próprio git.
