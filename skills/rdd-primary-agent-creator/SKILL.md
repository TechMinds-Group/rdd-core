---
name: rdd-primary-agent-creator
description: >-
  Cria um novo primary agent do OpenCode para o workflow RDD
  (~/.config/opencode/agents/<nome>.md, mode: primary). Coleta o domínio
  de atuação, define permissão ampla (padrão rdd-req/rdd-doc), gera o prompt
  completo com identidade, subagents que invoca e comportamento, e valida
  o front matter contra a schema do OpenCode. Use quando o usuário pedir
  para criar um primary agent RDD.
---
# rdd-primary-agent-creator — Criação de Primary Agent

Cria `~/.config/opencode/agents/<nome>.md` com `mode: primary` — um agente
de sessão principal, no padrão da Quadri RDD (`rdd-req.md`, `rdd-doc.md`, `rdd-dev.md`, `rdd-devops.md`). Primary agents conduzem
a sessão, invocam subagents e têm permissão ampla (blast-radius aceito e
documentado no AGENTS.md).

## Diferenciação

| Skill | Cria |
|-------|------|
| `rdd-subagent-creator` | Subagent (`mode: subagent`) — tarefa pontual, invocado via `@nome` |
| `rdd-primary-agent-creator` | Primary agent (`mode: primary`) — sessão principal, permissão ampla |
| `rdd-skill-creator` | Skill (`SKILL.md`) — conhecimento de referência sob demanda |

## Lê (upstream)

- `~/.config/opencode/AGENTS.md` — convenções do RDD, modelo de permissão
- `~/.config/opencode/agents/rdd-req.md` / `rdd-doc.md` / `rdd-dev.md` — padrão de primary agent (referência principal)
- `~/.config/opencode/ARCHITECTURE.md` — mapa de delegação (subagents por primary, skills por subagent — para inferir a árvore)
- `~/.config/opencode/ARCHITECTURE.md` — catálogo de subagents/skills (para a tabela do prompt)
- Skill `customize-opencode` — schema do front matter (mode, campos permitidos)

## Gera (downstream)

- `~/.config/opencode/agents/<nome>.md` — o primary agent
- Atualiza `~/.config/opencode/ARCHITECTURE.md` — diagrama (feito pelo `rdd-workflow-builder`)

## Nunca edita

- Nenhum artefato de módulo, nenhum outro agente, nenhum código.

## Tools

- `question` (coletar requisitos, confirmar plano)
- `glob` (verificar colisão de nome, listar subagents existentes)
- `read` (rdd-req.md, rdd-doc.md, rdd-dev.md, exemplos, customize-opencode)
- `write` (criar o arquivo do primary agent)
- `skill` (carregar customize-opencode)

## Modo de erro

`strict` — primary agent com front matter inválido quebra o startup do OpenCode.

## Questionário de requisitos

### Bloco 1 — Identificação (1 pergunta via `question`)

- **Nome** (ex: `rdd-req`, `rdd-doc`). Regras: lowercase-hyphen, ≤ 64
  chars, prefixo `rdd-` (RDD) ou prefixo do projeto, único (verificar com
  `glob` em `~/.config/opencode/agents/`).
- **Domínio de atuação** (1-2 frases: qual área do pipeline ou produto o
  agente conduz).

### Bloco 2 — Subagents e roteamento (1 pergunta)

- **Quais subagents existentes ele invoca?** Liste os `@rdd-*` relevantes
  (consultar `ARCHITECTURE.md` §1 — primary→subagents — e
  `ARCHITECTURE.md` L4).
- **Há subagents novos que ele deve invocar?** Se sim, o fluxo é:
  criar subagent(s) primeiro (via `rdd-subagent-creator`), depois o primary.
- **Inferência de skills por subagent**: para cada subagent que o primary
  delega, verifique no `ARCHITECTURE.md` §2 quais skills ele invoca.
  Se um subagent novo precisar de skills que não existem, reporte como
  "skill a criar" — o `rdd-workflow-builder` encadeia o `rdd-skill-creator`
  (Fase 4 do fluxo dele). O primary nunca referencia subagent/skill
  inexistente.

### Bloco 3 — Comportamento (1 pergunta)

- **Regras de sessão**: início de sessão (o que verificar primeiro),
  comportamento padrão, limites (ex: confirmar antes de commit/push/PR).
- **Permissão**: padrão é ampla (igual `rdd-req`/`rdd-doc`/`rdd-dev`). Só restrinja se o
  usuário pedir explicitamente.

## Template — agents/<nome>.md

