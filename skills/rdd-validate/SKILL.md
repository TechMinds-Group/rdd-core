---
name: rdd-validate
description: >-
  Percorre o grafo de documentos do projeto e valida integridade: RN sem
  downstream esperado, ID quebrado, CR aprovado sem reflexo. Gera relatório
  VALIDATION_REPORT.md. Suporta flag --fix para auto-correção.
  Use quando o usuário pedir "validar integridade", "checar a DAG",
  "validar referências cruzadas" ou "validação do módulo".
---
# rdd-validate — Validação de Integridade

Percorre o grafo de documentos do projeto e valida a integridade das
referências e cobertura. Gera `<modulo>/<projeto>/quality/VALIDATION_REPORT.md`.

## Referências

- Grafo de documentos: `docs/CONSTITUTION.md §15`
- Fonte primária de dados: `docs/CONSTITUTION.md §6`
- Estratégia de erro: `docs/CONSTITUTION.md §10`

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

- Todos os documentos existentes em `<modulo>/<projeto>/` — na raiz (REQUIREMENTS.md, DECISIONS.md) e nas subpastas IMP-011 (specs/DATA_MODEL.md, specs/API_CONTRACTS.md, specs/ERROR_CATALOG.md, specs/UI_SPEC.md, quality/TRACEABILITY.md, support/CHANGE_REQUESTS.md), com fallback para a raiz em módulos pré-IMP-011

## Gera (downstream)

- `<modulo>/<projeto>/quality/VALIDATION_REPORT.md` (relatório, não altera outros docs)
- `<modulo>/<projeto>/quality/CONFIDENCE_REPORT.md` (relatório de confiança — ver seção própria)

## Nunca edita

- Nenhum documento de origem (é read-only, exceto com flag `--fix`)

## Tools

- `read` (ler todos os documentos do projeto)
- `grep` (buscar referências a IDs)
- `write` (escrever VALIDATION_REPORT.md)
- `question` (confirmar correções, se aplicável)

## Modo de erro

`strict` — se a validação falhar, o commit não deve prosseguir.

## Formato de commit

```
docs: run validation for <projeto>
```

## Workflow

1. Leia todos os documentos do projeto
2. Valide cada categoria abaixo
3. Gere `quality/VALIDATION_REPORT.md` com os resultados
4. **Escaneie os artefatos do módulo** (REQUIREMENTS.md e `specs/`) por marcadores de confiança (🟢/🟡/🔴 e `**Confiança:**`) — **leia os arquivos em UTF-8** (o scan em encoding ANSI/`Get-Content` padrão mascara os emojis e reporta falso "0 marcadores" em módulo calibrado) e gere `quality/CONFIDENCE_REPORT.md` com: contagem por documento, percentual geral por artefato — fórmula `(🟢 + 0,5×🟡)/total` — e a lista dos 🔴/Baixa com link para os PEND-XXX correspondentes. Módulo sem marcadores → relatório com o aviso "sem calibração de confiança (análise reversa não aplicada)" — **nunca falhe o gate por isso**.

Observação: a categoria "ADR sem campo Decisor" trata o campo `Decisor:`
como **opcional para ADRs antigos** (pre-IMP-010). A validação apenas
sinaliza como warning, sem bloquear o pipeline nem exigir correção
retroativa.

## Categorias de Validação

### 1. RN sem downstream esperado

Para cada RN em REQUIREMENTS.md, verifique:
- Se a RN envolve dado persistido → deve ter entrada em DATA_MODEL.md
- Se a RN envolve API → deve ter entrada em API_CONTRACTS.md
- Se a RN envolve interface → deve ter entrada em UI_SPEC.md

**Severidade:** warning (não bloqueante, pode ser intencional)

### 2. Referência a ID inexistente

Busque em todos os documentos referências a `RN-XXX`, `CR-XXX`, `ADR-NNN` (legado: `DEC-XXX`),
`PEND-XXX` e verifique se o ID existe no documento de origem.

**Severidade:** error (bloqueante — referência quebrada)

### 3. CR aprovado sem reflexo

Para cada CR com status `approved` em CHANGE_REQUESTS.md, verifique se
a RN afetada já foi atualizada em REQUIREMENTS.md e se os downstreams
marcados foram repropagados.

**Severidade:** error (bloqueante — mudança aprovada não implementada)

### 4. DEC obsoleto não marcado

