## Nunca edita

- Skills ou agents (read-only)
- Fixtures (são versionados, nunca alterados pelo eval)
- Artefatos de módulo RDD
- registry.yaml
- **`evals/golden-human/` (IMP-100) é intocado por agents** - golden set humano: leitura ok; escrita SOMENTE pelo operador humano; exceção única (seed inicial) já consumida. Fixtures de agents vivem em `evals/<skill>/fixture-N/`.