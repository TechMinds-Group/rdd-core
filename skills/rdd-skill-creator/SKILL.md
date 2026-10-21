---
name: rdd-skill-creator
description: >-
  Cria uma nova skill do OpenCode para o workflow RDD
  (~/.config/opencode/skills/<nome>/SKILL.md). Coleta o propósito e o
  domínio (fase do pipeline), gera o SKILL.md completo no padrão RDD
  (front matter name/description, Lê/Gera/Nunca edita, Tools, Modo de
  erro, Algoritmo/Workflow, Template, Formato de commit, Casos de borda)
  e valida o front matter contra a schema do OpenCode. Use quando o
  usuário pedir para criar uma skill RDD.
---
# rdd-skill-creator — Criação de Skill

Cria `~/.config/opencode/skills/<nome>/SKILL.md` — uma skill completa,
pronta para ser carregada via `skill` tool, seguindo o padrão das skills
RDD existentes (rdd-handover, rdd-project-intake, etc.).

## Diferenciação

| Skill | Cria |
|-------|------|
| `rdd-subagent-creator` | Subagent (`mode: subagent`) — tarefa pontual, invocado via `@nome` |
| `rdd-primary-agent-creator` | Primary agent (`mode: primary`) — sessão principal, permissão ampla |
| `rdd-skill-creator` | Skill (`SKILL.md`) — conhecimento de referência sob demanda |

## Lê (upstream)

- `~/.config/opencode/AGENTS.md` — convenções do RDD
- `~/.config/opencode/ARCHITECTURE.md` — mapa de delegação (domínios e orquestradores — para registrar a skill no domínio certo)
- `~/.config/opencode/skills/<exemplo>/SKILL.md` — padrões de estilo (ex: rdd-handover, rdd-project-intake)
- Skill `customize-opencode` — schema do front matter de skill (name, description, metadata)

## Gera (downstream)

- `~/.config/opencode/skills/<nome>/SKILL.md` — a skill
- Atualiza `~/.config/opencode/ARCHITECTURE.md` — diagrama (feito pelo `rdd-workflow-builder`)

## Nunca edita

- Nenhum artefato de módulo, nenhum agente, nenhum código.

## Tools

- `question` (coletar requisitos, confirmar plano)
- `glob` (verificar colisão de nome)
- `read` (exemplos, AGENTS.md, customize-opencode)
- `write` (criar o SKILL.md)
- `skill` (carregar customize-opencode)

## Modo de erro

`strict` — skill com front matter inválido (name ≠ pasta, description
ausente) não é carregada pelo OpenCode.

## Questionário de requisitos

### Bloco 1 — Identificação (1 pergunta via `question`)

- **Nome** (ex: `rdd-coverage-audit`). Regras: lowercase-hyphen, ≤ 64
  chars, prefixo `rdd-` (RDD) ou prefixo do projeto, único (verificar com
  `glob` em `~/.config/opencode/skills/`).
- **Propósito** (1-2 frases: o que a skill faz).

### Bloco 2 — Domínio e fluxo (1 pergunta)

- **Domínio/fase** do pipeline: Intake, Requisitos, Tradução Técnica,
  Qualidade, Suporte, Governança, Azure, Figma, Fábrica externa, Handover,
  ou transversal. (Skills de pipeline são acessadas via orquestradores de
  fase; skills transversais via demanda direta.)
- **Upstreams** (o que a skill lê) e **downstreams** (o que gera).
- **Pertence a um orchestrator?** Se sim, qual `@rdd-*-orchestrator` o
  registra (o orchestrator precisa ser atualizado depois para listar a
  nova skill).

### Bloco 3 — Comportamento (1 pergunta)

- **Modo de erro**: `strict` (falha bloqueia o pipeline) vs `warn`
  (falha parcial não bloqueia). Exemplos: rdd-project-intake é strict;
  rdd-handover é warn.
- **Formato de commit** preferido (ex: `docs: ...` para artefatos).

## Template — skills/<nome>/SKILL.md

