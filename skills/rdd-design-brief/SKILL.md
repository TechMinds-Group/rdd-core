---
name: rdd-design-brief
description: >-
  Gera DESIGN_BRIEF.md — documento de contexto de produto para a IA do
  Figma Make: identidade e posicionamento, estilo visual,
  estado atual da UI (o que já está pronto) e constraints de design.
  Fonte única do "estilo do produto"; lê apenas docs RDD (PROJECT_CHARTER.md,
  REQUIREMENTS.md, UI_SPEC.md). O prompt por tela continua sendo papel da
  rdd-figma-prompt. Use quando o usuário pedir "design brief",
  "contexto de design", "brief para o Figma", "estilo do produto",
  "design context" ou "product design context".
license: MIT
compatibility: opencode
metadata:
  audience: analistas-e-designers
  workflow: documentacao-de-requisitos
---
# rdd-design-brief — Brief de Design de Produto para Figma Make

Gera `specs/DESIGN_BRIEF.md` — o contexto de **produto** que orienta a
geração de design no Figma Make (IA do Figma): quem o produto é, como deve
parecer e o que já existe pronto. Diferente da `rdd-figma-prompt` (que
descreve **telas** por feature), este brief é a camada de
identidade/estilo/estado — muda raramente e serve de base estável para
qualquer prototipação do produto.

## Diferenciação

| Skill | Escopo | Cadência |
|-------|--------|----------|
| `rdd-design-brief` (esta) | Contexto de produto: identidade, estilo, estado atual da UI, constraints | Rara — muda com identidade/posicionamento |
| `rdd-figma-prompt` | Prompts por tela/feature: telas, campos, estados, delta | Por feature |

## Referências

- Front matter: `CONSTITUTION.md §2`
- DAG: `CONSTITUTION.md §4`

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):
raiz (PROJECT_CHARTER.md, REQUIREMENTS.md), `specs/` (UI_SPEC.md,
DESIGN_BRIEF.md e demais downstreams).

**Regra de fallback (transição):** ao **LER** um artefato, verifique
primeiro o caminho novo (ex: `specs/UI_SPEC.md`); se não existir, use o
caminho legado na raiz do módulo (ex: `UI_SPEC.md`). Ao **ESCREVER/GERAR**,
use sempre o caminho novo (`specs/DESIGN_BRIEF.md`).

## Lê (upstream)

- `<modulo>/<projeto>/PROJECT_CHARTER.md` (obrigatório — propósito,
  posicionamento, público; campos `legado`/`sistema_existente` indicam
  produto já em produção)
- `<modulo>/<projeto>/REQUIREMENTS.md` (obrigatório — §1 escopo, §2 atores,
  §6 dados de formulário, §8 saídas/rótulos, Decisions and Out of Scope)
- `<modulo>/<projeto>/specs/UI_SPEC.md` (opcional — §2 telas e árvore de
  componentes, §5 regras de UI globais; fallback: raiz)

**Não lê (delimitação de escopo):**

- Código de aplicações/repos de frontend — NUNCA varre tokens de tema,
  `tailwind.config`, `styles/*` ou similar. A bifurcação
  greenfield/em-produção sai exclusivamente dos DOCS.
- `FIGMA_PROMPTS.md` — não é insumo nem alvo desta skill.
- Protótipos Figma anteriores.

## Gera (downstream)

- `<modulo>/<projeto>/specs/DESIGN_BRIEF.md` — merge incremental
  (padrão rdd-glossary: NUNCA deleta; ver "Regras de merge")

## Nunca edita

- `PROJECT_CHARTER.md`
- `REQUIREMENTS.md`
- `UI_SPEC.md`
- `FIGMA_PROMPTS.md`
- Qualquer código de aplicação/repo (FE, API, CORE)

## Tools

- `read` — ler os 3 docs de módulo
- `glob` — descobrir módulo(s) do projeto; detectar `DESIGN_BRIEF.md` existente
- `grep` — localizar seções nos docs (ex: §5 de UI_SPEC, out-of-scope)
- `question` — múltiplos módulos; confirmação de merge sobre conteúdo manual
- `write`/`edit` — criar/atualizar APENAS `specs/DESIGN_BRIEF.md`

## Modo de erro

`strict` — `PROJECT_CHARTER.md` ausente encerra com erro orientado
("gere o charter primeiro via rdd-project-intake"); `REQUIREMENTS.md`
ausente idem ("gere requisitos primeiro via rdd-requirements"). Múltiplos
módulos candidatos → `question` para o operador selecionar.

## Formato de commit

```
docs: add design brief for <projeto>
```

## Workflow

### Passo 1 — Resolver o módulo

1. Use `glob` para localizar `PROJECT_CHARTER.md` no diretório do módulo.
2. Se houver mais de um módulo candidato, pergunte via `question` qual usar.
3. Se nenhum charter existir: erro orientado (Modo de erro) e encerre.

### Passo 2 — Detectar o estado do produto (docs-only)

Classifique a partir dos DOCS, nunca de código:

| Sinal nos docs | Estado do produto |
|----------------|-------------------|
| Charter com `legado: true` ou `sistema_existente: true` | Em produção — UI já existe |
| UI_SPEC com telas detalhadas + RNs já marcadas como entregues em REQUIREMENTS | Em construção |
| Nenhum dos sinais | Greenfield — nada implementado |

### Passo 3 — Extrair conteúdo por seção

- **Identidade e propósito/públicos** → `PROJECT_CHARTER.md`
  (nome, posicionamento, diferencial, tom de voz inferido do charter)
