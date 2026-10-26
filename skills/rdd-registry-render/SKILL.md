---
name: rdd-registry-render
description: >-
  Gera as views do ARCHITECTURE.md (diagramas Mermaid, tabelas de agentes/skills/domínios)
  e as tabelas de subagents dos primary agents a partir do manifesto canônico registry.yaml.
  Lê o YAML, monta os grafos de delegação e substitui os blocos delimitados por
  <!-- BEGIN_REGISTRY --> / <!-- END_REGISTRY --> nos arquivos alvo.
  Idempotente: mesma entrada produz exatamente a mesma saída.
  Use quando o usuário pedir "renderizar registry", "regenerar architecture",
  "sincronizar views do registry", "atualizar diagramas do RDD", ou quando o
  @rdd-workflow-builder finalizar uma criação de componente.
---
# rdd-registry-render — Renderizador de Views do Registry RDD

Lê `registry.yaml` e regenera as seções estruturais do `ARCHITECTURE.md`
e as tabelas de subagents de `agents/rdd-req.md`, `agents/rdd-doc.md`,
`agents/rdd-dev.md` e `agents/rdd-devops.md` dentro dos marcadores
`<!-- BEGIN_REGISTRY -->` / `<!-- END_REGISTRY -->`.

## Lê (upstream)

- `<config-root>/registry.yaml` — manifesto canônico (essencial)
- `<config-root>/ARCHITECTURE.md` — arquivo alvo (para localizar marcadores)
- `<config-root>/agents/rdd-req.md` — arquivo alvo (para localizar marcadores)
- `<config-root>/agents/rdd-doc.md` — arquivo alvo (para localizar marcadores)
- `<config-root>/agents/rdd-dev.md` — arquivo alvo (para localizar marcadores)
- `<config-root>/agents/rdd-devops.md` — arquivo alvo (para localizar marcadores)

## Gera (downstream)

- Substitui blocos em `<config-root>/ARCHITECTURE.md`:
  - Diagrama de camadas (Mermaid flowchart BT) §1
  - Diagrama de interações (Mermaid flowchart LR) §2
  - Tabela de primary agents §3
  - Tabela de subagents §4
  - Tabela de skills por domínio §5
  - Taxonomia de domínios §6
- Substitui blocos em `<config-root>/agents/rdd-req.md`, `rdd-doc.md`, `rdd-dev.md` e `rdd-devops.md`:
  - Tabela de subagents

## Nunca edita

- Seções narrativas fora dos marcadores `<!-- BEGIN_REGISTRY --> / <!-- END_REGISTRY -->`
- Skills, agents, ou qualquer outro arquivo de configuração
- Artefatos de módulo RDD

## Tools

- `read` (ler registry.yaml, ARCHITECTURE.md, rdd-req.md, rdd-doc.md, rdd-dev.md)
- `edit` (substituir blocos delimitados)
- `question` (confirmar dry-run ou aplicar)

## Modo de erro

`interativo` — mostra diff entre o bloco atual e o gerado antes de aplicar.
Se registry.yaml não existir, aborta com instrução de criá-lo primeiro.
Se os marcadores não forem encontrados nos arquivos alvo, aborta e orienta.

## Casos de Borda

