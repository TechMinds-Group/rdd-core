---
name: rdd-azure-workitem-creator
description: >-
  Cria work items no Azure DevOps (Azure Boards) a partir das tasks do
  delivery (delivery/<grupo>/RN-NNN — <título> — Feature.md — IMP-093; fallbacks
  `— Tasks.md` pré-rename (IMP-092) e legados IMP-040 preservados). O CORPO/descrição do work item principal vem do
  RN-NNN — Analise-Funcional.md em analysis/ (linguagem de negócio); a
  ESTRUTURA (work item principal, tasks RN-NNN-M filhas com parent link,
  Activity, AreaPath, IterationPath) vem do arquivo — Feature.md (fallback: — Tasks.md pré-rename). Hierarquia:
  issue principal → Feature OU User Story (pergunta ao operador); tasks
  RN-NNN-M → Task filhas. Consulta antes de criar (nunca duplica), dry-run com
  confirmação prévia e usa o MCP Azure DevOps configurado no ambiente.
  Âncoras `PEND-NNN` em features são legado pré-IMP-094 (leitura ok — IMP-094;
  nada gera feature PEND). Use
  quando o usuário pedir "criar work items", "subir tasks para o Azure DevOps",
  "criar work items a partir das tasks", "publicar tasks no Azure Boards" ou
  "criar PBI no Azure".
---

# rdd-azure-workitem-creator — Criação de Work Items no Azure DevOps a partir das tasks do delivery

Cria work items no Azure DevOps correspondentes às features especificadas em
`delivery/<grupo>/RN-NNN — <título> — Feature.md` (IMP-092/IMP-093 — arquivo DIRETO por
feature, sem subpasta). Divisão fixa de fonte (espelha a `rdd-gh-issue-creator`):
a **ESTRUTURA** dos work items (work item principal, IDs de tasks `RN-NNN-M`,
`Activity`, repositórios) vem do `— Feature.md` (fallback: `— Tasks.md` pré-rename); o **CORPO/descrição** vem do
`RN-NNN — Analise-Funcional.md` em `analysis/RN-NNN — <título>/` (linguagem de
negócio — a linha `> Análise:` do Feature.md aponta o caminho relativo).

## Mapeamento hierárquico (Azure Boards)

| Elemento RDD | Work item Azure Boards |
|---|---|
| Issue principal (`## Issue principal` do Feature.md) | `Feature` **ou** `User Story` — pergunte ao operador qual (não decida por omissão) |
| Task `RN-NNN-M` (`### RN-NNN-M.`) | `Task` **filha** do work item principal (parent link) |
| Campo `**Activity**` do template canônico | Campo `Activity` do work item (`Development` etc.) |

## Pré-condições

- **MCP Azure DevOps configurado e habilitado** no ambiente (tools do server
  `azure-devops` — descoberta/listagem e criação de work items). Se o server não
  estiver disponível, o Modo de erro orienta a configuração e a skill ABORTA —
  não existe fallback CLI para criação.
- Arquivo `— Feature.md` revisado (fallback: `— Tasks.md` pré-rename; e o `Analise-Funcional.md` correspondente em
  `analysis/`; ver fallbacks)
- Parâmetros do Azure (org, projeto, AreaPath, IterationPath) — ver seção própria

## Localização do arquivo de feature (IMP-092/IMP-093; fallbacks: — Tasks.md pré-rename + legados preservados)

Como o título é variável, resolva SEMPRE por glob — NUNCA construa o nome
exato. Na localização, o `<grupo>` sob `delivery/` depende do estilo da §9 da
CONSTITUTION (monthly, sprint, release, flow, horizon, epic, custom — ver
`rdd-task-spec`); a **leitura é agnóstica ao estilo** (glob recursivo). Em
ordem:

1. glob `<modulo>/<projeto>/delivery/**/RN-NNN — * — Feature.md` (fallback: repetir com `— Tasks.md` pré-rename — IMP-092) — quando a RN é
   conhecida (deve retornar exatamente 1 arquivo; mais de 1 → ambiguidade:
   pergunte; 0 → próximo passo)
2. Sem RN específica: glob `delivery/**/* — Feature.md` (depois `* — Tasks.md` pré-rename) — liste todos (ou o mais
   recente, conforme o pedido)
