---
name: rdd-progress
description: >-
  Dashboard de progresso do pipeline RDD. Consolida dados de
  TRACEABILITY.md, PROPAGATION_STATUS.md, PEND-XXX e artefatos
  da DAG em 5 blocos: cobertura de requisitos, drift,
  pendências de cliente, resultado (outcome) e fase atual. Read-only — não edita nada.
  Use quando o usuário pedir "dashboard de progresso", "status do
  projeto", "onde estamos" ou "relatório para reunião".
---
# rdd-progress — Dashboard de Progresso RDD

Visão consolidada da saúde do projeto. Responde "onde estamos" —
diferente do `rdd-next`, que responde "o que fazer agora".

## Referências

- DAG de documentos: `CONSTITUTION.md §4`
- Fases do pipeline: `CONSTITUTION.md §2`
- IDs RN-XXX, PEND-XXX: `CONSTITUTION.md §1`
- `rdd-traceability` (TRACEABILITY.md): cobertura RN → artefatos
- `rdd-cr-propagation-guard` (PROPAGATION_STATUS.md): drift stale
- `rdd-clarify` (checkpoints meetings/): PENDs com tentativas
- `rdd-next`: recomendação de próxima ação (complementar)

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

- `<module-root>/PROJECT_CHARTER.md` (fase do projeto, legado)
- `<module-root>/quality/TRACEABILITY.md` (matriz RN → artefatos, gaps; fallback: raiz)
- `<module-root>/quality/PROPAGATION_STATUS.md` (entradas stale pendentes; fallback: raiz)
- `<module-root>/REQUIREMENTS.md` (PEND-XXX abertos/resolvidos)
- <module-root>/meetings/ (checkpoints de clarify com scores)
- <module-root>/support/CHANGE_REQUESTS.md (campo Origem de cada CR — IMP-099)
- <module-root>/delivery/**/RN-NNN — <título> — Feature.md (front matter entregue_em — glob recursivo, IMP-099)
- `<module-root>/CONSTITUTION.md`
- Todos os artefatos da DAG (para fase atual) — com fallback IMP-011 (subpasta primeiro, raiz depois)

## Gera (downstream)

- Apenas saída textual na sessão, a menos que `--save` seja usado.
- Se `--save`: escreve `<module-root>/quality/PROGRESS_REPORT.md` com
  timestamp, permitindo diff entre execuções.

## Nunca edita

- Nenhum artefato técnico. Read-only.

## Tools

- `glob` (descobrir módulos, listar artefatos existentes)
- `read` (ler TRACEABILITY.md, PROPAGATION_STATUS.md, REQUIREMENTS.md,
  checkpoints meetings/)
- `grep` (contar RNs, detectar PEND-XXX, parsear status na matriz)
- `question` (se múltiplos módulos, perguntar qual; confirmar --save)
- `write` (apenas se `--save` for usado, para PROGRESS_REPORT.md)

## Modo de erro

`warn` — se uma fonte de dado não existir (ex: TRACEABILITY.md nunca
gerado), o bloco correspondente mostra "dado não disponível" em vez
de falhar ou mostrar zero sem contexto.

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum projeto RDD encontrado. Execute rdd-project-intake."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual. Sem resposta, analise
  todos e mostre relatórios separados.

### Passo 2 — Coletar dados por bloco

#### Bloco A — Cobertura de Requisitos

Fonte: `TRACEABILITY.md` (se existir).

1. Leia a seção "## 1. Matriz RN vs Downstreams".
2. Parseie a tabela markdown. Cada linha tem:
   `| RN-NNN | descrição | status_DM | status_API | status_UI | status_ERR | status_geral |`
   onde status pode ser ✅, ❌, — ou N/A.
3. Conte para cada RN:
   - Se a coluna `Status` = `completo` → complete
   - Se a coluna `Status` = `parcial` → partial
   - Se a coluna `Status` = `gap` → gap
4. Leia a seção "## 4. Resumo" (se existir) para obter os totais
   consolidados já calculados: total RNs, completas, parciais, gaps,
   gaps críticos, ERROR_CATALOG status.

**Se TRACEABILITY.md não existe:** Bloco A mostra "dado não disponível.
Execute rdd-traceability primeiro."

