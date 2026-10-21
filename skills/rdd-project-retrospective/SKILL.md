---
name: rdd-project-retrospective
description: >-
  Retrospectiva pós-projeto — captura aprendizados, padrões e métricas
  de cada projeto concluído. Gera RETROSPECTIVE.md em docs/projects/<nome>/,
  invoca rdd-pattern-extractor para extrair padrões automaticamente e
  rdd-metrics-collector para acumular métricas. Use quando o usuário pedir
  "retrospectiva", "debrief", "o que aprendemos", "review do projeto",
  "lições aprendidas". Trigger: manual, ao final de projeto ou fase.
---
# rdd-project-retrospective — Retrospectiva Pós-Projeto

Captura aprendizados de cada projeto para alimentar o ciclo de melhoria
contínua do RDD. Cada retrospectiva vira um documento em
`docs/projects/<nome>/RETROSPECTIVE.md` que alimenta a pattern library
e o tracker de métricas.

## Lê (upstream)

- `docs/projects/<nome>/` — estado do projeto (se existir)
- `WORKFLOW_IMPROVEMENTS.md` — IMPs registrados durante o projeto
- `DECISIONS.md` — ADRs tomados durante o projeto
- `registry.yaml` — skills disponíveis
- Código do repo do projeto (se acessível) — para métricas

## Gera (downstream)

- `docs/projects/<nome>/RETROSPECTIVE.md` — documento da retrospectiva
- Invoca `rdd-pattern-extractor` — extrai padrões automaticamente
- Invoca `rdd-metrics-collector` — acumula métricas
- Paths `_docs/patterns/` e `_docs/METRICS.md` = repo de docs do produto
  (`repo_docs_rdd` no AGENTS.md — IMP-061); resolução feita pelas skills invocadas

## Nunca edita

- Código-fonte do projeto
- Artefatos de spec do módulo
- `WORKFLOW_IMPROVEMENTS.md` (read-only aqui — IMPs são registrados
  pelo improver, não pela retrospectiva)

## Tools

- `read`/`glob`/`grep` — inspecionar estado do projeto
- `question` — coletar feedback do usuário
- `write` — gerar RETROSPECTIVE.md
- `skill` — invocar rdd-pattern-extractor e rdd-metrics-collector

## Modo de erro

`warn` — se `docs/projects/<nome>/` não existir, crie a estrutura.
Se o projeto não tiver IMPs ou ADRs registrados, pule essas seções
com aviso.

## Workflow

### Passo 1 — Identificar o projeto

Pergunte ao usuário qual projeto está sendo retrospectado.
O nome deve corresponder ao diretório em `docs/projects/` ou ao
nome do repo. Se o projeto é novo, crie a estrutura:

```
docs/projects/<nome>/
└── RETROSPECTIVE.md
```

### Passo 2 — Coletar dados automaticamente

Leia automaticamente:
1. `WORKFLOW_IMPROVEMENTS.md` — filtre IMPs do período do projeto
2. `DECISIONS.md` — filtre ADRs do período do projeto
3. `registry.yaml` — conta skills ativas
4. `evals/reports/` — relatórios de eval existentes

### Passo 3 — Coletar feedback do usuário

Use `question` para coletar:

1. **O que funcionou bem?** (padrões, ferramentas, processos)
2. **O que não funcionou?** (problemas, gargalos, decisões erradas)
3. **Padrões novos descobertos?** (soluções reutilizáveis)
4. **Skills que faltaram?** (necessidades não atendidas)
5. **Métricas subjetivas?** (satisfação, complexidade, risco)

### Passo 4 — Gerar RETROSPECTIVE.md

Gere o documento com o template abaixo:

```markdown
# Retrospectiva — <Nome do Projeto>

**Data:** DD/MM/AAAA
**Projeto:** <nome> (<repo>)
**Duração:** <estimativa ou "N/A">
**Skills usadas:** <lista>

## O que funcionou

- <padrão/pattern que deu certo>
- <ferramenta que surpreendeu>
- <processo que fluiu bem>

## O que não funcionou

- <problema recorrente>
- <decisão que precisou ser revertida>
- <gargalo identificado>

## Padrões extraídos

- <novo pattern descoberto> → ver `_docs/patterns/<nome>/PATTERN.md`
- <convenção que surgiu naturalmente>

## Métricas do projeto

| Métrica | Valor |
|---------|-------|
| Skills usadas | N |
| Issues de qualidade | N |
| RNs implementadas | N |
| Quality gate final | PASS/WARN/FAIL |
| IMPs registrados | N |
| ADRs tomados | N |

## Ações para o workflow

| Ação | Tipo | Prioridade |
|------|------|------------|
| <melhoria na skill X> | IMP | alta |
| <novo pattern> | pattern | média |
| <checklist a ajustar> | IMP | baixa |

## Scorecard do Workflow (IMP-048)

Nota 0-10 por segmento, **somente com evidência do período** (sem uso = N/A,
nunca chute). Toda nota cita a evidência. Taxonomia fixa:

**Fases:** Intake · Requisitos & cliente · Tradução técnica · Entrega/tasks ·
Desenvolvimento · Verificação & qualidade · Suporte & pós-produção

**Transversais:** Governança da config · Meta-melhoria · Observabilidade &
eficiência (latência/contexto/custo) · Padrões & aprendizado · Segurança ·
Integrações externas · Portabilidade & onboarding

| Segmento | Tipo | Nota | Evidência |
|----------|------|:----:|-----------|
| <14 linhas, uma por segmento> | fase/transversal | 0-10 ou N/A | <fato do período ou "sem uso"> |

**Regras:** nota geral = média das fases COM evidência (transversais listadas
à parte); tendência vs milestone anterior vai para `_docs/METRICS.md`
(§Scorecard do Workflow, append-only via `rdd-metrics-collector`).
```

### Passo 4b — Scorecard do Workflow (IMP-048)

Preencha a seção `## Scorecard do Workflow` do RETROSPECTIVE.md:
1. Para cada um dos 14 segmentos, busque evidência no período (artefatos
   gerados, evals, métricas, incidentes). Sem evidência → N/A.
2. Nota geral = média das FASES com evidência; transversais informam contexto.
3. Append da linha do milestone na tabela `§Scorecard do Workflow` de
   `_docs/METRICS.md` (via hand-off ao `rdd-metrics-collector`, como o bloco
   de performance — IMP-041).

### Passo 5 — Extrair padrões automaticamente

Invocar `rdd-pattern-extractor` para:
1. Ler a seção "Padrões extraídos" da retrospectiva
2. Criar/atualizar `_docs/patterns/<nome>/PATTERN.md` para cada padrão
3. Atualizar `_docs/patterns/INDEX.md`

### Passo 6 — Coletar métricas

Invocar `rdd-metrics-collector` para:
1. Extrair métricas da retrospectiva
2. Adicionar linha em `_docs/METRICS.md`
3. Calcular tendências vs projetos anteriores

### Passo 7 — Registrar IMPs (se aplicável)

Se a retrospectiva identificou ações de melhoria para o workflow,
o `rdd-project-retrospective` deve:
1. Listar as ações identificadas
2. Perguntar ao usuário quais registrar como IMP
3. Para cada IMP aprovado, encaminhar para `rdd-workflow-improver`

**Não registre IMPs automaticamente** — sempre confirme com o usuário.

## Casos de Borda

- **Projeto muito curto (< 1 semana):** retrospectiva simplificada,
  métricas limitadas
- **Projeto sem código (apenas specs):** pule métricas de código,
  foque em specs e processos
- **Múltiplos projetos simultâneos:** retrospectiva por projeto,
  não consolidada
- **Projeto cancelado:** faça retrospectiva do que foi feito até
  o cancelamento (lições de abandono)
- **Primeiro projeto (sem histórico):** pule tendências, foque em
  establishing baseline

## Formato de commit

```
docs(retrospective): <nome-do-projeto> — retrospectiva pós-projeto
```
