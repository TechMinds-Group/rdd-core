---
name: rdd-restructure
description: > 
  Reestrutura projetos SDD/RDD em três modos: (1) legado — migra
  docs/projects/<nome>/ para <modulo>/<projeto>/; (2) IMP-011 — migra
  artefatos da raiz do módulo para a estrutura com subpastas (specs/,
  quality/, delivery/, support/, glossaries/, docs/); (3) merge — unifica
  pastas separadas por camada (ex: Salon-API/ + Salon-FE/) em uma pasta
  de produto única (Salon/); (4) split-delivery — divide o delivery legado
  IMP-040 (pasta com Analise-Funcional + Analise-Tecnica) no formato IMP-092
  (analysis/RN-NNN — <título>/ + delivery/<grupo>/RN-NNN — <título> —
  Feature.md — IMP-093). Move arquivos, atualiza referências cruzadas entre documentos,
  suporta migração em lote de múltiplos módulos e gera relatório de migração.
  IMP-094: features com âncora PEND (pré-IMP-094) são migradas mantendo a
  âncora legada e sinalizadas no relatório — nunca promovidas sozinhas.
  Use quando o usuário pedir "reestruturar projeto", "migrar para
  IMP-011", "mover artefatos para subpastas", "migrar de docs/projects",
  "unificar API e FE", "merge de pastas por camada", "split delivery" ou
  "migrar para IMP-092".
---
# rdd-restructure — Reestruturação de Projeto SDD/RDD

Reorganiza a estrutura de diretórios dos módulos RDD. Três modos:

1. **Modo legado** — `docs/projects/<projeto>/` → `<modulo>/<projeto>/`
2. **Modo IMP-011** — raiz flat → estrutura com subpastas
3. **Modo merge** — `< modulo>/<camada>/` + `<modulo>/<camada2>/` → `<modulo>/<produto>/`
4. **Modo split-delivery** — delivery legado IMP-040 (pasta com 2 arquivos) →
   `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` (IMP-092/IMP-093)

## Referências

- Estrutura de pastas: `CONSTITUTION.md §15` e IMP-011 (WORKFLOW_IMPROVEMENTS.md)
- Duas camadas análise + feature de delivery: `CONSTITUTION.md §9` e IMP-092 (WORKFLOW_IMPROVEMENTS.md)
- IDs RN-XXX, CR-XXX, DEC-XXX: `CONSTITUTION.md §1`

## Lê (upstream)

- `docs/projects/<projeto>/` (modo legado — se existir)
- `<modulo>/<projeto>/` (modo IMP-011 — artefatos na raiz)
- `CONSTITUTION.md` §9 (estilo de delivery + tracker — IMP-092, modo split-delivery)
- `delivery/**/RN-NNN — <título>/` (modo split-delivery — pastas legado IMP-040)

## Gera (downstream)

- `<modulo>/<projeto>/` com estrutura IMP-011 (subpastas specs/, quality/,
  delivery/, support/, glossaries/, docs/, meetings/)
- `<modulo>/<projeto>/analysis/RN-NNN — <título>/` + `delivery/<grupo-do-estilo>/RN-NNN — <título> — Feature.md` (modo split-delivery — IMP-092/IMP-093: análise com exatamente 2 arquivos + arquivo de feature canônico IMP-039 com a linha obrigatória `> Análise:`)
- `<modulo>/<projeto>/docs/MIGRATION_REPORT.md` (relatório da migração)

## Nunca edita

- Conteúdo semântico dos documentos (só paths e referências cruzadas mudam)
- Nenhum documento fora do escopo da reestruturação

## Tools

- `read` (ler documentos existentes)
- `write` (escrever documentos na nova estrutura + relatório)
- `glob` (encontrar arquivos e módulos)
- `grep` (buscar referências internas para update)
- `question` (confirmar módulos, preview e ações destrutivas)

## Modo de erro

`strict` — se a migração falhar no meio, o módulo fica inconsistente.
Sempre valide antes de remover arquivos antigos; o commit anterior é o
rollback.

## Formato de commit

```
docs: restructure <projeto> to IMP-011 layout
```

## Mapeamento canônico de arquivos (IMP-011)

**Mantêm na raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md,
DECISIONS.md, CHANGELOG.md, INDEX.md

