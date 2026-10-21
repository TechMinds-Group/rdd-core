---
name: rdd-wiki-lint
description: >-
  Audita integridade dos artefatos RDD: contradições entre seções, artefatos
  órfãos, referências cruzadas quebradas, links internos inválidos e drift
  de estrutura. Complementa rdd-validate (que valida a DAG de RNs → downstreams)
  e rdd-decision-audit (que valida DECISIONS.md) com foco em integridade
  documental dos artefatos individualmente. Use quando o usuário pedir
  "lint dos documentos", "verificar integridade dos artefatos",
  "wiki lint", "contradições nos docs" ou "validar estrutura".
---
# rdd-wiki-lint — Lint de Integridade Documental

Audita os artefatos RDD em busca de problemas de integridade que não são
cobertos pelas outras skills de validação: contradições entre seções,
artefatos órfãos, referências cruzadas quebradas, links internos inválidos
e desvio de estrutura/templado.

**Diferenciação:**

| Skill | Escopo | O que valida |
|-------|--------|-------------|
| `rdd-validate` | DAG de documentos | RNs sem downstream, IDs quebrados na DAG, CRs stale |
| `rdd-decision-audit` | DECISIONS.md | Conflitos semânticos, sequência de IDs, referências |
| `rdd-drift-detector` | Qualidade temporal | Tendência de degradação (baseline vs atual) |
| `rdd-wiki-lint` | Integridade documental | Contradições, órfãos, links, estrutura, placeholders |

## Referências

- Estrutura de artefatos: IMP-011
- Templates de artefatos: `CONSTITUTION.md §4` (DAG)
- Formato de artefatos: convenções de front matter e seções

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):

