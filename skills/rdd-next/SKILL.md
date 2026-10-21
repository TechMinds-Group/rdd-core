---
name: rdd-next
description: >-
  Inspeciona o estado real dos artefatos RDD no filesystem e recomenda a(s)
  próxima(s) skill(s) a executar. Read-only — nunca escreve, edita ou executa.
  Prioriza artefatos stale (PROPAGATION_STATUS.md), pendências de cliente
  (PEND-XXX), artefatos de tradução ausentes, e fases de qualidade.
  Use quando o usuário pedir "próxima skill", "o que fazer agora",
  "próximo passo do módulo" ou "auto-routing".
---
# rdd-next — Auto-Routing do Pipeline RDD

Inspeciona o módulo ativo e recomenda qual skill rodar a seguir, baseado
no estado real dos artefatos. Não executa nada — apenas diagnostica.

## Referências

- DAG de documentos: `CONSTITUTION.md §4`
- Fases do pipeline: `CONSTITUTION.md §2`
- Fluxo de demanda: `CONSTITUTION.md §8`
- IDs RN-XXX, PEND-XXX: `CONSTITUTION.md §1`

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):

- **Raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
- **`specs/`:** DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, FIGMA_PROMPTS.md, COMPLIANCE.md
- **`quality/`:** TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEABILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md
- **`analysis/`:** `RN-NNN — <título>/` — pasta por feature com 2 análises (`RN-NNN — Analise-Funcional.md` + `RN-NNN — Analise-Tecnica.md` — IMP-092)
- **`delivery/<grupo-do-estilo>/`:** arquivo de feature `RN-NNN — <título> — Feature.md` por feature (IMP-093; fallbacks legados de leitura: `— Tasks.md` IMP-092, pasta IMP-040 com 2 arquivos, flat pré-IMP-040, `RN-*.md` IMP-034, `TASKS*.md`)
- **`delivery/` (raiz):** TASKS.md, TASKS_*.md, TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md
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

- `<module-root>/PROJECT_CHARTER.md` (tipo de projeto, legado, escopo)
- `<module-root>/CONSTITUTION.md` (se existir, DAG do módulo)
- `<module-root>/REQUIREMENTS.md` (RNs, PENDs abertos)
- `<module-root>/support/CHANGE_REQUESTS.md` (CRs ativos; fallback: raiz)
- `<module-root>/quality/PROPAGATION_STATUS.md` (entradas stale pendentes; fallback: raiz)
- `<module-root>/meetings/` (checkpoints de clarify, para PENDs abertos)
- Artefatos de tradução (em `specs/`): `DATA_MODEL.md`, `API_CONTRACTS.md`, `UI_SPEC.md`,
  `ARCHITECTURE.md`, `ACCEPTANCE_CRITERIA.md`
- Glossários (em `glossaries/`): `DEV_GLOSSARY.md`, `BUSINESS_GLOSSARY.md`,
  `USER_GLOSSARY.md`, `GLOSSARY.md`
- Artefatos de qualidade (em `quality/`): `TEST_STRATEGY.md`,
  `TRACEABILITY.md`, `VALIDATION_REPORT.md`; e `delivery/SCOPE_AGREEMENT.md`
- Artefatos de suporte: `support/LEGACY_CONTEXT.md`, `DECISIONS.md` (raiz),
  `support/KNOWN_ERRORS.md`, `support/MIGRATION.md`

> **Fallback (transição IMP-011):** ao verificar existência de artefato,
> tente primeiro o caminho com subpasta (ex: `specs/DATA_MODEL.md`); se
> não existir, verifique o caminho legado na raiz (ex: `DATA_MODEL.md`).
> Considere o artefato existente se estiver em qualquer um dos dois.

## Gera (downstream)

- Por padrão, nada — a saída é textual, exibida ao usuário.
- Opcional (`--save`): `<module-root>/quality/NEXT_RECOMMENDATION.md` — grava
  a recomendação para histórico e diff entre execuções (mesmo padrão do
  `--save` do `rdd-progress`; convenção da IMP-026). Sem `--save`, o
  comportamento permanece idêntico ao original (nenhum arquivo escrito).