| De (raiz do módulo) | Para |
|---|---|
| DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, ESPECIFICACOES_US.md, FIGMA_PROMPTS.md, COMPLIANCE.md | `specs/` |
| TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEABILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md | `quality/` |
| TASKS.md, TASKS-*.md, TASKS_*.md (legado, pré-IMP-034) | `delivery/` (raiz) |
| RN-*.md na raiz de delivery/ (tasks vivos, formato IMP-034, pré-IMP-035; inclui `RN-NNN — <título>.md` pós-IMP-037) | `delivery/<YYYY-MM>/` (sprint do mês corrente ou inferível, confirmado no preview) |
| Arquivo flat `delivery/<YYYY-MM>/RN-NNN — <título>.md` (pré-IMP-040) | `delivery/<YYYY-MM>/RN-NNN — <título>/RN-NNN — Analise-Tecnica.md` — mover o conteúdo para dentro da pasta (nome da pasta = antigo .md sem extensão) e AUTORAR o `RN-NNN — Analise-Funcional.md` a partir das RNs do REQUIREMENTS.md (IMP-040; adicionar `> **Migrado em ...** — IMP-040` no bloco de proveniência; confirmar no preview) |
| TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md, CONTRATO*.md | `delivery/` (raiz) |
| LEGACY_CONTEXT.md, KNOWN_ERRORS.md, MIGRATION.md, CHANGE_REQUESTS.md | `support/` |
| DEV_GLOSSARY.md, BUSINESS_GLOSSARY.md, USER_GLOSSARY.md, GLOSSARY.md | `glossaries/` |
| HOWTO_*.md | `docs/howto/` |
| <SIGLA>_Pro.md e documentos auxiliares | `docs/` |

**Já organizados (não mover):** `meetings/`, `contracts/`, `docs/**`

**Arquivo não mapeado:** pergunte ao usuário em qual subpasta colocar
(ou se mantém na raiz) antes de mover.

> **Tasks por feature na sprint — pasta com 2 arquivos (IMP-040):** as tasks novas são
> `delivery/<YYYY-MM>/RN-NNN — <título da feature>/` — PASTA da feature na sprint, **uma pasta por
> FEATURE** nomeada pela RN-âncora + título (IMP-037), contendo SEMPRE `RN-NNN — Analise-Funcional.md`
> (análise funcional em linguagem de negócio) + `RN-NNN — Analise-Tecnica.md` (issue principal + tasks
> ID `RN-NNN-M`, geradas pelo `rdd-task-spec`). Arquivos flat `RN-NNN — <título>.md` na sprint
> (pré-IMP-040) são convertidos para o formato pasta (conteúdo → `Analise-Tecnica.md`; funcional
> autorada das RNs do REQUIREMENTS.md). Arquivos `RN-*.md` na raiz de
> `delivery/` (formato IMP-034, pré-IMP-035) são movidos para a pasta da
> sprint `<YYYY-MM>/` na reestruturação. Arquivos `TASKS*.md` (pré-IMP-034)
> permanecem como legado na raiz de `delivery/`. NÃO dividir uma feature
> em uma pasta por RN — a regeneração é feita via `rdd-task-spec` sob
> demanda. Consolidações e artefatos vivos (TASKS_AZURE_CONSOLIDADO.md,
> SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md,
> HANDOVER_LOG.md) permanecem na raiz de `delivery/`.

## Workflow

### Passo 1 — Detectar modo

1. `glob` por `docs/projects/*/` → se existir, **modo legado** (migre
   para `<modulo>/<projeto>/` primeiro; depois ofereça o modo IMP-011)
2. `glob` por artefatos mapeados na raiz dos módulos (ex:
   `<modulo>/<projeto>/DATA_MODEL.md`) → se existirem, **modo IMP-011**
3. `glob` por pares de pastas com sufixo de camada (ex: `Salon-API/` e
   `Salon-FE/`, ou `Mobilis.Motorista-FE/` e `Mobilis.Passageiro-FE/`) → se
   existirem, **modo merge** (unificar em pasta de produto)
4. `glob` recursivo por `delivery/**/RN-NNN*/RN-NNN — Analise-Funcional.md`
   (pastas legado IMP-040) sem par no formato vigente (`analysis/RN-NNN*/` + `— Feature.md` +
   `delivery/**/RN-NNN — <título> — Feature.md`) → se existirem, ofereça o
   **modo split-delivery** (migrar para IMP-092)
5. Nenhuma condição → módulo já estruturado; informe e encerre (idempotente)

### Passo 2 — Selecionar módulos (lote)

