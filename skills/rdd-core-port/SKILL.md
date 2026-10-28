---
name: rdd-core-port
description: >-
  Porta automaticamente o que foi publicado no espelho público (repo
  victor-souza-dev/RDD-CORE, clone local ~/.config/rdd-core) de volta ao core
  privado TM.CORE.RDD (~/.config/opencode/) — Fase 3 da proposta de contribuição
  cross-empresa (decisão D2: bot de port estilo GitLab 2017 — IMP-137). Detecta
  snapshots públicos não incorporados (mensagem `release: snapshot
  TM.CORE.RDD@<sha>`), valida que o patch só toca o subset essencial (fonte
  única: `publish/publish-core.sh`), aplica com `git apply --check` antes, roda
  os gates (evals + neutrality) e commita localmente — NUNCA push (publicar é
  da rdd-core-publish). Modo `--pr <N>` porta um PR específico do público
  (gh pr diff) com os mesmos checks. Use quando o usuário pedir "portar
  snapshot do público", "port do rdd-core", "trazer contribuição aceita para o
  core", "portar PR do público" ou "rdd-core-port".
---

# rdd-core-port — Port automatizado público → core privado

Responde "como trazer para o core privado o que já foi publicado no espelho
público?" — terceiro membro da convenção `rdd-<repo>-<action>` (IMP-124):
`rdd-core-update` traz do remote PRIVADO (pull), `rdd-core-publish` empurra ao
remote PRIVADO (commit + push), `rdd-core-port` porta o espelho PÚBLICO de
volta ao core (bot de port — IMP-137). Não confundir com `rdd-core-update`:
o remote origin do core é privado; o port consome um CLONE separado do repo
público (`~/.config/rdd-core`) e nunca empurra nada.

Modelo snapshot: os dois repos não compartilham ancestralidade de git — cada
release pública substitui o conteúdo público pelo subset essencial da HEAD do
core, commit `release: snapshot TM.CORE.RDD@<sha> (<data UTC>)`. O port
reconstrói a ponte por CONTEÚDO: um snapshot cujo `<sha>` já existe no
histórico do core já está incorporado; os demais são pendentes.

## Contexto dos repositórios

- **Core (destino):** `~/.config/opencode/` (contém `.git/`) — branch `main`.
- **Clone público (origem):** `~/.config/rdd-core` (parametrizável
  `--clone <path>`) — remote `origin` aponta para o repo público (ex.:
  `victor-souza-dev/RDD-CORE`; derive com
  `git -C <clone> remote get-url origin` — zero hardcode, IMP-105).
- **Fronteira (fonte única):** array `SUBSET` de `publish/publish-core.sh` —
  a mesma lista documentada em PUBLISH.md. O port NUNCA aplica path fora dela.

## Lê (upstream)

- `git -C <clone> fetch origin` + `git log` (snapshots em `HEAD..origin/main`)
- Mensagem dos snapshots: `release: snapshot TM.CORE.RDD@<sha> (<data UTC>)`
- Histórico do core — o `<sha>` do snapshot existe como commit?
  (`git cat-file -e <sha>^{commit}`)
- Array `SUBSET` de `publish/publish-core.sh` (fonte única da fronteira)
- `git diff` no clone (delta do port) e working tree do core (pré-condição)

## Gera (downstream)

- No máx. UM commit no core: `port: snapshot público <short-sha> (<data UTC>)`
  (ou `port: PR#N <título> (autor original preservado)` no modo `--pr`)
- Patch temporário em dir de temp do SO — **nunca** dentro de nenhum dos repos
- Relatório textual na sessão (pendentes/incorporados, paths tocados, gates).
  Não cria branch, tag nem PR.

## Nunca edita

- **Nunca** `git push` em NENHUM dos dois repos — publicar é sempre decisão do
  operador via `rdd-core-publish` (o port só aplica + commita localmente).
- **Nunca** aplica path fora do subset essencial (fronteira OBRIGATÓRIA —
  Passo 4): nem `rules/client-profile.md`/`rules/operator-profile.md` reais
  (só os `.template.md` saem), nem `evals/reports/`, `evals/trends/`,
  `evals/golden-human/`, nem qualquer path fora do array `SUBSET`. Patch fora
  → **ABORTA** sem aplicar nada.
