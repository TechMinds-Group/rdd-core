# Regra da organização — Demo (pack demo)

Regra da org Demo instalada no runtime via `provides` do pack `demo`
(v1.0.0, commit `def5678`). Conteúdo da versão 1.0.0 — atualizado em
relação à 0.9.0.

## Identidade

- Organização fictícia Demo — repos `<Produto>-<Camada>` na org `demo-org`.

## Infraestrutura validada

- VPS + Docker Compose, registry `ghcr.io/demo-org`, tunnel exclusivo por
  servidor (padrão do pack — IMP-105).

## Runbooks

- Deploy: push em `main` → pipeline → `deploy.sh` na VPS.
- Rollback de pack: restaurar pin anterior no `.rdd/sources.yaml` e
  reinstalar via `rdd-pack-update` (runtime volta ao estado do pin).