Para cada DEC em DECISIONS.md, verifique se há referência cruzada a
outra DEC que a substitui. Se uma DEC mais recente aborda o mesmo tema,
a antiga deve estar `superseded`.

**Severidade:** warning

### 5. ADR sem campo Decisor

Para cada ADR em DECISIONS.md, verifique se existe o campo `Decisor:`.
ADRs criados antes da correção IMP-010 podem não ter o campo — nesse
caso, registre como **observação** (warning) e siga em frente. Não
considere erro bloqueante e não exija preenchimento retroativo.
Se o campo existir mas estiver vazio ou `Não informado`, também registre
como warning.

**Severidade:** warning

### 6. Tabelas novas sem colunas de auditoria (se exigidas pela CONSTITUTION.md)

Para cada tabela em DATA_MODEL.md marcada como **nova** (não reaproveitada do legado), verifique se as colunas de auditoria definidas na CONSTITUTION.md do projeto estão presentes. Se a CONSTITUTION.md não definir colunas de auditoria, esta validação é ignorada.

**Severidade:** error (bloqueante — colunas de auditoria são obrigatórias quando definidas na CONSTITUTION.md)

### 7. Compliance obrigatório ausente (IMP-102)

Se PROJECT_CHARTER.md do módulo contém `compliance: true` (produto trata dado pessoal), verifique se existe `specs/COMPLIANCE.md` (fallback: raiz, módulos pré-IMP-011).

- `compliance: true` e artefato ausente → **finding "compliance obrigatório ausente"**
- Artefato presente → verificar se o eixo 1 declara claramente se o produto trata dado pessoal (artefato vazio/placeholder também é finding)
- Sem a flag no charter (módulos pré-IMP-102 ou produto sem dado pessoal) → N/A, sem finding
- Skill corretiva: `rdd-compliance-check` (via `@rdd-compliance-orchestrator`)

**Severidade:** error (bloqueante — dado pessoal em produção sem verificação LGPD)

### 8. Resiliente a docs ausentes

Se TRACEABILITY.md não existir (tier básico), pule validações que dependem
dele (CR aprovado sem reflexo, RN sem downstream). Valide apenas o que
existe.

## Template — VALIDATION_REPORT.md

```yaml
---
project: <NOME>
module: validacao
audience: [tecnica]
status: draft
---
```

```markdown
# Validation Report — [Nome do Sistema]

> **Data:** DD/MM/AAAA
> **Resultado:** ✅ Aprovado | ⚠️ Aprovado com ressalvas | ❌ Reprovado

---

## Resumo

| Categoria | Erros | Warnings | Status |
|---|---|---|---|
| RN sem downstream esperado | 0 | 2 | ⚠️ |
| Referência a ID inexistente | 1 | 0 | ❌ |
| CR aprovado sem reflexo | 0 | 0 | ✅ |
| DEC obsoleto não marcado | 0 | 1 | ⚠️ |
| ADR sem campo Decisor | 0 | 1 | ⚠️ |
| Tabelas novas sem colunas de auditoria | 0 | 0 | ✅ |
| Compliance obrigatório ausente | 0 | 0 | ✅ |

---

## 1. RN sem Downstream Esperado

| RN | Downstream faltante | Sugestão |
|---|---|---|
| RN-012 | UI_SPEC | RN envolve interface de usuário |

---

## 2. Referência a ID Inexistente

| Arquivo | Linha | Referência | Problema |
|---|---|---|---|
| API_CONTRACTS.md | 45 | RN-999 | RN não encontrada em REQUIREMENTS.md |

---

## 3. CR Aprovado sem Reflexo

| CR | RN | Downstreams afetados | Status |
|---|---|---|---|
| CR-001 | RN-001 | DATA_MODEL | ❌ Não refletido |

---

## 4. ADR Obsoleto não Marcado (legado: DEC)

| ADR | Tema | ADR mais recente | Ação |
|---|---|---|---|
| ADR-001 | Autenticação | ADR-005 | Marcar ADR-001 como Superseded |

---

## 5. ADR sem Campo Decisor

| ADR | Campo | Severidade | Ação |
|---|---|---|---|
| ADR-001 | Decisor ausente | warning | Preencher se o autor for conhecido; caso contrário, manter e prosseguir |

---

## 6. Tabelas Novas sem Colunas de Auditoria Padrão

| `<tabela>` | Colunas ausentes | Severidade | Ação |
|--------|-----------------|------------|------|
| `TABELA_EXEMPLO` | CTR_DTH_INC, CTR_USU_INC | error | Reexecutar rdd-data-model |

---

## 7. Findings por Documento

| Documento | Achados | Severidade | Skill corretiva |
|-----------|---------|------------|-----------------|
| DATA_MODEL.md | 1 erro (RN-999), 1 warning | 🔴 erro | rdd-data-model |
| API_CONTRACTS.md | 1 warning (RN-012 sem UI) | 🟡 warning | rdd-api-contracts |
| UI_SPEC.md | — | ✅ ok | — |
| ARCHITECTURE.md | — | ✅ ok | — |
| REQUIREMENTS.md | 1 warning (RN-015 órfã) | 🟡 warning | rdd-requirements |
| DECISIONS.md | 1 warning (ADR-001 sem Decisor) | 🟡 warning | rdd-requirements |
```

