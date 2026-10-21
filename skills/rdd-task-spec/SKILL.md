---
name: rdd-task-spec
description: >-
  Gera as DUAS camadas da feature (IMP-092) no diretório do módulo: a análise
  analysis/RN-NNN — <título>/ (RN-NNN — Analise-Funcional.md + RN-NNN —
  Analise-Tecnica.md — spec técnica PURA, sem tasks) e o arquivo de feature
  delivery/<grupo-do-estilo>/RN-NNN — <título> — Feature.md (IMP-093; canônico com issue
  principal + tasks RN-NNN-M, linkando a análise), a partir de PROJECT_CHARTER.md,
  REQUIREMENTS.md, DATA_MODEL.md, API_CONTRACTS.md, ARCHITECTURE.md e UI_SPEC.md,
  para revisão antes da criação das issues no GitHub/Azure — uma análise + um arquivo de feature
  por FEATURE, nomeados pela RN-âncora (IMP-094: âncora SÓ RN — PEND nunca
  ancora feature; âncora PEND ABORTA com orientação de promoção). Use quando
  o usuário pedir "gerar tasks", "spec de tasks", "tasks da RN-NNN" ou
  "especificar PBI e tasks".
---
# rdd-task-spec — Gera a análise e o arquivo de feature para revisão antes da criação das issues

Gera, numa passada, AS DUAS CAMADAS da feature (IMP-092) no diretório do módulo
(conforme IMP-011, IMP-035, IMP-037 e IMP-040):

1. **Análise** — pasta `analysis/RN-NNN — <título da feature>/` contendo SEMPRE exatamente
   2 arquivos: `RN-NNN — Analise-Funcional.md` (o que a feature precisa fazer — linguagem de
   negócio, sem tecnicidade) e `RN-NNN — Analise-Tecnica.md` (spec técnica PURA da feature —
   contexto, mapa RN→repositórios/endpoints/telas, decisões, contratos e tabelas, riscos —
   SEM issue principal, SEM tasks);
2. **Delivery** — arquivo DIRETO `delivery/<grupo-do-estilo>/RN-NNN — <título da feature> —
   Feature.md` (IMP-093 — SEM subpasta por feature) no canônico IMP-039: Issue principal, Resumo das
   tasks, Ordem de Execução em waves e tasks `RN-NNN-M`, com a linha de proveniência
   OBRIGATÓRIA `> Análise: ../../analysis/RN-NNN — <título>/` linkando a pasta da análise.

**Regra de ouro (IMP-092):** dependência UNIDIRECIONAL tasks→análise — o Feature.md linka a
análise e carrega o campo **RNs**; a análise NUNCA cita tasks, sprints ou delivery.
Reorganizar, mover ou apagar tasks nunca invalida a documentação.

O grupo de pasta sob `delivery/` (`<grupo-do-estilo>`) vem da CONSTITUTION.md §9 do projeto
("Organização de Delivery e Análise" — IMP-092); default de escrita enquanto a §9 não existe:
`monthly` → `YYYY-MM`. O usuário revisa e edita os arquivos; depois usa
`@rdd-github-orchestrator` (skill `rdd-gh-issue-creator`) ou o equivalente Azure para criar
as issues de forma interativa.

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):

- **Raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
- **`analysis/`:** `RN-NNN — <título da feature>/` — PASTA por feature com exatamente 2
  arquivos: `RN-NNN — Analise-Funcional.md` + `RN-NNN — Analise-Tecnica.md` (análise em pasta
  própria — IMP-092; RN-âncora — IMP-035; título sanitizado — IMP-037)
- **`delivery/<grupo-do-estilo>/`:** arquivo DIRETO `RN-NNN — <título da feature> — Feature.md`
  por feature, SEM subpasta (IMP-092). Grupo conforme CONSTITUTION §9: `monthly` → `YYYY-MM`
  (ex.: `2026-10`); `sprint` → `YYYY-MM-DD` (data de INÍCIO da sprint, sem prefixo
  `sprints/`); `release` → nome livre (`v2.1`, `Q1-2027`, `Cycle 4`); `flow` → `backlog`;
  `horizon` → `now`|`next`|`later`; `epic` → nome do épico; `custom` → placeholders do
  `custom_template`
