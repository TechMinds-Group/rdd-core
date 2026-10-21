---
name: rdd-gh-pr-creator
description: >-
  Cria Pull Requests no GitHub a partir de uma branch feature, vinculando
  a issue correspondente, com template padronizado (RNs cobertas, checklist
  de testes, screenshots quando aplicável). Usa gh CLI.
  Use quando o usuário pedir "abrir PR", "criar pull request", "PR da feature",
  "subir PR da task N", "abrir PR da branch".
---
# rdd-gh-pr-creator — Criação de Pull Requests no GitHub

Cria PRs no GitHub com template padronizado, vinculando a issue de origem
e incluindo checklist de qualidade.

## Pré-condições

- `gh` CLI instalada e autenticada (`gh auth status`)
- Branch feature já com push feito (`git push origin feature/<slug>`)
- Pasta da feature do módulo disponível (fonte do body do PR — ver Lê)
- Número da issue relacionada (opcional mas recomendado)
- **Task aprovada pelo `rdd-dev-reviewer`** — veredito `approve` informado
  na delegação (ou front matter `reviewed: true` no Feature.md). Task sem
  aprovação de review NÃO abre PR — retorne ao `rdd-dev` para rodar a
  revisão formal

## Lê (upstream)

- `branch-base` confirmada pelo operador no Gate de branch do `rdd-dev`
  (IMP-088) e informada na delegação — fonte preferencial da base do PR
- Estado do repositório (branch atual, commits)
- Pasta da feature do módulo (IMP-035/037/040) — `delivery/<YYYY-MM>/RN-NNN*/RN-NNN — Analise-Funcional.md` (CONTEÚDO do body: descrição, comportamento) e `RN-NNN — Analise-Tecnica.md` (RNs do campo **RNs**, issue principal, referências). Como o título é variável, resolva SEMPRE por glob de prefixo da PASTA — NUNCA construa o nome exato: glob `delivery/<YYYY-MM corrente>/RN-NNN*` (deve retornar 1 pasta; mais de 1 → pergunte; 0 → próximo passo) → sprints anteriores (pasta de sprint mais recente) → fallbacks legados (arquivo flat pré-IMP-040; `delivery/RN-*.md` pré-IMP-035; `TASKS*.md` pré-IMP-032 — nesses, extraia RNs e descrição do próprio arquivo)
- ISSUES_CREATED.md (se existir, para vincular issues)

## Gera (downstream)

- PR no GitHub via `gh pr create`

## Nunca edita

- Código fonte
- Artefatos RDD do módulo
- Issues existentes

## Tools

- `bash` (gh CLI — `gh pr create`, `gh pr view`)
- `question` (confirmar antes de criar)

## Modo de erro

`interativo` — se `gh` não estiver disponível, aborta e orienta.
Se branch não tiver push, aborta e orienta `git push`.

## Casos de Borda

- **Task sem aprovação de review:** veredito do `rdd-dev-reviewer` ausente ou `request-changes` (sem `reviewed: true`) → **recusar** abrir PR e retornar ao `rdd-dev` para revisão formal — nunca abrir PR não revisado.
- **Branch sem commits novos vs. base:** `git log base..head` vazio → aborta — PR vazio não se cria; oriente commitar/push antes.
- **`gh` CLI sem auth (`gh auth status` falha) ou não instalado:** aborte e encaminhe ao `rdd-gh-setup` antes de reintentar.
- **PR já existente para a branch:** `gh pr view feature/<slug>` retorna PR aberto → não duplique; reporte a URL existente e encerre.
- **`branch-base` informada não existe no remote:** não caia para `main` por inferência — confirme com o operador (IMP-088) antes de criar.
- **Pasta da feature não localizada (glob retorna 0):** aborta com orientação de regenerar via `rdd-task-spec` — nunca monte body de PR sem fonte funcional.

## Workflow

### Passo 1 — Coletar contexto

```bash
git branch --show-current
git log --oneline -5
```

### Passo 2 — Montar body do PR

O conteúdo funcional vem dos arquivos da pasta da feature:

```markdown
## Descrição
<"O que esta entrega faz" do RN-NNN — Analise-Funcional.md>

## RNs cobertas
- RN-XXX ✅ (campo RNs da issue principal no RN-NNN — Analise-Tecnica.md)
- RN-YYY ✅

## Review
Aprovado por @rdd-dev-reviewer (veredito: approve — `reviewed: true`)

## Docs atualizadas no ciclo
<lista dos artefatos de specs/glossaries tocados pelo executor no Passo 9
(do relatório da task) — ou "Nenhuma", com justificativa>

## Checklist
- [ ] Testes verdes (`cargo test` / `mvn verify` / `ng test`)
- [ ] Lint aprovado (`cargo clippy` / `mvn checkstyle` / `ng lint`)
- [ ] Código segue padrões da stack
- [ ] Docs vivas atualizadas apenas nas seções afetadas (specs/glossaries) — REQUIREMENTS/DECISIONS intocados
- [ ] Nenhuma spec foi editada
- [ ] (se UI) Screenshots anexados
- [ ] (se DB) Migração versionada

## Issue relacionada
Closes #<numero>

## Notas
<observações, decisões, pendências>
```

### Passo 3 — Determinar branch target e confirmar

Determine a base nesta ordem (IMP-088):
1. **`branch-base` confirmada (fonte preferencial):** base confirmada
   pelo operador no Gate de branch do `rdd-dev` e informada na
   delegação — use-a sem re-inferir.
2. **Fallback (campo ausente):** regra legada dos executors — compare
   `git log -1 --format=%ci main` e `git log -1 --format=%ci dev` — a
   mais recente é a target; sem `dev`, use `main`. Nunca fixe `main`
   por padrão.

Use `question` para exibir o resumo e confirmar:
- Repo: `<org>/<repo>`
- Base: `<target determinada>`
- Head: `feature/<slug>`
- Title: `<título da feature (RN-NNN)>`
- Body: (exibir resumo)

### Passo 4 — Criar PR

```bash
gh pr create \
  --repo "<org>/<repo>" \
  --base "<target determinada no Passo 3>" \
  --head "feature/<slug>" \
  --title "<título>" \
  --body "<body>" \
  --label "<labels>"
```

Se o número da issue foi informado, o body inclui `Closes #<numero>` para
fechamento automático.

## Exemplo de uso

```
Usuário: "abrir PR da task de criar endpoint de bloqueios"
rdd-dev → @rdd-github-orchestrator → rdd-gh-pr-creator

Saída:
✔ PR #12 criado: Arbor-API#12 — Criar endpoint GET /bloqueios
  https://github.com/Acme-Group/Arbor-API/pull/12
```