- **registry.yaml unparseável (YAML inválido):** **ABORTA** sem tocar nenhuma view — reporte a linha/erro de parse e oriente corrigir o manifesto primeiro; views desatualizadas são preferíveis a views corrompidas.
- **Marcadores `BEGIN_REGISTRY`/`END_REGISTRY` ausentes em arquivo alvo:** aborta e orienta — nunca crie blocos por conta própria; se apenas um alvo estiver sem marcadores, aborte o lote inteiro e reporte quais arquivos estão irregulares.
- **Id duplicado dentro da mesma coleção** (`subagents` ou `skills`): aborta e reporta — o render não decide qual entrada prevalece. Duplo registro ENTRE coleções (mesmo id em `subagents` e `skills` — ex.: rdd-next) é padrão legítimo e não é erro.
- **Colisão de ID de nó no Mermaid (dois nós com o mesmo `S<N>`):** o segundo `S<N>` sobrescreve o label do primeiro e o diagrama renderiza errado (IMP-129). O render NUNCA emite ID repetido: os IDs são regenerados da lista completa em uma passada determinística (regra da View A); ao detectar colisão com a view anterior, renumere nós, arestas e class na mesma passada e reporte a correção.
- **Conteúdo manual fora dos blocos:** seções narrativas fora dos marcadores (incl. edições manuais dentro do ARCHITECTURE.md) são **preservadas** — o render substitui SOMENTE o conteúdo entre `BEGIN_REGISTRY`/`END_REGISTRY`.
- **Registry desatualizado vs. disco (skill/agent em disco sem registro):** renderiza o que existe e reporta os órfãos (`registry:agentes_em_disco_registrados` / `registry:skills_em_disco_registradas`) — registrar componente novo é trabalho do `rdd-workflow-builder`, não deste render.
- **Referência pendente (delegates/invokes aponta para id inexistente):** reporte como dangling e aborta o gate (`registry:referencias_resolvem`) — não silencie a referência quebrada.
- **Duplo registro na camada de skills (§1):** skills também registradas como subagents (`rdd-next`, `rdd-progress`, `rdd-cr-propagation-guard`, `rdd-tasks-pending`) NÃO recebem nó próprio na camada L5 do diagrama — contam no label `<N> skills` e são representadas pelo subagent correspondente (L4). Toda outra skill registrada ganha nó.
- **Self-invokes (legado de duplo registro):** `invokes` auto-referente renderiza `—` na coluna "Invoca skills" da §4 e NÃO gera aresta — jamais emita aresta vazia (`X --> ` sem destino).
- **Numeração da §5:** numere as sub-tabelas `### 5.<N>` sequencialmente conforme a ordem de exibição no documento (5.1, 5.2, …) — nunca reaproveite a ordem interna do registry.
- **Encoding:** escreva sempre UTF-8 sem BOM (IMP-097); NUNCA produza mojibake (`ÔÇ—`, `â†’`, `â”€`, `Â§`). Mojibake pré-existente dentro do bloco é saneado na mesma passada (precedente IMP-105).

## Workflow

### Passo 1 — Ler registry.yaml

Leia o arquivo `registry.yaml`. Identifique:

- `primary_agents` — cada um com `id`, `delegates`, `invokes_direct`
- `subagents` — cada um com `id`, `owner`, `available_to`, `registered_by` (legado), `invokes`
- `skills` — cada um com `id`, `domain`, `description`
- `domains` — cada um com `orchestrator`, `skills`

Construa internamente os grafos:
- `primary → subagents` (via `delegates`)
- `subagent → skills` (via `invokes`)
- `domain → skills` (via agrupamento)

### Passo 2 — Gerar views

Gere cada view no formato especificado abaixo, usando os dados do registry.

#### View A — Diagrama de camadas (Mermaid flowchart BT)

```
flowchart BT
    subgraph L5["5. Skills (<N> skills)"]
        direction TB
        S1["rdd-xxx (Domain)"]
        S2["rdd-yyy (Domain)"]
    end
    subgraph L4["4. Subagents (<N>)"]
        direction TB
        SA1["@rdd-xxx<br/>desc curta"]
    end
    subgraph L3["3. Primary Agents"]
        REQ["rdd-req.md"]
        DOC["rdd-doc.md"]
        DEV["rdd-dev.md"]
        OPS["rdd-devops.md"]
    end
    REQ --> SA1
    DOC --> SA2
    SA1 --> S1 & S2
```

**Atribuição de IDs de nós de skills (`S<N>`) — regra determinística anti-colisão (IMP-129):**

