---
name: rdd-init
description: >-
  Executado automaticamente após rdd-project-intake. Verifica se CONSTITUTION.md
  existe na raiz do repositório (compartilhado entre todos os projetos). Se não
  existir, cria com template mínimo (incluindo a §9 de Organização de Delivery e
  Análise — IMP-092/IMP-093 com o arquivo de feature `RN-NNN — <título> — Feature.md`; defaults delivery_style: monthly e tracker: github). Se
  existir sem a §9, sugere adicioná-la (só com confirmação do operador). Adiciona
  o novo projeto na seção de projetos do CONSTITUTION.md e do INDEX.md.
  Use quando o usuário pedir "init do módulo", "criar CONSTITUTION.md",
  "estrutura de diretórios" ou "INDEX.md".
---
# rdd-init — Inicialização Pós-Intake

Executado **automaticamente** na primeira skill após `rdd-project-intake`.

## O que faz

1. Verifica se `CONSTITUTION.md` existe na **raiz do repositório** (compartilhado)
2. Se não existir, cria com template mínimo (DAG, princípios, ciclo de vida, tabela de projetos)
3. Adiciona o novo projeto na seção `## 6. Projetos` do CONSTITUTION.md
4. Verifica se `INDEX.md` existe na **raiz do repositório** (compartilhado)
5. Se não existir, cria com template mínimo (identidade, mapa de projetos)
6. Adiciona o novo projeto na seção `## Mapa de Projetos` do INDEX.md
7. Verifica se a estrutura do diretório do projeto segue IMP-011
8. Verifica se o CONSTITUTION.md contém a §9 "Organização de Delivery e Análise (IMP-092)"; se ausente, SUGERE adicioná-la com os defaults (`delivery_style: monthly`, `tracker: github`) — cria somente com confirmação explícita do operador

## Lê (upstream)

- `PROJECT_CHARTER.md` (para nome do projeto, sigla, repos, cliente, legado: true/false)

## Gera (downstream)

- `CONSTITUTION.md` na raiz do repositório (só se não existir — com §9 IMP-092 no template; ou atualiza a seção de projetos / sugere a §9)
- `INDEX.md` na raiz do repositório (só se não existir, ou atualiza seção de projetos)

## Nunca edita

- `PROJECT_CHARTER.md` (é upstream — só leitura)
- Artefatos da DAG (REQUIREMENTS.md, DATA_MODEL.md, etc.) — fora do escopo desta skill
- CONSTITUTION.md ou INDEX.md dentro de pastas de projeto (não existem mais)

## Tools

- `glob` (detectar estrutura do módulo e artefatos existentes)
- `read` (ler PROJECT_CHARTER.md, CONSTITUTION.md e INDEX.md existentes)
- `write` (criar CONSTITUTION.md e INDEX.md na raiz quando ausentes)
- `edit` (atualizar seção de projetos no CONSTITUTION.md e INDEX.md existentes)

## Modo de erro

`skip` — se CONSTITUTION.md já existir e o projeto já estiver na tabela, pode pular.

## Template de CONSTITUTION.md (raiz do repositório)

> **Nota:** Este template é para o CONSTITUTION.md **compartilhado** na raiz do repositório (`<REPO_DOCS>/CONSTITUTION.md`). Não criar CONSTITUTION.md dentro de pastas de projeto.