3. **Fallback legado IMP-040** (pré-IMP-092): pasta da feature
   `delivery/**/RN-NNN*/` com o PAR de 2 arquivos — a ESTRUTURA vem do
   `RN-NNN — Analise-Tecnica.md` e o CORPO do `RN-NNN — Analise-Funcional.md`
   dentro da pasta
4. Fallback legado pré-IMP-040: arquivo flat `delivery/<YYYY-MM>/RN-NNN — <título>.md`
5. Fallback legado IMP-034: `delivery/RN-*.md` na raiz de `delivery/`
6. Fallback legado IMP-032: sprint mais recente `delivery/<YYYY-MM>/TASKS*.md`
7. Fallback: `<modulo>/<projeto>/delivery/TASKS.md`
8. Fallback pré-IMP-011: `<modulo>/<projeto>/TASKS.md`

Ao resolver o `— Feature.md` (ou `— Tasks.md` pré-rename), leia a linha `> Análise: ../../analysis/RN-NNN — <título>/`
da proveniência e use o `RN-NNN — Analise-Funcional.md` dessa pasta como CORPO.
Se a linha existir mas o Funcional NÃO existir (feature migrada parcialmente),
use o próprio `— Feature.md` como corpo com AVISO na saída (ver Modo de erro).

## Lê (upstream)

- `<modulo>/<projeto>/delivery/<grupo>/RN-NNN — <título> — Feature.md` — ESTRUTURA: issue principal, tasks `RN-NNN-M`, `Activity`, repositórios (resolução por glob — seção acima)
- `<modulo>/<projeto>/analysis/RN-NNN — <título>/RN-NNN — Analise-Funcional.md` — CORPO do work item principal: "O que esta entrega faz", "Comportamento esperado", "Regras de negócio" (1..N), "O que fica de fora" (caminho da linha `> Análise:` do Feature.md; fallbacks da seção acima)
- `<modulo>/<projeto>/REQUIREMENTS.md` — RNs referenciadas nas tasks
- `<modulo>/<projeto>/specs/*.md` — specs associadas (API_CONTRACTS, UI_SPEC, DATA_MODEL) para a seção de referências
- CONSTITUTION.md §9 do repo de docs do produto — campo `tracker` (github|azure): azure confirma este destino

## Gera (downstream)

- Work items no Azure DevOps via MCP (1 principal `Feature`/`User Story` + N `Task` filhas com parent link)
- `<modulo>/<projeto>/delivery/<grupo>/ISSUES_CREATED.md` — resumo dos work items criados, na pasta do grupo do arquivo de feature lido (mesmo padrão da `rdd-gh-issue-creator`; se lido de local legado, na mesma pasta do arquivo lido)

## Nunca edita

- O arquivo `— Feature.md` (fallback: `— Tasks.md` pré-rename; fonte primária — a criação de tasks é do `rdd-task-spec`)
- Os arquivos de `analysis/` (fonte do corpo)
- Artefatos de specs do módulo
- Work items já existentes (nunca duplica — consulta antes; comentário/edição de work item alheio está fora de escopo)
- Config do OpenCode (AGENTS.md, opencode.jsonc, skills, agents)

## Tools

- Tools do MCP Azure DevOps (server `azure-devops`): consulta de work items existentes (antes de criar — deduplicação por título contendo `RN-NNN`/`RN-NNN-M`) e criação de work item com campos (title, type, area path, iteration path, activity, description, parent link). Descubra os nomes exatos das tools disponíveis no ambiente (ex.: via busca no catálogo de tools do runtime) — NÃO presuma nomes
- `read` (ler o Feature.md, o Funcional, REQUIREMENTS.md, specs)
- `glob` (resolver o arquivo de feature — nunca construir nome exato)
- `write` (gerar ISSUES_CREATED.md)
- `question` (parâmetros do Azure, tipo do work item principal, confirmação do dry-run — agrupar em UMA chamada, IMP-043)

## Parâmetros do Azure (pergunta agrupada — IMP-043)