- **`specs/`:** DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, FIGMA_PROMPTS.md, COMPLIANCE.md
- **`quality/`:** TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEABILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md
- **`delivery/` (raiz):** TASKS*.md legado (pré-IMP-034); RN-*.md legado IMP-034 (pré-IMP-035); PASTAS legadas IMP-040 `delivery/<YYYY-MM>/RN-NNN — <título>/` com 2 arquivos; arquivo flat `RN-NNN — <título>.md` na sprint (pré-IMP-040) — migráveis via `rdd-restructure` (pastas IMP-040: modo `split-delivery`)
- **`delivery/` (raiz):** TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md, ISSUES_CREATED.md
- **`support/`:** LEGACY_CONTEXT.md, KNOWN_ERRORS.md, MIGRATION.md, CHANGE_REQUESTS.md
- **`glossaries/`:** DEV_GLOSSARY.md, BUSINESS_GLOSSARY.md, USER_GLOSSARY.md, GLOSSARY.md
- **`docs/`:** howto/*.md e documentos auxiliares
- **`meetings/`, `contracts/`:** checkpoints (inalterados)

**Regra de fallback (transição):** ao **LER** um artefato, verifique primeiro
o caminho novo (ex: `specs/DATA_MODEL.md`); se não existir, use o caminho
legado na raiz do módulo (ex: `DATA_MODEL.md`). Ao **ESCREVER/GERAR**, use
sempre o caminho novo. Módulos ainda não migrados via `rdd-restructure`
continuam legíveis durante a transição.

**Duas camadas por feature (IMP-092):** a análise vive em `analysis/RN-NNN — <título da
feature>/` e o delivery em `delivery/<grupo-do-estilo>/RN-NNN — <título da feature> —
Feature.md` — ambos nomeados pela **RN-âncora + espaço + em-dash (`—`) + espaço + título da
feature** (IMP-035 + IMP-037). **Grafia fixa:** os nomes usam EXATAMENTE `Analise-Funcional`
e `Analise-Tecnica` (sem acento no "Analise") — NÃO mudar para "Análise". O em-dash `—`
(U+2014) é o separador válido. A RN-âncora sempre existe em REQUIREMENTS.md (nunca inventar
— IMP-033) e é SEMPRE uma RN (IMP-094: âncora = só `RN-XXX`; PEND nunca ancora feature).
**Sanitização do título (IMP-037):** substitua caracteres inválidos para nome de
pasta/arquivo (`/` `\` `:` `*` `?` `"` `<` `>` `|`) por espaço; colapse espaços duplicados;
remova espaços/pontos finais. NÃO troque o em-dash por hífen.

**IMP-093 (rename do arquivo de feature):** o arquivo de delivery chama-se `RN-NNN — <título> — Feature.md` (renomeado de `— Tasks.md` da IMP-092 — SÓ o nome do arquivo muda). Seções internas e o canônico IMP-039 são INALTERADOS (`## Issue principal`, `## Resumo das tasks`, `## Ordem de Execução`, tasks `### RN-NNN-M` continuam "tasks" — coerentes com o tracker). H1 e a linha `> Análise:` permanecem. Arquivos `— Tasks.md` pré-rename permanecem legíveis como fallback de leitura — NUNCA gerados.

Ao **ESCREVER/GERAR**, crie as duas camadas numa passada (batch multi-feature → um par
análise + Feature.md por feature/RN-âncora). Ao **LER**, o título é variável — resolva SEMPRE
por glob, NUNCA construindo o nome exato, nesta ordem:

1. **Feature (formato vigente IMP-093):** glob recursivo `delivery/**/RN-NNN — *` (quando a RN
   é conhecida) e `delivery/**/PEND-NNN — *` — o padrão `PEND-NNN` é LEGADO de LEITURA
   (features pré-IMP-094, ex: projeto legado; NUNCA gerado — IMP-094) — o candidato deve ser único (mais de 1 →
   ambiguidade: pergunte; 0 → próximo). Se for o ARQUIVO `RN-NNN — <título> — Feature.md` (IMP-093),
   leia direto (o pré-rename `— Tasks.md` da IMP-092 permanece legível como fallback — nunca gerado).
2. **Tasks (legado IMP-040):** se o candidato do glob for a PASTA `RN-NNN — <título>/`, leia
   `RN-NNN — Analise-Tecnica.md` dentro dela.
3. **Análise:** glob na pasta `analysis/` com prefixo `RN-NNN*` — leia
   `RN-NNN — Analise-Tecnica.md` e/ou `RN-NNN — Analise-Funcional.md` conforme o pedido.
4. **Sem RN específica:** glob recursivo `delivery/**/RN-*` (todas/mais recente conforme o
   pedido), preferindo arquivos `— Feature.md` (fallback: `— Tasks.md` pré-rename).
5. Legado pré-IMP-040: arquivo flat `delivery/<YYYY-MM>/RN-NNN — <título>.md` (ler o arquivo
   direto).
6. Legado IMP-034 (pré-IMP-035): `delivery/RN-*.md` na raiz de `delivery/`.
7. Legado IMP-032: sprint mais recente `delivery/<YYYY-MM>/TASKS*.md`.
8. Fallback `delivery/TASKS.md`; (9) `TASKS.md` na raiz do módulo.

## Lê (upstream)

- `<modulo>/<projeto>/PROJECT_CHARTER.md` — módulo, visão geral, repositórios
- `<modulo>/<projeto>/REQUIREMENTS.md` — RNs confirmadas e descrições
- `specs/API_CONTRACTS.md` — endpoints, request/response, validações e erros
- `specs/DATA_MODEL.md` — tabelas reais, colunas, PKs/FKs
- `specs/UI_SPEC.md` — telas, componentes, fluxos e validações de frontend
- `support/LEGACY_CONTEXT.md` (se existir) — queries e tabelas do legado
- `CONSTITUTION.md` do projeto — §9 (Organização de Delivery e Análise — IMP-092: `delivery_style`, `sprint_weeks`, `custom_template`, `tracker`), §13 (prefixos de título) e §14 (colunas de auditoria padrão)
- `<repo_docs_rdd>/_docs/patterns/INDEX.md` — bloco `rdd-docs-repo` do AGENTS.md (condicional — IMP-047): para cenários recorrentes no lote, consultar padrões aplicáveis (Tipos `codigo`/`ui`/`dados`/`teste`) e citá-los na `Analise-Tecnica` das features afetadas

## Gera (downstream)

- `<modulo>/<projeto>/analysis/RN-NNN — <título da feature>/` — PASTA por feature/RN-âncora com exatamente 2 arquivos: `RN-NNN — Analise-Funcional.md` (análise funcional em linguagem de negócio) e `RN-NNN — Analise-Tecnica.md` (spec técnica PURA — contexto, mapa RN→repos, decisões, contratos e tabelas, riscos — SEM tasks); batch multi-feature → N pastas (IMP-092)
- `<modulo>/<projeto>/delivery/<grupo-do-estilo>/RN-NNN — <título da feature> — Feature.md` — ARQUIVO DIRETO (IMP-093) por feature/RN-âncora (sem subpasta): canônico IMP-039 (issue principal + tasks `RN-NNN-M` para revisão do operador) + linha OBRIGATÓRIA `> Análise:` linkando a análise (IMP-092)

## Nunca edita

- Os documentos-fonte acima (somente leitura)
- Análises e tasks de outras features ou de grupos de delivery anteriores (`analysis/RN-MMM — <título>/` e `delivery/**/RN-MMM — <título> — Feature.md` — resolva por glob prefixo `RN-MMM*`) — apenas os arquivos das features alvo, na geração corrente, são criados
- Tasks legado (pasta IMP-040 `RN-NNN — <título>/` com 2 arquivos; arquivo flat `RN-NNN — <título>.md` na sprint — pré-IMP-040; `RN-*.md` na raiz de `delivery/` — IMP-034; `TASKS*.md` em subpastas de sprint ou `delivery/TASKS.md` — pré-IMP-034) — não migrar nem converter (isso é papel do `rdd-restructure`, modo `split-delivery`)
- GitHub — a criação de issues é do `@rdd-github-orchestrator` (skill `rdd-gh-issue-creator`), não desta skill
- Config do OpenCode (AGENTS.md, opencode.jsonc, skills, agents)

## Tools

- `read`/`glob`/`grep` — ler os documentos de entrada do módulo
- `question` — apenas o mínimo necessário (RN-âncora da feature, milestone, AreaPath, REDMINE — e o que a CONSTITUTION §9 não resolver: data de início da sprint, nome de release/épico, placeholders custom, tracker — Fase 3)
- `write`/`edit` — materializar as duas camadas (IMP-092): `analysis/RN-NNN — <título>/` (`RN-NNN — Analise-Funcional.md` + `RN-NNN — Analise-Tecnica.md`) e `delivery/<grupo>/RN-NNN — <título> — Feature.md`

## Fluxo

```
PROJECT_CHARTER.md ───────┐
REQUIREMENTS.md ──────────┤
specs/API_CONTRACTS.md ───┤
specs/DATA_MODEL.md ──────┼──► rdd-task-spec ──► analysis/RN-NNN — <título>/ (Funcional + Técnica PURA — IMP-092)
specs/UI_SPEC.md ─────────┤                └───► delivery/<grupo>/RN-NNN — <título> — Feature.md (IMP-093 + link > Análise:)
support/LEGACY_CONTEXT.md ┘
CONSTITUTION.md §9 ───────┘  (delivery_style + tracker)
                          │ (revisão manual, depois via @rdd-github-orchestrator)