```markdown
---
project: <REPO_DOCS>
audience: [tecnica, negocio]
status: active
---

# Constituição do Repositório — <REPO_DOCS>

> **Propósito:** Documentar decisões, requisitos e arquitetura de todos os projetos `<CLIENTE>` (do perfil — `rules/client-profile.md`).
> **Última atualização:** <DATA_ATUAL>

---

## 1. Produto

### Missão

Evoluir os sistemas `<CLIENTE>` com documentação rastreável.

### Visão

Todo requisito de negócio tem um documento de origem, uma decisão registrada
e um artefato técnico correspondente.

---

> **Regra de idioma:** CONSTITUTION.md em português brasileiro (PT-BR). Títulos, descrições, princípios e seções em PT-BR. Apenas notação DAG, acrônimos (ADR, RN, DAG, RDD) e termos técnicos universais permanecem no original.

## 2. Objetivo do Produto

Documentar, modelar e especificar os módulos seguindo:

```
PROJECT_CHARTER → REQUIREMENTS → DATA_MODEL → API_CONTRACTS → UI_SPEC → TEST_STRATEGY
```

---

## 3. Princípios

| # | Princípio | Descrição |
|---|-----------|-----------|
| 1 | Rastreabilidade primeiro | Toda RN deve ter um artefato downstream |
| 2 | Decisão registrada | Toda decisão tem um ADR em DECISIONS.md |
| 3 | Legado explícito | Sistemas legados documentados em LEGACY_CONTEXT.md |
| 4 | Escopo delimitado | Cada módulo documenta seu escopo e o que está fora |
| 5 | Pendência visível | Tudo não definido fica como PEND no REQUIREMENTS.md |

---

## 4. Grafo de Documentos (DAG)

```
PROJECT_CHARTER.md
    │
    ▼
REQUIREMENTS.md
    │
    ├──▶ DATA_MODEL.md
    ├──▶ API_CONTRACTS.md
    ├──▶ UI_SPEC.md
    └──▶ SCOPE_AGREEMENT.md
    │
    ├──▶ TEST_STRATEGY.md
    └──▶ HOWTO.md
