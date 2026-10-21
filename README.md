# TM.CORE.RDD — Workflow RDD (Open Core)

**RDD (Requisitos, Documentação e Desenvolvimento)** é a plataforma de
orquestração de requisitos, documentação técnica e desenvolvimento assistido por
IA do TechMinds-Group, construída sobre skills e subagents do OpenCode.

Centraliza o ciclo de vida de especificação — da captura de uma demanda de
negócio até a criação dos artefatos técnicos rastreáveis que alimentam
issues e pull requests.

## Propósito

Tornar-se a ferramenta principal da organização para levantamento de requisitos,
documentação e desenvolvimento — reduzindo o drift entre o que o cliente pede, o
que fica documentado e o que é implementado. Cada skill e subagent do RDD é um
bloco independente que pode ser executado isoladamente ou composto em fluxos
maiores, mas todos compartilham as mesmas convenções de ID, rastreabilidade e
governança.

## Como funciona

O RDD aplica uma metodologia de especificação em fases para levar um requisito de
negócio até um artefato técnico rastreável:

1. **Intake** — captura o charter do projeto, contexto legado e faz perguntas
   estruturadas para reduzir ambiguidade antes de gerar requisitos formais.
2. **Requisitos** — consolida regras de negócio (RNs), casos de uso, campos e
   decisões num `REQUIREMENTS.md` versionado, com IDs estáveis e pendências
   rastreáveis (PEND-XXX).
3. **Tradução Técnica** — a partir das RNs, gera até 7 artefatos paralelos:
   modelo de dados, contratos de API, especificação de UI, arquitetura,
   glossários, histórias de usuário e critérios de aceitação.
4. **Qualidade e Entrega** — test strategy, matriz de rastreabilidade, validação
    de integridade da DAG, especificação de tasks.

Cada fase é opcional — módulos podem pular artefatos que não se aplicam ao seu
contexto.

## Componentes

- **Primary agents (Quadri RDD):**
  - `rdd-req` — Requirements: descoberta de negócio, intake greenfield, reuniões e gestão de requisitos.
  - `rdd-doc` — Documentation: documentação técnica de sistemas existentes, engenharia reversa multi-repo e specs.
  - `rdd-dev` — Development: implementação de código nos repositórios a partir de tasks aprovadas.
  - `rdd-devops` — DevOps: infraestrutura de deploy (VPS, Docker, registry, SSH, Cloudflare tunnels) e troubleshooting guiado.
- **Subagents:** orquestradores de fase (`rdd-intake-orchestrator`,
  `rdd-requirements-orchestrator`, `rdd-translation-orchestrator`,
  `rdd-quality-orchestrator`, `rdd-support-orchestrator`,
  `rdd-governance-orchestrator`), engenharia reversa (`rdd-reverse-orchestrator`),
  especialistas de código (`rdd-dev-backend`, `rdd-dev-frontend`) e utilitários
  (Figma, GitHub, workflow builder/improver, next, progress, cr-propagation-guard).
- **Skills:** blocos de conhecimento sob demanda (prefixo `rdd-`), executáveis
  isoladamente ou compostos em fluxos maiores.

## Convenções

- Prefixo `rdd-` em toda skill e subagent da plataforma.
- IDs estáveis: RN-XXX (regras de negócio), PEND-XXX (pendências de
  esclarecimento). IDs são imutáveis — uma RN nunca renumera.
- Artefatos versionados em Git — a fonte da verdade é o arquivo mais recente no
  repositório.
- DAG de documentos: PROJECT_CHARTER → REQUIREMENTS → artefatos de tradução →
  qualidade.
- Regras de projeto específicas vivem no produto (`<repo>/.opencode/rules/`),
  não no core.
- Idioma PT-BR.

## Como começar

1. Selecione o agent primário desejado no OpenCode (use Tab para alternar):
   - `rdd-req` para novos requisitos e discovery de negócio;
   - `rdd-doc` para documentar sistemas existentes ou engenharia reversa;
   - `rdd-dev` para implementar código a partir das tasks;
   - `rdd-devops` para infraestrutura de deploy e troubleshooting de VPS.
