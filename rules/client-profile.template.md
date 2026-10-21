# Perfil do Cliente (IMP-103/IMP-105)

<!-- Fonte de verdade dos defaults do cliente desta máquina. -->
<!-- Gravado pelo `rdd-setup` (Passo 2b). NUNCA versionado (gitignore). -->
<!-- Este template é o esqueleto versionado; o preenchido vive em rules/client-profile.md (gitignored). -->
<!-- Consumido por: rdd-azure-setup, rdd-azure-workitem-creator, @rdd-azure-orchestrator, -->
<!-- rdd-gh-setup, rdd-cicd-workflow, rdd-vps-setup, rdd-observability, rdd-stack-boilerplate (IMP-105). -->

## Tracker

| Campo | Valor |
|-------|-------|
| Organização Azure DevOps | `<org>` |
| Projeto Azure padrão | `<projeto>` |
| Usuário | `<nome> <email>` |
| Repos padrão (tracker_repos) | `<PREFIXO.*>` |
| Tracker default | `azure-devops` |

## Identidade e infraestrutura (IMP-105)

| Campo | Valor |
|-------|-------|
| Organização GitHub (org_github) | `<org-github>` |
| Registry de imagens (ghcr_registry) | `<ghcr.io/<org-em-minusculas>>` |
| Domínio DNS de deploy (dns_domain) | `<empresa.example>` |
| E-mail de deploy (deploy_email) | `<deploy@empresa.example>` |
| Canal de alerta (alert_channel) | `telegram` \| `slack` \| `email` |
| OS das VPS (infra_os) | `<ex.: Amazon Linux 2023>` |
| Org dos boilerplates (boilerplate_org) | `<org-github>` |
| Diretório de projetos | `<caminho>` |
| Workspace de produtos (docs) | `<caminho>` |

## Packs (IMP-111)

| Campo | Valor |
|-------|-------|
| Packs instalados (packs) | `<id>@<faixa>` \| `<nenhum>` |
| Repos dos packs (pack_repos) | `<id>` → `<URL do repo do pack>` |
| Regra da organização | `rules/packs/<id>.md` (instalada pelo rdd-setup a partir do pack) |