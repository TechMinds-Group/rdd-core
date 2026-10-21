---
name: rdd-subagent-creator
description: >-
  Cria um novo subagent do OpenCode para o workflow RDD
  (~/.config/opencode/agents/<nome>.md). Coleta o propósito, define o
  escopo de permissão pelo princípio do menor privilégio, gera o prompt
  completo no padrão RDD (identidade, princípios, Lê/Gera, Tools,
  algoritmo, casos de borda) e valida o front matter contra a schema do
  OpenCode. Use quando o usuário pedir para criar um subagent RDD.
---
# rdd-subagent-creator — Criação de Subagent

Cria `~/.config/opencode/agents/<nome>.md` — um subagent completo,
pronto para uso, seguindo o padrão dos subagents RDD existentes
(rdd-next, rdd-progress, rdd-cr-propagation-guard, etc.).

## Diferenciação

| Skill | Cria |
|-------|------|
| `rdd-subagent-creator` | Subagent (`mode: subagent`) — tarefa pontual, invocado via `@nome` |
| `rdd-primary-agent-creator` | Primary agent (`mode: primary`) — sessão principal, permissão ampla |
| `rdd-skill-creator` | Skill (`SKILL.md`) — conhecimento de referência sob demanda |

## Lê (upstream)

- `~/.config/opencode/AGENTS.md` — convenções do RDD
- `~/.config/opencode/ARCHITECTURE.md` — mapa de delegação (skills por domínio, para inferir dependências)
- `~/.config/opencode/registry.yaml` — manifesto canônico
- `~/.config/opencode/agents/<exemplo>.md` — padrões de estilo (ex: rdd-next.md, rdd-cr-propagation-guard.md)
- Skill `customize-opencode` — schema do front matter (campos permitidos, modos, permissões)

## Gera (downstream)

- `~/.config/opencode/agents/<nome>.md` — o subagent
- Atualiza `registry.yaml` e primary agents (`rdd-req.md`, `rdd-doc.md`, `rdd-dev.md`) — tabela de subagents (feito pelo `rdd-workflow-builder`)
- Atualiza `~/.config/opencode/ARCHITECTURE.md` — diagrama (feito pelo `rdd-workflow-builder`)

## Nunca edita

- Nenhum artefato de módulo, nenhum outro agente, nenhum código.

## Tools

- `question` (coletar requisitos, confirmar plano)
- `glob` (verificar colisão de nome)
- `read` (exemplos, AGENTS.md, customize-opencode)
- `write` (criar o arquivo do subagent)
- `skill` (carregar customize-opencode)

## Modo de erro

`strict` — subagent com front matter inválido quebra o startup do OpenCode.

## Questionário de requisitos

### Bloco 1 — Identificação (1 pergunta via `question`)

- **Nome** (ex: `rdd-coverage-audit`). Regras: lowercase-hyphen, ≤ 64
  chars, prefixo `rdd-` (RDD) ou prefixo do projeto, único (verificar com
  `glob` em `~/.config/opencode/agents/`).
- **Propósito** (1-2 frases: o que faz, para quê serve).

### Bloco 2 — Comportamento (1 pergunta)

- **O que faz**: entrada (lê o quê), saída (gera o quê), decisão (algoritmo).
- **Escopo de permissão** — escolha um dos perfis:

| Perfil | Uso típico | Permissão |
|--------|-----------|-----------|
| **Read-only** | Diagnóstico, recomendação, dashboards (rdd-next, rdd-progress) | read/glob/grep allow; edit/write/bash deny |
| **Escrita restrita** | Guard que persiste 1 arquivo específico (rdd-cr-propagation-guard) | edit/write apenas no caminho-alvo; bash deny |
| **Orquestrador** | Roteia para skills (rdd-azure-orchestrator) | read/glob/grep allow; edit/write ask ou deny; bash ask |
| **Escrita em config** | Edita a configuração do próprio workflow (rdd-workflow-improver) | edit/write restritos a `~/.config/opencode/**`; bash deny |

- **Skills que o subagent invoca** (obrigatório para orquestradores e
  subagents que executam skills): liste as skills que o subagent vai
  carregar via `skill` tool para cumprir a função. Consulte o
  `ARCHITECTURE.md` §3 (skills por domínio) para selecionar as
  existentes. **Verifique a existência de cada uma com `glob`** em
  `~/.config/opencode/skills/`. Se alguma não existir, reporte como
  **"skill a criar"** — o `rdd-workflow-builder` decide se encadeia o
  `rdd-skill-creator` (Fase 4 do fluxo dele).

### Bloco 3 — Registro (1 pergunta)

- Confirmar se será registrado no `registry.yaml`, primary agents e no `ARCHITECTURE.md` (padrão: sim).

## Template — agents/<nome>.md

