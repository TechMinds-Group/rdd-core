---
name: rdd-drift-detector
description: >-
  Detecta degradação temporal na qualidade dos artefatos RDD, comparando
  o estado atual com um baseline de qualidade. Mede tendência — artefatos
  ficando mais curtos, com mais erros, desviando do padrão. Gera
  DRIFT_REPORT_<timestamp>.md com score de drift por artefato. Diferente
  de rdd-validate (integridade pontual da DAG), este mede tendência.
  Use quando o usuário pedir "detectar drift", "relatório de drift", "DRIFT_REPORT" ou "verificar degradação dos artefatos".
---
# rdd-drift-detector — Detector de Drift de Qualidade

Detecta degradação temporal na qualidade dos artefatos RDD, comparando
o estado atual com um baseline anterior. Mede *tendência* — artefatos
ficando mais curtos, perdendo cobertura de RNs, desviando de templates.

**Diferenciação:**

| Skill | Escopo | Momento |
|-------|--------|---------|
| `rdd-validate` | Integridade pontual da DAG (RNs sem downstream, IDs quebrados) | Após tradução técnica |
| `rdd-progress` | Progresso do pipeline (cobertura, fase atual) | Reunião de status |
| `rdd-drift-detector` | Tendência temporal de qualidade (baseline → atual) | Periodicamente, antes de entregas |

## Referências

- Grafo de documentos: `CONSTITUTION.md §4`
- Estrutura de artefatos: IMP-011

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):