- **Escopo e atores** → `REQUIREMENTS.md` §1-§2 (quem usa, o que cada um vê)
- **Identidade visual** → derive de UI_SPEC §5 (regras de UI
  globais: formatação, toasts, confirmações) e §2 (árvore de componentes —
  padrões de layout); quando os docs não especificarem paleta/tipografia,
  registre como "a definir" com sugestão coerente com o posicionamento —
  NUNCA invente como se fosse decisão confirmada
- **Estado atual da UI** → resultado do Passo 2, com lista de telas
  mencionadas em UI_SPEC §2 / REQUIREMENTS §8
- **Constraints** → REQUIREMENTS (out-of-scope, Decisions), charter
  (restrições de cliente/plataforma), UI_SPEC (regras de exibição)
- **Telas prioritárias** → ordene as telas de UI_SPEC §2 / REQUIREMENTS §7
  por valor de negócio (atores principais primeiro, fluxo crítico primeiro)
- **Instruções para o Figma Make** → do/don't derivados do próprio brief
  (ex: "seguir densidade de tabela descrita", "não inventar funcionalidade
  de out-of-scope")

### Passo 4 — Merge incremental (never-delete)

1. Verifique com `glob` se `specs/DESIGN_BRIEF.md` já existe.
2. Se não existe: gere do template completo e escreva.
3. Se existe: leia o brief atual e aplique as Regras de merge
   (abaixo) — seções manuais do operador são autoritativas.
4. Se o merge confrontar conteúdo manual ambíguo, pergunte via `question`.

### Passo 5 — Persistir e reportar

1. Escreva/atualize `specs/DESIGN_BRIEF.md` (sempre caminho novo, IMP-011).
2. Exiba o resumo: estado do produto detectado, seções adicionadas vs
   preservadas.
3. Aponte o próximo passo natural: gerar prompts por tela com
   `rdd-figma-prompt` (via `rdd-figma-orchestrator`).

## Regras de merge (never-delete — padrão rdd-glossary)

- Seção inexistente no brief atual → **adiciona**.
- Seção existente com conteúdo manual (não derivável dos insumos) →
  **PRESERVA** e anuncia ao operador.
- Seção existente derivada de insumo que mudou → **atualiza o conteúdo**,
  preservando trechos manuais reconhecíveis.
- **NUNCA remove** seção, estilo, termo ou decisão já registrada.
- **Edição manual do brief é fonte autoritativa** — vence sobre inferência.

## Template de saída

```markdown
---
project: <NOME>
module: design-brief
audience: [design]
status: draft
---
# DESIGN_BRIEF — <Nome do Produto>

> Contexto de produto para geração de design no Figma Make.
> Fonte: PROJECT_CHARTER.md, REQUIREMENTS.md, UI_SPEC.md — <data>

## 1. Identidade do produto

- **Nome:** <nome>
- **Posicionamento:** <1-2 frases>
- **Tom de voz:** <formal/amigável/técnico — inferido ou "a definir">
- **Diferencial:** <o que o torna único>

## 2. Propósito e públicos

- **Propósito:** <do charter>
- **Públicos/atores:** <ator — o que usa e o que vê>

## 3. Identidade visual

- **Paleta:** <hex ou "a definir — sugestão: ...">
- **Tipografia:** <fontes ou "a definir">
- **Densidade/estilo geral:** <compacto/espaçado; cantos; elevação>
- **Iconografia:** <estilo ou "a definir">

## 4. Design system / padrões visuais

- **Padrões de layout:** <da árvore de componentes de UI_SPEC §2>
- **Regras de UI globais:** <formatação, toasts, confirmações — UI_SPEC §5>

## 5. Estado atual da UI

- **Status do produto:** greenfield | em construção | em produção
- **Telas já especificadas/existentes:** <lista de UI_SPEC §2 / REQUIREMENTS §8>
- **Padrões já adotados:** <se documentados nos docs>

## 6. Constraints de design

- <responsividade, acessibilidade, branding do cliente, plataforma>
- **Out of scope (não prototipar):** <de Decisions/Out of Scope>

## 7. Telas prioritárias

1. <tela> — <por que é prioritária>
2. <tela> — <...>

## 8. Instruções para o Figma Make

**Faça:**
- <ex: seguir as regras de UI globais da seção 4>

**Não faça:**
- <ex: inventar funcionalidades de out-of-scope; alterar a paleta definida>
```

## Casos de Borda

- **Greenfield sem UI_SPEC:** derive tudo de PROJECT_CHARTER + REQUIREMENTS;
  seção 5 marca "greenfield — nada implementado"; telas prioritárias
  orientam o primeiro protótipo.
- **Módulo com sistema existente** (charter `legado`/`sistema_existente`):
  seção 5 marca "em produção" — o Figma Make deve gerar designs coerentes
  com o que o produto JÁ é, não reinventar.
- **Re-geração com brief editado manualmente:** merge never-delete; conteúdo
  manual vence; nunca deletar sem confirmação explícita via `question`.
- **Módulo pré-IMP-011 (UI_SPEC na raiz):** resolva com fallback para a raiz;
  escreva sempre em `specs/`.
- **Docs não especificam estilo visual:** registre "a definir" com sugestão
  explícita — nunca apresente inferência como decisão confirmada.

## Composição futura (NÃO implementado)

- A `rdd-figma-prompt` consome `DESIGN_BRIEF.md` como insumo opcional da
  seção "Instrução de estilo" (derivada de fontes de design — IMP-089).
- O `rdd-figma-orchestrator` já roteia pedidos de "estilo/contexto de
  design" para esta skill (registro no `registry.yaml`, domínio `figma`).