1. Liste todos os módulos detectáveis (diretórios com PROJECT_CHARTER.md)
2. Use `question`: migrar todos em lote ou selecionar módulos específicos
3. Para cada módulo, mostre preview dos arquivos que serão movidos

### Passo 3 — Confirmar migração

Antes de mover qualquer arquivo, confirme com `question`:
- Lista completa arquivo → destino
- Aviso: referências cruzadas serão atualizadas automaticamente
- Estratégia de commit: um commit por módulo ou commit único de lote

### Passo 4 — Mover arquivos

Para cada arquivo mapeado:
1. Crie a subpasta de destino se não existir
2. Leia o conteúdo do arquivo
3. Atualize referências internas de caminho (Passo 5)
4. Escreva no novo caminho
5. Remova o arquivo antigo APENAS após validar que o novo foi escrito

### Passo 5 — Atualizar referências cruzadas

Em TODOS os arquivos .md do módulo (migrados e mantidos na raiz):

| Padrão antigo | Novo padrão |
|---|---|
| `](DATA_MODEL.md` (link relativo) | `](specs/DATA_MODEL.md` |
| `](API_CONTRACTS.md` | `](specs/API_CONTRACTS.md` |
| `](UI_SPEC.md` | `](specs/UI_SPEC.md` |
| `](TRACEABILITY.md` | `](quality/TRACEABILITY.md` |
| `](TASKS.md` | `](delivery/TASKS.md` |
| `](delivery/RN-NNN.md` (IMP-034, na raiz) | `](delivery/<YYYY-MM>/RN-NNN — <título>/RN-NNN — Analise-Tecnica.md` — usar o nome REAL da pasta na sprint (glob prefixo `RN-NNN*`; ex.: `](delivery/2026-09/RN-063 — Comandas e Controle de Consumo/RN-063 — Analise-Tecnica.md`) — IMP-037/IMP-040; flat pré-IMP-040 (`](delivery/<YYYY-MM>/RN-NNN — <título>.md`) também é reescrito para o caminho do `Analise-Tecnica.md` |
| `](LEGACY_CONTEXT.md` | `](support/LEGACY_CONTEXT.md` |
| ... | (idem para cada artefato do mapeamento) |

Regras:
1. Atualize links markdown relativos, menções em "Derivado de:", headers
   e URLs do Azure DevOps (`path=<modulo>/<projeto>/DATA_MODEL.md` →
   `path=<modulo>/<projeto>/specs/DATA_MODEL.md`)
2. Preserve menções conceituais onde o nome do arquivo é o conceito
   (ex: "o DATA_MODEL.md define...") — atualize links e paths, não prosa
3. Use `grep` para varrer cada nome de artefato e corrija cada link/caminho

### Passo 6 — Validação pós-migração

Para cada módulo migrado:
1. Nenhum artefato mapeado restou na raiz
2. `grep` por links quebrados: para cada link `](specs/...`, `](quality/...`
   etc., verifique que o arquivo de destino existe
3. Raiz contém apenas: PROJECT_CHARTER.md, CONSTITUTION.md,
   REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md (+ subpastas)
4. Se encontrar referência não atualizada, corrija antes de prosseguir

### Passo 7 — Relatório de migração

Escreva `<modulo>/<projeto>/docs/MIGRATION_REPORT.md`:

```markdown
# Migration Report — <modulo>/<projeto>

> **Data:** DD/MM/AAAA HH:MM
> **Modo:** IMP-011 (flat → estruturado)
> **Resultado:** ✅ Sucesso | ⚠️ Sucesso com ressalvas | ❌ Falha

## Arquivos movidos

| Arquivo | Origem | Destino |
|---|---|---|
| DATA_MODEL.md | raiz | specs/ |

## Referências atualizadas

| Arquivo | Ocorrências atualizadas |
|---|---|

## Ressalvas

- (arquivos não mapeados, decisões do usuário, etc.)
```

### Passo 8 — Commit

```
docs: restructure <projeto> to IMP-011 layout
```

(um commit por módulo; ou `docs: restructure all modules to IMP-011 layout`
se lote confirmado)

### Passo 9 — Regenerar INDEX.md

Após a migração de cada módulo, regenerar o `INDEX.md` do módulo:

1. Se `INDEX.md` não existir na raiz do módulo, crie com o template canônico (ref: IMP-012, template em `rdd-init/SKILL.md`)
2. Se já existir, atualize o **Mapa de artefatos** com os novos caminhos resultantes da migração:
   - Use o mapeamento de arquivos movidos (Passo 4) para atualizar a coluna "Caminho"
   - Exemplo: `DATA_MODEL.md` → `specs/DATA_MODEL.md`