Pergunte em UMA única `question` (defaults do ambiente — org/projeto/repos/usuário
do perfil do cliente: `rules/client-profile.md` (IMP-103), espelhados no bloco
`azure-devops` do AGENTS.md global — pré-oferecidos, SEMPRE aceitando override;
nunca hardcode como únicos):

| Parâmetro | Default do ambiente | Observação |
|---|---|---|
| Org | `<org-do-perfil>` | organização Azure DevOps — consultar `rules/client-profile.md` (IMP-103) |
| Projeto | `<projeto-do-perfil>` | projeto do produto — consultar `rules/client-profile.md` (IMP-103) |
| AreaPath | área default do projeto | aceitar override |
| IterationPath | iteração corrente do projeto | aceitar override; nunca invente |
| Tipo do principal | `Feature` ou `User Story` | pergunta obrigatória — sem default por omissão |
| Tracker §9 | — | se CONSTITUTION §9 `tracker: azure`, destino confirmado; se `github`, confirme a troca de destino |

Se o pedido já trouxer algum parâmetro explícito, não re-pergunte o informado.

## Modo de erro

- `strict` para o MCP: server `azure-devops` indisponível → oriente a configuração
  do MCP Azure DevOps no ambiente e ABORTE (nada é criado por fallback). Nunca
  logue, imprima ou persista tokens/pat — o acesso é problema do MCP, não desta skill.
- Arquivo de feature não encontrado em nenhuma localização da seção de
  localização → aborta com mensagem clara.
- `Analise-Funcional.md` ausente com linha `> Análise:` presente (migração
  parcial): AVISE e use o próprio `— Feature.md` como corpo do work item
  principal, sinalizando regenerar via `rdd-task-spec` ou completar a migração
  via `rdd-restructure` (modo split-delivery).
- Erro do Azure na criação (permissão, area/iteration inexistente): reporte o
  erro tal qual retornado pelo MCP, interrompa o lote e registre no
  ISSUES_CREATED.md o que foi criado até o ponto da falha.

## Workflow

### Passo 1 — Validar ambiente

Confirme que as tools do server `azure-devops` estão disponíveis. Se não:
orientar a configuração do MCP Azure DevOps e abortar (strict).

### Passo 2 — Ler o arquivo de feature + a análise

Localize o `— Feature.md` (fallback: `— Tasks.md` pré-rename; seção de localização) e leia a linha `> Análise:` da
proveniência; leia o `RN-NNN — Analise-Funcional.md` apontado. Do `— Feature.md`
(ESTRUTURA), identifique: issue principal (título, milestone, repos) e tasks
filhas: título, RNs, `Activity`, prefixo (`[Database]`, `[DevOps]`, `[<repo>]`).
Do Funcional (CORPO): "O que esta entrega faz", "Comportamento esperado",
"Regras de negócio" (1..N), "O que fica de fora". Nunca use trechos técnicos
(endpoints, tabelas, frameworks) do `Analise-Tecnica.md`/spec pura no corpo —
eles ficam na descrição das `Task` filhas e nas referências.

### Passo 3 — Deduplicar (nunca duplica)

Consulte work items existentes no projeto alvo (query por título contendo o
token `RN-NNN` e `RN-NNN-M`). Work item já existente → pule e registre no
relatório como "já existente (não duplicado)". Case pelo token do ID, nunca
pelo texto livre.

### Passo 4 — Perguntar parâmetros (1 question agrupada)

Org, projeto, AreaPath, IterationPath, tipo do principal (Feature/User Story) —
defaults do ambiente pré-oferecidos, sempre com override. Inclua o dry-run do
Passo 5 na MESMA interação quando possível (IMP-043: decisão única).

### Passo 5 — Dry-run (confirmação)

Exiba a lista completa de work items que serão criados:

```
⚠️ Dry-run — NADA foi criado ainda.

Work items a criar em https://dev.azure.com/<org>/<projeto> (AreaPath: <area> · IterationPath: <iteration>):
1. [Feature] [Salon-demo] RN-082 — Programa de Fidelidade
   RNs: RN-082, RN-083
   Body: <"O que esta entrega faz" do Funcional>
2.   └─ [Task] [Salon-API] RN-082-1 — Migration: tabela PontosFidelidade (Activity: Development)
3.   └─ [Task] [Salon-FE]  RN-082-3 — Extrato de pontos no portal (Activity: Development)

Total: 1 Feature + N Tasks · Já existentes (pulados): <M>

Criar? (sim/não)
```