## Nunca edita

- Nenhum artefato de módulo — com ou sem `--save`, a skill é read-only
  quanto aos artefatos; o único arquivo que escreve (com `--save`) é o
  próprio relatório `quality/NEXT_RECOMMENDATION.md`.

## Tools

- `glob` (descobrir módulos, listar artefatos existentes)
- `read` (ler conteúdo de artefatos para detectar PENDs, RNs, CRs, staleness)
- `grep` (contar RNs em REQUIREMENTS.md, detectar PEND-XXX)
- `question` (se múltiplos módulos, perguntar qual inspecionar)

## Modo de erro

`warn` — se algo falhar na leitura (ex: artefato corrompido), reporta
mas continua com os dados que conseguiu ler.

## Algoritmo de Roteamento

### Passo 1 — Descobrir módulo(s)

Use `glob` para encontrar diretórios que contêm `PROJECT_CHARTER.md`.
Um **módulo** é qualquer diretório com este arquivo na raiz.

- Se nenhum módulo encontrado → recomende `rdd-project-intake` e pare.
- Se exatamente 1 módulo → use-o.
- Se múltiplos módulos → use `question` para perguntar qual inspecionar.
  Se o usuário não especificar, analise todos e mostre recomendações
  separadas por módulo.

### Passo 2 — Mapa de artefatos

Para o módulo selecionado, verifique a existência de cada artefato
(caminhos seguem IMP-011; em módulos pré-IMP-011, verifique também
o fallback na raiz do módulo):

**Fase 0 — Intake & Governança:**
| Artefato | Arquivo | Skill que gera |
|----------|---------|---------------|
| Project Charter | `PROJECT_CHARTER.md` | `rdd-project-intake` |
| Constitution | `CONSTITUTION.md` | `rdd-init` |
| Legacy Context | `support/LEGACY_CONTEXT.md` | `rdd-legacy-context` |
| Clarify checkpoints | `meetings/*.md` | `rdd-clarify` |

**Fase 1 — Requisitos & Escopo:**
| Artefato | Arquivo | Skill que gera |
|----------|---------|---------------|
| Requirements | `REQUIREMENTS.md` | `rdd-requirements` |
| Change Requests | `support/CHANGE_REQUESTS.md` | `rdd-change-request` |
| Propagation Status | `quality/PROPAGATION_STATUS.md` | `rdd-cr-propagation-guard` |
| Scope Agreement | `delivery/SCOPE_AGREEMENT.md` | `rdd-scope-agreement` |
| Client Requirements | `delivery/CLIENT_REQUIREMENTS.md` | `rdd-client-requirements` |

**Fase 2 — Tradução Técnica (6 artefatos):**
| # | Artefato | Arquivo | Skill que gera |
|---|----------|---------|---------------|
| T1 | Data Model | `specs/DATA_MODEL.md` | `rdd-data-model` |
| T2 | API Contracts | `specs/API_CONTRACTS.md` | `rdd-api-contracts` |
| T3 | UI Spec | `specs/UI_SPEC.md` | `rdd-ui-spec` |
| T4 | Architecture | `specs/ARCHITECTURE.md` | `rdd-architecture` |
| T5 | Glossary | `glossaries/DEV_GLOSSARY.md`, `glossaries/BUSINESS_GLOSSARY.md`, `glossaries/USER_GLOSSARY.md`, ou `glossaries/GLOSSARY.md` | `rdd-glossary` |
| T6 | Acceptance Criteria | `specs/ACCEPTANCE_CRITERIA.md` | `rdd-acceptance-criteria` |

**Fase 3 — Qualidade & Entrega:**
| Artefato | Arquivo | Skill que gera |
|----------|---------|---------------|
| Test Strategy | `quality/TEST_STRATEGY.md` | `rdd-test-strategy` |
| Traceability | `quality/TRACEABILITY.md` | `rdd-traceability` |
| Validation Report | `quality/VALIDATION_REPORT.md` | `rdd-validate` |
| Features (análise + delivery) | `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` | `rdd-task-spec` |
| Figma Prompt | `specs/FIGMA_PROMPTS.md` ou via Q7 | `rdd-figma-prompt` |
| How-to guides | `docs/howto/*.md` | `rdd-howto` |