3. Atualize a seção **Desambiguação** se aplicável (ex: se TASKS foi movido para `delivery/<YYYY-MM>/`)
4. Atualize a seção **Fora da DAG** se `docs/MIGRATION_REPORT.md` foi criado
5. **Não altere** a seção Identidade (sigla, repos, cliente) — ela é estável

> **Regra:** O INDEX.md é invariants-only. Não insira status, fase, pendências
> ou dados voláteis durante a reestruturação.

---

## Modo Merge — Unificar Pastas por Camada em Produto Único

> **⚠️ REGRA:** A unidade organizacional é o **produto**, não a camada técnica.
> Pastas como `Salon-API/` e `Salon-FE/` devem ser unificadas em `Salon/`.

### Quando usar

- Usuário pede "unificar API e FE", "merge de pastas", "juntar em produto único"
- Detector automático: duas ou mais pastas com mesmo prefixo e sufixos de camada (`-API`, `-FE`, `.Motorista-FE`, etc.)

### Workflow do modo merge

#### Passo M1 — Detectar grupos de merge

1. Liste todas as pastas com PROJECT_CHARTER.md
2. Agrupe por prefixo (antes do `-API`, `-FE`, `.Motorista-FE`, etc.)
3. Para cada grupo com 2+ pastas, proponha merge

#### Passo M2 — Confirmar merge

Para cada grupo, confirme com `question`:
- Lista de pastas que serão unificadas
- Nome da pasta de destino (o nome do produto)
- Aviso: charters serão mesclados, meetings serão combinados

#### Passo M3 — Criar pasta de destino

1. Crie `<produto>/` (se não existir)
2. Crie subpastas conforme necessário (`meetings/`, `quality/`, etc.)

#### Passo M4 — Mesclar PROJECT_CHARTER.md

1. Leia o charter de cada pasta origem
2. Crie um charter unificado que:
   - Use o nome do **produto** (não da camada)
   - Liste **todos os repos** no campo `Repositórios`
   - Descreva o escopo do **produto inteiro** (todas as camadas)
   - Marque como greenfield se todas as origens forem greenfield
3. Escreva o charter unificado em `<produto>/PROJECT_CHARTER.md`

#### Passo M5 — Combinar meetings

1. Para cada pasta origem, leia os arquivos em `meetings/`
2. Crie um arquivo combinado em `<produto>/meetings/` com todas as sessões
3. Use o mesmo padrão de nome `YYYY-MM-DD-NN.md`
4. Cada sessão deve ter um heading indicando a origem (ex: "## Sessão 1: Salon API")

#### Passo M6 — Mover quality/ e outros subdiretórios

1. Se alguma pasta origem tiver `quality/`, mova para `<produto>/quality/`
2. Atualize o campo `project` no front matter de cada arquivo

#### Passo M7 — Atualizar referências globais

1. Atualize `INDEX.md` — substitua as entradas antigas por uma entrada do produto
2. Atualize `CONSTITUTION.md` §6 — substitua as linhas antigas por uma linha do produto
3. Atualize `AGENTS.md` se houver referências às pastas antigas

#### Passo M8 — Remover pastas antigas

1. **Confirme** com `question` antes de remover
2. Remova cada pasta origem (só após validar que todos os arquivos foram migrados)

#### Passo M9 — Validação pós-merge

1. Verifique que a pasta de destino tem todos os arquivos
2. Verifique que nenhuma referência quebrada aponta para pastas antigas
3. Verifique que INDEX.md e CONSTITUTION.md estão atualizados

## Modo Split-Delivery — Dividir Delivery IMP-040 em Análise + Tasks (IMP-092)

> **⚠️ REGRA (IMP-092):** a feature vive em DUAS camadas — a análise
> `analysis/RN-NNN — <título>/` (Funcional + Técnica PURA) e o arquivo direto
> `delivery/<grupo-do-estilo>/RN-NNN — <título> — Feature.md` (canônico IMP-093/IMP-039 + linha
> `> Análise:`). Dependência UNIDIRECIONAL tasks→análise: o Feature.md linka a análise;
> a análise NUNCA cita tasks, sprints ou delivery.

### Quando usar