```markdown
---
name: rdd-<nome>
description: >-
  <descrição em 1-3 linhas: o que faz + quando invocar. Front-load
  keywords e nomes de arquivos que o usuário provavelmente vai dizer.>
mode: subagent
temperature: 0.1
permission:
  read: allow
  glob: allow
  grep: allow
  skill: <allow se invoca skills; senão omita>
  edit: <allow|deny|ask|{caminho: allow, "*": deny}>
  write: <allow|deny|ask|{caminho: allow, "*": deny}>
  bash: <deny|ask>
---
Você é o **RDD <Nome Formatado>**. <propósito em 1-2 frases>.

## Princípios

1. <princípio 1>
2. <princípio 2>

## Lê (upstream)

- <o que este subagent lê — caminhos e formatos>

## Gera (downstream)

- <o que este subagent gera/persiste>

## Nunca edita

- <o que está fora do escopo>

## Skills disponíveis (se invoca skills)

| Skill | Quando usar |
|-------|-------------|
| `rdd-<skill-1>` | <quando> |
| `rdd-<skill-2>` | <quando> |

## Tools disponíveis

- `read` — <para quê>
- `glob` — <para quê>
- `grep` — <para quê>
- `skill` — <para quê: carregar as skills listadas acima>
- `question` — <para quê>

## Algoritmo

### Passo 1 — <nome do passo>

<instrução detalhada com critérios verificáveis>

### Passo 2 — <nome do passo>

<instrução detalhada>

## Formato de saída

```text
═══ rdd-<nome> — <título> ═══
<saída estruturada>
```

## Casos de Borda

- **<caso>**: <comportamento>
```

### Regras do template

1. **Front matter**: `name` (obrigatório, casa com o nome do arquivo),
   `description` (obrigatória, efetiva), `mode: subagent`, `temperature: 0.1`
   (subagents de precisão) ou 0.2 (criativos). Campos adicionais só se
   necessário (`model` para delegar a modelo específico).
2. **Permissões**: menor privilégio. `edit`/`write` **nunca** `allow` amplo
   para subagent — sempre `deny`, `ask` ou restrito a caminho.
3. **Front matter proibido**: NUNCA use `tools:` no front matter — este
   campo **não existe** na schema OpenCode RDD. O campo correto é
   `permission:` com granularidade `allow`/`deny`/`ask` + paths. Se vir
   `tools:` em algum exemplo externo, ignore — é padrão de outro framework.
4. **Heading do corpo**: a seção de ferramentas no corpo do prompt DEVE ser
   `## Tools disponíveis` (informativo) — nunca `## Tools`. O enforcement
   real está no `permission:` do front matter.
5. **Prompt**: sempre nas seções do template (Princípios, Lê/Gera/Nunca
   edita, Tools disponíveis, Algoritmo, Formato de saída, Casos de Borda). PT-BR.
4. **Algoritmo verificável**: cada passo tem critério concreto — nunca
   instrução vaga tipo "documente bem".

## Workflow

1. Carregue `customize-opencode` (skill) para validar o shape do front matter.
2. Colete requisitos com o questionário (3 blocos, 1 pergunta cada — nunca
   campo por campo).
3. Verifique colisão de nome com `glob` em `~/.config/opencode/agents/`.
4. **Verifique as skills invocadas** (se o subagent invoca skills): `glob`
   em `~/.config/opencode/skills/` para cada skill listada no Bloco 2.
   Faltantes → reporte como "skill a criar" (o builder encadeia o
   `rdd-skill-creator`). Se o subagent invoca skills, o front matter deve
   ter `skill: allow`.
5. Escreva `~/.config/opencode/agents/<nome>.md` com o template completo
   (preenchido, não placeholder).
6. Valide o front matter: `name` ≤ 64 chars lowercase-hyphen; `description`
   presente; `mode: subagent`; permissões com menor privilégio; `skill:
   allow` se invoca skills.
7. **Gate de validação (obrigatório)** — execute a "Checklist para Novo
   Subagent" de `CHECKLISTS.md` contra o arquivo criado (front matter,
   permissões sem path de máquina, seções, skills invocadas existentes,
   registro). Resultado (PASS + itens verificados / FAIL + violações)
   vai na seção "Validação" do IMP. Item obrigatório violado bloqueia o
   fechamento.
8. Exiba o conteúdo para revisão do usuário (`read` + resumo na resposta).
9. Informe que o `rdd-workflow-builder` fará o registro em
   `registry.yaml`, `ARCHITECTURE.md` e primary agents e que o
   componente só valerá após reiniciar o OpenCode.

## Formato de commit

```
chore(opencode): add rdd-<nome> subagent
```

## Casos de Borda

- **Nome já existe**: informe e pergunte — sobrescrever, renomear, cancelar.
- **Pedido vago**: se o usuário não souber o que o subagent faz, sugira
  perfis prontos (read-only auditor, orquestrador de um domínio, guard de
  integridade) com exemplos de subagents existentes.
- **Subagent que só invoca skill**: prefira um orchestrator (padrão
  `rdd-*-orchestrator`) com permissão `edit: deny`/`write: deny`; o fluxo
  de roteamento vai no prompt, não em código.
- **Skill invocada não existe**: reporte como "skill a criar" e deixe o
  `rdd-workflow-builder` encadear o `rdd-skill-creator` — nunca crie o
  subagent referenciando skill inexistente sem sinalizar.
- **Precisa de ferramenta externa**: se o subagent precisar de `bash`
  (ex: git), justifique e limite a `bash: ask` com padrões específicos.
