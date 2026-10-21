# Cenário — onboarding da Nimbus no RDD open core

O operador pede o scaffold do pack da empresa fictícia **Nimbus**
("criar pack" / "onboarding de empresa no open core"). Respostas da
coleta (UMA `question` agrupada — IMP-043):

| Pergunta | Resposta |
|---|---|
| Organização/empresa | Nimbus |
| Id do pack | `nimbus` (lowercase-hyphen) |
| Org GitHub | `nimbus-org` (default do perfil, confirmado pelo operador) |
| Nome do repo | `nimbus-org.RDD.PACK.NIMBUS` (default validado) |
| Visibilidade | `private` |
| Nome da regra | `rules/packs/nimbus.md` (default) |

## Estado do ambiente (input/)

- `client-profile.md` — perfil parcial com `org_github: nimbus-org` e
  nenhum pack registrado (`packs` e `pack_repos` vazios → id livre).
- Nenhuma colisão — `rules/packs/nimbus.md` não existe no core
  (no-override ok na criação).
- `requires-core` proposto (">=1 <2") compatível com a versão local do
  core (`registry.yaml` + `BREAKING-CHANGES.md`).

## Escopo desta fixture

Somente o **esqueleto local** em `packs/nimbus/` — conforme o passo 3 do
workflow da skill, a partir do contrato `PACK_SCHEMA.md`:

- `pack.yaml` v0.1.0 — `id`, `name`, `version: 0.1.0`, `requires-core`,
  `provides: [rules/packs/nimbus.md]` e `accumulation` (IMP-116) com
  `accumulation/patterns/`, `accumulation/metrics/` e
  `accumulation/reverses/`.
- Regra da org `rules/packs/nimbus.md` com seções-guia a preencher
  (Identidade, Infraestrutura validada, Runbooks).
- Acúmulo vazio com READMEs — `accumulation/{patterns,metrics,reverses}/README.md`.
- `README.md` do pack.

Passos de efeito externo (primeiro commit, `gh repo create`, entrada no
perfil e instalação no runtime) dependem de confirmação explícita e ficam
como pendências (⚠️) no relatório final — fora do escopo do output-expected.