- Usuário pede "split delivery", "dividir tasks e análise", "migrar para IMP-092"
- Renomear módulos já migrados para IMP-092 (arquivos `— Tasks.md` pré-rename): o mesmo modo renomeia em lote `delivery/**/* — Tasks.md` → `* — Feature.md` (IMP-093) — SÓ o nome do arquivo muda (H1, seções `## Issue principal`, `## Resumo das tasks`, `## Ordem de Execução`, tasks `### RN-NNN-M` e linha `> Análise:` permanecem).
- Detector: pastas legado `delivery/<YYYY-MM>/RN-NNN — <título>/` contendo exatamente
  `RN-NNN — Analise-Funcional.md` + `RN-NNN — Analise-Tecnica.md` (IMP-040), sem par
  no formato vigente (`— Feature.md`; fallback `— Tasks.md` pré-rename)

### Workflow do modo split-delivery

#### Passo S1 — Detectar pastas IMP-040

1. `glob` recursivo por `delivery/**/RN-NNN*/RN-NNN — Analise-Funcional.md` — liste todas
   as pastas de feature com 2 arquivos (IMP-040)
2. Ignore features que JÁ existem no formato vigente (`analysis/RN-NNN*/` com 2 arquivos E
   `delivery/**/RN-NNN — <título> — Feature.md`)
3. **Âncora PEND legada (pré-IMP-094):** pastas/arquivos detectados com âncora
   `PEND-NNN` (ex: `delivery/**/PEND-NNN — <título>/`) são migrados normalmente
   MANTENDO a âncora legada — nunca renomear para RN — e sinalizados no
   relatório (Passo S5). Esta skill NUNCA promove PEND a RN sozinha (papel do
   `rdd-requirements` — IMP-094).

#### Passo S2 — Resolver o grupo do delivery (CONSTITUTION §9)

1. Leia a §9 da CONSTITUTION.md e resolva `<grupo-do-estilo>`: monthly → `YYYY-MM`;
   sprint → `YYYY-MM-DD` (data de INÍCIO da sprint, sem prefixo `sprints/`);
   release/epic → nome livre; flow → `backlog`; horizon → `now|next|later`;
   custom → placeholders do `custom_template`
2. **§9 ausente → pergunte ao operador e OFEREÇA persistir na §9**; se recusar, use o
   estilo apenas para esta migração. Default `monthly`: mantenha o `YYYY-MM` original
   da pasta legado

#### Passo S3 — Dividir cada feature

Para cada pasta legado `delivery/<grupo>/RN-NNN — <título>/`:

1. **`RN-NNN — Analise-Funcional.md`** — COPIE o conteúdo sem alteração para
   `analysis/RN-NNN — <título>/RN-NNN — Analise-Funcional.md`
2. **`RN-NNN — Analise-Tecnica.md`** — DIVIDA o conteúdo:
   - **Extraia** as seções canônicas de tasks (`## Issue principal`, `## Resumo das
     tasks`, `## Ordem de Execução`, tasks `### RN-NNN-M`, `## Dependências entre Tasks`)
     para o NOVO arquivo `delivery/<grupo-do-estilo>/RN-NNN — <título> — Feature.md`:
     preservar front matter (com `status`), H1 original e bloco de proveniência `>`,
     ADICIONANDO a linha obrigatória `> Análise: ../../analysis/RN-NNN — <título>/`
     logo após a 1ª linha `>` e a anotação `> **Migrado em <data>** — IMP-092.`
   - **O restante** do Técnica (contexto técnico, mapa RN→repos, decisões, contratos,
     riscos — tudo que NÃO é seção de tasks) vira a spec PURA
     `analysis/RN-NNN — <título>/RN-NNN — Analise-Tecnica.md`; se o Técnica legado era
     100% tasks, gere a spec pura com o esqueleto mínimo (H1, proveniência, Contexto
     técnico, Contratos e tabelas) derivado das RNs e dos specs — SEM citar tasks
3. **PROIBIDO** na spec pura resultante (IMP-092): `## Issue principal`, `## Resumo das
   tasks`, `## Ordem de Execução`, tasks `### RN-NNN-M` ou menção a sprint/estilo/delivery
4. **NUNCA renumerar IDs** — os `RN-NNN-M` seguem exatamente como estavam

#### Passo S4 — Confirmar e materializar

1. Preview: para cada feature, lista pasta legado → arquivos gerados (análise + Feature.md)
2. Confirme com `question` (por módulo ou em lote, como nos demais modos)
3. Escreva os novos arquivos; **NUNCA destrua a pasta legado sem confirmação explícita** —
   por default MANTENHA a pasta legado; só remova após o operador confirmar a exclusão
   no preview E após validar que os novos arquivos foram escritos (padrão do Passo 4)

