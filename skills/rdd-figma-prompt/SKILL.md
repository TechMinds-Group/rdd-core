---
name: rdd-figma-prompt
description: >-
  Gera prompt para protótipo visual no Figma Make a partir de REQUIREMENTS.md,
  UI_SPEC.md, DATA_MODEL.md e API_CONTRACTS.md. Substitui o figma-make-prompt
  com suporte a múltiplos documentos de entrada, mapeamento RN->tela,
  árvore de componentes, delta incremental via git diff, e persistência
  em FIGMA_PROMPTS.md para rastreabilidade.
  Use quando o usuário pedir "prompt do Figma", "protótipo no Figma Make",
  "prompt de protótipo visual" ou "FIGMA_PROMPTS".
license: MIT
compatibility: opencode
metadata:
  audience: analistas-e-devs
  workflow: documentacao-de-requisitos
---
# rdd-figma-prompt — Prompt para Figma Make

Gera prompt textual pronto para colar no Figma Make, descrevendo a interface
a ser prototipada — telas, componentes, campos, estados visuais e comportamentos.
Quando `UI_SPEC.md` existe, usa sua estrutura rica de telas, componentes e estados.
Quando não existe, faz fallback para `REQUIREMENTS.md` apenas (mesmo comportamento
do `figma-make-prompt` legado).

## Referências

- Front matter: `CONSTITUTION.md §2`
- DAG: `CONSTITUTION.md §4`

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

- `<modulo>/<projeto>/REQUIREMENTS.md` (obrigatório — §1 Scope, §2 Atores, §5 RNs de UI, §7 Casos de Uso, §8 Saídas, §10 Decisions/Out of Scope)
- `<modulo>/<projeto>/specs/UI_SPEC.md` (obrigatório se existir — telas, componentes, campos, estados, árvore de componentes, regras condicionais; fallback: raiz)
- `<modulo>/<projeto>/specs/DATA_MODEL.md` (opcional — enriquece tipos de campo; fallback: raiz)
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` (opcional — enriquece validações de frontend; fallback: raiz)
- `<modulo>/<projeto>/specs/DESIGN_BRIEF.md` (opcional — identidade visual/estilo do produto; fallback: raiz)

## Gera (downstream)

- Prompt textual **na resposta** (exibido ao usuário)
- `<modulo>/<projeto>/specs/FIGMA_PROMPTS.md` (append-only, com timestamp/versão) — para rastreabilidade

## Nunca edita

- `REQUIREMENTS.md`
- `UI_SPEC.md`
- `DATA_MODEL.md`
- `API_CONTRACTS.md`

## Tools

- `read` (ler REQUIREMENTS.md, UI_SPEC.md, DATA_MODEL.md, API_CONTRACTS.md)
- `question` (perguntar escopo: completo vs. incremental)
- `bash` (git log/diff para delta incremental)

## Modo de erro

`continue` — se o prompt não for gerado, o time de design perde agilidade mas o desenvolvimento não é bloqueado.

## Formato de commit

```
docs: add figma prompt for <projeto>
```

## Workflow

1. Leia `REQUIREMENTS.md` — extraia escopo, atores, RNs de UI, casos de uso, saídas visuais, out of scope
2. Verifique se `specs/UI_SPEC.md` existe no mesmo módulo (fallback: `UI_SPEC.md` na raiz):
   - **Se existir:** use como fonte principal para telas, componentes, campos, estados, árvore de componentes
   - **Se não existir:** faça fallback extraindo apenas de REQUIREMENTS.md
3. Leia `DATA_MODEL.md` (se existir) — enriqueça tipos de campo no prompt
4. Leia `API_CONTRACTS.md` (se existir) — enriqueça validações que afetam UI
5. Pergunte o escopo via `question`:

```
question({
  questions: [{
    question: "Gerar o prompt do Figma Make a partir de:",
    options: [
      "Documentos completos (novo protótipo)",
      "Apenas mudanças recentes (protótipo existente)"
    ]
  }]
})
```

6. Execute o modo escolhido (completo ou delta)
7. Atualize o arquivo de estado `.opencode/figma-prompt-state.json`

## Rastreamento de sincronia

Usa o mesmo mecanismo do `figma-make-prompt` legado: arquivo `.opencode/figma-prompt-state.json`.

```json
{ "last_synced_commit": "<hash>", "last_synced_at": "DD/MM/AAAA" }
```

Regras:
- **Modo completo:** gera prompt de todos os documentos. Atualiza o estado com o commit atual de `REQUIREMENTS.md`.
- **Modo delta:** se o estado não existir, avise e oferte modo completo. Se existir, rode `git diff` sobre `REQUIREMENTS.md` e `UI_SPEC.md` entre `last_synced_commit` e `HEAD`. Gere prompt apenas com o delta.
- Se o repositório Git não estiver disponível, informe e oferte modo completo.

## O que entra no prompt (e o que não entra)

**Inclua:**
- Telas/fluxos com propósito, URL, permissão de acesso por ator — de UI_SPEC.md §2 ou REQUIREMENTS.md §7
- Campos de formulário com tipo de input (text, date, select, checkbox), obrigatoriedade e comportamento condicional — de UI_SPEC.md §2.4 ou REQUIREMENTS.md §6
- Estados visuais (loading, empty, error, sucesso) — de UI_SPEC.md §2.6
- Árvore de componentes (layout hierárquico da tela) — de UI_SPEC.md §2.3
- Regras de exibição condicional (mostrar/esconder baseado em valor) — de UI_SPEC.md §2.5
- Fluxo de navegação entre telas — de UI_SPEC.md §4 ou REQUIREMENTS.md §7
- Regras de UI globais (formatação, confirmações, toasts) — de UI_SPEC.md §5
- Papéis de usuário e o que cada um vê na interface — de REQUIREMENTS.md §2
- Textos e rótulos de interface (nomes de botões, campos, mensagens) — de REQUIREMENTS.md §8

**Nunca inclua:**
- Identificadores técnicos (nomes de campo de banco, endpoints, enums internos) — traduza para o rótulo que o usuário vê
- IDs internos de regra (`RN-XXX`, `PEND-XXX`)
- Detalhes de backend/infraestrutura (camadas, serviços, integrações de sistema, persistência)
- Conteúdo de "Decisions and Out of Scope" — em vez de omitir, inclua instrução explícita "Não incluir" dizendo ao Figma Make para não prototipar essas funcionalidades

## Modo: completo

Prompt único e estruturado cobrindo:

1. **Contexto** — objetivo do produto (1-2 frases, de REQUIREMENTS.md §1)
2. **Atores e permissões visuais** — quem vê o quê na interface (REQUIREMENTS.md §2)
3. **Lista de telas** — para cada tela:
   - Nome, URL, propósito
   - Layout / árvore de componentes
   - Campos com tipo de input, obrigatoriedade, condicionais
   - Estados visuais
   - RNs que originam a tela (apenas os números, sem descrição)
4. **Fluxo de navegação** entre telas
5. **Regras de UI globais** — formatação, confirmações, toasts
6. **Seção "Não incluir"** — itens de Decisions and Out of Scope relevantes à interface
7. **Instrução de estilo** — derivada das fontes de design do módulo (UI_SPEC.md §5 e DESIGN_BRIEF.md quando existirem) para o Figma Make gerar componentes visualmente compatíveis — NUNCA de stack de implementação (frameworks, libs de componentes)

## Modo: delta (mudanças recentes)

Prompt mais curto assumindo que o Figma Make já tem o contexto do protótipo existente:

1. **Contexto:** "Atualização do protótipo existente com base em mudanças nos requisitos."
2. **Lista de mudanças:** telas/campos/estados novos, alterados ou removidos — cada item conciso (instrução de edição, não redescrição)
3. **Remoções explícitas:** se algo foi removido do escopo, inclua "remover X do protótipo"

## Saída esperada

Produza o prompt como texto pronto para copiar e colar no Figma Make, diretamente na resposta. 
Após entregar o prompt, **grave-o em `<modulo>/<projeto>/specs/FIGMA_PROMPTS.md`** no formato append-only:

```markdown
## Prompt — DD/MM/AAAA HH:MM (modo: completo/delta)

