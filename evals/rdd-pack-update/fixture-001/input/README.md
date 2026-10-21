# Cenário — update do pack demo (movimento de pin autorizado)

Runtime RDD (`~/.config/opencode/`) com o pack `demo` instalado e pinado.
O operador pede **explicitamente** para mover o pin para a última versão
publicada do pack ("atualize o pack demo para a última" — pedido explícito,
não o update default que reinstala o pin atual).

## Estado inicial (input/)

- `.rdd/sources.yaml` — lockfile com o pin atual do pack `demo`:
  version `0.9.0`, commit `abc1234`, path instalado `rules/packs/demo.md`.
- `packs/demo/pack.yaml` — clone do pack no estado do commit pinado (v0.9.0).
- `rules/client-profile.md` — faixa autorizada `packs: [demo@>=0.9 <2]`
  (referência do cenário; read-only para a skill).

## O que muda no remote (fictício — sem rede e sem git real)

- Novo commit `def5678` no `main` do pack, versionando `1.0.0`.
- `requires-core` continua compatível (">=1 <2"); sem BREAKING-CHANGES.
- `provides` permanece `rules/packs/demo.md` (regra nova de conteúdo).

## Resultado esperado (output-expected/)

- `.rdd/sources.yaml` atualizado — pin movido para version `1.0.0` /
  commit `def5678`, mesmo `paths` instalado.
- Regra nova disponível em `packs/demo/rules/packs/demo.md` (fonte no clone,
  reinstalada por cópia no runtime via `provides`; `accumulation/` intocado).
- `DELTA.md` — relatório do delta por pack (versão antiga → nova, arquivos
  reinstalados, validações `requires-core` e no-override, pendências).
