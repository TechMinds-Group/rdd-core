---
name: rdd-decision-log
description: >-
  Formaliza o registro de decisões tomadas durante o fluxo de requisitos,
  adicionando timestamps, rastreabilidade (RN afetada, PEND resolvido),
  impacto e alternativas consideradas, no padrão ADR-NNN (formato MADR).
  Complementa DECISIONS.md existente com merge incremental. Use quando o
  usuário pedir "registrar decisão", "adicionar decisão", "ADR-NNN",
  "decision log" ou "decidir sobre RN". Prompts do operador com
  "DEC-XXX" mapeiam para ADR-NNN (esquema legado, pré-migração).
---
# rdd-decision-log — Log de Decisões

Formaliza decisões de requisitos em `<modulo>/<projeto>/DECISIONS.md`
com merge incremental (nunca deleta decisões existentes). Cada entrada
tem ID estável (ADR-NNN, formato MADR — mesmo template do `rdd-requirements`)
e rastreabilidade para RNs e PENDs afetados.

## Referências

- IDs ADR-NNN: `CONSTITUTION.md §1` (entradas `DEC-XXX` pré-migração = legado imutável — nunca renumerar)
- DECISIONS.md: artefato da raiz do módulo (Fase 1 — Requirements)

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

- `<modulo>/<projeto>/REQUIREMENTS.md` (RNs existentes, PENDs)
- `<modulo>/<projeto>/DECISIONS.md` (decisões existentes — merge incremental)
- `<modulo>/<projeto>/support/CHANGE_REQUESTS.md` (se existir — verificar CRs vinculados)

## Gera (downstream)

- `<modulo>/<projeto>/DECISIONS.md` (merge incremental — adiciona nova entrada)

## Nunca edita

- Artefatos técnicos (DATA_MODEL, API_CONTRACTS, UI_SPEC, etc.)
- `REQUIREMENTS.md` (lê para rastreabilidade, mas não altera)
- Entradas de decisão existentes em DECISIONS.md (merge incremental, nunca sobrescreve)

## Tools

- `read` (ler DECISIONS.md existente, REQUIREMENTS.md, CHANGE_REQUESTS.md)
- `write` (atualizar DECISIONS.md com merge incremental)
- `question` (coletar detalhes da decisão: alternativas, responsável, justificativa)
- `grep` (buscar ADR-NNN existentes para gerar o próximo ID; DEC-XXX legado não entra na sequência)
- `glob` (verificar se DECISIONS.md existe)

## Modo de erro

`strict` — DECISIONS.md é artefato de governance. Falha na escrita deve
ser reportada e bloqueia a confirmação da decisão.

## Formato de commit

```
docs(requirements): add ADR-<NNN> — <título-curto>
```

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum módulo RDD encontrado. Informe o caminho do módulo."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual módulo.

### Passo 2 — Ler DECISIONS.md existente

Leia `<modulo>/<projeto>/DECISIONS.md` (com fallback para a raiz se
módulo pré-IMP-011).

- Se não existe → crie um novo com o template base (apenas front matter
  e cabeçalho).
- Se existe → extraia o maior `ADR-NNN` existente para gerar o próximo ID.
  Entradas legadas `DEC-XXX` não entram na sequência — se não houver
  nenhum ADR, comece em `ADR-001`.

### Passo 3 — Coletar detalhes da decisão

Use `question` para coletar:

1. **Título curto** da decisão (ex: "Autenticação via JWT")
2. **Contexto** (o que motivou a decisão — qual problema ou RN)
3. **RN ou PEND vinculado** (ex: RN-015, PEND-003 — opcional)
4. **Alternativas consideradas** (mínimo 2, se aplicável)
5. **Decisão tomada** (o que foi decidido)
6. **Decisor** (quem decidiu)
7. **Justificativa** (por que esta alternativa venceu)

### Passo 4 — Gerar entrada

Gere a entrada no formato do template e faça merge com DECISIONS.md
existente. **Nunca** reescreva entradas anteriores — apenas adicione
a nova entrada na seção correta.

### Passo 5 — Atualizar CHANGELOG.md (opcional)

Se CHANGELOG.md existir, adicione uma linha referenciando o novo ADR.
(Se não existir, não crie — não é escopo desta skill.)

## Template — Entrada em DECISIONS.md

Mesmo formato do `rdd-requirements` (MADR). Cabeçalho do arquivo:
`# Architecture Decision Records — [Nome do Módulo]`.

```markdown
## ADR-NNN: [título curto]

**Status:** Aceito | Proposto | Rejeitado | Superseded by ADR-YYY
**Data:** DD/MM/AAAA
**Decisor:** [nome do decisor/autor da decisão] | Não informado
**Contexto:** [censo que levou à decisão. Referencie RN-XXX ou PEND-XXX
se aplicável; em supersede, referencie a ADR antiga]
**Decisão:** [o que foi decidido — usar linguagem direta]
**Consequências:** [impactos positivos, negativos, riscos, dívidas
técnicas; RNs afetadas, PENDs resolvidos e artefatos downstream, se
aplicável]
```

## Merge Incremental

Ao adicionar uma entrada a DECISIONS.md:

1. Leia o conteúdo existente completo.
2. Localize a posição correta (após a última ADR na seção de decisões,
   ou antes da seção "Decisões Antigas/Superseded" se existir).
3. Insira a nova entrada **sem alterar** nenhuma entrada existente.
4. Se a ADR atual substitui uma anterior, marque a anterior como
   `Superseded by ADR-YYY` (apenas atualize o campo Status da ADR antiga
   — não remova a entrada). Entradas legadas `DEC-XXX` nunca são
   alteradas — referencie-as no Contexto da nova ADR quando relacionadas.

## Casos de Borda

- **DECISIONS.md não existe:** crie o arquivo com front matter + cabeçalho
  "Architecture Decision Records — [Nome do Módulo]" + a primeira entrada.
- **Decisão que substitui outra:** marque a ADR antiga como `Superseded
  by ADR-NNN` e crie a nova com status `Aceito`. Referencie a ADR antiga
  na seção "Contexto" da nova.
- **RN ou PEND não existe no REQUIREMENTS.md:** registre como referência
  (o ID pode ser de uma RN que será criada futuramente).
- **Múltiplas decisões em sessão:** crie entradas separadas (ADR-NNN,
  ADR-NNN+1, etc.) — nunca agrupar decisões distintas numa só entrada.
- **Decisão reversada depois:** crie uma nova ADR com status `Aceito` e
  marque a anterior como `Superseded by ADR-NNN` — não edite o conteúdo
  da ADR original.
- **Entradas legadas `DEC-XXX` em DECISIONS.md:** nunca renumere nem
  migre — IDs estáveis são imutáveis. A nova entrada é sempre `ADR-NNN`
  (sequência própria); referencie a DEC legada no Contexto quando
  relacionada.