**Se TRACEABILITY.md existe mas não tem matriz (vazia):** "Nenhuma RN
mapeada ainda. Execute rdd-requirements para popular RNs."

**Saída do bloco:**
```
📋 Cobertura de Requisitos
   Total de RNs: 51
   ✅ Completas: 2 (RN-025, RN-035)
   🟡 Parciais: 21
   ❌ Gaps:      26
   🔥 Gaps críticos: RN-013/014/016, RN-020/021, RN-044, RN-046

   RNs incompletas (mostrar até 10):
   - RN-005: gap em DATA_MODEL (partida vencida)
   - RN-008: gap em DATA_MODEL (restrição etária)
   ...
```

Para listar RNs incompletas, extraia da matriz quais colunas (DATA_MODEL,
API_CONTRACTS, UI_SPEC) estão ❌ para cada RN com status `parcial` ou
`gap`. Limite a 10 na exibição, com nota "+ N mais" se exceder.

#### Bloco B — Drift (Staleness de CRs)

Fonte: `PROPAGATION_STATUS.md` (se existir).

1. Leia a seção "## Pendentes".
2. Para cada linha da tabela `| RN | CR | Artefatos Stale | Detectado em |`:
   - Extraia a lista de artefatos stale (ex: `DATA_MODEL, API_CONTRACTS`)
3. Agrupe por artefato afetado:
   ```
   DATA_MODEL: 2 entradas (RN-020 via CR-002, RN-021 via CR-002)
   API_CONTRACTS: 1 entrada (RN-020 via CR-002)
   UI_SPEC: 1 entrada
   ```
4. Conte total de entradas pendentes e artefatos únicos afetados.

**Se PROPAGATION_STATUS.md não existe:** "dado não disponível. Execute
rdd-cr-propagation-guard para detectar possíveis drifts."

**Se existe mas vazio (sem pendentes):** "Nenhum drift detectado. Todos
os artefatos estão atualizados em relação aos CRs aprovados."

**Saída do bloco:**
```
🔄 Drift (Staleness)
   Total de entradas stale pendentes: 3
   Artefatos afetados: 3

   DATA_MODEL:      2 stale (RN-020, RN-021 via CR-002, desde 28/07/2026)
   API_CONTRACTS:   1 stale (RN-020 via CR-002, desde 28/07/2026)
   UI_SPEC:         1 stale (RN-049 via CR-004, desde 29/07/2026)
```

#### Bloco C — Pendências de Cliente

Fontes: `REQUIREMENTS.md` §11, checkpoints `meetings/*.md`.

1. Leia `REQUIREMENTS.md` §11 (seção "## 11. Open Pendencies").
2. Extraia todos os `**PEND-XXX**` que NÃO tenham `[resolvido]` nem
   `[bloqueado]`.
3. Para cada PEND-XXX aberto, extraia:
   - ID (PEND-XXX)
   - Data de criação: `(DD/MM/AAAA)` após o ID
   - Descrição: texto após o `—`
4. Para estimar tentativas de clarify, leia os checkpoints em
   `meetings/*.md`. Para cada checkpoint, use `grep` para `PEND-XXX`.
   Conte em quantos checkpoints distintos o PEND aparece.
   - Se 0 checkpoints → tentativas: 0 (nunca perguntado)
   - Se 1 checkpoint → tentativas: 1
   - Se 2+ checkpoints → tentativas: N
   - Se checkpoints tiverem `[Nª tentativa]` explícito, use esse valor.
5. Calcule idade aproximada: data atual − data de criação.

**Se REQUIREMENTS.md não existe:** "Nenhuma pendência — REQUIREMENTS.md
ainda não foi gerado."

**Se §11 não existe ou está vazia:** "Nenhuma PEND em aberto."

**Saída do bloco:**
```
⏳ Pendências de Cliente
   Total de PENDs abertos: 11

   PEND-001 (22/04/2026 — 99 dias) — contradição de nomenclatura... — tentativas: 0
   PEND-002 (22/04/2026 — 99 dias) — marco não definido... — tentativas: 0
   PEND-004 (22/04/2026 — 99 dias) — autocadastro... — tentativas: 0
   PEND-005 (22/04/2026 — 99 dias) — numeroCadastro... — tentativas: 0
   PEND-006 (28/07/2026 — 2 dias)  — erro 404... — tentativas: 1
   ...

   → Resolver pendências antes de avançar para novas traduções.
   Execute rdd-clarify para abordar as pendências mais antigas.
```