```

## Workflow

### Fase 1: Ler documentos de entrada

1. **PROJECT_CHARTER.md**
   - Nome do módulo (frontmatter `project:` ou nome do diretório)
   - Visão geral do projeto
   - Repositórios envolvidos

2. **REQUIREMENTS.md**
   - RNs confirmadas: linhas `**RN-NNN**` com tag `[confirmado]`
   - Texto da descrição de cada RN
   - Secões: Dados e Campos, Regras de Negócio, Restrições Técnicas

3. **API_CONTRACTS.md**
   - Endpoints: método, path, request/response, path params, query params
   - Validações e erros (ERROR_CATALOG.md ou seção de erros)
   - Identificar quais RNs cada endpoint implementa

4. **DATA_MODEL.md**
   - Tabelas envolvidas: nome real da tabela (ex: `SDA_BLOQUEIO`), colunas, PKs, FKs
   - Relacionamentos entre tabelas
   - Mapeamento de colunas para uso no template "Tabelas de referência" e "Query de referência"

5. **UI_SPEC.md**
   - Telas, componentes, fluxos de navegação
   - Validacões de frontend
   - Identificar quais RNs cada tela implementa

6. **LEGACY_CONTEXT.md** (se existir)
   - SQL queries de referência do sistema legado
   - Tabelas e colunas existentes
   - Mecanismos legados a evitar ou reaproveitar

7. **CONSTITUTION.md** (raiz do projeto)
   - §9 (Organização de Delivery e Análise — IMP-092): `delivery_style` (monthly|sprint|release|flow|horizon|epic|custom), `sprint_weeks` (1..6, quando sprint), `custom_template` (quando custom), `tracker` (github|azure). **§9 ausente → a Fase 3 pergunta e oferece persistir** (default de escrita: `monthly`)
   - §14 (Colunas de Auditoria): colunas obrigatórias (`CTR_DTH_INC`, `CTR_DTH_ATU`, `CTR_USU_INC`, `CTR_USU_ATU`, `CTR_NRO_IP_INC`, `CTR_NRO_IP_ATU`) com tipos e obrigatoriedade, definidas na CONSTITUTION.md do projeto
   - §13 (Convenção de Nomenclatura de Repositórios em Tasks): prefixos `[Database]` / `[DevOps]` e regras de título

### Fase 2: Mapear RNs para repositórios e telas/endpoints

**REGRAS DE MAPEAMENTO (NUNCA perguntar ao usuário):**

| Documento de origem | Repositório destino | Tipo de task |
|---|---|---|
| API_CONTRACTS.md | Backend (ex: `<nome>.API`) | Backend |
| UI_SPEC.md | Frontend (ex: `<nome>.MFE`) | Frontend |
| LEGACY_CONTEXT.md (legado:true) | Legado (ex: `<nome>.Web`) | Legado |

**Como derivar o repositório:**
- Backend: extrair do frontmatter do PROJECT_CHARTER.md (ex: `repos:` → `<nome>.API`)
- Frontend: extrair do frontmatter ou do nome do módulo MFE (ex: `<nome>.MFE`)
- Legado: se `PROJECT_CHARTER.md` contém `legado: true`, usar o repo do sistema legado

**⚠️ Exceção — sistema alvo diferente (CR com abordagem validada):**
Se um `CHANGE_REQUESTS.md` com status `proposed`, `approved` ou `implemented` já tiver validado a abordagem indicando repositório/sistema **diferente** do backend padrão do módulo, o repositório backend DEVE ser o indicado na validação de abordagem. O campo `Repositório alvo` no CR tem precedência sobre a inferência automática.

**Exemplo:** Uma listagem pública de habilitados pode ter sido validada para ir para `Consultas Publicas` em vez de `<nome>.API`. Neste caso, a task deve usar `[Consultas Publicas]` como repositório.

**Como agrupar tasks:**
- **1 task por endpoint backend** — agrupa todas as RNs que aquele endpoint implementa
- **1 task por tela/componente frontend** — agrupa todas as RNs que aquela tela implementa
- **1 task para alteração em legado** — se alguma RN exige alteração no sistema legado (ex: redirect, compatibilidade)

**Regra de escopo único (uma task = um repositório/escopo):**
- Cada task DEVE conter **apenas um repositório/escopo** no título (ex: `<nome>.API` ou `<nome>.MFE`).
- **NUNCA** agrupar, numa mesma task, trabalho que envolva mais de um repo, módulo, frontend+backend simultaneamente, ou banco + código aplicacional como entregáveis misturados.
- Se uma RN toca backend e frontend: gere **duas tasks separadas** (uma `[<backend>]`, outra `[<frontend>]`).
- Se uma RN exige alteração de banco (changeset) e alteração de código: gere **task de banco separada** (`[Database]`) e task de código separada (`[<repo>]`).
- Se uma RN exige configuração DevOps (pipeline, deploy, secrets) e alteração de código: gere **task de DevOps separada** (`[DevOps]`) e task de código separada (`[<repo>]`).
- O objetivo é manter tasks pequenas, independentes e revisáveis — cada uma com um único propósito e um único local de entrega.

**Feature e RN-âncora (IMP-035):**
- Uma **feature** é um bloco de tasks entregue junto — a unidade de entrega. Pode realizar 1..N RNs registradas.
- Cada feature tem uma **RN-âncora**: a primeira RN do escopo (ou a que o usuário indicar). O nome da análise e do arquivo de feature e os IDs das tasks usam APENAS a RN-âncora (o nome inclui também o título da feature — IMP-037).
- As demais RNs realizadas continuam registradas em REQUIREMENTS.md e aparecem no campo **RNs** de cada task. **Proibido** criar `RN-064.md`, `RN-065.md`... para dividir a feature.
- O RN é gerado pelo sistema (REQUIREMENTS.md, sequencial, nunca se repete) — o arquivo reusa a RN-âncora existente; nunca inventa (IMP-033).
- **Âncora é SEMPRE uma RN (IMP-094 R1):** PEND NUNCA ancora feature — âncora `PEND-XXX` ABORTA a geração (Modo de erro). A PEND de origem de uma RN promovida aparece apenas como nota de proveniência em REQUIREMENTS.md (`> Promovida de PEND-NNN em <data>`).

**Validação de IDs (IMP-033 + IMP-094):** ao mapear as RNs de cada task, confira se **todos** os IDs referenciados existem em REQUIREMENTS.md e usam o prefixo `RN-XXX`. A âncora e o campo **RNs** das tasks aceitam SÓ RNs (IMP-094): PEND não ancora feature e não entra no campo RNs. Tasks NUNCA referenciam IDs inventados ou de prefixo paralelo (ex: `COM-01`). Se faltar registro, aborte e instrua o usuário a registrar as regras primeiro (via rdd-requirements, numeração sequencial). Âncora `PEND-XXX` → aborte com orientação de promoção (IMP-094 R1).

**O mapeamento alimenta as DUAS camadas (IMP-092):** a seção `## Mapa RN → repositórios/endpoints/telas` da spec técnica pura (`analysis/.../RN-NNN — Analise-Tecnica.md`) e o campo **RNs** + os títulos das tasks no Feature.md — cada camada com o seu papel; a spec pura NUNCA lista tasks.