Se o operador disser não, aborta sem criar nada.

### Passo 6 — Criar work items

Ordem: (1) work item principal (`Feature`/`User Story`) com o corpo funcional;
(2) cada `Task` filha com parent link para o principal. Descrição da `Task`
filha: o bloco correspondente do `— Feature.md` (Descrição, Contrato, Validações,
Critério de Aceitação, Dependências, Notas técnicas — blocos condicionais do
template canônico) + campo **RNs**. Nunca concatene duas tasks num work item
(escopo único por task).

**Body do work item principal** — seções funcionais do
`Analise-Funcional.md`; `## RNs` do campo **RNs** das tasks do `— Feature.md`:

```markdown
## Descrição
<parágrafo "O que esta entrega faz" do Analise-Funcional.md>

## Comportamento esperado
<bullets da seção "Comportamento esperado" do Analise-Funcional.md>

## Regras de negócio
<tabela numerada 1..N da seção "Regras de negócio" do Analise-Funcional.md>

## O que fica de fora
<bullets da seção "O que fica de fora" do Analise-Funcional.md>

## RNs
- RN-XXX
- RN-YYY

## Referências
- [RN-NNN — Analise-Funcional.md](<caminho em analysis/>)
- [RN-NNN — <título> — Feature.md](<caminho em delivery/>)
- [API_CONTRACTS.md](<caminho em specs/>)
- [UI_SPEC.md](<caminho em specs/>)
- [DATA_MODEL.md](<caminho em specs/>)
```

### Passo 7 — Registrar ISSUES_CREATED.md

Após criar todos os work items, gere `delivery/<grupo>/ISSUES_CREATED.md`
(pasta do grupo do arquivo de feature lido; legado → mesma pasta do arquivo):

```markdown
# Work Items Criados — <módulo> (Azure DevOps)

> Criados em <data> via rdd-azure-workitem-creator · <org>/<projeto> ·
> Iteration: <iteration> · Area: <area>

| # | Task | Work item | Tipo | Link |
|---|------|-----------|------|------|
| 1 | (principal) RN-NNN — <título> | #<id> | Feature/User Story | <url> |
| 2 | RN-NNN-1 | #<id> | Task | <url> |
| 3 | RN-NNN-2 | #<id> | Task | <url> |

Pulados (já existentes): <lista ou "nenhum">
```

## Formato de commit

```
feat(tasks): create Azure DevOps work items for <modulo>
```

## Casos de Borda

- **MCP Azure indisponível** — abortar (strict) com orientação de configuração; nunca tentar criar via REST manual com token no comando.
- **Tipo do principal não informado** — pergunta obrigatória (Feature vs User Story); jamais assumir por omissão.
- **AreaPath/IterationPath inválidos no projeto** — erro do Azure reportado; sugerir override na próxima tentativa; nada é "quase criado".
- **Work item já existe (dedupe por RN-NNN/RN-NNN-M)** — pular e registrar; nunca criar duplicata nem editar a existente.
- **Feature migrada parcialmente (linha `> Análise:` sem Funcional)** — corpo do próprio Feature.md com aviso.
- **Estilo de delivery diferente de monthly (sprint/release/flow/horizon/epic/custom)** — irrelevante para a leitura: o glob recursivo resolve o `— Feature.md` (ou `— Tasks.md` pré-rename) em qualquer grupo; ISSUES_CREATED.md é gravado no grupo do arquivo lido.
- **Legado IMP-040 (pasta com 2 arquivos)** — usa o par Técnica(estrutura)+Funcional(corpo) da pasta, sem exigir migração prévia.
- **Lote multi-feature** — uma feature (RN-âncora) por vez: principal + filhas; repita o ciclo por arquivo `— Feature.md` (ou `— Tasks.md` pré-rename) alvo.
- **Feature com âncora PEND legada (pré-IMP-094)** — legível (glob de leitura mantém `PEND-NNN` como legado); nada gera feature PEND — novas features nascem só de RN (IMP-094).