```markdown
---
description: <descrição em 1-2 linhas: domínio de atuação + quando usar>
mode: primary
temperature: 0.3
permission:
  read: allow
  edit: allow
  glob: allow
  grep: allow
  list: allow
  bash: allow
  write: allow
  task: allow
  todowrite: allow
  question: allow
  skill: allow
  webfetch: allow
  websearch: allow
  lsp: allow
  external_directory: allow
---

Você é o **<Nome>** — o agente primário para <domínio de atuação>.
Conduz a sessão principal quando o trabalho é <escopo>.

## Identidade e propósito

<parágrafo: o que o agente é e o que entrega>

## Regras de precedência

Siga a hierarquia documentada no AGENTS.md (seção "Hierarquia de
Precedência"): em conflito de instrução, a camada mais específica vence —
AGENTS.md Global → AGENTS.md do Projeto → Agent (primary) → Subagent →
Skill. Nunca contradiga as convenções do AGENTS.md: prefixo `rdd-`, IDs
RN-XXX/PEND-XXX, DAG de documentos, idioma PT-BR.

## Início de sessão

<o que verificar no início de cada sessão — ex: @rdd-next para próxima ação>

### Subagents

| Subagent | Quando invocar |
|----------|----------------|
| `@rdd-<nome>` | <quando> |
| ... | ... |

Invocação detalhada:

- `@rdd-<nome>` — <detalhe de quando e como invocar>

### Roteamento de domínio

<quais skills/orquestradores o agente acessa e como>

## Comportamento

- <regra de comportamento 1>
- <regra de comportamento 2>
- Confirme com o usuário antes de ações irreversíveis (commit, push, PR).
```

### Regras do template

1. **Front matter**: `description` (obrigatória), `mode: primary`,
   `temperature: 0.3` (padrão Quadri RDD). **Não** usar `name:` no front
   matter de primary agents — a convenção do RDD não usa, e o
   nome vem do arquivo.
2. **Permissão ampla**: copie o bloco de permissões do `rdd-req.md`
   (todas allow). É o modelo de permissão documentado no AGENTS.md.
3. **Prompt**: seções obrigatórias — Identidade e propósito, Regras de
   precedência, Início de sessão, Subagents (tabela + invocação detalhada),
   Roteamento de domínio, Comportamento. PT-BR.
4. **Tabela de subagents**: liste apenas os subagents que o agente
   realmente invoca — não copie a lista inteira do primary.

## Workflow

1. Carregue `customize-opencode` (skill) para validar o shape do front matter.
2. Colete requisitos com o questionário (3 blocos, 1 pergunta cada).
3. Verifique colisão de nome com `glob` em `~/.config/opencode/agents/`.
4. **Verifique a árvore de delegação**: para cada subagent que o primary
   invoca, confirme a existência com `glob` em `~/.config/opencode/agents/`
   e as skills dele no `ARCHITECTURE.md` §2. Faltantes → reporte como
   "a criar" (o builder encadeia `rdd-subagent-creator`/`rdd-skill-creator`).
5. Se o primary invoca subagents novos, crie-os primeiro via
   `rdd-subagent-creator` (e informe o usuário).
6. Escreva `~/.config/opencode/agents/<nome>.md` com o template completo.
7. Valide o front matter: `mode: primary`, `description` presente,
   permissões amplas, sem `name:` no front matter.
8. **Gate de validação (obrigatório)** — execute a "Checklist para Novo
   Primary Agent" de `CHECKLISTS.md` contra o arquivo criado (front
   matter, permissão ampla, seções, subagents existentes, registro).
   Resultado (PASS + itens verificados / FAIL + violações) vai na seção
   "Validação" do IMP. Item obrigatório violado bloqueia o fechamento.
9. Exiba o conteúdo para revisão do usuário.
10. Informe que o `rdd-workflow-builder` fará o registro em
    `ARCHITECTURE.md`, `ARCHITECTURE.md` e que o componente só valerá
    após reiniciar o OpenCode.

## Formato de commit

```
chore(opencode): add <nome> primary agent
```

## Casos de Borda

- **Nome já existe**: informe e pergunte — sobrescrever, renomear, cancelar.
- **Primary agent sem subagents**: ok — omita a tabela e o roteamento,
  mantenha Identidade, Precedência e Comportamento.
- **Confusão subagent vs primary**: primary conduz sessão e tem permissão
  ampla; subagent é tarefa pontual com permissão escopada. Se o pedido for
  "agente que faz X pontualmente", é subagent.
- **Subagent invocado não existe**: reporte como "a criar" — o
  `rdd-workflow-builder` encadeia o `rdd-subagent-creator` antes de criar o
  primary (bottom-up). Nunca crie primary referenciando subagent inexistente.
- **Default agent**: se o usuário quiser que o novo primary seja o agente
  padrão do projeto, isso é config em `opencode.json`
  (`default_agent`), não no arquivo do agente — oriente.