### Fase 3: Perguntar ao usuário (mínimo necessário)

Perguntar APENAS:
- RN-âncora da feature (IMP-035): se o contexto não indicar, pergunte qual — ou apresente as RNs confirmadas de REQUIREMENTS.md sem análise/tasks na geração corrente (comparar com glob `analysis/RN-*` e glob recursivo `delivery/**/RN-*`). Nunca derive por omissão. **Âncora `PEND-XXX` → ABORTE (IMP-094 R1)** com a orientação: "promova a PEND a RN primeiro (nova RN sequencial em REQUIREMENTS.md citando a origem — via rdd-requirements), depois gere com a RN como âncora". Se a feature realiza várias RNs (ex: RN-063..073), confirme a âncora (a primeira do escopo ou a que o usuário indicar) — e NÃO crie uma análise por RN. Capture também o **título da feature** (obrigatório para o nome — IMP-037): use o título presente no contexto (REQUIREMENTS.md, discussão da feature); só se NÃO houver título derivável, pergunte APENAS o título da feature.
- Sprint/milestone (ex: `Sprint 33`, `v2.1`)
- Repositório/area para as issues (ex: `org/repo`)
- Se as issues já têm tracking externo (ex: REDMINE, Jira). Se sim, qual.
- **Grupo do delivery (IMP-092)** — SOMENTE o que a CONSTITUTION §9 NÃO resolver:
  - `delivery_style: sprint` → data de INÍCIO da sprint (grupo = `YYYY-MM-DD`, sem prefixo `sprints/`)
  - `delivery_style: release` ou `epic` → nome do grupo (ex.: `v2.1`, `Pagamentos`)
  - `delivery_style: horizon` → qual horizonte (`now`, `next` ou `later`)
  - `delivery_style: custom` → o valor de CADA placeholder do `custom_template` (ex.: `<cliente>`, `<trimestre>`)
  - `tracker` (github|azure) se §9 ausente
  - **§9 inteira ausente** → pergunte o estilo desejado e OFEREÇA persisti-lo na §9 da CONSTITUTION (só persiste com confirmação explícita do operador); se o operador recusar, use o estilo APENAS para a geração corrente. Enquanto a §9 não existe, o default de escrita é `monthly`.

NÃO perguntar:
- Qual repo para cada RN (já derivado dos documentos)
- Se é front ou back (já derivado)
- Se uma RN é front ou back (derivar de API_CONTRACTS.md vs UI_SPEC.md)
- O grupo do delivery quando derivável da §9 (IMP-092): `monthly` → mês corrente `YYYY-MM` (derivado, sem pergunta extra); `flow` → `backlog` (fixo); `sprint`/`release`/`epic`/`horizon`/`custom` → apenas o valor pendente listado acima
- O nome dos arquivos (IMP-035 + IMP-037 + IMP-092): é `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` (IMP-093), derivado do grupo + RN-âncora + título da feature (sanitizado) — sem pergunta extra, desde que o título esteja no contexto. Os arquivos internos da análise têm nomes FIXOS: `RN-NNN — Analise-Funcional.md` e `RN-NNN — Analise-Tecnica.md`. Só pergunte o título se não for derivável (Fase 3).
### Fase 4: Gerar as duas camadas — analysis/ + delivery/<grupo>/RN-NNN — <título> — Feature.md (IMP-092/IMP-093)

Criar, numa passada, para cada feature/RN-âncora do batch:

1. **Análise** — criar `<modulo>/<projeto>/analysis/RN-NNN — <título sanitizado da feature>/`
   (nome usa o título sanitizado — IMP-037 — e deve coincidir com o H1 gerado) com SEMPRE os
   2 arquivos: (a) **`RN-NNN — Analise-Tecnica.md`** — **spec técnica PURA** no formato da
   seção "Formato da spec técnica pura" (proveniência, H1, contexto técnico, mapa
   RN→repositórios/endpoints/telas, decisões técnicas, contratos e tabelas envolvidos —
   referenciando `specs/` —, riscos/pré-requisitos); (b) **`RN-NNN — Analise-Funcional.md`** —
   análise funcional no template da seção "Formato da análise funcional", derivada da
   RN-âncora + RNs do escopo em REQUIREMENTS.md. **Proibido** no funcional: endpoints/métodos
   HTTP, nomes de tabelas/colunas, frameworks, nomes de serviço/componente técnico, queries,
   códigos de erro técnicos ou menção a repos. **Proibido** na spec pura (Regra de ouro
   IMP-092): `## Issue principal`, `## Resumo das tasks`, `## Ordem de Execução`, tasks
   `### RN-NNN-M` ou qualquer menção a sprint/estilo de delivery/pasta de delivery — tasks
   vivem EXCLUSIVAMENTE no Feature.md.