**Documentos de Suporte:**
| Artefato | Arquivo | Skill que gera |
|----------|---------|---------------|
| Decisions | `DECISIONS.md` | efeito colateral de várias skills |
| Known Errors | `support/KNOWN_ERRORS.md` | `rdd-known-error` |
| Migration | `support/MIGRATION.md` | `rdd-migration` |

### Passo 3 — Coletar indicadores

Para cada artefato que existe, colete:

1. **PROJECT_CHARTER.md**:
   - `legado: true/false` — se true e sem LEGACY_CONTEXT.md → gap
   - Status do projeto (active/draft)

2. **REQUIREMENTS.md**:
   - Contagem de RNs (via `grep` para `RN-\d{3}`)
   - Contagem de PENDs abertos (via `grep` para `**PEND-`, excluindo
     `[resolvido]` ou `[bloqueado]`)
   - Se PENDs abertos existem em `REQUIREMENTS.md §11`

3. **CHANGE_REQUESTS.md**:
   - CRs com status `approved` ou `implemented` (que podem gerar staleness)
   - CRs com status `pending` (que precisam de aprovação)

4. **PROPAGATION_STATUS.md**:
   - Entradas na seção ## Pendentes (arte e CR ativos c/ staleness)
   - Copie os artefatos stale listados (ex: `DATA_MODEL`, `API_CONTRACTS`)

5. **Checkpoints de clarify** (`meetings/*.md`):
   - Itens com score < 70 ou marcados como PEND-XXX
   - Itens com `[bloqueado]` após 3 tentativas

6. **Artefatos de tradução (T1-T7)**:
   - Para cada artefato, se existe ou não
   - Se existe, se contém RNs referenciadas (via grep para `RN-\d{3}`)

7. **Artefatos de qualidade**:
   - `TEST_STRATEGY.md` — se existe
   - `SCOPE_AGREEMENT.md` — se existe
   - `TRACEABILITY.md`, `VALIDATION_REPORT.md` — se existem

### Passo 4 — Gerar recomendações

Avalie as condições abaixo na ordem de prioridade. Cada condição
verdadeira gera uma recomendação. Limite a 5 recomendações no máximo
(se houver mais, mostre as 5 de maior prioridade).

#### Prioridade 1 — Staleness ativo (PROPAGATION_STATUS.md)

**Condição:** `PROPAGATION_STATUS.md` existe e tem entradas na seção
"## Pendentes".

**Recomendação:** Para cada entrada pendente, gere uma ação recomendando
a skill de tradução que cobre o artefato stale.

**Formato:** `1. 🔴 Rodar rdd-{skill} — {RN} stale em {artefato} desde {data} (CR-XXX)`

**Exemplo:**
```
1. 🔴 Rodar `rdd-data-model` — RN-020 stale em DATA_MODEL.md desde 28/07/2026 (CR-002)
2. 🔴 Rodar `rdd-api-contracts` — RN-021 stale em API_CONTRACTS.md desde 28/07/2026 (CR-002)
```

Se múltiplas entradas stale referenciam o mesmo artefato (ex: duas RNs
diferentes stale no mesmo DATA_MODEL.md), agrupe em uma única recomendação:
"Rodar `rdd-data-model` — 2 RNs stale (RN-020, RN-021)".

#### Prioridade 2 — Pendência de cliente (PEND-XXX aberto)

**Condição:** `REQUIREMENTS.md` §11 tem PENDs abertos (sem `[resolvido]`
nem `[bloqueado]`), ou checkpoints de clarify têm itens com score < 70.

**Recomendação:** Sugerir `rdd-clarify` para resolver as pendências,
listando quantos PENDs estão em aberto.

**Formato:** `2. 🟡 Rodar rdd-clarify — {N} PEND(s) em aberto aguardando resposta do cliente`