#### Bloco D — Fase Atual

Fonte: inspeção de filesystem (existência de artefatos).

Para cada fase, verifique quais artefatos existem:

**Fase 0 — Intake (4 artefatos):**
| Artefato | Existência |
|----------|-----------|
| PROJECT_CHARTER.md | obrigatório |
| CONSTITUTION.md | |
| support/LEGACY_CONTEXT.md | só se `legado: true` |
| meetings/ (qualquer checkpoint) | |

**Fase 1 — Requirements (3 artefatos):**
| Artefato | Existência |
|----------|-----------|
| REQUIREMENTS.md | |
| support/CHANGE_REQUESTS.md | |
| delivery/SCOPE_AGREEMENT.md | |

**Fase 2 — Translation (7 artefatos):**
| Artefato | Arquivo |
|----------|---------|
| DATA_MODEL | `specs/DATA_MODEL.md` |
| API_CONTRACTS | `specs/API_CONTRACTS.md` |
| UI_SPEC | `specs/UI_SPEC.md` |
| ARCHITECTURE | `specs/ARCHITECTURE.md` |
| GLOSSARY | `glossaries/*_GLOSSARY.md` ou `glossaries/GLOSSARY.md` |
| ACCEPTANCE_CRITERIA | `specs/ACCEPTANCE_CRITERIA.md` |

**Fase 3 — Quality (5 artefatos):**
| Artefato | Arquivo |
|----------|---------|
| TEST_STRATEGY | `quality/TEST_STRATEGY.md` |
| TRACEABILITY | `quality/TRACEABILITY.md` |
| VALIDATION_REPORT | `quality/VALIDATION_REPORT.md` |
| HOWTO guides | `docs/howto/*.md` |
| Features (análise + delivery) | `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` |

> **Fallback (transição IMP-011):** para cada artefato, verifique primeiro
> o caminho com subpasta; se não existir, o caminho legado na raiz.

**Determinação da fase predominante:**

Use a fase mais avançada que tem pelo menos 1 artefato presente:
- Nenhum artefato (só PROJECT_CHARTER.md) → "Intake (0/4)"
- Apenas Fase 0 → "Intake (N/4)"
- Fase 0 + 1 → "Requirements (N/3)"
- Fase 0 + 1 + algum T1-T7 → "Translation (N/7)"
- Fase 0 + 1 + 2 + algum Quality → "Quality (N/5)"

Para cada fase, mostre ✓ para artefatos existentes, ❌ para ausentes,
— para não aplicáveis (ex: LEGACY_CONTEXT se `legado: false`).

**Saída do bloco:**
```
📊 Fase Atual: Quality (4/4)
   Fase 0 — Intake:      4/4 completos
     ✓ PROJECT_CHARTER.md
     ✓ CONSTITUTION.md
     ✓ LEGACY_CONTEXT.md
     ✓ meetings/ (checkpoints)

   Fase 1 — Requirements: 3/3 completos
     ✓ REQUIREMENTS.md
     ✓ CHANGE_REQUESTS.md
     ✓ SCOPE_AGREEMENT.md

   Fase 2 — Translation:  7/7 completos
     ✓ DATA_MODEL.md  ✓ UI_SPEC.md  ✓ GLOSSARY
     ✓ API_CONTRACTS  ✓ ACCEPTANCE_CRITERIA
     — ARCHITECTURE.md (não aplicável)

   Fase 3 — Quality:     4/5
     ✓ TEST_STRATEGY.md
     ✓ TRACEABILITY.md
     ❌ VALIDATION_REPORT.md (rode rdd-validate)
     ✓ docs/howto/
     ✓ Features (analysis/ + delivery/)

   → Use rdd-next para ver a próxima ação recomendada.
```

#### Bloco E — Resultado (outcome — IMP-099)

Fontes: `REQUIREMENTS.md` §11, `support/CHANGE_REQUESTS.md` (campo `Origem`),
front matter `entregue_em` dos arquivos de feature `delivery/**/RN-NNN — <título> — Feature.md` (glob recursivo).

