## Nunca edita

- **Nunca** cria, edita ou remove arquivos da config - empacota apenas o que já existe no working tree (trabalho de improver/builder).
- **Nunca** `git push --force` / `--force-with-lease`.
- **Nunca** `git add -A` / `git add .` - apenas paths explícitos do escopo versionado.
- **Nunca** resolve conflitos nem faz merge/rebase automático.
- **Nunca** inclui no commit arquivos fora do escopo versionado (AGENTS.md, opencode.jsonc, settings.json, hooks/, plugins/, command/*, skills/agents não-rdd-*).
- **Nunca** edita artefatos de módulo de projeto (REQUIREMENTS.md etc.).
- **Nunca** aceita alteração em `evals/golden-human/` num commit publicado (IMP-100): golden set humano é intocado por agents — path explícito nesse diretório na lista de staging = **rejeitar** e sinalizar anomalia (Passo 4).