---
name: rdd-split-commits-by-diff
description: >
  Use when the user asks to split existing changes into multiple commits.
  Triggers: "split commits", "separar commits", "commits separados",
  "commits por assunto", "organizar commits". Always use this skill when
  the working tree has mixed changes that should be committed in logical groups.
---

# Split Commits by Diff

Use this skill to turn a mixed working tree into clean, scoped commits.

## Lê (upstream)

- Estado do working tree do repo alvo: `git status` e `git diff` (inclui `git diff --cached`).
- Histórico recente de commits do repo alvo, para alinhar o estilo das mensagens.

## Gera (downstream)

- Plano de commits agrupados por assunto (intenção), apresentado antes de tocar no index.
- Commits atômicos no repo alvo — staging por paths explícitos (`git add <file>` / `git add -p`) e mensagens Conventional Commits no padrão do repo.

## Nunca edita

- Conteúdo dos arquivos — atua apenas no index/staging e nas mensagens de commit.
- `git add -A` / `git add .` — staging sempre por paths explícitos.
- Push sem pedido explícito do operador (assim como reescrita de histórico e comandos destrutivos).

## Modo de erro

- Conflitos/unmerged paths ou working tree com conversas em andamento → ABORTA sem commitar e reporta ao operador.
- Se não houver mudanças reais → informa "nada a commitar" e encerra (nunca cria commit vazio).

## Outcomes

- Produce a commit plan before touching the index.
- Keep each commit focused on one intent (feature, fix, refactor, docs, test, chore).
- Preserve user changes while avoiding accidental staging.
- Create clear commit messages that explain why each commit exists.

## Safety Rules

- Never run destructive git commands (`reset --hard`, `checkout --`, force push) unless the user explicitly asks.
- Never rewrite history (`commit --amend`, rebase) unless the user explicitly asks.
- Never commit secrets or credential-like files (`.env`, key files, token dumps).
- If pre-commit hooks modify files, include those modifications in a new commit unless the user asks otherwise.
- If there are no real changes, do not create an empty commit.

## Workflow

### 1) Inspect the repository state

Run these first:

```bash
git status --short
git diff
git diff --cached
git log -n 12 --pretty=format:"%h %s"
```

Understand:

- Which files are changed and whether they are staged or unstaged.
- Whether the changes represent one concern or multiple concerns.
- The repository's commit message style.

### 2) Build a commit grouping plan

Create a grouping proposal before staging:

- Group by intent, not only by file path.
- Keep dependent changes together when splitting would break tests/build.
- Prefer 2-6 commits for a medium mixed diff. Avoid over-splitting tiny edits.

For each proposed group, define:

- Group name (short)
- Files/hunks included
- Rationale (why this grouping is coherent)
- Commit message draft

If one hunk belongs to a different intent than the rest of the file, use patch staging.

### 3) Stage only the intended changes for one group

Default staging strategy:

- Full-file stage when file is single-intent: `git add <file>`
- Hunk-level stage when file is mixed-intent: `git add -p <file>`

If interactive hunk selection is unavailable in the runtime, use this fallback:

1. Stage full file.
2. Unstage unintended hunks or file parts with `git restore --staged` for specific files.
3. Iterate until `git diff --cached` matches the current group exactly.

### 4) Commit the current group

Commit with a concise message aligned to repo style.

Message guidance:

- First line: short imperative summary.
- Optional body: 1-2 lines explaining why.
- Prefer semantic prefixes only if repository already uses them.

Example styles:

- `fix(auth): avoid duplicate refresh token writes`
- `refactor(blog): extract locale normalization helper`
- `docs: clarify cache invalidation workflow`

### 5) Validate and continue

After each commit:

```bash
git show --stat --oneline -1
git status --short
```

Then repeat staging and commit for the next group until complete.

### 6) Final verification

At the end, run:

```bash
git log --oneline -n <number_of_new_commits>
git status
```

Report:

- Number of commits created
- Commit subjects in order
- Remaining uncommitted files (if any)

## Decision Heuristics

When splitting is ambiguous, prioritize in this order:

1. Keep the repository buildable/testable after each commit.
2. Keep one conceptual change per commit.
3. Keep reviewer readability high.
4. Minimize risky partial staging.

Do not force perfect atomicity if it causes fragile or misleading commits.

## Communication Contract

When invoked, communicate in this sequence:

1. Briefly summarize current diff shape.
2. Show proposed commit groups.
3. Execute staging + commit per group.
4. Report final commit list and remaining state.

Be decisive. Only ask for user input when there are multiple equally valid split strategies that materially change history.