1. **PENDs abertos vs. resolvidos** — agrupados por feature/RN-âncora:
   total abertos, total resolvidos (`[resolvido]`, promovidos a RN ou
   virados CR/decisão) e taxa de resolução = resolvidos / (abertos + resolvidos).
2. **CRs por origem** (IMP-099) — campo `**Origem:**` de cada CR:
   `requisito-mal-capturado | evolucao | bug | decisao-cliente`. A fração
   `requisito-mal-capturado` é a proxy de retrabalho de requisitos.
3. **Drift-check pós-entrega** — features com `entregue_em` há mais de
   14 dias e sem drift-check registrado (PROPAGATION_STATUS.md sem
   entrada recente para a RN-âncora).

**Invariante (IMP-099):** dado ausente → linha `N/A (sem dados)`
declarada — nunca número estimado nem zero fingido. CR sem campo `Origem`
é contabilizado como `N/A (sem dados)` — nunca inventar origem.

**Saída do bloco:**
```
🎯 Resultado (outcome)
   PENDs: 11 abertos / 4 resolvidos (taxa de resolução: 27%)
     por feature: RN-010 (2 abertos), RN-021 (1 resolvido), ...
   CRs por origem: 2 requisito-mal-capturado / 3 evolucao / 0 bug / 1 decisao-cliente
     → retrabalho de requisitos: 2/6 (33%)
   Features entregues há >14 dias sem drift-check: 1
     - RN-012 — Tela de bloqueios (entregue 01/09/2026)
```

### Passo 3 — Montar dashboard

Combine os 5 blocos na ordem A → B → C → D → E (E = Resultado, IMP-099).

**Header:** `═══ rdd-progress — <nome-do-modulo> ═══  <timestamp>`

**Footer (se --save):** `Relatório salvo em <module-root>/PROGRESS_REPORT.md`

### Passo 4 — Persistência opcional (--save)

Se o usuário solicitar `--save`:

1. Escreva o relatório completo em `<module-root>/quality/PROGRESS_REPORT.md`.
2. Use o template abaixo, com timestamp ISO 8601 no front matter.
3. O arquivo pode ser versionado em Git para permitir diff entre
   execuções (ex: comparar cobertura entre semanas).

## Formato de commit

Por padrão não gera commit (read-only). Se `--save` for usado:

```
docs: save progress report for <modulo>
```

## Casos de Borda

### Projeto sem nenhum artefato (pré-intake)

```
═══ rdd-progress — <nome> ═══

📋 Cobertura de Requisitos: N/A — projeto em fase de Intake.
   Nenhuma RN levantada ainda. Próximo passo: rdd-project-intake.

🔄 Drift: N/A — sem artefatos técnicos para verificar drift.

⏳ Pendências de Cliente: Nenhuma — sem REQUIREMENTS.md gerado.

📊 Fase Atual: Intake (1/4)
   ✓ PROJECT_CHARTER.md
   ❌ CONSTITUTION.md
   ❌ LEGACY_CONTEXT.md (legado: true)
   ❌ meetings/

   → Use rdd-next para ver o próximo passo.
```

### TRACEABILITY.md não existe

Bloco A mostra: "dado não disponível. Execute rdd-traceability primeiro."
Sem inventar percentuais de cobertura.

### PROPAGATION_STATUS.md não existe

Bloco B mostra: "dado não disponível. Execute rdd-cr-propagation-guard
para verificar drifts."

### Projeto maduro sem pendências

Bloco B: "Nenhum drift detectado."
Bloco C: "Nenhuma PEND em aberto."
Bloco D: fase mais avançada com indicadores verdes.

Nunca inventar recomendações artificiais de melhoria apenas para
preencher espaço. Se está tudo pronto, o dashboard reflete isso.

### Múltiplos módulos

Se o usuário não escolher um módulo específico, analise todos e mostre
relatórios sequenciais separados por `---`.

### Artefato esperado mas ausente na DAG

Para ARCHITECTURE.md ou GLOSSARY: se ausente, marque como ❌ na fase
de Translation, a menos que o módulo tenha justificativa documentada
(ex: "sem UI" para pular UI_SPEC). Nesse caso, use — (não aplicável).

## Template — PROGRESS_REPORT.md (para --save)

```yaml
---
project: <NOME>
module: progress-report
audience: [tecnica]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
---
```