- **Raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
- **`specs/`:** DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, FIGMA_PROMPTS.md, COMPLIANCE.md
- **`quality/`:** TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEABILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md
- **`delivery/`:** TASKS.md, TASKS_*.md, TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md
- **`support/`:** LEGACY_CONTEXT.md, KNOWN_ERRORS.md, MIGRATION.md, CHANGE_REQUESTS.md
- **`glossaries/`:** DEV_GLOSSARY.md, BUSINESS_GLOSSARY.md, USER_GLOSSARY.md, GLOSSARY.md
- **`docs/`:** howto/*.md e documentos auxiliares
- **`meetings/`, `contracts/`:** checkpoints (inalterados)

**Regra de fallback (transição):** ao **LER** um artefato, verifique primeiro
o caminho novo (ex: `specs/DATA_MODEL.md`); se não existir, use o caminho
legado na raiz do módulo (ex: `DATA_MODEL.md`). Ao **ESCREVER/GERAR**, use
sempre o caminho novo. Módulos ainda não migrados via `rdd-restructure`
continuam legíveis durante a transição.

## Lê (upstream)

- Todos os artefatos RDD do módulo (RAIZ + specs/ + quality/ + delivery/ + support/ + glossaries/ + docs/)
- `~/.config/opencode/skills/*/SKILL.md` (para verificar templates esperados — opcional)

## Gera (downstream)

- `<modulo>/<projeto>/quality/WIKI_LINT_<yyyy-MM-dd-hh:mm>.md` (relatório de lint)

## Nunca edita

- Nenhum artefato RDD. **Read-only absoluto.** Apenas diagnostica.

## Tools

- `glob` (listar todos os artefatos do módulo)
- `read` (ler artefatos para análise)
- `grep` (buscar referências cruzadas, placeholders, links)
- `write` (escrever WIKI_LINT_*.md)

## Modo de erro

`warn` — se algum artefato não puder ser lido (encoding, permissão),
inclua no relatório como "não avaliado" em vez de falhar. O relatório
deve ser gerado mesmo com dados parciais.

## Formato de commit

```
docs(quality): add wiki lint report <timestamp>
```

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum módulo RDD encontrado. Informe o caminho do módulo."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual módulo analisar.

**Registry lint:** independentemente do módulo, se `registry.yaml` existir
na raiz da config, inclua a verificação §9 (drit registry vs views) no
relatório — escopo config, não módulo.

### Passo 2 — Mapear artefatos

Use `glob` para listar todos os `.md` no diretório do módulo e subpastas.
Classifique cada arquivo pela sua localização (raiz, specs/, quality/, etc.).

### Passo 3 — Executar verificações

Execute as 8 categorias de lint abaixo, em paralelo quando possível.

### Passo 4 — Gerar relatório

Monte o relatório com o template e salve em `quality/WIKI_LINT_<timestamp>.md`.

## Categorias de Lint

### 1. Artefatos Órfãos

Artefatos que existem mas não são referenciados por **nenhum** outro artefato
no módulo.

Método:
1. Para cada `.md` no módulo, extraia o nome base (ex: `DATA_MODEL.md`)
2. Busque por esse nome em todos os outros `.md` do módulo (exceto ele mesmo)
3. Se não for encontrado em nenhum → é órfão

- **Warning:** `specs/SECURITY.md` não é referenciado por nenhum outro artefato
- **Info:** Artefatos na raiz (REQUIREMENTS.md, DECISIONS.md) são naturalmente
  "raiz" — não são órfãos mesmo sem referência explícita

### 2. Referências Cruzadas Quebradas

Artefatos que referenciam outros artefatos que não existem.

Método:
1. Busque por padrões de referência: `ver DATA_MODEL.md`, `conforme API_CONTRACTS.md`,
   `descrito em UI_SPEC.md`, `definido em ARCHITECTURE.md`, etc.
2. Para cada referência encontrada, verifique se o arquivo referenciado existe
3. Considere tanto o caminho novo (`specs/X.md`) quanto o legado (`X.md`)

- **Erro:** `REQUIREMENTS.md` referencia "ver specs/DATA_MODEL.md" mas o arquivo não existe
- **Warning:** `API_CONTRACTS.md` referencia "conforme ERROR_CATALOG.md" usando caminho legado

### 3. Contradições entre Seções

Detecta afirmações conflitantes dentro do mesmo artefato ou entre artefatos.

Estratégia:
1. Para cada artefato, extraia afirmações factuais (frases com "é", "usa", "deve", "contém")
2. Busque por termos opostos: "usar X" vs "não usar X", "obrigatório" vs "opcional",
   "sim" vs "não" sobre o mesmo tema
3. Compare afirmações entre artefatos complementares (ex: ARCHITECTURE.md vs DATA_MODEL.md
   sobre tecnologia de banco)

- **Erro:** `ARCHITECTURE.md` diz "banco: PostgreSQL" mas `DATA_MODEL.md` diz "banco: MySQL"
- **Warning:** `REQUIREMENTS.md` diz campo X é "obrigatório" mas `API_CONTRACTS.md` diz "opcional"
- **Warning:** `TEST_STRATEGY.md` lista funcionalidade Y mas `REQUIREMENTS.md` não menciona Y

### 4. Placeholders Não Preenchidos

Busca por marcadores de placeholder que ficaram na versão final.

Padrões buscados:
- `TODO`, `FIXME`, `XXX`, `HACK`
- `<descrição>`, `<nome>`, `<data>`, `<valor>`
- `[NÃO IMPLEMENTADO]`, `[PENDENTE]`, `[A DEFINIR]`
- `{{variavel}}` (exceto em templates legais que usam Mustache)
- `PLACEHOLDER`, `CHANGEME`, `LOREM`

- **Erro:** `API_CONTRACTS.md` contém `<descrição do endpoint>` na linha 45
- **Warning:** `UI_SPEC.md` contém `TODO: definir validação` na linha 120

### 5. Estrutura/Template Desviado

Verifica se os artefatos seguem a estrutura esperada (front matter + seções obrigatórias).

Para cada tipo de artefato, verifique:

| Artefato | Front Matter | Seções Obrigatórias |
|----------|-------------|---------------------|
| REQUIREMENTS.md | ✅ | §1 Visão Geral, §6 Regras de Negócio, §8 Pendências |
| DATA_MODEL.md | ✅ | Tabelas, Colunas, Relacionamentos |
| API_CONTRACTS.md | ✅ | Endpoints, Métodos, Request/Response |
| UI_SPEC.md | ✅ | Telas, Componentes, Validações |
| ARCHITECTURE.md | ✅ | Stack, Decisões, Padrões |
| DECISIONS.md | ✅ | DEC-XXX entries |
| TEST_STRATEGY.md | ✅ | Níveis, Ferramentas, Cenários |
| TRACEABILITY.md | ✅ | Matriz RN → Artefatos |

- **Warning:** `DATA_MODEL.md` não tem front matter YAML
- **Warning:** `UI_SPEC.md` não tem seção "Validações"

### 6. IDs Inconsistentes

Verifica se IDs usados em um artefato são consistentes com o formato esperado.

- RN-XXX deve ser numérico de 3 dígitos (RN-001, não RN-1 ou RN-0001)
- PEND-XXX deve ser numérico de 3 dígitos
- DEC-XXX deve ser numérico de 3 dígitos
- KE-XXX deve ser numérico de 3 dígitos
- CR-XXX deve ser numérico de 3 dígitos

- **Erro:** `REQUIREMENTS.md` usa `RN-1` em vez de `RN-001`
- **Warning:** `TRACEABILITY.md` referencia `PEND-7` em vez de `PEND-007`

### 7. Artefatos com Conteúdo Mínimo

Detecta artefatos que existem mas têm conteúdo insuficiente (possivelmente gerados mas não preenchidos).

Critérios:
- Arquivo com menos de 10 linhas (excluindo front matter)
- Arquivo com apenas front matter e nenhum conteúdo
- Arquivo com seções todas vazias

- **Warning:** `specs/SECURITY.md` tem apenas 5 linhas (front matter + título)
- **Warning:** `quality/TEST_STRATEGY.md` tem front matter mas nenhuma seção implementada

### 8. Links Internos Inválidos

Se os artefatos contêm links markdown para outros arquivos (formato `[texto](caminho)`),
verifique se os caminhos apontam para arquivos existentes.

- **Erro:** `howto/configuracao.md` contém `[ver modelo](../specs/DATA_MODEL.md)` mas
  `specs/DATA_MODEL.md` não existe
- **Warning:** `INDEX.md` contém `[DECISIONS](DECISIONS.md)` usando caminho relativo
  que pode quebrar dependendo do renderer

### 9. Registry.yaml vs Views (drift detection)

Se o arquivo `registry.yaml` existir na raiz da config do OpenCode, valide
que as views geradas (ARCHITECTURE.md, tabelas de subagents dos primary agents)
estão sincronizadas com o manifesto.

**Método:**
1. Leia `registry.yaml` e extraia a lista de componentes (primary_agents,
   subagents, skills) e suas relações
2. Compare com o conteúdo de `ARCHITECTURE.md` dentro dos marcadores
   `<!-- BEGIN_REGISTRY -->` / `<!-- END_REGISTRY -->`
3. Drift detection:
   - **Componente no registry mas não na view:** erro — re-renderizar
   - **Componente na view mas não no registry:** erro — view manual obsoleta
   - **Relação divergente** (ex: subagent delegado diferente): warning
4. **Skill sem arquivo:** para cada skill no registry, verifique se
   `skills/<id>/SKILL.md` existe. Se não → erro
5. **Subagent sem arquivo:** para cada subagent no registry, verifique se
   `agents/<id>.md` existe. Se não → erro
6. **Ownership inválido:** para cada subagent, verifique se `owner` existe em
   `primary_agents`, se `available_to` contém apenas primaries existentes e se
   `registered_by` (quando presente) coincide com `owner`.
7. **Delegação indisponível:** para cada primary, verifique se todo subagent
   em `delegates` aparece no `available_to` correspondente.

**Severidade:** error (bloqueante para o builder — registry inconsistente
gera nós órfãos na próxima inferência)

**Ação corretiva sugerida:** executar `rdd-registry-render` para
regenerar as views, ou corrigir registry.yaml manualmente se o arquivo
físico foi deletado.

## Template — WIKI_LINT_<timestamp>.md

```yaml
---
project: <NOME_DO_MODULO>
module: wiki-lint
audience: [qualidade, governanca]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
artifacts_scanned: N
---
```

```markdown
# Wiki Lint — <nome-do-modulo>

