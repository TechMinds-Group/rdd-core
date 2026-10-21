---
name: rdd-ui-spec
description: >-
  Gera UI_SPEC.md a partir das RNs em REQUIREMENTS.md. Descreve telas,
  componentes, fluxos de navegação, validações de frontend e regras de
  exibição condicional.
  Use quando o usuário pedir "especificação de UI", "spec de telas",
  "layout de formulários" ou "fluxo de navegação".
---
# rdd-ui-spec — Especificação de UI

Gera `<modulo>/<projeto>/specs/UI_SPEC.md` com a especificação de interface
derivada das regras de negócio e casos de uso.

## Referências

- Front matter: `docs/CONSTITUTION.md §2`
- EARS (para validações de frontend): `docs/CONSTITUTION.md §3`

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

- `<modulo>/<projeto>/REQUIREMENTS.md` (essencial — §2 Atores, §5 RNs, §7 Casos de Uso, §8 Saídas)
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` (se existir, para campos e validações; fallback: raiz do módulo)
- `<modulo>/<projeto>/specs/DATA_MODEL.md` (se existir, para tabelas e colunas envolvidas; fallback: raiz do módulo)
- `<modulo>/<projeto>/glossaries/` (se existir, para consistência terminológica; fallback: raiz do módulo)

## Gera (downstream)

- `<modulo>/<projeto>/specs/UI_SPEC.md`

## Nunca edita

- `REQUIREMENTS.md`
- `API_CONTRACTS.md`
- `DATA_MODEL.md`

## Tools

- `read` (ler REQUIREMENTS.md, API_CONTRACTS.md, DATA_MODEL.md)
- `write` (escrever UI_SPEC.md)
- `question` (para ambiguidades de layout ou comportamento visual)

## Modo de erro

`strict` — se a UI spec não for gerada, o time de frontend não tem input.

## Propagação de confiança (legado)

- Afirmações derivadas de RN induzida de engenharia reversa **herdam a marca de confiança da RN de origem** (campo `**Confiança:**` em REQUIREMENTS.md).
- Escala: Alta → 🟢 CONFIRMADO · Média → 🟡 INFERIDO · Baixa → 🔴 GAP.
- **Regra de ouro:** na dúvida, nível mais baixo.
- Quando disponível, anexe a evidência da análise reversa (`[arquivo:linha]` ou `@<hash>`) — **afirmação sem evidência nunca recebe 🟢**.

## Formato de commit

```
docs: add ui spec for <projeto>
```

## Workflow

1. Leia `REQUIREMENTS.md §2 (Atores e Permissões)` — identifique perfis de usuário
2. Leia `REQUIREMENTS.md §5 (Regras de Negócio)` — identifique regras de exibição condicional
3. Leia `REQUIREMENTS.md §7 (Casos de Uso)` — identifique fluxos de tela
4. Leia `REQUIREMENTS.md §8 (Saídas e Integrações)` — identifique outputs visuais
5. Leia `API_CONTRACTS.md` (se existir) — identifique campos e validações a espelhar no frontend
6. Para cada ator, descreva:
   - Telas disponíveis
   - Fluxo de navegação entre telas
   - Permissões por tela/ação
7. Para cada fluxo, descreva:
   - Componentes de tela (formulários, tabelas, modais)
   - Campos com tipo de input (text, date, select, checkbox)
   - Regras de exibição condicional (exibir/ocultar campo baseado em valor)
   - Validações de frontend (derivadas de RNs)
   - Estados (carregando, vazio, erro, sucesso)
8. Escreva `specs/UI_SPEC.md`
9. Aponte o próximo passo natural: fechado o conjunto de specs do módulo, a camada seguinte da DAG é a de features — proponha gerá-la com `rdd-task-spec` (análise `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-092/093) ou confirme a ordem com `rdd-next`.

## Template — UI_SPEC.md

```yaml
---
project: <NOME>
module: ui
audience: [tecnica]
status: draft
---
```

```markdown
# UI Specification — [Nome do Sistema]

> **Derivado de:** REQUIREMENTS.md (RN-XXX, RN-YYY)
> **Última atualização:** DD/MM/AAAA

---

## 1. Atores e Telas

| Ator | Telas disponíveis | Fluxo inicial |
|---|---|---|
| [papel] | [lista de telas] | [tela de entrada] |

---

## 2. [Tela 1 — Nome]

### 2.1 Acesso

**Permissão:** [papel]
**URL:** /[path]

### 2.2 Layout

[Descrição textual do layout, seções da tela]

### 2.3 Componentes

| Componente | Tipo | Campos | Regras |
|---|---|---|---|
| Formulário de cadastro | Form | campo1, campo2 | RN-XXX |
| Tabela de listagem | Table | coluna1, coluna2 | RN-YYY |

### 2.4 Campos do Formulário

| Campo | Input | Obrigatório | Validação | RN |
|---|---|---|---|---|
| nome | text | Sim | max 100 chars | RN-XXX |
| data | date | Sim | >= data mínima | RN-YYY |
| tipo | select | Sim | options: [A, B, C] | RN-ZZZ |

### 2.5 Regras de Exibição Condicional

| Condição | Ação | RN |
|---|---|---|
| Se tipo = A | Exibir campo X | RN-XXX |
| Se propriedade rastreada | Exibir aba Animais | RN-YYY |

### 2.6 Estados

| Estado | Comportamento |
|---|---|
| Carregando | Skeleton/spinner |
| Vazio | Mensagem "Nenhum registro encontrado" |
| Erro | Toast com mensagem do erro |
| Sucesso | Redirecionar para listagem |

---

## 3. [Tela 2 — Nome]

...

---

## 4. Fluxo de Navegação

```
[Tela 1] → [Tela 2] → [Tela 3]
    ↓                      ↓
[Erro]                [Sucesso]
```

---

## 5. Regras de UI Globais

| Regra | Descrição | RN |
|---|---|---|
| Formatação de data | DD/MM/AAAA | — |
| Moeda | R$ 1.234,56 | — |
| Confirmação antes de excluir | Modal "Tem certeza?" | — |
```

## Casos de Borda

- **Sem API_CONTRACTS.md** — derive campos e validações apenas de REQUIREMENTS.md e sinalize a ausência no cabeçalho (`Derivado de:`).
- **Projeto API-only (sem UI)** — informe que a skill não se aplica ao módulo e encerre sem gerar arquivo.
- **RN ambígua para layout/comportamento visual** — use `question` antes de especificar (não invente interação).
- **Regra de exibição condicional sem RN associada** — pergunte qual RN origina a regra; toda linha das seções de exibição deve referenciar uma RN-XXX.
- **Ator sem permissão definida em REQUIREMENTS.md** — pergunte antes de criar tela para o ator.