2. Para produtos novos, execute `rdd-project-intake` no `rdd-req`.
3. Para produtos já existentes com código, acione o `rdd-doc` informando os repositórios.
4. Peça ao agente primário a próxima ação no início de cada sessão (ele consulta o
   auto-routing `@rdd-next`).

## Versionamento

Este repositório versiona: `agents/rdd-*.md` (primaries e subagents),
`skills/rdd-*/` (SKILL.md e assets), `registry.yaml`, `ARCHITECTURE.md`,
`WORKFLOW_IMPROVEMENTS.md`, docs vivos (`DECISIONS.md`, `GLOSSARY.md`,
`CHECKLISTS.md`, `PERMISSIONS.md`, `CONTRIBUTING.md`, `ROADMAP.md`,
`TROUBLESHOOTING.md`), `evals/` (fixtures, runner, trends e relatórios),
`rules/` (templates e packs versionáveis), `quality/` (relatórios de
auditoria), `.github/workflows/`, `AGENTS.template.md`, `MANIFEST.sha256` e
este README. Locais, não versionados: `opencode.jsonc`, `AGENTS.md`,
`settings.json`, `hooks/`, `plugins/`, `command/*`, `get-shit-done/*`,
`cli.json`, `service.json` e `rules/client-profile.md` (perfil do cliente —
IMP-103).

O `registry.yaml` é o **manifesto canônico** do workflow — contém todos os
componentes, suas relações e domínios. As views estruturais do
`ARCHITECTURE.md` são geradas a partir dele pela skill `rdd-registry-render`.
**Nunca edite as seções estruturais do ARCHITECTURE.md manualmente** —
sempre altere o registry e re-renderize.

O campo `version` no registry.yaml indica a **schema do manifesto** —
incrementa apenas quando a estrutura do YAML mudar (novos campos
obrigatórios, refatoração de seções). Conteúdo (adição/remoção de skills,
agents) é versionado pelo git — não incrementa `version`.

- **Publicar melhorias:** skill `rdd-self-publish` (commit + push em `main`).
- **Atualizar config local:** skill `rdd-self-update` (git pull --ff-only).

## Open Core

O RDD é distribuído como **open core**: a base neutra é licenciada sob
**Apache-2.0 + DCO** (`LICENSE`); packs proprietários por organização carregam o
conhecimento específico de cada empresa; a monetização ocorre em packs e
suporte — nunca na base.

**Modelo de publicação (snapshot):** o desenvolvimento acontece no repositório
**privado** `TM.CORE.RDD` (este repo); as releases públicas são **snapshots
limpos** do subset essencial publicados no repo público
**`TechMinds-Group/rdd-core`** — via script `publish/publish-core.sh`
(processo completo em `PUBLISH.md`). O histórico interno (IMPs, ADRs,
quality, reports, trends) nunca entra no público. Contribuições externas são
feitas via **PR no `rdd-core`**, com **DCO** (sign-off, sem CLA) e aprovação do
**neutrality gate** (`evals/neutrality/scan.sh`) — detalhes em
`CONTRIBUTING.md`.

**Arquitetura em 3 camadas:**

```
CORE (público — este repo, Apache-2.0 + DCO)
 │   agents/, skills/, rules/ (templates), registry.yaml
 │
PACK (privado da organização — ex.: TechMinds)
 │   provides/ → conteúdo instalável no core (via cópia)
 │   accumulation/  → patterns/metrics/retros — nunca instalado
 │
PROFILE (local, gitignored — rules/client-profile.md)
     declara packs: [<id>@<faixa>]
```

**Runtime:**

```
clone do core
 └── packs/<id>/      (gitignored — clones dos packs)
      └── installer copia provides/ para o core
 └── .rdd/sources.yaml (lockfile: pack → versão instalada)
```

**Precedência de conteúdo:** PROFILE > PACK > CORE.

**Regra de ouro (neutrality gate):** só entra no core conteúdo generalizado e
anonimizado, via PR — conhecimento de cliente específico permanece no pack.