> **Gerado em:** DD/MM/AAAA HH:MM
> **Artefatos analisados:** N
> **Resultado Geral:** ✅ Limpo | ⚠️ Warnings | ❌ Erros encontrados

---

## Resumo

| Categoria | Erros | Warnings | Info |
|-----------|-------|----------|------|
| 1. Artefatos Órfãos | — | N | N |
| 2. Referências Quebradas | N | N | — |
| 3. Contradições | N | N | — |
| 4. Placeholders | N | N | — |
| 5. Estrutura/Template | — | N | — |
| 6. IDs Inconsistentes | N | N | — |
| 7. Conteúdo Mínimo | — | N | — |
| 8. Links Inválidos | N | N | — |
| **Total** | **N** | **N** | **N** |

---

## 1. Artefatos Órfãos

| Artefato | Localização | Observação |
|----------|-------------|------------|

<ou "✅ Nenhum artefato órfão">

---

## 2. Referências Cruzadas Quebradas

| Artefato Origem | Referência | Artefato Esperado | Existe? |
|----------------|-----------|-------------------|---------|

<ou "✅ Todas as referências são válidas">

---

## 3. Contradições entre Seções

### <Artefato A> vs <Artefato B>

**<Artefato A>:** <afirmação encontrada>
**<Artefato B>:** <afirmação conflitante>
**Tema:** <descrição do tema conflitante>

