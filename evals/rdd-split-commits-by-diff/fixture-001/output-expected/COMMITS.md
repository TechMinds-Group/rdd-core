# Plano de Commits — working tree misturado (Auth Service)

Estado de entrada: 4 arquivos alterados em 3 concerns + 1 arquivo não
versionado (`.env.local` — segredo local, fica fora de qualquer commit).

## Commit 1 — feat(auth): renova sessão expirada automaticamente

- Arquivos: `src/auth/session.ts`, `src/auth/session.test.ts`
- Tipo: feat — nova funcionalidade (renovação automática de sessão)
- Agrupamento: implementação + teste do mesmo intent (arquivos single-intent)

## Commit 2 — fix(api): aumenta timeout do client HTTP para 30s

- Arquivos: `src/api/client.ts`
- Tipo: fix — correção de comportamento existente
- Agrupamento: concern distinto do Commit 1; um intent por commit

## Commit 3 — docs: atualiza guia de setup com variáveis de ambiente

- Arquivos: `docs/setup.md`
- Tipo: docs — somente documentação

## Estratégia de staging

- Commits 1-3: full-file stage — `git add <arquivo>` (arquivos single-intent)
- Arquivo mixed-intent: hunk-level — `git add -p <arquivo>`
- Ajuste fino do índice: `git restore --staged <arquivo>`
- `.env.local`: nenhum commit o inclui (segredo)

## Verificação

- Após cada commit: `git show --stat --oneline -1` e `git status --short`
- Ao final: `git log --oneline -n 3` e `git status` — `.env.local` permanece sem staging
