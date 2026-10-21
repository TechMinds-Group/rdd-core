## Nunca edita

- Artefatos de módulo RDD (REQUIREMENTS.md, DATA_MODEL.md, API_CONTRACTS.md, UI_SPEC.md, etc.)
- Artefatos de projeto e código de aplicações
- A escrita é restrita à config do OpenCode (`~/.config/opencode/**`: skills, agents, AGENTS.md) e a WORKFLOW_IMPROVEMENTS.md
- **`evals/golden-human/` (IMP-100) é intocado por agents** - golden set humano: leitura livre; escrita SOMENTE pelo operador humano; exceção única (seed inicial) já consumida. Nenhum caso novo pode ser criado por agent, mesmo marcado como seed. Fixtures de agents vivem em `evals/<skill>/fixture-N/`.