```markdown
# RDD Progress Report — <nome-do-modulo>

> **Gerado em:** DD/MM/AAAA HH:MM

---

## 📋 Cobertura de Requisitos

**Total de RNs:** 51
| Status | Contagem | RNs |
|--------|----------|-----|
| ✅ Completas | 2 | RN-025, RN-035 |
| 🟡 Parciais | 21 | ... |
| ❌ Gaps | 26 | ... |

**Gaps críticos:** RN-013/014/016, RN-020/021, RN-044, RN-046

---

## 🔄 Drift (Staleness)

| Artefato | Entradas Stale | CRs |
|----------|---------------|-----|
| DATA_MODEL | 2 | CR-002 |
| API_CONTRACTS | 1 | CR-002 |

---

## ⏳ Pendências de Cliente

| PEND | Criado em | Idade | Tentativas | Descrição |
|------|-----------|-------|------------|-----------|
| PEND-001 | 22/04/2026 | 99d | 0 | contradição de nomenclatura... |
| PEND-002 | 22/04/2026 | 99d | 0 | marco não definido... |

---

## 📊 Fase Atual: Quality (4/4)

### Fase 0 — Intake (4/4)
- [x] PROJECT_CHARTER.md
- [x] CONSTITUTION.md
- [x] LEGACY_CONTEXT.md
- [x] meetings/

### Fase 1 — Requirements (3/3)
- [x] REQUIREMENTS.md (51 RNs, 11 PENDs)
- [x] CHANGE_REQUESTS.md
- [x] SCOPE_AGREEMENT.md

### Fase 2 — Translation (6/7)
- [x] DATA_MODEL.md
- [x] API_CONTRACTS.md
- [x] UI_SPEC.md
- [ ] ARCHITECTURE.md
- [x] GLOSSARY (DEV, BUSINESS, USER)

- [x] ACCEPTANCE_CRITERIA.md

### Fase 3 — Quality (3/5)
- [x] TEST_STRATEGY.md
- [x] TRACEABILITY.md
- [ ] VALIDATION_REPORT.md
- [x] docs/howto/
- [ ] Features (analysis/ + delivery/)

---

## 🎯 Resultado (Outcome — IMP-099)

| Métrica | Valor |
|----------|-------|
| PENDs abertos / resolvidos (taxa) | 11 / 4 (27%) |
| CRs por origem (rmc/evo/bug/dec) | 2/3/0/1 |
| Retrabalho de requisitos (fração rmc) | 33% |
| Features >14d sem drift-check | 1 (RN-012) |
| Métrica sem dado | N/A (sem dados) |
```

## Workflow

1. Descubra módulo(s) (Passo 1).
2. Para o módulo selecionado, colete dados dos 5 blocos (Passo 2):
   A. Cobertura de Requisitos → TRACEABILITY.md
   B. Drift → PROPAGATION_STATUS.md
   C. Pendências de Cliente → REQUIREMENTS.md + meetings/
   D. Fase Atual → inspeção de filesystem`n   E. Resultado (IMP-099) → CHANGE_REQUESTS.md + delivery Feature.md (`entregue_em`) + REQUIREMENTS.md
3. Monte o dashboard (Passo 3).
4. Se `--save`, persista como quality/PROGRESS_REPORT.md (Passo 4).
5. Exiba o relatório ao usuário.

## Diferenciação de rdd-next

| Aspecto | rdd-progress | rdd-next |
|---------|-------------|----------|
| Pergunta | "Onde estamos?" | "O que fazer agora?" |
| Saída | 4 blocos de KPIs | 3-5 ações priorizadas |
| Fontes | TRACEABILITY, PROPAGATION, PENDs, DAG | mesma inspeção + PROPAGATION |
| Recomendação | ❌ Nunca recomenda ação | ✅ Recomenda a próxima skill |
| Persistência | Opcional via --save | Nunca persiste |
| Uso típico | Reunião de status, diff semanal | Início de sessão de trabalho |

### Bloco E sem dados (IMP-099)

Se `CHANGE_REQUESTS.md` não existir, nenhum CR tiver campo `Origem` ou
nenhuma Feature.md tiver `entregue_em` no front matter, o Bloco E mostra
`N/A (sem dados)` na linha correspondente — nunca número estimado, nunca
zero fingido. CR sem campo origem = N/A (não inventar origem).