2. **Delivery** — criar o ARQUIVO DIRETO
   `<modulo>/<projeto>/delivery/<grupo-do-estilo>/RN-NNN — <título sanitizado da feature> —
   Feature.md` (IMP-093 — SEM subpasta por feature) com o canônico IMP-039 COMPLETO (seção "Estrutura
   canônica do arquivo de tasks": front matter, H1, proveniência + linha OBRIGATÓRIA
   `> Análise: ../../analysis/RN-NNN — <título>/`, Issue principal, Resumo das tasks, Ordem
   de Execução, tasks `RN-NNN-M`, Dependências opcional).

O H1 da spec pura e do Feature.md é `# RN-NNN — <título da feature>` (coincide com o nome da
pasta da análise e com o nome do arquivo de feature sem o sufixo ` — Feature.md`).

### Fase 4.5 — Classificar tasks e aplicar prefixos `[Database]` / `[DevOps]`

> **Fonte oficial da convenção:** `CONSTITUTION.md §13` do projeto. Esta fase implementa as heurísticas de classificação definidas lá.
> **Destino (IMP-092):** a classificação alimenta EXCLUSIVAMENTE o arquivo de feature (`RN-NNN — <título> — Feature.md`) — títulos no `## Resumo das tasks`, na `## Ordem de Execução` e nas tasks individuais. A spec técnica pura NUNCA cita tasks.

Após derivar o título preliminar `[<repo>] <descrição>`, classifique cada task conforme as heurísticas abaixo.

**Prefixo `[Database]`** (quando o trabalho predominante for de banco de dados):
- Criação/alteração de tabelas, colunas, índices, constraints, sequences, triggers, views, procedures, functions, packages, synonyms.
- Criação/execução de scripts DDL, DML, Liquibase/Flyway changesets.
- Modelagem derivada de `DATA_MODEL.md`, `LEGACY_CONTEXT.md` ou queries de referência.
- Migração de dados, carga, correção/ajuste de dados.
- Configuração de schema, tablespace, partitionamento, comentários em colunas/tabelas.

Exemplo de reescrita:
- `[Bloqueios.API] Criar changeset Liquibase para coluna IND_BLOQUEIO_GTA`
  → `[Database] Criar changeset Liquibase para coluna IND_BLOQUEIO_GTA`

**Prefixo `[DevOps]`** (quando o trabalho predominante for infraestrutura/CI/CD):
- Criação/configuração de pipelines YAML no Azure Pipelines, GitHub Actions, Jenkins.
- Criação/configuração de ambientes, deploy, release, build, publicação de artefatos.
- Dockerfiles, Docker Compose, Kubernetes manifests, Helm charts.
- Config Server, Service Discovery, API Gateway, secrets, variáveis de ambiente.
- Terraform, Ansible, scripts de provisionamento, nova infraestrutura, certificados.
- Setup inicial de repositório quando a entrega principal for pipeline/dependências/ambiente/conexão.

Exemplo de reescrita:
- `[Bloqueios.API] Configurar pipeline de build e deploy`
  → `[DevOps] Configurar pipeline de build e deploy no Azure Pipelines`

**Regras gerais de classificação:**
- Aplique **no máximo um** prefixo por task (`[Database]` **OU** `[DevOps]`). Se ambos se aplicarem, use `[Database]` (o entregável principal assume o prefixo).
- **Nunca duplique**: se o título já começar com `[Database]` ou `[DevOps]`, mantenha como está.
- Não altere títulos que não se enquadrarem em nenhum dos dois prefixos.
- A classificação é sobre o **trabalho da task**, não sobre o repositório. Uma task em uma API pode ser `[Database]` se o trabalho for changeset/DML.
- Combine com a regra de escopo único: se uma task envolver banco + código aplicacional, quebre em duas — `[Database] ...` e `[<repo>] ...`.

### Fase 4.6 — Incluir colunas de auditoria em tasks `[Database]`

> **Fonte:** CONSTITUTION.md §14 (Colunas de Auditoria).
> **Destino (IMP-092):** os DDLs verificados/garantidos aqui pertencem às tasks `[Database]` do Feature.md.

Para toda task classificada como `[Database]` cujo DDL inclua `CREATE TABLE` (tabela nova), **verificar e garantir** a presença das colunas de auditoria definidas na CONSTITUTION.md do projeto no DDL.

**Regras:**
- Colunas de inclusão são `NOT NULL`; colunas de atualização são nullable
- Se a CONSTITUTION.md não definir colunas de auditoria, esta fase é ignorada

## Formato da spec técnica pura (`analysis/RN-NNN — Analise-Tecnica.md`)

Camada da análise que descreve a feature do ponto de vista técnico SEM especificar tasks — a
execução é detalhada no Feature.md (dependência unidirecional tasks→análise — IMP-092):

```markdown
---
project: <projeto>
module: <módulo>
audience: [tecnica]
status: draft
---

# RN-NNN — <título da feature>

> Gerado por rdd-task-spec em <data>. Edite para revisar.

## Contexto técnico

<Parágrafo: onde a feature se encaixa no sistema, qual problema técnico resolve,
restrições de arquitetura e dependências de contexto.>

## Mapa RN → repositórios/endpoints/telas

| RN | Repositório | Endpoints / Telas |
|---|---|---|
| RN-063 | <nome>.API | GET /bloqueios-produtor/tipos, POST /bloqueios-produtor |
| RN-064 | <nome>.MFE | Tela de bloqueios (listagem + formulário) |

## Decisões técnicas

| # | Decisão | Justificativa |
|---|---|---|
| 1 | <decisão> | <motivo, ADR relacionado, alternativa descartada> |

## Contratos e tabelas envolvidos

- **Contratos de API:** `specs/API_CONTRACTS.md` — <endpoints afetados>
- **Modelo de dados:** `specs/DATA_MODEL.md` — <tabelas/colunas envolvidas>
- **UI:** `specs/UI_SPEC.md` — <telas/componentes afetados>
- **Legado (se houver):** `support/LEGACY_CONTEXT.md` — <queries/tabelas legadas>

## Riscos e pré-requisitos

- <risco, pré-requisito de ambiente/infra, dependência de outra feature>
```

**Regras da spec pura:**
- Fontes: as mesmas da Fase 1 (REQUIREMENTS.md, specs/, LEGACY_CONTEXT.md, CONSTITUTION.md).
- **PROIBIDO** conter (Regra de ouro IMP-092): seções `## Issue principal`, `## Resumo das
  tasks`, `## Ordem de Execução`; tasks `### RN-NNN-M` ou IDs `RN-NNN-M`; menção a sprint,
  estilo de delivery ou pasta/arquivo de delivery. A rastreabilidade RN→task vive
  EXCLUSIVAMENTE no campo **RNs** do Feature.md.