```

### Documentos transversais (raiz do projeto)

| Documento | Finalidade |
|-----------|------------|
| PROJECT_CHARTER.md | Termo de abertura do projeto |
| REQUIREMENTS.md | Regras de negócio (raiz da DAG) |
| DECISIONS.md | Decisões arquiteturais (ADR) |
| CHANGELOG.md | Histórico de mudanças |

### Estrutura de diretórios do módulo (IMP-011)

```
<projeto>/
├── PROJECT_CHARTER.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
├── analysis/     # RN-NNN — <título>/ (Analise-Funcional.md + Analise-Tecnica.md pura — IMP-092)
├── specs/        # DATA_MODEL, API_CONTRACTS, ERROR_CATALOG, UI_SPEC, ARCHITECTURE, SECURITY, ACCEPTANCE_CRITERIA, USER_STORIES
├── quality/      # TEST_STRATEGY, DEFINITION_OF_DONE, TRACEABILITY, VALIDATION_REPORT, PROPAGATION_STATUS
├── delivery/     # <grupo-do-estilo>/RN-NNN — <título> — Feature.md (arquivo direto por feature — IMP-093), TASKS_AZURE_CONSOLIDADO, SCOPE_AGREEMENT, CLIENT_REQUIREMENTS, CLIENT_REPORT_*
├── support/      # LEGACY_CONTEXT, KNOWN_ERRORS, MIGRATION, CHANGE_REQUESTS
├── glossaries/   # DEV_GLOSSARY, BUSINESS_GLOSSARY, USER_GLOSSARY
├── docs/         # howto/ e documentos auxiliares
└── meetings/     # checkpoints de clarify
```

> **Duas camadas por feature (IMP-092):** a análise vive em `analysis/RN-NNN — <título da feature>/` — pasta
> com SEMPRE exatamente 2 arquivos: `RN-NNN — Analise-Funcional.md` (análise funcional em linguagem de negócio)
> e `RN-NNN — Analise-Tecnica.md` (spec técnica PURA — contexto, mapa RN→repos, decisões, contratos, riscos —
> SEM tasks). O delivery vive no ARQUIVO DIRETO `delivery/<grupo-do-estilo>/RN-NNN — <título> — Feature.md` (IMP-093 — SEM
> subpasta por feature), no canônico IMP-039 (issue principal + tasks ID `RN-NNN-M`, M sequencial a partir de 1),
> com a linha obrigatória `> Análise: ../../analysis/RN-NNN — <título>/`. O `<grupo-do-estilo>` segue a §9
> (default `monthly` → `YYYY-MM`; `sprint` → `YYYY-MM-DD`; `release` → nome livre; `flow` → `backlog`;
> `horizon` → `now|next|later`; `epic` → nome do épico; `custom` → placeholders do template). Leitores resolvem
> por glob recursivo `delivery/**/RN-NNN*` (preferindo arquivos `— Feature.md`; fallback: `— Tasks.md` pré-rename). Ambas as camadas são geradas pelo
> `rdd-task-spec`. Dependência unidirecional tasks→análise: a análise NUNCA cita tasks, sprints ou delivery.

---

## 5. Ciclo de Vida dos Documentos

| Status | Significado |
|--------|-------------|
| draft | Em elaboração, pode mudar |
| review | Aguardando revisão |
| approved | Aguardando revisão do stakeholder |
| active | Vigente, fonte da verdade |
| superseded | Substituído |
| archived | Não é mais relevante |

---

## 6. Projetos

| Projeto | Repositórios | Status | Início | Última atualização |
|---------|-------------|--------|--------|-------------------|
| `<NOME_DO_PROJETO>` | `repo1`, `repo2` | draft | <DATA_ATUAL> | <DATA_ATUAL> |

---

## 7. Papéis e Responsabilidades

| Papel | Responsável | Responsabilidades |
|-------|-------------|-------------------|
| Lead Técnico | (a definir) | Decisões arquiteturais |
| Patrocinador (sponsor) | `<CLIENTE>` (perfil) | Aprovação de escopo |
| RDD Docente | opencode (IA) | Geração de documentos RDD |

---

## 8. Glossário do Projeto

| Termo | Definição |
|-------|-----------|
| RDD | Requisitos, Documentação e Desenvolvimento |
| RN | Regra de Negócio |
| PEND | Pendência a definir |
| ADR | Architecture Decision Record |
| DAG | Directed Acyclic Graph |

---

## 9. Organização de Delivery e Análise (IMP-092)

> Define onde vivem a análise e as tasks das features e como o delivery é agrupado.
> Editável por projeto; consultada pelo `rdd-task-spec` e pelo `rdd-restructure`.

| Campo | Valor | Descrição |
|-------|-------|-----------|
| `delivery_style` | `monthly` | Estilo de agrupamento sob `delivery/`: `monthly` (`YYYY-MM`), `sprint` (`YYYY-MM-DD` — data de início da sprint), `release` (nome livre, ex.: `v2.1`), `flow` (`backlog`), `horizon` (`now`/`next`/`later`), `epic` (nome do épico), `custom` (usa `custom_template`) |
| `sprint_weeks` | — | Duração da sprint em semanas (1..6) — usado somente quando `delivery_style: sprint` |
| `custom_template` | — | Template de caminho quando `delivery_style: custom` (ex.: `delivery/<cliente>/<trimestre>/`); placeholders resolvidos por pergunta na geração |
| `tracker` | `github` | Sistema de tracking das issues: `github` ou `azure` |

> **Estrutura (IMP-092):** cada feature gera a análise `analysis/RN-NNN — <título>/`
> (`RN-NNN — Analise-Funcional.md` + `RN-NNN — Analise-Tecnica.md`, spec técnica pura) e o
> arquivo direto `delivery/<grupo>/RN-NNN — <título> — Feature.md` (canônico IMP-093/IMP-039 + linha
> `> Análise:`). Dependência unidirecional tasks→análise: a análise NUNCA cita tasks,
> sprints ou delivery.
```

## Workflow

1. Verifique se `CONSTITUTION.md` existe na **raiz do repositório** (não na pasta do projeto)
2. Se não existir: crie com o template acima (seção "Template de CONSTITUTION.md")
3. Se existir: leia e verifique se o novo projeto já está na tabela `## 6. Projetos`
4. Se o projeto não estiver na tabela: adicione uma linha com nome, **repositórios** (liste todos os repos do produto), status `draft`, data de início e última atualização
5. Verifique se `INDEX.md` existe na **raiz do repositório**
6. Se não existir: crie com o template abaixo (seção "Template de INDEX.md")
7. Se existir: leia e verifique se o novo projeto está na seção `## Mapa de Projetos`
8. Se o projeto não estiver no mapa: adicione uma linha com nome, caminho, **repos** e status
9. Verifique se a estrutura do diretório do projeto segue IMP-011 (subpastas specs/, quality/, etc.)
10. Se os artefatos estiverem na raiz do projeto (pré-IMP-011), recomende `rdd-restructure`
11. Verifique se o CONSTITUTION.md contém a §9 "Organização de Delivery e Análise (IMP-092)"; se ausente, SUGIRA adicioná-la com os defaults (`delivery_style: monthly`, `tracker: github`) — crie somente sob confirmação explícita do operador

