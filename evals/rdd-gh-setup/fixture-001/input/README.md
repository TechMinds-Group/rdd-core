# Cenário — fixture-001

Máquina nova para onboarding do RDD:

- `gh` CLI pode ou não estar instalada (wizard decide no Passo 1).
- Usuário pode ou não estar autenticado (Passo 3 orienta `gh auth login --web`).
- Org esperada: `org_github` do `rules/client-profile.md` (IMP-105; nesta máquina: Acme-Group).
- Pré-condição das skills `rdd-gh-issue-creator` e `rdd-gh-pr-creator`.

A skill não lê artefatos de módulo — valida o ambiente via `bash`
(`gh --version`, `gh auth status`) e emite relatório textual no Passo 5.