<ou "✅ Nenhuma contradição detectada">

---

## 4. Placeholders Não Preenchidos

| Artefato | Linha | Placeholder | Contexto |
|----------|-------|-------------|----------|

<ou "✅ Nenhum placeholder encontrado">

---

## 5. Estrutura/Template

| Artefato | Front Matter | Seções Obrigatórias | Status |
|----------|-------------|---------------------|--------|

<ou "✅ Todos os artefatos seguem o template esperado">

---

## 6. IDs Inconsistentes

| Artefato | ID Encontrado | ID Esperado | Linha |
|----------|--------------|-------------|-------|

<ou "✅ Todos os IDs seguem o padrão">

---

## 7. Conteúdo Mínimo

| Artefato | Linhas | Observação |
|----------|--------|------------|

<ou "✅ Todos os artefatos têm conteúdo suficiente">

---

## 8. Links Internos Inválidos

| Artefato Origem | Link | Caminho | Existe? |
|----------------|------|---------|---------|

<ou "✅ Todos os links são válidos">

---

## Recomendações

| Prioridade | Ação | Artefato |
|-----------|------|----------|
| ❌ Alta | <ação> | <artefato> |
| ⚠️ Média | <ação> | <artefato> |
| ℹ️ Baixa | <ação> | <artefato> |
```

## Casos de Borda

- **Módulo com 1 único artefato:** execute apenas as verificações aplicáveis
  (placeholders, estrutura, conteúdo mínimo). Órfãos e referências cruzadas
  não se aplicam com apenas 1 artefato.
- **Módulo pré-IMP-011 (sem subpastas):** verifique artefatos na raiz.
  No relatório, note que o módulo ainda não foi migrado.
- **Artefatos muito grandes (>5000 linhas):** execute as verificações em
  lotes por seção para manter performance.
- **Contradição ambígua:** quando a detecção automática não for conclusiva,
  marque como "⚠️ Revisão humana recomendada" em vez de classificar como erro.
- **Artefatos legais com Mustache:** os templates legais (TERMO_DE_USO,
  POLITICA_DE_PRIVACIDADE) usam `{{placeholder}}` intencionalmente —
  exclua-os da verificação de placeholders.
- **Relatório anterior existe:** não sobrescreva — gere um novo com
  timestamp diferente (permite diff entre execuções).