- O mapa RN→repos lista RNs (a âncora e as do escopo), NUNCA tasks.
- Seções técnicas extras são permitidas APENAS se descreverem a feature (nunca o plano de
  execução); em dúvida, detalhe de execução pertence ao Feature.md.

## Formato do arquivo de feature (`delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-093)

### Estrutura canônica do arquivo de feature (IMP-039 + IMP-092 + IMP-093)

Todo arquivo de feature `RN-NNN — <título> — Feature.md` — gerado por `rdd-task-spec` OU por qualquer
outro executor (ex: `rdd-req` migrando legado) — DEVE ter EXATAMENTE esta sequência de
elementos, com nomes de seção FIXOS. A estrutura é idêntica entre todos os arquivos; só
campos de estado legítimos divergem (`status` do front matter, linha `Status` da Issue
principal, datas, Tracking ID):

1. **Front matter YAML** — chaves fixas: `project`, `module`, `audience: [tecnica]`, `status` (`draft` = gerado para revisão; `implemented` = migrado já implementado)
2. **H1** — `# RN-NNN — <título da feature>` (coincide com o nome do arquivo sem o sufixo ` — Feature.md` — IMP-092/IMP-093)
3. **Bloco de proveniência** (linhas `>`) — 1ª linha no padrão fixo `> Gerado por <executor> em <DD/MM/AAAA>.` (executor REAL: `rdd-task-spec` na geração; o agente migrador — ex: `rdd-req` — na migração de legado); **2ª linha OBRIGATÓRIA** `> Análise: ../../analysis/RN-NNN — <título>/` — link relativo para a pasta da análise (ajuste a quantidade de `../` se o grupo do delivery tiver profundidade maior que 1 — ex.: `custom` com múltiplos placeholders); linhas `>` adicionais opcionais para anotações (`**Migrado em ...**`, `**Fonte:** ...`, `**Rastreamento:** ...`, `**✅ Implementado em ...**`)
4. **`## Issue principal`** — tabela Campo/Valor com as linhas fixas `Título`, `Tracking ID`, `Módulo`, `Milestone`, `Repositórios` + linha opcional `Status` (somente quando o arquivo refletir implementação concluída; proibida em arquivo `draft`)
5. **`## Resumo das tasks`** — tabela de 4 colunas (Regra das 4 colunas)
6. **`## Ordem de Execução`** — formato canônico em waves (seção "Ordem de Execução" abaixo)
7. **Tasks** — `### RN-NNN-M. <título>`, separadas por `---`, cada uma no "Template de cada task"
8. **`## Dependências entre Tasks`** (OPCIONAL) — somente para features com grafo de dependências não-trivial; diagrama ASCII ou lista. Se ausente, as waves do item 6 são a representação canônica de ordem/dependência

**Proibido:** seções fora desta lista, nomes alternativos para as seções de nome fixo
("Ordem de Execução do Batch", "Resumo de Dependências entre Tasks", etc.) ou reordenação.
Anotações curtas entre parênteses junto aos IDs são permitidas na `## Ordem de Execução`;
rationale longo vai nas **Notas técnicas** da task individual. O Feature.md NUNCA duplica o
conteúdo da spec pura — ele linka a análise via `> Análise:` (Regra de ouro IMP-092).

### Cabeçalho

```markdown
# RN-NNN — <título da feature>

> Gerado por <executor> em <data>. Edite para revisar.
> Análise: ../../analysis/RN-NNN — <título>/
> Após revisão, use o workflow de issues para criar as tarefas no sistema de tracking.
> (linhas `>` adicionais opcionais: **Migrado em ...**, **Fonte:** ..., **Rastreamento:** ...)

## Issue principal

| Campo | Valor |
|---|---|
| Título | `[<tracking_id>] RN-NNN — <título>` |
| Tracking ID | #<numero> |
| Módulo | <nome do módulo> |
| Milestone | <milestone> |
| Repositórios | <org/repo> (um ou mais, separados por vírgula) |
| Status | (OPCIONAL — apenas quando o arquivo refletir implementação concluída; proibido em draft) |
```

`<executor>` é o executor REAL do arquivo — a proveniência é verídica; o PADRÃO da linha
é fixo. A linha "Após revisão..." existe apenas em arquivo `status: draft`. A linha
`> Análise:` é OBRIGATÓRIA em todo arquivo de feature (IMP-092).

### Template de cada task

Cada task DEVE seguir este template completo. **Blocos condicionais (IMP-039):** os blocos
de `**Path params:**` em diante (Path params, Query params, Contrato, Tabelas de referência,
Query de referência (legado), Validações / Erros, Critério de Aceitação, Dependências,
Notas técnicas) são incluídos APENAS quando aplicáveis à task — SEMPRE nesta ordem canônica;
bloco não aplicável é omitido inteiro (sem placeholder). `**Descrição:**` e `**Dependências:**`
existem em TODA task (`**Dependências:**` usa `— (primeira task)` quando não há dependências).
`**Critério de Aceitação:**` e `**Notas técnicas:**` entram quando houver comportamento
verificável ou decisão técnica de implementação a registrar. `**Critério de Aceitação:**`,
`**Dependências:**` e `**Notas técnicas:**` fazem PARTE do canon — ao migrar tasks legadas,
nunca descarte esses blocos (são documentação de implementação valiosa).

```markdown
### RN-NNN-M. <título da task>

| Campo | Valor |
|---|---|
| **Título** | `[Database] RN-NNN-M — <descrição>` ou `[DevOps] RN-NNN-M — <descrição>` quando classificável; caso contrário `[<repo>] RN-NNN-M — <descrição>`. Cada task tem **exatamente um** repo/escopo. **Nunca** concatenar dois prefixos. |
| **Activity** | Development |
| **RNs** | RN-063, RN-064 — TODAS as RNs realizadas pela task (inclusive as não-âncoras) — SÓ RNs, nunca PEND (IMP-094) |

**Descrição:**
<Parágrafo explicando o propósito, o que entrega, e por quê>

**Path params:**
| Parâmetro | Tipo | Descrição |
|---|---|---|
| <nome> | <tipo> (path) | <descrição> |

**Query params:**
| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| <nome> | <tipo> | sim/não | <descrição> |

**Contrato:**
```
<Método> <path>
Request: <JSON ou "vazio">
Response <status>: <JSON ou "vazio">
```

**Tabelas de referência:**
| Tabela | Coluna alvo | Uso |
|---|---|---|
| <tabela> | <coluna> | <propósito> |

**Query de referência (legado):**
```sql
<SQL existente do sistema legado, se aplicável>
```

**Validações / Erros:**
- <código>: <descrição> → <status code>
- <código>: <descrição> → <status code>

**Critério de Aceitação:**
- Dado <contexto>, Quando <ação>, Então <resultado>
- Dado <contexto>, Quando <ação>, Então <resultado>

**Dependências:** <tasks necessárias antes desta>

**Notas técnicas:**
- <observação relevante>
- <observação relevante>
```
### Tabela de tarefas (resumo)