## Template de INDEX.md (raiz do repositório)

> **Nota:** Este template é para o INDEX.md **compartilhado** na raiz do repositório (`<REPO_DOCS>/INDEX.md`). Não criar INDEX.md dentro de pastas de projeto.

```markdown
# INDEX — <REPO_DOCS>

> **Manifesto de navegação do repositório** (padrão IMP-012).
> Contém apenas invariáveis: identidade, mapa de caminhos e desambiguação.
> Estado volátil (fase, pendências, status) → `@rdd-next` / HANDOVER_LOG.
> Atualizar somente quando a estrutura do repositório mudar.

## Identidade

| Campo | Valor |
|---|---|
| Sigla | <REPO_DOCS> |
| Constituição | CONSTITUTION.md |
| Remote | `<ORG>/<REPO_DOCS>` (do perfil/cliente — ex.: `minha-org/rdd-docs`) |
| Cliente | `<CLIENTE>` (perfil) |

## Mapa de Projetos

| Projeto | Caminho | Repos | Status |
|---------|---------|-------|--------|
| `<NOME_DO_PROJETO>` | `<NOME_DO_PROJETO>/` | `repo1`, `repo2` | draft |

## Estrutura Padrão por Projeto

```
<projeto>/
├── PROJECT_CHARTER.md      # Termo de abertura
├── REQUIREMENTS.md         # Regras de negócio (raiz da DAG)
├── DECISIONS.md            # Decisões arquiteturais (ADR)
├── CHANGELOG.md            # Histórico de mudanças
├── analysis/               # Análise por feature — analysis/RN-NNN — <título>/ (Analise-Funcional + Analise-Tecnica pura — IMP-092)
├── specs/                  # Artefatos técnicos
├── quality/                # Qualidade e rastreabilidade
├── delivery/               # Entrega — delivery/<grupo-do-estilo>/RN-NNN — <título> — Feature.md (arquivo direto por feature — IMP-093; grupo conforme CONSTITUTION §9)
├── support/                # Suporte e migração
├── glossaries/             # Glossários
├── docs/                   # Documentação auxiliar
└── meetings/               # Checkpoints de sessões
```

## Desambiguação

- Nenhuma pendência de nomenclatura registrada no momento.

## Fora da DAG

- `CONSTITUTION.md` — governança compartilhada de todos os projetos
- `INDEX.md` — este manifesto
```

## Formato de commit

```
docs: init module structure for <projeto>
```

## Casos de Borda

- **CONSTITUTION.md já existe na raiz** — não recria; apenas adiciona o projeto na tabela `## 6. Projetos` se não estiver presente.
- **INDEX.md já existe na raiz** — não recria; apenas adiciona o projeto na seção `## Mapa de Projetos` se não estiver presente.
- **Projeto já está no CONSTITUTION.md e INDEX.md** — nada a fazer; skill completa sem alterações.
- **Módulo em `docs/projects/` (legado)** — recomenda `rdd-restructure` (modo legado) antes de prosseguir.
- **Artefatos na raiz do módulo (pré-IMP-011)** — recomenda `rdd-restructure` (modo IMP-011).
- **CONSTITUTION.md sem §9 (IMP-092)** — sugira adicionar a seção "Organização de Delivery e Análise" com os defaults (`delivery_style: monthly`, `tracker: github`); crie somente sob confirmação explícita do operador.
- **PROJECT_CHARTER.md ausente** — encerre com erro: o charter é pré-requisito do init.