**Exemplo:**
```
2. 🟡 Rodar `rdd-clarify` — 3 PENDs em aberto (PEND-001, PEND-004, PEND-005)
```

#### Prioridade 3 — Bloqueio por tentativas esgotadas

**Condição:** Existem PENDs com `[bloqueado]` após 3 tentativas de clarify.

**Recomendação:** Sugerir prosseguir com `rdd-requirements` mesmo com
pendência, com nota de bloqueio.

**Formato:** `3. 🟡 Rodar rdd-requirements — {N} PEND(s) bloqueado(s) após 3 tentativas, prosseguir com nota`

#### Prioridade 4 — Artefatos de tradução ausentes

**Condição:** `REQUIREMENTS.md` existe e contém RNs, mas um ou mais
artefatos T1-T7 estão ausentes.

Para cada artefato ausente, verifique:
- Se o artefato tem pré-requisitos satisfeitos (ex: `rdd-glossary`
  pode rodar a qualquer momento).
- Se o artefato não se aplica ao projeto → não recomende. Para detectar
  aplicabilidade, use convenções (ex: projeto declarado como "API-only"
  pode pular `rdd-ui-spec` — por default, todos são aplicáveis).

**Ordem sugerida dentro desta prioridade:** T1 → T2 → T3 → T4 → T5 → T6
(seguindo a ordem natural da DAG: modelo primeiro, depois contratos,
depois UI, etc.).

**Formato:** `4. 🟢 Rodar rdd-{skill} — {artefato} ausente, {N} RNs em REQUIREMENTS.md`

**Exemplo:**
```
4. 🟢 Rodar `rdd-api-contracts` — API_CONTRACTS.md ausente, 50 RNs em REQUIREMENTS.md
5. 🟢 Rodar `rdd-ui-spec` — UI_SPEC.md ausente, REQUIREMENTS.md já tem RNs de UI
```

#### Prioridade 5 — Features (analysis/ + delivery/) ausentes

**Condição:** `REQUIREMENTS.md` existe com RNs confirmadas e não há
nenhuma feature no módulo: nenhuma pasta `RN-NNN — *` em `analysis/` e
nenhum `RN-NNN — <título> — Feature.md` em `delivery/` (glob recursivo;
fallbacks legados — pasta IMP-040 com 2 arquivos, flat pré-IMP-040,
`RN-*.md` IMP-034, `TASKS*.md` — contam como cobertura existente).