- **Nunca** porta sobre working tree sujo: QUALQUER saída em
  `git status --porcelain` do core → **ABORTA** antes de tudo (inclusive WIP
  de `knowledge/` — sem exceção; simplicidade: commitar/stash é do operador).
- **Nunca** resolve conflito de apply sozinho — conflito = **ABORTA** com
  relatório, sem aplicar nada (nunca sujar o tree).
- **Nunca** `git add -A` / `git add .` — só os paths tocados pelo patch.
- **Nunca** regenera `MANIFEST.sha256` (papel do `rdd-core-publish`, Passo
  3.7) — e o patch nunca o toca (fora do subset).
- **Nunca** edita artefatos de módulo de projeto nem arquivos fora dos dois
  repos envolvidos.

## Tools

- `bash` — comandos `git` nos dois repos (sempre `-C <repo>` explícito),
  `gh pr diff/view` (modo `--pr`) e os gates (`bash evals/run-evals.sh --all`,
  `bash evals/neutrality/scan.sh` a partir da raiz do core). O patch é
  redirecionado para o temp do SO (`mktemp -d` / `$env:TEMP`).
- `read` — ler `publish/publish-core.sh` (array SUBSET), o patch temporário e
  arquivos conflitantes, se necessário.

## Modo de erro

`strict` — qualquer condição de risco (working tree sujo, clone ausente,
rede/credencial, snapshot sem base, path fora do subset, conflito de apply,
gate vermelho) **aborta a operação inteira** sem aplicar nada — ou revertendo
integralmente o que foi aplicado (gate vermelho). A skill nunca força, nunca
resolve conflito, nunca empurra.

## Algoritmo

### Passo 0 — Pré-condições (core limpo, clone presente)

```bash
git -C ~/.config/opencode status --porcelain   # DEVE ser vazio
git -C ~/.config/opencode rev-parse HEAD        # core é repo?
[ -d ~/.config/rdd-core/.git ]                  # clone existe?
```

- Working tree do core com QUALQUER saída → **ABORTA**: liste os sujos e
  oriente commitar/stash. Não há exceção (nem `knowledge/` de sessão
  paralela).
- Core não é repo ou clone inexistente → **ABORTA** (casos de borda).

### Passo 1 — Sincronizar o clone público

```bash
git -C <clone> fetch origin
```

- Falha (rede/credencial) → **ABORTA**: estado local intocado, tente depois.

### Passo 2 — Detectar snapshots pendentes (por sha, não por diff)

```bash
git -C <clone> log --format='%H|%s' HEAD..origin/main
```

- **Range vazio** (HEAD == origin/main) → **NO-OP**: "nada a portar — o clone
  já está no snapshot mais recente". Encerre (idempotente).
- Para cada linha cujo subject casa
  `^release: snapshot TM\.CORE\.RDD@([0-9a-f]{40}) \(([0-9-]{10})\)$`: extraia
  `<sha>` e teste no core `git -C <core> cat-file -e <sha>^{commit}` —
  **existe = já incorporado**; **não existe = pendente**.
- Commits NÃO-snapshot no range (ex.: edição direta no público) → **warning**:
  não são portáveis por snapshot; se for PR aceito, use `--pr <N>`.
- Nenhum pendente (todos os snapshots novos referenciam shas já no core) →
  **NO-OP** listando os incorporados. Encerre.

### Passo 3 — Base e delta

- **Base** = o snapshot mais novo em TODA a história do clone cujo `<sha>`
  existe no core (varredura `git -C <clone> log --format='%H|%s' origin/main`,
  mais novo → mais velho). Base não encontrada na história inteira →
  **ABORTA**: "o core não compartilha nenhum estado com o público — rode
  `publish/publish-core.sh` antes de portar".
- **Delta:** `git -C <clone> diff <base>..origin/main > "$TMP/port.patch"` —
  um patch acumulado mesmo com N pendentes (o estado final é o que importa).
  N > 1 → commit único com short-sha do snapshot MAIS RECENTE e body listando
  todos os shas incorporados, na ordem.