## Seção Findings por Documento

Sempre inclua a seção `## 7. Findings por Documento` no relatório.
Para cada documento com achados, liste:
- **Documento:** nome do arquivo
- **Achados:** lista de problemas encontrados (com referência à linha/seção da categoria anterior)
- **Severidade:** `error` (bloqueante) ou `warning` (não bloqueante)
- **Skill corretiva sugerida:** nome da skill de Fase 1/2 que deve ser reexecutada para corrigir

| Severidade | Ação |
|------------|------|
| `error` | Reexecução obrigatória da skill corretiva antes de prosseguir |
| `warning` | Reexecução recomendada; pode prosseguir com ressalva |

## Relatório de Confiança (CONFIDENCE_REPORT.md)

Gerado a partir dos marcadores 🟢/🟡/🔴 e `**Confiança:**` presentes em REQUIREMENTS.md e nos artefatos de `specs/`:

| Artefato | 🟢 | 🟡 | 🔴 | Percentual geral |
|---|---|---|---|---|
| REQUIREMENTS.md | 12 | 3 | 1 | (12 + 0,5×3)/16 = 84% |

- **Percentual geral por artefato:** fórmula `(🟢 + 0,5×🟡)/total`.
- **Lista dos 🔴/Baixa** com link para os PEND-XXX correspondentes (RN induzida de confiança Baixa não validada por humano segue IMP-094 — PEND).
- **Módulo sem marcadores:** emita o relatório com o aviso `⚠️ Sem calibração de confiança (análise reversa não aplicada)` — aviso, nunca falha de gate.

### Auditoria anti-🟢 disfarçado (Jev, opcional)

- No passo 4, além do grep de marcadores, as afirmações marcadas 🟢 (ou amostra, se >20) vão ao `@rdd-jev-classifier` com pergunta do tipo "há linguagem de inferência (provavelmente/deve/aparentemente) ou evidência ausente nesta afirmação?" — criteria: `{evidencia_direta, linguagem_inferencia, sem_evidencia}`.
- O resultado vira **coluna** no CONFIDENCE_REPORT (ex.: `🟢⤵ sugestão Jev: rebaixar (p=0.4)`) — **nunca edita o artefato de origem**; a reclassificação cabe a uma re-execução humana/reverse.
- O Jev é **opcional** — nunca gate bloqueante; se indisponível/falhar, gere o relatório sem a coluna e registre o aviso no CONFIDENCE_REPORT.

## Flag --fix

Se o usuário passar `--fix`, as seguintes correções automáticas são aplicadas:

1. IDs órfãos (referência a ID inexistente) → remover a referência
2. DECs obsoletos → marcar como `superseded` com referência à DEC mais recente

**Nunca** auto-corrigir:
- RN sem downstream (pode ser intencional)
- CR aprovado sem reflexo (requer ação humana)

## Casos de Borda

- **Documento ausente** — pule as validações que dependem dele; valide apenas o que existe.
- **Módulo pré-IMP-011** — resolva caminhos com fallback para a raiz antes de reportar "documento ausente".
- **`--fix`** — só auto-corrige itens estruturais; nunca RN sem downstream nem CR aprovado sem reflexo.
- **Nenhum achado** — emita relatório `✅ Aprovado`; não invente problemas para preencher o relatório.
- **ADR antigo sem decisor registrado** — warning apenas; não bloqueie nem exija correção retroativa.
- **Módulo sem marcadores de confiança** — gere CONFIDENCE_REPORT.md com o aviso "sem calibração de confiança (análise reversa não aplicada)"; isso NUNCA falha o gate (marcadores só existem quando a engenharia reversa foi aplicada).
