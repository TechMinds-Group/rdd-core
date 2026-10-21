# RDD.PACK.NIMBUS — pack da organização Nimbus

Repo privado do pack Nimbus no RDD open core (arquitetura
CORE / PACK / PROFILE — ver `PACK_SCHEMA.md`). Esqueleto criado pelo
`rdd-pack-scaffold` (v0.1.0).

## Conteúdo

- `pack.yaml` — contrato do pack (`id`, `name`, `version`, `requires-core`,
  `provides`, `accumulation`).
- `rules/packs/nimbus.md` — regra da org, com seções-guia a preencher.
- `accumulation/` — acúmulo de conhecimento da org (patterns, metrics,
  reverses) — versionado neste repo, NUNCA instalado no runtime (IMP-116).

## Instalação

Os paths de `provides` são copiados para o runtime pelo instalador
(`rdd-pack-update` / `rdd-setup`): instalação por cópia, no-override de
paths do core, pin de commit em `.rdd/sources.yaml`.
