# RDD — Workflow RDD (Open Core)

**RDD (Requisitos, Documentação e Desenvolvimento)** é um workflow open core de
engenharia de contexto para o [OpenCode](https://opencode.ai): orquestração de
requisitos, documentação técnica e desenvolvimento assistido por IA — da demanda
de negócio até artefatos técnicos rastreáveis que alimentam issues e pull
requests.

Mantido pela TechMinds-Group. Licença **Apache-2.0** + contribuição via **DCO**.

## Como funciona

O RDD aplica uma metodologia de especificação em fases para levar um requisito
de negócio até um artefato técnico rastreável:

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

- **Primary agents (Quadri RDD)** — a persona ativa da sua sessão no OpenCode
  (alternância com Tab):
  - `rdd-req` — Requirements: descoberta de negócio, intake greenfield, reuniões e gestão de requisitos.
  - `rdd-doc` — Documentation: documentação técnica de sistemas existentes, engenharia reversa multi-repo e specs.
  - `rdd-dev` — Development: implementação de código nos repositórios a partir de tasks aprovadas.
  - `rdd-devops` — DevOps: infraestrutura de deploy (VPS, Docker, registry, SSH, Cloudflare tunnels) e troubleshooting guiado.
- **Subagents (25):** orquestradores de fase (`rdd-intake-orchestrator`,
  `rdd-requirements-orchestrator`, `rdd-translation-orchestrator`,
  `rdd-quality-orchestrator`, `rdd-support-orchestrator`,
  `rdd-governance-orchestrator`), engenharia reversa (`rdd-reverse-orchestrator`),
  especialistas de código (`rdd-dev-backend`, `rdd-dev-frontend`), QA
  independente (`rdd-dev-qa`), revisão pré-PR (`rdd-dev-reviewer`) e
  utilitários (GitHub, Azure, Figma, workflow builder/improver, next, progress).
- **Skills (78):** blocos de conhecimento sob demanda (prefixo `rdd-`),
  executáveis isoladamente ou compostos em fluxos maiores.

## Getting Started

Pré-requisitos: [OpenCode](https://opencode.ai) instalado; `git`; `gh` CLI
(opcional — só para criar o repo remoto do seu pack).

```bash
# 1. Clone o core no diretório global de config do OpenCode
git clone https://github.com/TechMinds-Group/rdd-core.git ~/.config/opencode
```

2. Abra o OpenCode no diretório dos seus projetos e selecione o primary com
   **Tab** (comece pelo `rdd-req`).
3. Rode a skill **`rdd-setup`** — wizard de primeira configuração: diretório de
   projetos, perfil da sua organização (`rules/client-profile.md`, local e
   gitignored) e validação do ambiente. Campos de tracker/infraestrutura podem
   ficar genéricos se você ainda não os usar.
4. Crie o pack da sua organização com **`rdd-pack-scaffold`** — esqueleto
   completo (`pack.yaml` + regra da org + acúmulo), repo privado no seu GitHub e
   instalação no runtime. O conteúdo específico da **sua** empresa vive aqui —
   nunca no core.
5. Comece a trabalhar:
   - Produto novo → `rdd-project-intake` no `rdd-req`;
   - Sistema existente → `rdd-doc` com os repositórios;
   - Código a partir de tasks → `rdd-dev`.
6. Atualizações do core: `git pull` no seu clone (arquivos gerados são
   gitignored — seu runtime nunca fica sujo).

> **Detalhe:** o `rdd-setup` pergunta defaults de tracker (Azure) e
> infraestrutura — se você não usa, preencha com valores genéricos ou pule; o
> workflow funciona sem eles.

## Arquitetura open core

Três camadas com precedência de conteúdo **PROFILE > PACK > CORE**:

```
CORE (público — este repo, Apache-2.0 + DCO)
 │   agents/, skills/, rules/ (templates), registry.yaml
 │
PACK (privado da SUA organização)
 │   pack.yaml → provides/  → conteúdo instalável no core (via cópia)
 │              accumulation/ → patterns/metrics/reverses — nunca instalado
 │
PROFILE (local, gitignored — rules/client-profile.md)
     declara packs: [<id>@<faixa>]
```

Runtime (`~/.config/opencode/`):

```
clone do core
 ├── packs/<id>/          clones dos packs (gitignored)
 ├── rules/packs/<id>.md  regra da organização (instalada do pack)
 ├── .rdd/sources.yaml    lockfile: pack → versão + commit instalado
 └── core + arquivos instalados (cópia de provides)
```

**Regra de ouro (neutrality gate):** só entra no core conteúdo generalizado e
anonimizado, via PR — conhecimento de cliente específico permanece no seu pack.
O gate (`evals/neutrality/scan.sh`) roda no CI, no pre-push e antes de cada
release.

## Registry e artefatos

O `registry.yaml` é o **manifesto canônico** do workflow — todos os
componentes, relações e domínios. As views estruturais do `ARCHITECTURE.md` são
geradas a partir dele pela skill `rdd-registry-render` — nunca edite essas
seções manualmente. O campo `version` do registry é o schema do manifesto;
conteúdo é versionado pelo git.

Documentação neste repo: `PACK_SCHEMA.md` (contrato de packs),
`BREAKING-CHANGES.md`, `CONTRIBUTING.md` (DCO + checklist de anonimização),
`PUBLISH.md` (processo de release).

## Releases

Modelo **snapshot**: os mantenedores desenvolvem em um repositório privado e
publicam **cópias limpas do subset essencial** neste repo (`publish-core.sh` +
processo em `PUBLISH.md`) — o público não contém histórico interno. Histórico
de melhorias e decisões de design fica no repo de desenvolvimento.

- **Adotador:** atualize com `git pull` no seu clone.
- **Contribuidor:** PR neste repo, com **DCO** (`git commit -s`) e aprovação do
  neutrality gate — guia completo em `CONTRIBUTING.md`.

## Convenções

- Prefixo `rdd-` em toda skill e subagent da plataforma.
- IDs estáveis: RN-XXX (regras de negócio), PEND-XXX (pendências de
  esclarecimento). IDs são imutáveis — uma RN nunca renumera.
- Nomes estruturais (paths, campos de contrato) em inglês; conteúdo e
  documentação em PT-BR.
- Convenção de ciclo de repo: `rdd-<repo>-<action>` — `rdd-core-update`/
  `rdd-core-publish` (core) e `rdd-pack-update`/`rdd-pack-publish` (packs).
- Regras de projeto específicas vivem no produto (`<repo>/.opencode/rules/`),
  não no core.
- DAG de documentos: PROJECT_CHARTER → REQUIREMENTS → artefatos de tradução →
  qualidade.

## License

[Apache-2.0](LICENSE) — contribuições sob [DCO 1.1](https://developercertificate.org/).