```markdown
---
name: rdd-<nome>
description: >-
  <descrição em 1-3 linhas: o que a skill faz + quando usá-la. Front-load
  as keywords/nomes de arquivos que o usuário provavelmente vai dizer.>
---
# rdd-<nome> — <título>

<parágrafo curto: o que a skill faz e para que responde>

## Diferenciação

<se houver skills parecidas, tabela comparando — senão omita>

## Lê (upstream)

- <o que a skill lê — arquivos e formatos>

## Gera (downstream)

- <o que a skill gera/atualiza>

## Nunca edita

- <o que está fora do escopo>

## Tools

- `glob` (<para quê>)
- `read` (<para quê>)
- `grep` (<para quê>)
- `question` (<para quê>)
- `write` (<para quê>)

## Modo de erro

`<strict|warn>` — <o que acontece se falhar>

## Formato de commit

```
<exemplo de mensagem de commit>
```

## Algoritmo (ou Workflow)

### Passo 1 — <nome do passo>

<instrução detalhada com critérios verificáveis>

### Passo 2 — <nome do passo>

<instrução detalhada>

## Template de saída (se aplicável)

```<formato>
<template do documento/artefato gerado>
```

## Casos de Borda

- **<caso>**: <comportamento>
```

### Regras do template

1. **Front matter**: `name` (obrigatório, lowercase-hyphen, ≤ 64 chars,
   **deve casar com o nome da pasta**), `description` (obrigatória — skill
   sem description é filtrada e nunca é descoberta). Opcionais: `license`,
   `compatibility`, `metadata`.
2. **Estrutura**: use as seções do template acima (Lê/Gera/Nunca edita/
   Tools/Modo de erro/Formato de commit/Algoritmo ou Workflow/Template/
   Casos de Borda). PT-BR.
3. **Algoritmo verificável**: cada passo tem critério concreto — nunca
   instrução vaga.
4. **Nunca colocar `prompt:` no front matter** — o corpo do arquivo é o
   conteúdo da skill.

## Workflow

1. Carregue `customize-opencode` (skill) para validar o shape do front matter.
2. Colete requisitos com o questionário (3 blocos, 1 pergunta cada).
3. Verifique colisão de nome com `glob` em `~/.config/opencode/skills/`.
4. Crie a pasta `~/.config/opencode/skills/<nome>/` e escreva `SKILL.md`
   com o template completo (preenchido, não placeholder).
5. Valide o front matter: `name` == nome da pasta, `description` presente
   e com "Use quando..."/triggers.
6. **Fechamento com o orchestrator (obrigatório)**: se a skill pertence a
   um domínio com orchestrator (consultar `ARCHITECTURE.md` §3-§4):
   - Verifique se o orchestrator lista a skill na tabela "Skills
     disponíveis" do prompt dele (`~/.config/opencode/agents/<orchestrator>.md`).
   - Se não lista, **atualize o prompt do orchestrator** (adicionar linha na
     tabela) — não apenas oriente o usuário.
   - Se o orchestrator não existe, reporte como "orchestrator a criar" —
     o `rdd-workflow-builder` decide se encadeia o `rdd-subagent-creator`.
7. Exiba o conteúdo para revisão do usuário.
8. **Gate de validação (obrigatório)** — execute a "Checklist para Nova
   Skill" de `CHECKLISTS.md` contra o SKILL.md criado. Todos os itens
   obrigatórios marcados, ou exceções justificadas explicitamente. O
   resultado (PASS + itens verificados / FAIL + itens violados) vai na
   seção "Validação" do IMP que esta criação registrará.
   Item obrigatório violado bloqueia o fechamento da criação.
9. Informe que o `rdd-workflow-builder` fará o registro em
   `ARCHITECTURE.md` e `ARCHITECTURE.md` e que o componente só valerá
   após reiniciar o OpenCode.

## Formato de commit

```
chore(opencode): add rdd-<nome> skill
```

## Casos de Borda

- **Nome já existe**: informe e pergunte — sobrescrever, renomear, cancelar.
- **Skill que pertence a orchestrator**: além do SKILL.md, atualize a
  tabela "Skills disponíveis" do orchestrator (passo 6 do Workflow) — o
  fechamento é obrigatório, não opcional.
- **Orchestrator do domínio não existe**: reporte como "orchestrator a
  criar" — o `rdd-workflow-builder` encadeia o `rdd-subagent-creator`
  (bottom-up) antes de registrar a skill no mapa.
- **Skill transversal**: sem orchestrator — acessada diretamente pelo
  primary agent (ex: rdd-handover); registre no mapa §3 como acessada via
  `rdd-req` ou `rdd-doc` (demanda do usuário).
- **Skill de projeto específico**: use o prefixo do projeto (ex:
  `<projeto>-test-generator`) e não registre na seção RDD do AGENTS.md.