#### Passo S5 — Validação e relatório

1. Valide por feature: análise existe com exatamente 2 arquivos; Feature.md existe com a
   linha `> Análise:`; spec pura SEM seções de tasks
2. Gere o relatório no padrão (`docs/MIGRATION_REPORT.md` — **Modo:** split-delivery (IMP-092))
3. **Sinalize no relatório** toda feature migrada com âncora `PEND-NNN`
   (pré-IMP-094): âncora legada — leitura ok, mas re-geração exige promover a
   PEND a RN (rdd-requirements) e re-gerar com a RN como âncora (IMP-094). A
   migração NUNCA promove sozinha.
4. Commit: `docs: split-delivery <projeto> to IMP-092 layout`

## Regras importantes

1. **Nunca mova arquivos que não são do RDD** — só artefatos do mapeamento
2. **Sempre leia e reescreva o conteúdo** — não é um `git mv` simples
   (referências precisam ser atualizadas)
3. **Confirme antes de remover** arquivos antigos
4. **Idempotente** — módulo já estruturado → informe e não faça nada
5. **Modo legado primeiro** — projeto em `docs/projects/` migra para
   `<modulo>/<projeto>/` antes de receber o layout IMP-011
6. **Modo merge para camadas** — pastas separadas por camada (`-API`, `-FE`)
   devem ser unificadas em produto único antes de receber o layout IMP-011
7. **Rollback via Git** — o commit anterior é o ponto de restauração;
   nunca force push
8. **Modo split-delivery (IMP-092)** — dependência unidirecional
   tasks→análise: o Feature.md linka a análise via `> Análise:`; a análise
   NUNCA cita tasks, sprints ou delivery. NUNCA renumerar IDs `RN-NNN-M`;
   nunca destruir a pasta legado sem confirmação explícita

## Casos de Borda

- **Módulo já estruturado (idempotente)** — informe e não mova nada.
- **Arquivo não mapeado** — pergunte ao usuário a subpasta de destino (ou raiz) antes de mover.
- **Colisão de nome (IMP-035/IMP-037/IMP-040)** — pasta `RN-NNN*` (glob prefixo) já existe na sprint de destino (ou a pasta criada a partir do flat movido da raiz colide com homônimo já existente na sprint): confirmar sobrescrita/merge no preview.
- **Falha no meio da migração** — restaure pelo commit anterior (rollback via Git) e reporte o estado; nunca deixe o módulo inconsistente.
- **Projeto em `docs/projects/`** — migre primeiro para `<modulo>/<projeto>/` (modo legado); só depois ofereça o layout IMP-011.
- **Referência não atualizada na validação** — corrija antes de prosseguir; não conclua o módulo com link quebrado.
- **Lote com falha em um módulo** — o commit por módulo garante que os já migrados permanecem íntegros.
- **Pastas por camada (API/FE)** — use o modo merge para unificar em produto único antes de qualquer outra operação.
- **Merge com quality/ em múltiplas pastas** — combine os arquivos de validação, mantendo o mais recente como base e adicionando achados das origens como observações.
- **Feature já no formato IMP-092** (análise em `analysis/` + `— Feature.md` existentes; fallback `— Tasks.md` pré-rename) — pule no modo split-delivery (idempotente).
- **Técnica legado 100% tasks (sem seções de spec)** — a spec pura resultante recebe o esqueleto mínimo (H1, proveniência, Contexto técnico, Contratos e tabelas — derivados das RNs e dos specs); nunca deixe a análise vazia e nunca deixe seções de tasks nela.
- **Colisão de Feature.md no destino** (glob `delivery/**/RN-NNN — <título> — Feature.md`; fallback: `— Tasks.md` pré-rename) — confirmar sobrescrita/merge no preview.
- **CONSTITUTION §9 ausente (split-delivery)** — pergunte o estilo e OFEREÇA persistir na §9; recusa → use só para a migração; default `monthly` mantém o `YYYY-MM` original da pasta legado.
- **Feature com âncora PEND legada (pré-IMP-094)** — migra mantendo a âncora `PEND-NNN` (nunca renumerar para RN) e sinaliza no relatório que a âncora é pré-IMP-094 e deve ser promovida a RN para novas gerações; nunca promove sozinha (IMP-094).