> **Versão dos documentos:** <commit hash>
> **Documentos fonte:** REQUIREMENTS.md, UI_SPEC.md, DATA_MODEL.md, API_CONTRACTS.md

<prompt gerado>

---
```

Se o arquivo já existir, adicione a nova entrada ao final (append). Se não existir,
crie-o com front matter:

```yaml
---
project: <NOME>
module: figma-prompts
audience: [design]
status: draft
---
```

Após salvar, atualize o arquivo de estado local e informe brevemente que o
marcador foi atualizado e que o prompt foi persistido em FIGMA_PROMPTS.md.

Em seguida, aponte o próximo passo natural: fechado o conjunto de specs do
módulo, a camada seguinte da DAG é a de features — proponha gerá-la com
`rdd-task-spec` (análise `analysis/RN-NNN — <título>/` +
`delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-092/093) ou
confirme a ordem com `rdd-next`.

## Casos de Borda

- **Nenhum documento-fonte disponível** (nem UI_SPEC nem REQUIREMENTS): informe e encerre — não gere prompt vazio.
- **Módulo pré-IMP-011 (UI_SPEC.md na raiz):** resolva com fallback para a raiz.
- **Delta sem mudanças desde o último prompt:** informe "nenhuma mudança desde DD/MM" e não gere prompt duplicado.
- **RN ambígua para a tela:** use `question` antes de descrever comportamento visual no prompt.
- **Validação pendente/reprovada:** alerte o usuário antes de gerar o prompt (gate de qualidade).
