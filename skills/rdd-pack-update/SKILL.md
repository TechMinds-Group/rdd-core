---
name: rdd-pack-update
description: >-
  Atualiza packs instalados no runtime RDD — git pull dos clones em
  `packs/<id>/`, respeitando o pin do `.rdd/sources.yaml` (só move o pin
  sob pedido explícito do operador), valida `requires-core`
  (BREAKING-CHANGES.md) e no-override, reinstala os paths de `provides`
  e reporta o delta. Use quando o usuário pedir "atualizar packs",
  "update do pack", "atualizar pack <id>", "sync de packs" ou "pack update".
---

# rdd-pack-update — Atualização de packs instalados

Mantém os packs instalados no runtime (`~/.config/opencode/`) em sincronia
com os clones em `packs/<id>/`. O **pin** do lockfile `.rdd/sources.yaml`
manda: a skill reinstala a partir do commit pinado; mover o pin (atualizar
de fato a versão) é sempre decisão explícita do operador. Contrato do
pack.yaml em `PACK_SCHEMA.md`; compatibilidade em `BREAKING-CHANGES.md`.

## Lê (upstream)

- `packs/<id>/` — clones dos packs (estado git, `pack.yaml`, paths de `provides`)
- `.rdd/sources.yaml` — lockfile com o pin atual (pack → version, commit, paths[])
- `rules/client-profile.md` — faixa autorizada (`packs: [<id>@<faixa>]`)
- `registry.yaml` + `BREAKING-CHANGES.md` — versão local do core e compatibilidade (`requires-core`)

## Gera (downstream)

- Instalação atualizada no runtime — cópia dos paths de `provides` (nunca `acumulo/`)
- `.rdd/sources.yaml` atualizado (novo pin/delta quando o operador autorizar mover)
- Relatório textual do delta (versão antiga → nova, paths adicionados/removidos/alterados).
  **Nunca persiste nada fora disso.**

## Nunca edita

- Arquivos do core — só instala paths de `provides` sem colisão com path existente do core
- `acumulo/` do pack — nunca instala nem altera
- `rules/client-profile.md` — read-only (a faixa é decisão do operador/rdd-setup)
- Repos remotos — nunca commita nem pusha (nem no core, nem no pack)

## Tools

- `read`/`glob`/`grep`: **allow** — `pack.yaml`, `.rdd/sources.yaml`, perfil, compat
- `bash`: **ask** — `git pull`/`git clone`/`git checkout` nos clones, cópia de arquivos
- `edit`/`write`: **apenas** `.rdd/sources.yaml`, paths instalados de pack e `.gitignore` local (seção gerada)
- `skill`: **allow**

## Modo de erro

- **Pack ausente/corrompido** → reclona a partir do remote registrado no lockfile/perfil (idempotente) e reinstala.
- **`requires-core` incompatível** com a versão local do core → **FALHA clara** apontando `BREAKING-CHANGES.md`; pula o pack e registra pendência.
- **Colisão de path** (um `provides` colide com path do core) → **aborta sem instalar nada** deste pack (transacional — runtime não fica pela metade).

## Workflow

1. **Inventário:** leia `.rdd/sources.yaml` e `rules/client-profile.md`
   (`packs:`) e monte a lista de packs alvo — todos os instalados, ou o
   `<id>` pedido pelo operador.
2. **Sincronize o clone:** para cada pack, `git -C packs/<id> fetch` + status;
   ausente ou corrompido → reclona (Modo de erro).
3. **Resolva a versão:** o **pin** do `.rdd/sources.yaml` manda —
   `git checkout <commit-pinado>`. Mover o pin (main mais novo, bump de
   versão) **só sob pedido explícito do operador**; a faixa do perfil
   autoriza o destino, nunca autoriza o movimento sozinha.
4. **Valide `requires-core`:** leia `pack.yaml` e confira a faixa contra a
   versão local do core (`registry.yaml` `version` + `BREAKING-CHANGES.md`).
   Incompatível → FALHA clara (Modo de erro) e siga para o próximo pack.
5. **Valide no-override:** nenhum path de `provides` pode colidir com path
   do core. Colisão → aborte a instalação deste pack sem instalar nada
   (transacional) e registre pendência.
6. **Reinstale:** copie os paths de `provides` do clone para o runtime;
   atualize a seção gerada do `.gitignore` local (paths adicionados/removidos);
   nunca toque em `acumulo/`.
7. **Grave o lockfile e reporte:** atualize `.rdd/sources.yaml`
   (version/commit/paths) somente se o pin mudou; apresente o delta por pack
   (versão antiga → nova, paths ±, pendências ⚠️).

## Casos de borda

- **Pin vs faixa:** a faixa do perfil (`<id>@<faixa>`) só autoriza o destino;
  o pin garante reprodutibilidade. **Não move o pin sem pedido explícito**
  ("atualize para a última" move; "atualize os packs" reinstala o pin atual).
- **Múltiplos packs:** processados de forma independente — falha de um não
  bloqueia os demais; pendências vão para o relatório final.
- **Reclone pós `git clean -fdx`:** clone de pack sumido/corrompido → reclona
  idempotente e reinstala a partir do pin do lockfile (o runtime volta ao
  estado exato do pin).