### Passo 4 — Fronteira OBRIGATÓRIA (subset)

1. Leia o array `SUBSET` de `publish/publish-core.sh` (fonte única — NUNCA
   lista copiada para dentro da skill): extraia as entradas entre `SUBSET=(`
   e `)` (sem comentários).
2. Liste os paths tocados:
   `git -C <clone> diff --name-only <base>..origin/main` (modo `--pr`:
   extraia dos headers `diff --git a/<path> b/<path>` do patch).
3. Um path é **aceito** somente se: (a) match exato de entrada-arquivo
   (`.gitignore`, `registry.yaml`, `AGENTS.template.md`, `README.md`,
   `LICENSE`, `CONTRIBUTING.md`, `PUBLISH.md`, `PACK_SCHEMA.md`,
   `BREAKING-CHANGES.md`, `.github/workflows/evals.yml`,
   `rules/stack-templates.yaml`, `rules/client-profile.template.md`,
   `rules/operator-profile.template.md`), OU (b) prefixo `<entrada>/` de
   entrada-diretório (`agents`, `skills`, `evals`, `patterns`) — **EXCETO**:
   `evals/reports/`, `evals/trends/`, `evals/golden-human/` (NUNCA) e
   `rules/client-profile.md` / `rules/operator-profile.md` reais (NUNCA).
4. **Qualquer path fora → ABORTA** com relatório: path, entrada do subset mais
   próxima e instrução explícita de que NADA foi aplicado. Nenhum comando
   mutante roda antes deste gate.

### Passo 5 — Aplicar com segurança

```bash
git -C <core> apply --check "$TMP/port.patch"    # dry-run
```

- OK → `git -C <core> apply "$TMP/port.patch"`.
- Conflito/erro → **ABORTA sem aplicar**: relate os arquivos conflitantes
  (o git lista os que falharam) e oriente resolução manual. Nunca `--3way`
  para "resolver" — semiaplicado é estado proibido.

### Passo 6 — Gates pré-commit

A partir da raiz do core:

```bash
bash evals/run-evals.sh --all
bash evals/neutrality/scan.sh
```

- Ambos verdes (exit 0) → Passo 7.
- Qualquer vermelho → **REVERT**: `git -C <core> apply -R "$TMP/port.patch"`
  (desfaz adds/deletes/modificações do patch); confirme com
  `git status --porcelain` vazio; resíduo em arquivo rastreado →
  `git -C <core> checkout -- <path>`. Relate gate + checks vermelhos e
  encerre SEM commitar.

### Passo 7 — Commit local (NUNCA push)

```bash
git -C <core> add -- <paths tocados pelo patch>
git -C <core> commit -m "port: snapshot público <short-sha> (<data UTC>)"
```

- `<short-sha>`/`<data>` = sha (7 chars) e data do snapshot MAIS RECENTE
  incorporado; N > 1 → body lista todos os shas.
- **Nunca** `git push`. O próximo passo é sempre decisão do operador
  (`rdd-core-publish`). Avise: skills/agents portados exigem **reiniciar o
  OpenCode**.

### Passo 8 — Modo `--pr <N>` (contribuição aceita antes da próxima snapshot)

```bash
gh pr diff <N> --repo <public> > "$TMP/pr.patch"
gh pr view <N> --repo <public> --json title,author
```

- Mesmos Passos 4-7 (fronteira, `apply --check`, gates, commit), com commit
  `port: PR#<N> <título> (autor original preservado)`.
- `gh` indisponível, PR sem diff ou patch vazio → **ABORTA** com orientação.

## Formato de saída