1. Monte a lista completa de nós ANTES de atribuir qualquer ID: todas as skills registradas exceto as de duplo registro (caso de borda acima), ordenadas pela ordem das chaves `domains:` no registry.yaml e, dentro de cada domínio, pela ordem da lista `skills:` do domínio.
2. Atribua `S1..SN` sequencialmente sobre essa lista em UMA única passada — IDs estritamente únicos.
3. NUNCA derive ID da view anterior ("próximo ID livre" contra snapshot stale) — a numeração é SEMPRE regenerada da lista completa: mesma árvore, mesma saída (idempotência).
4. Antes de aplicar, valide: (a) contagem de nós = N; (b) nenhum `S<N>` repetido; (c) as arestas e a linha `class ... skill` referenciam exatamente os IDs da lista final — sem duplicar nem omitir.

#### View B — Diagrama de interações (Mermaid flowchart LR)

```
flowchart LR
    User((Usuário))
    subgraph Primary["1. Primary Agents"]
        REQ["rdd-req.md"]
        DOC["rdd-doc.md"]
        DEV["rdd-dev.md"]
        OPS["rdd-devops.md"]
    end
    subgraph Subagents["2. Subagents"]
        NEXT["@rdd-next"]
    end
    subgraph Skills["3. Skills"]
        S1["rdd-xxx"]
    end
    subgraph External["4. Sistemas"]
        FS["Filesystem do projeto"]
        GITHUB["GitHub Issues/PRs"]
    end
    User --> REQ & DOC
    REQ --> SA1
    DOC --> SA2
    SA1 --> S1
    S1 -.->|"escreve"| FS
```

#### View C — Tabela de Primary Agents

```
| Primary | Descrição | Delega para | Invoca diretamente |
|---------|-----------|-------------|--------------------|
| `rdd-req` | ... | subagents list | skills list |
| `rdd-doc` | ... | subagents list | skills list |
| `rdd-dev` | ... | subagents list | skills list |
| `rdd-devops` | ... | subagents list | skills list |
```

#### View D — Tabela de Subagents

```
| Subagent | Descrição | Invoca skills | Owner | Disponível para |
|----------|-----------|---------------|-------|----------------|
| `@rdd-xxx` | ... | skills | `rdd-yyy` | `rdd-yyy`, `rdd-zzz` |
```

#### View E — Tabela de Skills por Domínio

Gerar uma sub-tabela para cada domínio, com header `### <N>.<M> <Domain>`.

```
| Skill | Descrição | Acessada via |
|-------|-----------|--------------|
| `rdd-xxx` | ... | `@rdd-orchestrator` |
```

#### View F — Taxonomia de Domínios

```
| Domínio | Orquestrador padrão | Skills |
|---------|---------------------|--------|
| intake | `@rdd-intake-orchestrator` | project-intake, init, legacy |
```

#### View G — Tabela de subagents dos primary agents (rdd-req.md, rdd-doc.md, rdd-dev.md, rdd-devops.md)

```
| Subagent | Quando invocar |
|----------|----------------|
| `@rdd-xxx` | descrição curta |
```

### Passo 3 — Dry-run

Leia os arquivos alvo e localize os blocos `<!-- BEGIN_REGISTRY -->` / `<!-- END_REGISTRY -->`.
Compare o bloco atual com o bloco gerado. Exiba o diff via `question`.

Pergunte: "Aplicar alterações? (sim/não/detalhar)"

### Passo 4 — Aplicar

Para cada arquivo alvo (incluindo `agents/rdd-devops.md`):
1. Localize `<!-- BEGIN_REGISTRY -->` ... `<!-- END_REGISTRY -->`
2. Substitua o conteúdo interno pelos blocos gerados
3. Informe quais seções foram alteradas

### Passo 5 — Confirmar

Exiba resumo:
- ARCHITECTURE.md: <N> seções atualizadas
- rdd-req.md / rdd-doc.md / rdd-dev.md / rdd-devops.md: tabelas de subagents atualizadas
- Diff total: <N> linhas alteradas

## Formato de commit

```
ops(registry): render views from registry.yaml
```