**Recomendação:** Sugerir `rdd-task-spec` — gerar a análise
(`analysis/RN-NNN — <título>/`) + o arquivo de feature
(`delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-092/093) por
RN-âncora. Specs de tradução ausentes não bloqueiam (a skill marca as
tasks afetadas como "sujeitas a revisão").

**Formato:** `5. 🟢 Rodar rdd-task-spec — {N} RNs em REQUIREMENTS.md sem feature em analysis/ + delivery/`

#### Prioridade 6 — Artefatos de qualidade

**Condição:** Pelo menos T1 (DATA_MODEL), T2 (API_CONTRACTS), T3 (UI_SPEC)
e T7 (ACCEPTANCE_CRITERIA) existem (pré-requisitos de Q1).

**Recomendação:** Sugerir `rdd-test-strategy` se `TEST_STRATEGY.md`
estiver ausente.

**Formato:** `6. 🟢 Rodar rdd-test-strategy — pré-requisitos T1/T2/T3/T7 presentes, TEST_STRATEGY.md ausente`

#### Prioridade 7 — Documentos de suporte

**Condição:** 
- `LEGACY_CONTEXT.md` indica migração e `MIGRATION.md` ausente → sugerir
  `rdd-migration`
- `SCOPE_AGREEMENT.md` ausente e requisitos maduros → sugerir
  `rdd-scope-agreement`
- `CLIENT_REQUIREMENTS.md` ausente e `REQUIREMENTS.md` existe → sugerir
  `rdd-client-requirements`

**Formato:** `7. 🔵 Rodar rdd-migration — LEGACY_CONTEXT.md indica migração, MIGRATION.md ausente`

#### Prioridade 8 — Validação e Governança

**Condição:** 
- `TRACEABILITY.md` ausente e múltiplos artefatos de tradução existem →
  sugerir `rdd-traceability`
- `VALIDATION_REPORT.md` nunca gerado e vários artefatos prontos →
  sugerir `rdd-validate`

**Formato:** `8. ⚪ Rodar rdd-traceability — 4 artefatos de tradução gerados, matriz de rastreabilidade ausente`

### Passo 5 — Montar saída

Combine as recomendações em ordem de prioridade (1 = mais alta).
Limite a **5 itens**. Se houver mais que 5, mostre os 5 primeiros
e uma nota: `"+ {N} recomendações adicionais. Execute rdd-next novamente após resolver as acima."`

Se **nenhuma recomendação** for gerada (todos os artefatos existem,
sem staleness, sem PENDs abertos):

```
Nada pendente para o módulo <nome>.

✓ PROJECT_CHARTER.md — ok
✓ CONSTITUTION.md — ok
✓ REQUIREMENTS.md — {N} RNs, sem PENDs abertos
✓ PROPAGATION_STATUS.md — sem entradas pendentes
✓ Todos os artefatos de tradução (T1-T7) gerados
✓ TEST_STRATEGY.md — ok
```

## Formato de commit

Não se aplica — skill read-only, nunca escreve arquivos nem gera commit.

## Casos de Borda

### Projeto recém-criado (só PROJECT_CHARTER.md)

Recomendação única: `rdd-init` (para gerar CONSTITUTION.md e estrutura),
depois `rdd-clarify` + `rdd-requirements` na sequência.

```
1. 🟢 Rodar `rdd-init` — CONSTITUTION.md ausente, módulo sem estrutura DAG
2. 🟢 Rodar `rdd-clarify` — próxima etapa após CONSTITUTION.md pronta
```

### Todos os artefatos completos

Não invente recomendação artificial. Mostre o sumário de "tudo ok" e
encerre. Se houver CRs recém-implementados, sugira rodar
`rdd-cr-propagation-guard` para verificar se algo ficou stale. Antes de
declarar "tudo ok", confirme que as RNs confirmadas têm feature
correspondente (`analysis/` + `delivery/`) — caso contrário, a Prioridade 5
se aplica.

### Artefato de tradução não aplicável

Se um artefato não se aplica ao módulo (ex: `rdd-ui-spec` para
projeto API-only, `rdd-glossary` para módulo já glossariado), não
sugira. Para detectar:

1. Se o diretório do projeto é backend-only por declaração
   (`PROJECT_CHARTER.md` pode conter anotação tipo `ui: false` no
    front matter — se não houver, assuma que UI é aplicável).
2. Se o artefato já existe e contém RNs → já foi feito, não sugira de novo.
3. Se `meetings/` contém checkpoint que explicitamente diz "sem UI" →
   não sugira.
4. Para GLOSSARY: se pelo menos um dos arquivos
   (`DEV_GLOSSARY.md`, `BUSINESS_GLOSSARY.md`, `USER_GLOSSARY.md` ou
   `GLOSSARY.md`) existe, considere T5 como concluído.

### Múltiplas pendências de tipos diferentes

Se há stale entries E PENDs abertos E artefatos ausentes, liste todos
respeitando a ordem de prioridade. Ex:

```
1. 🔴 Rodar `rdd-data-model` — RN-020 stale em DATA_MODEL.md (CR-002)
2. 🟡 Rodar `rdd-clarify` — 3 PENDs abertos (PEND-001, PEND-004)
3. 🟢 Rodar `rdd-api-contracts` — API_CONTRACTS.md ausente, 50 RNs
4. 🟢 Rodar `rdd-ui-spec` — UI_SPEC.md ausente
5. 🔵 Rodar `rdd-scope-agreement` — SCOPE_AGREEMENT.md ausente
```

### REQUIREMENTS.md sem RNs ainda

Se REQUIREMENTS.md existe mas não contém RNs (só escopo, atores),
não sugira artefatos de tradução — a fonte ainda não está madura.
Sugira `rdd-requirements` para popular RNs primeiro.

### Módulo com legado mas LEGACY_CONTEXT.md já gerado

Se `legado: true` e `LEGACY_CONTEXT.md` existe, não sugira novamente.
Avance para as recomendações de Fase 1 ou 2 conforme o estado.

### CHANGE_REQUESTS.md com CRs pending mas não approved

CRs em `pending` não acionam staleness. Se não houver outros
indicadores, apenas registre que existem CRs pendentes de aprovação.

## Workflow

1. Descubra módulo(s) com PROJECT_CHARTER.md (Passo 1).
2. Se múltiplos, pergunte ao usuário qual inspecionar.
3. Para o módulo selecionado, faça o mapeamento de artefatos (Passo 2).
4. Colete indicadores lendo cada artefato existente (Passo 3).
5. Gere recomendações avaliando condições na ordem de prioridade (Passo 4).
6. Monte a saída com no máximo 5 itens (Passo 5).
7. Exiba o resultado ao usuário.
8. Se `--save` foi solicitado, grave a recomendação em
   `<module-root>/quality/NEXT_RECOMMENDATION.md` (template abaixo),
   criando o diretório `quality/` se necessário.

## Formato de saída

```text
═══ rdd-next — <nome-do-modulo> ═══

1. 🔴 Rodar `rdd-data-model` — RN-020 stale em DATA_MODEL.md (CR-002)
   Desde 28/07/2026. Regerar DATA_MODEL.md refletindo a mudança da RN-020.

2. 🟡 Rodar `rdd-clarify` — 2 PENDs em aberto (PEND-001, PEND-005)
   Aguardando resposta do cliente sobre: contradição de nomenclatura.

3. 🟢 Rodar `rdd-api-contracts` — API_CONTRACTS.md ausente
   REQUIREMENTS.md tem 50 RNs, nenhuma referenciada em contratos de API ainda.

4. 🟢 Rodar `rdd-ui-spec` — UI_SPEC.md ausente
   REQUIREMENTS.md tem seções de UI (telas, fluxos) não especificadas.

5. 🔵 Rodar `rdd-test-strategy` — pré-requisitos T1/T2/T3/T7 completos
   DATA_MODEL, API_CONTRACTS, UI_SPEC e ACCEPTANCE_CRITERIA existem.

Dica: execute cada skill na ordem acima. Após resolver os itens 🔴,
rode rdd-next novamente para ver as próximas recomendações.
```

**Legenda dos ícones:**
| Ícone | Significado |
|-------|-------------|
| 🔴 | Staleness — drift ativo entre requisito e artefato |
| 🟡 | Pendência de cliente — aguardando resposta externa |
| 🟢 | Próximo passo natural da DAG |
| 🔵 | Documento de suporte ou governança |
| ⚪ | Validação / qualidade |

## Template — NEXT_RECOMMENDATION.md (para --save)

```yaml
---
project: <NOME>
module: next-recommendation
audience: [tecnica]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
---
```

```markdown
# RDD Next Recommendation — <nome-do-modulo>

> **Gerado em:** DD/MM/AAAA HH:MM

## Recomendação

| # | Prioridade | Skill | Motivo |
|---|-----------|-------|--------|
| 1 | 🟢 | rdd-data-model | DATA_MODEL.md ausente, 3 RNs em REQUIREMENTS.md |

## Estado analisado

- <indicadores-chave: RNs, PENDs abertos, staleness, artefatos ausentes>
```

## Exemplos de consulta

### Módulo único

```text
Encontrei 1 módulo: vacinacao/
```

### Múltiplos módulos (pergunta ao usuário)

```
Encontrei 3 módulos com PROJECT_CHARTER.md:
1. vacinacao/ (active — 50 RNs, 4 CRs, 1 stale)
2. bloqueios/ (draft — escopo definido, sem RNs ainda)
3. gta/ (draft — apenas PROJECT_CHARTER.md)

Qual módulo devo inspecionar?
```