```text
═══ rdd-core-port — <RESULTADO> ═══

🪞 Clone público: ~/.config/rdd-core (origin @ main)
🎯 Core destino : ~/.config/opencode/ @ <head>

✅ PORTADO
   Snapshots incorporados (N):
     - <short-sha> (2026-10-28) — release: snapshot TM.CORE.RDD@...
   Patch: <base>..origin/main (M arquivos, todos no subset)
   Gates: evals --all VERDE · neutrality OK
   Commit local: <sha> port: snapshot público <short-sha> (<data>)
   Push: NUNCA pelo port — publique via rdd-core-publish quando decidir.
   ⚠️ Reinicie o OpenCode (skills/agents portados).

── ou ──

✅ NO-OP — nada a portar
   HEAD do clone == origin/main; snapshot <short> referencia <sha> (já no core).

── ou ──

⛔ ABORTADO — <motivo>
   Fronteira subset: paths fora do subset (nada foi aplicado):
     - evals/reports/EVAL_REPORT_x.md (exclusão de evals — NUNCA)
   Conflitos: <arquivos> — resolução manual; working tree permaneceu limpo.
```

## Workflow

1. Pré-condições (core limpo + clone presente) — Passo 0.
2. `git fetch origin` no clone — Passo 1.
3. Detectar pendentes por sha (range `HEAD..origin/main`) — Passo 2.
4. Base (último snapshot incorporado) + delta acumulado — Passo 3.
5. Fronteira OBRIGATÓRIA contra o SUBSET de `publish/publish-core.sh` — Passo 4.
6. `git apply --check` → `git apply` — Passo 5.
7. Gates: `evals --all` + neutrality; vermelho = revert (`git apply -R`) — Passo 6.
8. Commit local `port: ...` (nunca push) + aviso de reinício — Passo 7.
9. Modo `--pr <N>`: mesmo fluxo 5-8 com patch do PR — Passo 8.

## Casos de Borda

### Clone público ausente

`~/.config/rdd-core` não existe / não é repo → **ABORTA** e orienta: *"Clone o
espelho público: `git clone <URL do público> ~/.config/rdd-core` (URL derivada
do remote do seu setup — veja PUBLISH.md) e rode de novo."* Nunca inicialize o
clone por conta própria.

### Sem snapshots novos (no-op idempotente)

Range vazio ou todos os shas já no core → mensagem clara de no-op, zero
comandos mutantes. Rodar duas vezes seguidas é seguro.

### Patch fora do subset (fronteira)

Path fora do SUBSET (ou em exclusão: `evals/reports|trends|golden-human`,
perfis reais) → **ABORTA com relatório antes de qualquer apply**. Isso pode
indicar conteúdo privado parado no espelho público — sinalize para revisão do
mantenedor. NUNCA aplique "só os paths bons": o patch entra inteiro ou não
entra (seletividade manual é decisão do operador).

### Conflito de apply

`git apply --check` falha → relatório com os arquivos conflitantes + hint de
resolução manual (rebase do core, nova snapshot via publish-core.sh, ou port
seletivo pelo operador). Working tree permanece limpo — nada semiaplicado.

### Gate vermelho pós-apply

`evals --all` ou `neutrality` falham após o apply → **revert integral**
(`git apply -R` + `checkout --` residual) + relatório do gate/checks. O core
fica exatamente como antes; o problema é investigado antes de reintentar.

### Core com working tree sujo

Qualquer saída no `status --porcelain` (inclusive `knowledge/` de sessão
paralela) → **ABORTA** e instrui commitar/stash. Sem exceções — portar sobre
WIP mistura trabalho alheio no commit de port.

### Snapshot sem base no core

Nenhum snapshot na história do clone referencia sha do core (ex.: core
recriado do zero) → **ABORTA**: não há como calcular delta seguro; rode
`publish/publish-core.sh` para realinhar os espelhos.

### Commits não-snapshot no público

Commit direto no repo público (fora do formato `release: snapshot ...`) não é
portável por snapshot → warning + orientação `--pr <N>` (se PR) ou port manual
pelo mantenedor.

### Rede / credencial indisponível

`fetch` falha → **ABORTA** sem alterar nada (nem clone nem core).

### `gh` indisponível (modo --pr)

Comando ausente ou sem auth → **ABORTA** com orientação `gh auth status`.

## Formato de commit

- `port: snapshot público a1b2c3d (2026-10-28)` — body (N>1): lista dos shas
- `port: PR#42 adiciona patterns/INDEX (autor original preservado)`
- **NUNCA push** — a publicação (privado via `rdd-core-publish`; público via
  `publish/publish-core.sh`) é sempre decisão do operador.