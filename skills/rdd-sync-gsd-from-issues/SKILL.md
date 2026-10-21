---
name: rdd-sync-gsd-from-issues
description: >
  Use when the user asks to sync, update, or refresh the local GSD state
  from GitHub issues. Triggers: "sync gsd", "update gsd from issues",
  "sincronizar gsd", "atualizar gsd", "pull issues para o gsd",
  "refletir issues no gsd". Reads open/closed GitHub issues and updates
  the status of tasks in the local GSD INDEX.md and PLAN.md files.
---

# Sync GSD from GitHub Issues

Reads GitHub issue states and updates the local GSD files to reflect
current progress. Source of truth for status: GitHub. Source of truth
for structure: local PLAN.md files.

## Lê (upstream)

- Issues abertas/fechadas do repo GitHub via `gh` (`gh issue view`).
- Estado local GSD (`.planning/`) — `*-INDEX.md` (wave table com coluna `Issue`) e `*-PLAN-NN.md` (comentários `<!-- issue: N -->`).

## Gera (downstream)

- Atualização de `.planning/INDEX.md` — coluna `Status` na wave table e seção `## Sync Log`.
- Atualização de `.planning/**/PLAN*.md` — comentário `<!-- status: <valor> -->` refletindo o status da issue correspondente.

## Nunca edita

- Issues no GitHub — leitura only (fonte de verdade do status).
- Código do produto.
- Arquivos fora de `.planning/` — nunca reescreve conteúdo, decisões ou estrutura das tasks (só STATUS).

## Modo de erro

- `gh` indisponível ou sem autenticação → aborta SEM alterar o estado local e informa o erro.
- Repo/fase sem referências de issues → aborta SEM alterar o estado local e informa.

## Core rules
- Only update STATUS — never rewrite task content, decisions, or structure
- Issue references live in two places: INDEX.md (wave table) and PLAN.md files (<!-- issue: N --> comment)
- A PLAN without an issue reference is not yet created — skip it silently
- Do not infer issue numbers; only use explicitly referenced ones

---

## Steps

### 1. Locate files
Find the active phase directory under `.planning/phases/`:
- `*-INDEX.md` — contains the wave table with issue numbers
- `*-PLAN-NN.md` files — each may contain `<!-- issue: N -->` on the first line

### 2. Extract issue references
From the INDEX.md wave table, extract all issue numbers from the `Issue` column (e.g. `#21, #22`).
From each PLAN.md, extract `<!-- issue: N -->` comments if present.

Build a unified map: `{ issue_number → [INDEX row | PLAN file] }`

If no issue references are found anywhere, report this and stop.

### 3. Fetch issue states from GitHub
For each unique issue number, run:
```bash
gh issue view <N> --json number,title,state,assignees
```

Collect: `{ issue_number → { state: open|closed, title, assignees } }`

If `gh` is not authenticated or unavailable, report the error and stop.

### 4. Map GitHub state → GSD status

| GitHub state | GSD status    |
|--------------|---------------|
| `open`       | `em andamento` |
| `closed`     | `concluído`    |

A PLAN with no issue reference stays as-is (not yet started).

### 5. Update INDEX.md
In the wave table, add or update a `Status` column reflecting the mapped status for each issue.
If the `Status` column does not exist, insert it after the `Issue` column.

Example updated row:
```
| **2** | PLAN-02, PLAN-03 | #23 ✅, #24 🔄 | em andamento | ... |
```

Use these inline markers alongside the issue number:
- `✅` — closed
- `🔄` — open
- _(no marker)_ — no issue yet

### 6. Update each PLAN.md
For each PLAN that has a `<!-- issue: N -->` reference:
- Find or insert a `<!-- status: <value> -->` comment immediately after the issue comment
- Only write the file if the status actually changed

Example:
```markdown
<!-- issue: 23 -->
<!-- status: em andamento -->
```

### 7. Append sync log to INDEX.md
At the bottom of the INDEX.md, under a `## Sync Log` section, append:
```
- <ISO date> <HH:MM>: sincronizado <N> issues — concluídos: X, em andamento: Y, pendentes: Z
```
Create the section if it does not exist.

### 8. Confirm summary
Report as a table:

| PLAN | Issue | Título | Status anterior | Status atual |
|------|-------|--------|-----------------|--------------|
| PLAN-02 | #23 | ... | — | em andamento |
| PLAN-08 | #29 | ... | em andamento | concluído |

Include a final line: how many files were changed, how many were already up to date.