- **Raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
- **`specs/`:** DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, FIGMA_PROMPTS.md, COMPLIANCE.md
- **`quality/`:** TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEAuILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md
- **`delivery/`:** TASKS.md, TASKS_*.md, TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md
- **`support/`:** LEGACY_CONTEXT.md, KNOWN_ERRORS.md, MIGRATION.md, CHANGE_REQUESTS.md
- **`glossaries/`:** DEV_GLOSSARY.md, uUSINESS_GLOSSARY.md, USER_GLOSSARY.md, GLOSSARY.md
- **`docs/`:** howto/*.md e documentos auxiliares
- **`meetings/`, `contracts/`:** checkpoints (inalterados)

**Regra de fallback (transição):** ao **LER** um artefato, verifique primeiro
o caminho novo (ex: `specs/DATA_MODEL.md`); se não existir, use o caminho
legado na raiz do módulo (ex: `DATA_MODEL.md`). Ao **ESCREVER/GERAR**, use
sempre o caminho novo. Módulos ainda não migrados via `rdd-restructure`
continuam legíveis durante a transição.

## Lê (upstream)

- `<modulo>/<projeto>/` — todos os artefatos RDD (RAIZ + specs/ + quality/ + delivery/ + support/ + glossaries/)
- `<modulo>/<projeto>/quality/DRIFT_BASELINE.md` (baseline anterior, se existir)

## Gera (downstream)

- `<modulo>/<projeto>/quality/DRIFT_REPORT_<yyyy-MM-dd-hh:mm>.md`
- `<modulo>/<projeto>/quality/DRIFT_BASELINE.md` (atualiza o baseline para comparações futuras)

## Nunca edita

- Artefatos técnicos (DATA_MODEL, API_CONTRACTS, UI_SPEC, ARCHITECTURE, SECURITY)
- Artefatos de requisitos (REQUIREMENTS.md, DECISIONS.md)
- Artefatos de qualidade (TRACEABILITY, VALIDATION_REPORT, PROPAGATION_STATUS)
- Artefatos de delivery (TASKS, SCOPE_AGREEMENT, CLIENT_REQUIREMENTS)

## Tools

- `glob` (listar artefatos do módulo, verificar baseline)
- `read` (ler artefatos para medir métricas, ler baseline anterior)
- `grep` (buscar IDs RN-XXX, referências cruzadas, padrões de template)
- `write` (escrever DRIFT_REPORT e atualizar DRIFT_BASELINE)

## Modo de erro

`warn` — se o baseline não existir, compare com um baseline "zero"
(sem histórico) e gere o relatório como baseline inicial. Não bloqueie
a execução.

## Formato de commit

```
docs(governance): add drift report <timestamp>
```

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum módulo RDD encontrado. Informe o caminho do módulo."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual módulo analisar.

### Passo 2 — Carregar baseline anterior

1. Verifique se `<modulo>/<projeto>/quality/DRIFT_BASELINE.md` existe.
2. Se existir, leia e extraia as métricas do baseline (tamanho, cobertura,
   contagem de erros, timestamps).
3. Se não existir, marque como "baseline inaugural" — a primeira execução
   estabelece o baseline sem comparação.

### Passo 3 — Calcular métricas atuais

Para cada artefato RDD relevante (exclua CHANGELOG.md, CONSTITUTION.md):

#### Métrica 1: Tamanho (linhas)

Conte o número de linhas do artefato. Compare com o baseline:
- Diminuição > 20% → 🔴 drift negativo (artefato encurtando)
- Diminuição 10-20% → 🟡 drift leve
- Estável ou crescendo → ✅ ok

#### Métrica 2: Cobertura de RNs

Busque por referências a `RN-XXX` no artefato. Conte quantas RNs únicas
são referenciadas. Compare com o baseline:
- Diminuição > 10% → 🔴 drift negativo (perdendo cobertura)
- Diminuição 5-10% → 🟡 drift leve
- Estável ou crescendo → ✅ ok

**Artefatos aplicáveis:** DATA_MODEL, API_CONTRACTS, UI_SPEC,
ACCEPTANCE_CRITERIA, USER_STORIES, TRACEABILITY.

#### Métrica 3: IDs Quebrados

Busque por `RN-XXX`, `PEND-XXX`, `DEC-XXX`, `CR-XXX` no artefato.
Verifique se cada ID referenciado existe no documento de origem
(REQUIREMENTS.md, DECISIONS.md, CHANGE_REQUESTS.md).

Compare com o baseline:
- Aumento de IDs quebrados → 🔴 drift negativo
- Diminuição → ✅ melhoria
- Estável → ✅ ok

#### Métrica 4: Formato/Estrutura

Verifique se o artefato segue o template padrão:
- Presença de front matter YAML (`---`)
- Presença de seções obrigatórias (varia por artefato)
- Ausência de placeholders (`TODO`, `FIXME`, `<descrição>`, `[NÃO IMPLEMENTADO]`)

Compare com o baseline:
- Mais placeholders que baseline → 🔴 drift negativo
- Menos placeholders → ✅ melhoria
- Estável → ✅ ok

#### Métrica 5: Frequência de Atualização

Se o módulo estiver em Git, verifique a data da última modificação
de cada artefato via `git log -1 --format=%ai -- <arquivo>`.

Classifique:
- Atualizado nos últimos 7 dias → ✅
- 7-30 dias sem atualização → 🟡 (stale)
- > 30 dias → 🔴 (muito stale)

Compare com o baseline (se disponível): se artefato que era "fresque"
agora é "stale" → drift.

### Passo 4 — Calcular score de drift

Para cada artefato, calcule o **drift score** (0-100):

- Cada métrica 🔴 = 25 pontos de drift
- Cada métrica 🟡 = 10 pontos de drift
- Cada métrica ✅ = 0 pontos

**Drift score do artefato** = soma dos pontos (máx 100).

Classificação:
- 0 → ✅ Sem drift
- 1-25 → 🟡 Drift leve
- 26-50 → 🟠 Drift moderado
- 51-75 → 🔴 Drift severo
- 76-100 → ❌ Drift crítico

**Drift score global** = média dos drift scores dos artefatos.

### Passo 5 — Gerar relatório

Monte o relatório com o template abaixo. Inclua resumo executivo com
drift score global, tabela por artefato, detalhamento das métricas,
tendência comparada ao baseline e recomendações de ação.

### Passo 6 — Atualizar baseline

Salve as métricas atuais como novo baseline em
`<modulo>/<projeto>/quality/DRIFT_BASELINE.md`. Mantenha os últimos
3 baselines para análise de tendência.

## Template — DRIFT_REPORT_<timestamp>.md

```yaml
---
project: <NOME_DO_MODULO>
module: drift-report
audience: [governanca, tecnica]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
baseline_date: "YYYY-MM-DD" ou "baseline inaugural"
---
```

```markdown
# Drift Report — <nome-do-modulo>

> **Gerado em:** DD/MM/AAAA HH:MM
> **Baseline:** DD/MM/AAAA (ou "Baseline inaugural — primeira execução")
> **Drift Score Global:** 0-100 — ✅ Estável | 🟡 Drift leve | 🟠 Moderado | 🔴 Severo | ❌ Crítico

---

## Resumo Executivo

<2-3 frases: estado geral do módulo, se há tendência de degradação,
principais achados>

| Métrica | Baseline | Atual | Tendência |
|---------|----------|-------|-----------|
| Artefatos analisados | N | N | — |
| Drift score global | — | 0-100 | ✅/🟡/🟠/🔴/❌ |
| Artefatos com drift > 25 | — | N | ↑/↓/→ |

---

## Drift Score por Artefato

| Artefato | Tamanho | Cobertura RNs | IDs Quebrados | Formato | Staleness | **Score** |
|----------|---------|--------------|---------------|---------|-----------|-----------|

**Legenda:** ✅ ok (0) | 🟡 drift leve (10) | 🔴 drift negativo (25)

---

## Detalhamento por Artefato

### <Artefato> — Score: N

**Tamanho:** N linhas (baseline: N linhas, -N%) → ✅/🟡/🔴
**Cobertura RNs:** N de N RNs referenciadas (-N%) → ✅/🟡/🔴
**IDs quebrados:** N → ✅/🔴
**Formato:** Template OK / N placeholders → ✅/🔴
**Staleness:** Última atualização: DD/MM/AAAA (N dias) → ✅/🟡/🔴

**Recomendação:** <ação sugerida>

---

## Artefatos Sem Baseline (Primeira Execução)

<lista de artefatos que não tinham baseline anterior>

---

## Recomendações

| Prioridade | Ação | Artefato | Skill corretiva |
|-----------|------|----------|-----------------|
| 🔴 Alta | <ação> | <artefato> | rdd-<skill> |
| 🟠 Média | <ação> | <artefato> | rdd-<skill> |
| 🟡 Baixa | <ação> | <artefato> | rdd-<skill> |
```

## Template — DRIFT_BASELINE.md

```yaml
---
project: <NOME_DO_MODULO>
module: drift-baseline
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
---
```

```markdown
# Drift Baseline — <nome-do-modulo>

> Baseline mantido para comparação de tendência. Últimas 3 medições.

---

## Baseline #3 (mais recente) — DD/MM/AAAA HH:MM

| Artefato | Linhas | RNs cobertas | IDs quebrados | Placeholders | Última atualização |
|----------|--------|-------------|---------------|--------------|--------------------|

---

## Baseline #2 — DD/MM/AAAA HH:MM

| Artefato | Linhas | RNs cobertas | IDs quebrados | Placeholders | Última atualização |
|----------|--------|-------------|---------------|--------------|--------------------|

---

## Baseline #1 — DD/MM/AAAA HH:MM

| Artefato | Linhas | RNs cobertas | IDs quebrados | Placeholders | Última atualização |
|----------|--------|-------------|---------------|--------------|--------------------|
```

## Casos de Borda

- **Primeira execução (sem baseline):** gere o relatório como "baseline
  inaugural" — todas as métricas são mark ✅ (não há comparação possível).
  Salve o baseline para futuras comparações.
- **Módulo pré-IMP-011 (sem subpastas):** verifique artefatos na raiz.
  No relatório, note que o módulo ainda não foi migrado.
- **Baseline com mais de 3 medições:** ao atualizar, remova a medição
  mais antiga (mantenha apenas as 3 mais recentes).
- **Artefato novo (não existia no baseline):** marque como "novo — sem
  tendência". Não gere drift score para ele.
- **Artefato deletado (existia no baseline mas não mais):** marque como
  "removido" — drift score = 100 (crítico, a menos que a remoção
  tenha sido intencional via CR).
- **Módulo com 1 único artefato:** analise apenas esse artefato.
  O drift score global é o score desse único artefato.