Incluir também a seção de nome fixo `## Resumo das tasks` (entre a `## Issue principal` e a `## Ordem de Execução`) com a tabela de resumo para visão geral:

```markdown
| Task | Tipo | Repo | Descrição |
|---|---|---|---|
| RN-010-1 | Backend | <nome>.API | Criar endpoint GET /bloqueios-produtor/tipos |
| RN-010-2 | Backend | <nome>.API | Criar endpoint POST /bloqueios-produtor |
```

**Regra das 4 colunas (exclusividade obrigatória):** a tabela de resumo contém
**SOMENTE E APENAS** as colunas `Task | Tipo | Repo | Descrição` — **proibido**
adicionar qualquer coluna extra (RNs/PENDs, prioridade, status, data, ou qualquer
outra). A rastreabilidade RN→task vive no campo **RNs** de cada task individual;
status e prioridade, quando existirem, pertencem à task individual ou ao cabeçalho
do arquivo — nunca ao resumo. Ao migrar/reescrever tasks de formato legado
(ex: `TASKS.md` com 7 colunas), **converta** a tabela para as 4 colunas canônicas —
nunca copie a tabela legada como está.

### Ordem de Execução (seção canônica — IMP-039)

Todo arquivo traz, após o `## Resumo das tasks`, a seção de nome fixo `## Ordem de Execução`
— proibido nome alternativo (ex: "Ordem de Execução do Batch", "Sequenciamento", "Plano de
execução"). Formato canônico em **waves**:

```markdown
## Ordem de Execução

**Wave 1 — <fase>:**
RN-NNN-1 → RN-NNN-2 → RN-NNN-3

**Wave 2 — <fase> (paralelizável):**
RN-NNN-4, RN-NNN-5

**Wave N — Qualidade:**
RN-NNN-M (testes de regressão)
```

- `→` = execução sequencial (dependência); `,` = paralelizável dentro da wave.
- Anotações curtas entre parênteses junto ao ID são permitidas (ex: `RN-NNN-14 (crítica — PEND-001)`); rationale longo vai nas **Notas técnicas** da task.
- A última wave é sempre a de qualidade/testes de regressão.
- Ao migrar lista legada numerada ("1. ... 2. ..."), **CONVERTA** para waves — não copie o formato legado.

### Ordem das tasks

Dentro da seção canônica `## Ordem de Execução` (formato em waves — seção anterior), as tasks DEVEM ser ordenadas por dependência:
1. Primeiro endpoints de consulta (GET sem dependências)
2. Depois endpoints de criação (POST)
3. Depois endpoints de listagem/detalhe (GET com dependência)
4. Depois endpoints de ação (encerramento, etc.)
5. Depois tasks transversais (perfil, padronização, compatibilidade)
6. Por último tasks de legado (redirect, compatibilidade reversa)

### Regras de título

| Elemento | Formato |
|---|---|
| **PBI** | `[Animall] REDMINE #XXXXX - Título descritivo` |
| **Task** | `[<repo>] RN-NNN-M — <descrição>` — ex: `[<nome>.API] RN-010-1 — Criar endpoint de listagem de tipos` |
| **Task de banco** | `[Database] <descrição>` — ex: `[Database] Criar changeset Liquibase para coluna IND_BLOQUEIO_GTA` |
| **Task de DevOps** | `[DevOps] <descrição>` — ex: `[DevOps] Configurar pipeline de build e deploy` |
| **ID de task** | RN-NNN-M — M sequencial a partir de 1, dentro do arquivo |
| **Repo** | Nome do repositório de código (apenas um por task) |
| **RNs** | Campo da task com TODAS as RNs realizadas (âncora + não-âncoras) — único local de rastreabilidade RN→task; o Resumo tem SOMENTE as 4 colunas canônicas (Regra das 4 colunas — nenhuma coluna extra) |

### Regras de conteúdo técnico

Cada task DEVE conter:

1. **Path params e Query params** — listagem exaustiva com tipos
2. **Contrato request/response** — JSON completo com tipos dos campos
3. **Tabelas de referência** — nome real da tabela (ex: `SDA_BLOQUEIO`, não `BloqueioProdutor`), colunas envolvidas (ex: `NRO_INT_PESSOA_FISICA`, não `produtorId`), propósito. Extrair de DATA_MODEL.md.
4. **Query de referência (se legado existe)** — SQL do sistema legado que o novo código precisa ser compatível (ex: WHERE clauses, joins)
5. **Validações e erros** — mapear cada validação para um código de erro e status HTTP
6. **Critério de aceitação** — no formato Dado/Quando/Então
7. **Dependências** — lista de tasks que precisam ter sido implementadas antes
8. **Notas técnicas** — observações de implementação, decisões arquiteturais, mecanismos a evitar/reusar

Itens 1–5 são aplicáveis conforme o tipo de task (endpoint backend: obrigatórios;
frontend/banco/DevOps: substituídos pelo artefato equivalente — modelo de dados/tela,
DDL, pipeline — dentro dos blocos canônicos). A ordem dos blocos é a canônica do
"Template de cada task" (IMP-039).

## Formato da análise funcional (`analysis/RN-NNN — Analise-Funcional.md`)

Arquivo gerado na pasta da análise (`analysis/RN-NNN — <título>/`), irmão da spec técnica
pura (IMP-092), em linguagem 100% de negócio:

```markdown
---
project: <projeto>
module: <módulo>
audience: [negocio]
status: draft
---

# RN-NNN — <título da feature> — Análise Funcional

> Gerado por rdd-task-spec em <data> a partir de REQUIREMENTS.md (RN-âncora + RNs do escopo).

## O que esta entrega faz

<Parágrafo curto, em linguagem de negócio, descrevendo o que o sistema passa a fazer e para quem.>

## Comportamento esperado

- <comportamento do ponto de vista do usuário, um por linha>
- <...>

## Regras de negócio

| Regra | O que garante |
|---|---|
| 1 | <descrição funcional da regra, sem termos técnicos> |
| 2 | <...> |

## O que fica de fora

<Opcional — limites de escopo em linguagem de negócio.>
```

Regras: fonte exclusiva REQUIREMENTS.md (todas as RNs do escopo, inclusive não-âncoras);
a coluna "Regra" usa numeração sequencial simples 1..N (1 linha por regra do escopo — por
RN ou agrupamento funcional) — numeração MERAMENTE COSMÉTICA e NÃO-rastreável: PROIBIDO
usar IDs `RN-XXX` no Analise-Funcional (a rastreabilidade formal por RN vive exclusivamente
no campo **RNs** do Feature.md e no REQUIREMENTS.md); proibido jargão técnico;
verificação rápida — se um leitor de negócio não entender uma frase, reescreva a frase
(nunca adicione jargão).

## Modo de erro

- **REDMINE = "#pendente"**: abortar, pedir para atualizar PROJECT_CHARTER.md e REQUIREMENTS.md com o número do REDMINE
- **Nenhuma RN confirmada**: abortar, não há tasks a gerar
- **RN referenciada inexistente ou prefixo inválido (IMP-033)**: se alguma task for referenciar um ID que não existe em REQUIREMENTS.md, ou usar prefixo diferente de `RN-XXX`/`PEND-XXX` (ex: `COM-01`, `REQ-01`), abortar a geração e instruir o registro das regras em REQUIREMENTS.md (numeração sequencial, via rdd-requirements) antes de gerar o Feature.md. Tasks só referenciam IDs existentes. RN-âncora inexistente em REQUIREMENTS.md → abortar (IMP-033). **IMP-094:** âncora e campo **RNs** aceitam SÓ `RN-XXX` — `PEND-XXX` não ancora feature nem entra no campo RNs (anotação de bloqueio tipo `RN-NNN-M (bloqueada por PEND-NNN)` na Ordem de Execução continua permitida).
- **Âncora PEND (IMP-094 R1)**: PEND NUNCA ancora feature. Pedido com âncora `PEND-XXX` (ou âncora que corresponde a PEND de REQUIREMENTS.md) → ABORTAR a geração com a orientação: "promova a PEND a RN primeiro (nova RN sequencial em REQUIREMENTS.md citando a origem — via rdd-requirements), depois gere com a RN como âncora". Nenhum arquivo é criado. Features `PEND-NNN — *` legadas (pré-IMP-094, ex: projeto legado) são apenas legíveis.
- **Sem DATA_MODEL.md, API_CONTRACTS.md, ARCHITECTURE.md ou UI_SPEC.md**: não abortar — gerar as duas camadas mesmo assim, mas marcar as tasks afetadas como **"sujeitas a revisão"** até o documento técnico correspondente ser fechado. Incluir aviso no bloco de proveniência do Feature.md listando quais documentos estão faltando e quais tasks são afetadas.
- **Análise ou Feature.md da RN-âncora já existe** (glob prefixo `RN-NNN*` em `analysis/` e glob recursivo `delivery/**/RN-NNN*` — IMP-037/IMP-092): perguntar sobrescrever ou merge. Se existir apenas formato legado (pasta IMP-040 com 2 arquivos na sprint, ou arquivo flat pré-IMP-040 `RN-NNN — <título>.md`), perguntar se converte para o formato vigente (em lote, papel do `rdd-restructure` modo `split-delivery`)

## Formato de commit

```
docs(tasks): gerar analysis/RN-NNN — <título>/ + delivery/<grupo>/RN-NNN — <título> — Feature.md (IMP-092/IMP-093) da feature RN-NNN do módulo <nome> para revisão
```

## Casos de Borda

- **Sprint/AreaPath não informados** — pergunte o mínimo necessário (Fase 3); nunca invente iteration path.
- **CONSTITUTION §9 ausente (IMP-092)** — pergunte o estilo de delivery, OFEREÇA persistir na §9; recusa do operador → use o estilo apenas na geração corrente. Default de escrita enquanto a §9 não existe: `monthly` (`YYYY-MM` = mês corrente).
- **Estilo `sprint`** — grupo = `YYYY-MM-DD` da data de INÍCIO da sprint (pergunte se não inferível), SEM prefixo `sprints/`; `sprint_weeks` (1..6) da §9 define o alcance da sprint.
- **Estilo `custom`** — resolva CADA placeholder do `custom_template` por pergunta (Fase 3); profundidade de pastas maior que 1 exige ajustar a quantidade de `../` da linha `> Análise:`.
- **RN toca backend e frontend** — gere duas tasks separadas (`[<backend>]` e `[<frontend>]`).
- **RN exige banco + código** — task `[Database]` separada da task `[<repo>]`.
- **RN exige DevOps + código** — task `[DevOps]` separada da task `[<repo>]`.
- **CR com abordagem validada indicando outro repositório** — o `Repositório alvo` do CR tem precedência sobre a inferência automática.
- **Análise ou Feature.md da RN-âncora já existe (glob prefixo `RN-NNN*` em `analysis/` + recursivo `delivery/**` — IMP-037/IMP-092)** — pergunte se sobrescreve ou faz merge.
- **Módulo com tasks legado (pasta IMP-040 com 2 arquivos na sprint; flat pré-IMP-040 `RN-NNN — <título>.md`; pré-IMP-035: `RN-*.md` na raiz de `delivery/` — IMP-034 — ou `TASKS*.md` em sprint/flat)** — gere as duas camadas novas (IMP-092) normalmente; não mova nem converta tasks legadas (isso é papel do `rdd-restructure`, modo `split-delivery`).
- **Batch multi-feature** — um par análise + Feature.md por feature (RN-âncora); NUNCA divida uma feature em `RN-064`, `RN-065`... — as RNs não-âncora vão apenas no campo **RNs** de cada task. Referências cruzadas a outras RNs na descrição são permitidas.
- **Executor diferente (ex: `rdd-req` migrando legado)** — os arquivos resultantes seguem os formatos canônicos (spec pura + Feature.md — IMP-039/IMP-092/IMP-093) com estrutura IDÊNTICA à da geração pela skill; só campos de estado legítimos divergem.
- **Feature PEND legada (pré-IMP-094)** — features `delivery/**/PEND-NNN — *` existentes (ex: projeto legado) são LEGÍVEIS (globs de leitura mantêm o padrão como legado); re-geração exige promover a PEND a RN primeiro (rdd-requirements) e gerar com a RN como âncora — nunca regenere com âncora PEND (IMP-094 R1).