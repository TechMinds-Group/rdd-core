# evals/ — Testes de Regressão para Skills RDD

Este diretório contém fixtures de teste para skills RDD. Cada fixture
simula uma entrada real e define critérios de aceitação para o output
gerado. A skill `rdd-skill-eval` executa estes testes automaticamente.

## Runner determinístico

Para executar os checks dos criteria.yaml sem agente (rápido e repetível):

```powershell
# Windows (PowerShell 5.1+)
.\run-evals.ps1                                # todas as fixtures
.\run-evals.ps1 -Skill rdd-data-model          # uma skill
.\run-evals.ps1 -Fixture rdd-validate/fixture-001
.\run-evals.ps1 -Changed                       # skills alteradas no git
.\run-evals.ps1 -Module C:\caminho\modulo      # valida outputs de um módulo real
```

```bash
# Linux / macOS / Git-Bash
./run-evals.sh                                 # todas as fixtures
./run-evals.sh --skill rdd-data-model
./run-evals.sh --fixture rdd-validate/fixture-001
./run-evals.sh --changed
./run-evals.sh --module /caminho/modulo
```

- Exit codes: 0 = sem FAIL error · 1 = regressão · 2 = erro de uso
- Sem `-Module`, os checks rodam em **baseline-mode** (module root =
  `output-expected/`). Com `-Module`, validam os artefatos de um módulo real.
- Ambos escrevem relatório em `reports/` e append em `trends/trends.json`.
- No Windows o trends usa o próprio PowerShell; no Linux requer `python3`
  real (sem o stub da Microsoft Store — sem ele, o trends é pulado com aviso).

## Estrutura

```
evals/
└── <skill-name>/
    └── fixture-<NNN>/
        ├── input/               # arquivos de entrada (simulam specs reais)
        │   ├── REQUIREMENTS.md  # (opcional, conforme inputs_required)
        │   ├── API_CONTRACTS.md
        │   ├── UI_SPEC.md
        │   └── ...
        ├── criteria.yaml        # checks que o output deve atender
        └── output-expected/     # (opcional) outputs de referência para diff
```

## Quando rodar

- **Automaticamente:** `@rdd-workflow-improver` e `@rdd-workflow-builder`
  rodam evals após edições/criações de skills
- **Manual:** `rdd-skill-eval --skill rdd-data-model` ou `rdd-skill-eval --all`

## Como criar uma fixture nova

1. Crie diretório `evals/<skill>/fixture-<N+1>/input/`
2. Adicione os arquivos de entrada (os mesmos que a skill lê)
3. Crie `criteria.yaml` com os checks desejados (veja schema abaixo)

## Schema do criteria.yaml

```yaml
name: "Nome descritivo do teste"
description: "Contexto do que está sendo testado"
inputs_required: [REQUIREMENTS.md, API_CONTRACTS.md]

checks:
  - type: file_exists        # output foi gerado?
    path: "specs/DATA_MODEL.md"
    severity: error           # error | warning

  - type: section_exists      # seção markdown presente?
    path: "specs/DATA_MODEL.md"
    section: "## 1. Diagrama"
    severity: error

  - type: contains            # texto esperado?
    path: "specs/DATA_MODEL.md"
    pattern: "RN-001"
    severity: error

  - type: not_contains        # texto proibido?
    path: "specs/DATA_MODEL.md"
    pattern: "ORGEX"
    severity: warning

  - type: no_todos            # placeholders não preenchidos?
    path: "specs/DATA_MODEL.md"
    patterns: ["TODO", "FIXME"]
    severity: warning

  - type: frontmatter_valid   # YAML front matter válido?
    path: "specs/DATA_MODEL.md"
    severity: error

  - type: id_sequence         # IDs em ordem crescente de aparição?
    path: "specs/DATA_MODEL.md"
    pattern: "RN-(\\d+)"
    allow_gaps: true
    severity: error

  - type: cross_ref           # IDs citados existem nas fontes?
    path: "specs/DATA_MODEL.md"
    pattern: "RN-(\\d+)"
    sources: ["REQUIREMENTS.md"]
    severity: error

  - type: mermaid_valid       # blocos mermaid sintaticamente ok?
    path: "specs/DATA_MODEL.md"
    severity: error

  - type: line_count_range    # output na faixa esperada de linhas?
    path: "specs/DATA_MODEL.md"
    min: 100
    max: 400
    severity: warning

  - type: section_order       # seções na ordem do template?
    path: "specs/DATA_MODEL.md"
    sections:
      - "## 1. Diagrama Entidade-Relacionamento"
      - "## 2. Tabelas"
    severity: error
```

## Tipos de check

| Tipo | O que verifica |
|------|---------------|
| `file_exists` | Se o arquivo de output foi gerado |
| `section_exists` | Se uma seção markdown específica existe |
| `contains` | Se o output contém um pattern (regex ou texto) |
| `not_contains` | Se o output NÃO contém um pattern |
| `no_todos` | Se o output não tem placeholders (TODO, FIXME, etc.) |
| `frontmatter_valid` | Se o YAML front matter é válido |
| `id_sequence` | Se os IDs aparecem em ordem crescente (sem renumeração) |
| `cross_ref` | Se todo ID citado no output existe nos arquivos de origem |
| `mermaid_valid` | Se os blocos mermaid têm tipo, cercas e chaves ok |
| `line_count_range` | Se o output está entre min e max linhas |
| `section_order` | Se as seções existem e aparecem na ordem especificada |
| `dir_has_files` | Se o diretório tem ao menos 1 arquivo (outputs com data no nome) |
| `not_file_exists` | Se o arquivo NÃO existe (contrato de abort — skill recusa criar) |
| `reference_match` | Diff normalizado contra baseline em output-expected/ |

## Retenção de relatórios

Os relatórios em `evals/reports/` são podados para manter apenas os **8 relatórios mais recentes por tipo**. O tipo é o prefixo do nome antes do timestamp (formato `yyyy-MM-dd-HHmmss`), ex.: `EVAL_REPORT_runner_all_`, `EVAL_REPORT_runner_registry_`, `EVAL_REPORT_runner_skill-rdd-setup_`, `EVAL_REPORT_rdd-skill-eval_` (cada skill é um tipo próprio).

- **Histórico permanente:** relatórios antigos vivem no histórico do git — recuperáveis via `git log -- evals/reports`.
- **CI:** cada execução sobe os relatórios como artifacts, com retenção de 14 dias.
- **Poda:** manual/na publicação — o runner nunca apaga relatórios.

## Tipos de fixture (IMP-121)

- **Baseline** (padrão): `output-expected/` presente — o runner valida os checks contra ele. Ausente sem marca `mode: manual` = **FAIL** (fixture quebrada — ver `.gitignore` ancorado na raiz).
- **Rubrica manual** (`mode: manual` no criteria.yaml): checks `structural`/`semantic` executados por agente/humano contra a skill real; o runner lista como SKIPPED ("rubrica manual"). 13 fixtures marcadas em 21/10/2026. Dívida de automação: `rdd-change-request/fixture-002`, `rdd-core-publish`, `rdd-skill-eval`, `rdd-task-spec/fixture-003` têm checks parseáveis pendentes de `output-expected`; as demais são rubricas de revisão.
- **Module-mode**: qualquer fixture roda contra um módulo real via `--module <path>`.

Dívida de encoding: títulos com mojibake em fixtures antigas (ex.: `rdd-change-request/fixture-002`) — corrigir ao automatizar.