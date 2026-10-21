---
name: rdd-pack-publish
description: >-
  Publica o pack da organização no repositório remoto — valida o working tree
  do clone em `packs/<id>/`, commita as mudanças, faz push origin main,
  reinstala os paths de `provides` no runtime (requires-core + no-override),
  move o pin do `.rdd/sources.yaml` para o novo commit e reporta o delta.
  Par de publicação do `rdd-pack-update` (que consome); segue a convenção
  `rdd-<repo>-<action>` (o core tem os análogos rdd-core-update/rdd-core-publish).
  Use quando o usuário pedir "publicar pack", "publish do pack", "subir o pack",
  "commitar o pack" ou "publicar mudanças do pack".
---

# rdd-pack-publish — Publicação do pack da organização

Fecha o ciclo do mantenedor no open core: editou o conteúdo do pack
(`packs/<id>/`) → publica (commit + push) → reinstala no runtime → move o
pin. Espelho do par: `rdd-pack-update` traz do remote para o runtime; esta
skill leva do working tree do clone para o remote e o runtime. Contrato do
`pack.yaml` em `PACK_SCHEMA.md`; compatibilidade em `BREAKING-CHANGES.md`.

## Lê (upstream)

- `packs/<id>/` — clone do pack (working tree, estado git)
- `packs/<id>/pack.yaml` — version/requires-core/provides
- `.rdd/sources.yaml` — pin atual (version + commit + paths[])
- `registry.yaml` + `BREAKING-CHANGES.md` — versão local do core e compatibilidade
- `rules/client-profile.md` — packs autorizados (`packs: [<id>@<faixa>]`)

## Gera (downstream)

- Commit + push do repo do pack (origin main)
- Reinstalação dos paths de `provides` no runtime (cópia a partir do clone)
- `.rdd/sources.yaml` com novo pin (version + commit)
- Relatório textual do delta (arquivos ±, pin novo, instalação).
  **Nunca persiste nada fora disso.**

## Nunca edita

- Arquivos do core — no-override: `provides` só instala paths novos, nunca sobrescreve path existente do core
- `accumulation/` do pack — content edits são da org: publique via commit normal do pack, mas NUNCA altere você mesmo o conteúdo de patterns/metrics/reverses
- Packs de terceiros — só o pack do perfil em operação
- `rules/client-profile.md` — read-only (a faixa é decisão do operador/rdd-setup)

## Tools

- `read`/`glob`/`grep`: **allow** — `pack.yaml`, `.rdd/sources.yaml`, perfil, compat
- `question`: **allow** — confirmações agrupadas (mensagem de commit, push, mover pin — IMP-043)
- `bash`: **ask** — `git status/diff/add/commit/push` no clone do pack, cópia de `provides`
- `edit`/`write`: **apenas** paths de `provides` no runtime + `.rdd/sources.yaml`

## Modo de erro

- **Working tree do clone limpo e nada a publicar** → informa *"nada a publicar"* e encerra sem tocar em nada.
- **WIP não relacionado ao pack no core** → NÃO toque (nunca `git add` no core); reporte e siga apenas com o clone do pack.
- **Push rejeitado (non-FF)** → **ABORTA** e orienta rebase manual (`git -C packs/<id> rebase origin/main`); nunca força push.
- **`requires-core` incompatível** com o core local → **ABORTA** apontando `BREAKING-CHANGES.md` (o que mudou no major e como migrar).
- **Colisão de path core × `provides`** → **ABORTA** sem instalar nada deste pack (no-override — transacional).

## Workflow

1. **Valide o id:** confira o `<id>` do pack em `rules/client-profile.md` (`packs:`); id ausente ou não autorizado → aborta.
2. **Inspecione o clone:** `git -C packs/<id> status` + `git diff` — WIP não relacionado ao pack → pergunte; mudanças do pack → resuma o diff (arquivos ±).
3. **Confirme (question única, IMP-043):** apresente o pacote completo — arquivos, mensagem de commit sugerida (Conventional Commits), push e movimento de pin — opções aprovar / ajustar / cancelar.
4. **Commite:** `git -C packs/<id> add -u` (só o pack, nunca o core) + `git commit -m "<mensagem aprovada>"`; path novo (untracked) → `git add <path>` explícito — nunca `git add .`/`git add -A`.
5. **Pusha:** `GIT_TERMINAL_PROMPT=0 git -C packs/<id> push origin main` (KE-001 — nunca travar em prompt de credencial; falha rápida). Falhou por credencial (WSL) → commit local mantido; oriente o push pelo lado Windows com `wslpath -w packs/<id>`.
6. **Reinstale `provides`:** valide `requires-core` × versão local do core (`registry.yaml` + `BREAKING-CHANGES.md`) e no-override (nenhum path colide com path do core); copie os paths de `provides` do clone para o runtime; atualize a seção gerada do `.gitignore` local. Nunca copie `accumulation/`.
7. **Mova o pin:** atualize `.rdd/sources.yaml` com o novo `version` (do `pack.yaml`) e o novo `commit` (HEAD do clone).
8. **Reporte:** delta de arquivos (±), pin novo (version + commit), resultado da instalação — e avise que a config exige reinício do OpenCode para valer.

## Casos de borda

- **Primeiro publish pós-scaffold:** repo do pack sem remote `origin` → publica apenas local (commit ok, push pendente), reinstala e registra a pendência de `git remote add origin` no relatório.
- **Pack sem mudanças:** working tree limpo e HEAD == origin/main → *"nada a publicar"*; nada é commitado nem reinstalado.
- **`provides` colidindo com path do core:** aborta a reinstalação (no-override) — commit/push já feitos permanecem; oriente renomear o path no `pack.yaml`.
- **Múltiplos packs:** rode por pack, um de cada vez — nunca em lote; falha de um não publica os demais por cima.
