---
name: rdd-setup
description: >-
  Wizard de primeira configuração do RDD numa máquina nova — idempotente e
  executado por demanda. Pergunta o diretório padrão de projetos, coleta os
  defaults do cliente (org Azure, projeto, repos, usuário) e grava `rules/client-profile.md` (IMP-103), cria/repara o AGENTS.md
  local A PARTIR do `AGENTS.template.md` versionado (neutro — IMP-105),
  repõe o índice lazy de `rules/` (IMP-048),
  aplica os overrides de permissão dos
  subagents de dev (rdd-dev-backend, rdd-dev-frontend) no opencode.jsonc,
  instala os packs declarados no perfil (`packs:` — clone em `packs/<id>/`,
  instala `provides`, grava `.rdd/sources.yaml`),
  delega para rdd-azure-setup e rdd-gh-setup e, quando presente na instalação
  (skill de pack opcional — IMP-105), rdd-pia-connect-setup;
  valida o ambiente (repos clonados, mvn/ng/JDK/gh no PATH).
  Use quando o usuário pedir "configurar o rdd", "setup do rdd",
  "primeira configuração", "onboarding do rdd" ou ao migrar de máquina.
---
# rdd-setup — Wizard de Primeira Configuração do RDD

Onboarding de máquina nova: configura os artefatos **locais** (que não
versionados) com os paths desta máquina e valida o ambiente. Idempotente
— pode ser reexecutado; passos já completos são pulados.

## Contexto do problema que resolve

A config versionada (`agents/rdd-*.md`, `skills/rdd-*/SKILL.md`) é
portátil — sem paths de máquina. O que varia por máquina vive em dois
artefatos locais:

| Artefato | O que contém | Versionado? |
|----------|-------------|-------------|
| `AGENTS.md` (`~/.config/opencode/`) | blocos `<!-- azure-devops -->`, `<!-- org-pack -->` (quando o cliente tiver pack — IMP-105), `<!-- projeto-padrao -->`, `<!-- rdd-docs-repo -->` + Índice de Referências lazy (`rules/`, IMP-048) | ❌ gitignored — nasce do `AGENTS.template.md` versionado (IMP-105) |
| `opencode.jsonc` (`~/.config/opencode/`) | `permission.external_directory` + `agent.rdd-dev-*.permission` (overrides de path) | ❌ gitignored |
| `rules/client-profile.md` (`rules/`) | defaults do cliente (org Azure, projeto, repos, usuário, diretório de projetos — IMP-103) | ❌ gitignore explícito (dado de cliente nunca versionado) |
| `.secrets/` (`~/.config/opencode/.secrets/`) | credenciais (APM Keys, PATs, tokens) referenciadas via `{file:...}` | ❌ gitignored |

Este wizard preenche/repõe esses artefatos e valida o ambiente. O template
versionado do AGENTS.md é `AGENTS.template.md` (neutro, IMP-105) — o local é
gerado dele + client-profile; nunca invente conteúdo fora dos blocos marcadores.

## Lê (upstream)

- `~/.config/opencode/AGENTS.md` — blocos existentes (azure, projeto-padrao, repositorios) e índice lazy
- `~/.config/opencode/rules/*.md` — arquivos de referência lazy existentes (IMP-048)
- `rules/client-profile.md` / `rules/client-profile.template.md` — perfil do cliente (IMP-103)
- `~/.config/opencode/opencode.jsonc` — permission e agent overrides existentes
- `~/.config/opencode/skills/rdd-azure-setup/SKILL.md` — prerequisites de Azure
- `<raiz-de-projetos>/TM.Opencode.RDD/REPOSITORIES.md` (ou o path do bloco `<!-- repositorios -->`) — inventário de repos para validação de clones

## Gera (downstream)

- Edição em `~/.config/opencode/AGENTS.md` — bloco `<!-- projeto-padrao -->` e Índice de Referências lazy (merge, idempotente)
- Substituição no AGENTS.md gerado: o placeholder `rules/<pack-da-organizacao>.md` (índice lazy e bloco `<!-- org-pack -->`) é trocado pelo valor "Regra da organização" do perfil (ex.: `rules/packs/<id>.md`); sem pack, a linha do índice é removida (IMP-115)
- Edição em `~/.config/opencode/opencode.jsonc` — `permission.external_directory` + `agent.rdd-dev-backend/frontend.permission` com os paths da máquina
- Relatório textual de validação de ambiente (não persiste arquivo)
- Criação/atualização de `~/.config/opencode/rules/client-profile.md` — defaults do cliente (gitignored; IMP-103)

## Nunca edita

- Agentes e skills versionados (`agents/rdd-*.md`, `skills/rdd-*/SKILL.md`) — são do remote via `rdd-self-update`
- Blocos `provider`, `model`, `mcp` do opencode.jsonc — só `permission` e `agent`
- Artefatos de módulo RDD (REQUIREMENTS, TASKS, etc.)
- Remote — este wizard nunca commita nem push

## Tools

- `read` (AGENTS.md, opencode.jsonc, REPOSITORIES.md)
- `glob` (detectar módulos/repos no filesystem)
- `question` (perguntar paths e opções — 1 pergunta por bloco)
- `edit`/`write` (editar os 2 artefatos locais)
- `bash` (validação de ambiente: Test-Path, java -version, mvn -version, node -v)
- `skill` (delegar rdd-azure-setup / rdd-gh-setup; rdd-pia-connect-setup somente se existir na instalação — skill de pack opcional, IMP-105)

## Modo de erro

`warn` — validações de ambiente que falharem não bloqueiam a conclusão:
 entram no relatório como ⚠️ com orientação de correção. Só é `strict`
 na escrita do opencode.jsonc (JSONC inválido quebra o OpenCode — validade
 o resultado com parse antes de encerrar).

## Formato de commit

Nenhum — este wizard edita apenas artefatos **locais** (gitignored) e
nunca commita.

## Algoritmo

### Fluxo síncrono (obrigatório)

O wizard executa os passos em **ordem sequencial**, esperando a conclusão
de cada um antes de prosseguir. O usuário pode **pular** qualquer passo
opcional, mas nunca executar dois passos em paralelo.

```
Passo 1 → Passo 2 → Passo 2b (perfil) → Passo 3 → Passo 4 (Azure) → Passo 5 (PIA) → Passo 5b (gh) → Passo 6 → Passo 6b (Packs) → Passo 6c (hardening) → Passo 7
              ↓           ↓           ↓                ↓              ↓
           [pular]     [pular]     [pular]          [pular]        [pular]
```

### Passo 1 — Detectar estado atual

Leia AGENTS.md e opencode.jsonc e monte o diagnóstico:

| Item | Fonte | Estado esperado |
|------|-------|----------------|
| Bloco `<!-- azure-devops -->` | AGENTS.md | org, project, team, iteration preenchidos |
| Bloco `<!-- projeto-padrao -->` | AGENTS.md | diretório de projetos informado |
| Bloco `<!-- repositorios -->` | AGENTS.md | caminho do REPOSITORIES.md |
| Índice de Referências (lazy) | AGENTS.md | seção presente, 1 linha por `rules/*.md` (IMP-048) |
| Arquivos `rules/*.md` | `~/.config/opencode/rules/` | cada arquivo referenciado no índice existe |
| `permission.external_directory` | opencode.jsonc | inclui o diretório de projetos |
| `agent.rdd-dev-backend` / `agent.rdd-dev-frontend` | opencode.jsonc | overrides de edit/write com o path |

Exiba o diagnóstico antes de alterar qualquer coisa.

### Passo 2 — Perguntar o diretório de projetos

Via `question`, uma única pergunta: "Qual o diretório padrão onde ficam
os repos SDA (ex: `<raiz-de-projetos>`)?"

- Se `<!-- projeto-padrao -->` já existe, ofereça o valor atual como default
- Valide: se o diretório não existe no filesystem, confirme (pode ser
  intencional — máquina nova) e marque como ⚠️ no relatório

### Passo 2b — Perfil do cliente (rules/client-profile.md — IMP-103)

Coleta os defaults do cliente desta máquina e grava em
`~/.config/opencode/rules/client-profile.md`, a partir do template
versionado `rules/client-profile.template.md`. O perfil é a FONTE DE
VERDADE do cliente para o workflow — skills de tracker (Azure DevOps,
GitHub) leem o perfil em vez de hardcode.

1. Via `question` (pergunta consolidada), colete:
   - organização Azure DevOps e projeto padrão
   - usuário (nome + e-mail)
   - repos padrão do setor (ex.: prefixos `POL.*`, `SDA.*`)
   - diretório de projetos (se ainda não coletado no Passo 2)
2. Grave `rules/client-profile.md` preenchendo o template. O arquivo é
   gitignored — NUNCA versionar dado de cliente; se o `.gitignore` não
   contiver `rules/client-profile.md`, adicione a linha.
3. O wizard do Azure (Passo 4) e qualquer tracker passam a validar contra
   o perfil — nunca contra valores hardcoded.
4. Reexecutável: se o perfil já existe, mostre os valores e pergunte se
   deseja atualizar (stale = atualizar).

### Passo 3 — Aplicar config local

1. **AGENTS.md (a partir do template — IMP-105):**
   - Se `AGENTS.md` NÃO existir (máquina nova ou pós-`self-update` que
     removeu o arquivo do versionamento): copie `AGENTS.template.md`
     (versionado, neutro) para `AGENTS.md` e preencha os placeholders
     `<preenchido pelo rdd-setup>` com os valores do
     `rules/client-profile.md` (tracker, diretório de projetos,
     `repo_docs_rdd`).
   - Bloco `<!-- org-pack -->`: preencha SOMENTE se o perfil do cliente
     tiver pack de organização (ex.: Acme → `rules/<pack-da-organizacao>.md`);
     cliente sem pack → mantenha o placeholder do template.
   - Se `AGENTS.md` já existe: apenas sincronize os blocos marcadores
     (`<!-- projeto-padrao -->`, `<!-- rdd-docs-repo -->`, azure/org-pack)
     com o perfil (se já existe com valor igual, pule — idempotente; com
     valor diferente, confirme a troca antes).
2. **AGENTS.md — índice lazy (IMP-048):** se a seção "Índice de
   Referências — lazy loading" estiver ausente (máquina antiga), repõe o
   padrão: instrução CRITICAL (ler só sob demanda) + 1 linha por
   `rules/*.md`. Se algum `rules/*.md` referenciado não existir,
   oriente `rdd-self-update` (rules/ é versionado) e registre ⚠️ —
   nunca crie conteúdo de rules/ por conta própria.
3. **opencode.jsonc**:
   - `permission.external_directory["<dir>/**"] = "allow"`
   - `agent.rdd-dev-backend.permission = { edit: { "<dir>/**": "allow", "*": "ask" }, write: { ... } }`
   - `agent.rdd-dev-frontend.permission = { ... idem ... }`
   - **Preserve** todas as chaves existentes (provider, model, mcp, hooks).
     Edite por inserção cirúrgica — nunca reescreva o arquivo inteiro.
   - Após editar, valide que o JSONC continua parseável.

### Passo 4 — Azure (síncrono, opcional)

Se o bloco `<!-- azure-devops -->` estiver ausente ou incompleto →
pergunte: "Deseja configurar o Azure DevOps agora?"

- **Sim** → carregue `rdd-azure-setup` e **aguarde** a conclusão
  completa antes de prosseguir para o Passo 5.
- **Pular** → registre como pendência no relatório e siga para o Passo 5.

### Passo 5 — PIA (síncrono, opcional)

Se o provider `pia-broker` não existir no opencode.jsonc → pergunte:
"Deseja configurar o PIA agora?"

- **Sim** → verifique se a skill `rdd-pia-connect-setup` existe nesta
  instalação (é skill de pack opcional — IMP-105, pode não estar presente).
  Existe → carregue-a e **aguarde** a conclusão completa antes de prosseguir
  para o Passo 5b. Não existe → registre ⚠️ pendência no relatório (padrão
  do `@rdd-onboarding-orchestrator` — IMP-080) e siga para o Passo 5b.
- **Pular** → registre como pendência opcional no relatório e siga para
  o Passo 5b.

### Passo 5b — GitHub CLI / gh (síncrono, opcional)

Se `gh auth status` falhar (ou `gh --version` ausente) → pergunte:
"Deseja configurar a GitHub CLI (gh) agora?"

- **Sim** → carregue `rdd-gh-setup` e **aguarde** a conclusão completa
  antes de prosseguir para o Passo 6.
- **Pular** → registre como pendência no relatório e siga para o Passo 6.

### Passo 6 — Validar ambiente

Use `bash` (read-only) para verificar e reporte em tabela:

| Verificação | Comando | O que confirma |
|-------------|---------|----------------|
| REPOSITORIES.md acessível | `Test-Path` no path do bloco | inventário disponível |
| Repos clonados | `Test-Path` em cada repo do REPOSITORIES.md | desenvolvimento possível |
| Git | `git --version` | rastreabilidade |
| JDK | `java -version` | repos Java/Quarkus |
| Maven | `mvn -version` (senão `mvnw` no repo) | build backend |
| Node | `node -v` | repos frontend |
| Angular CLI | `npx ng version` (opcional) | MFE Angular |
| GitHub CLI | `gh --version` + `gh auth status` | pré-condição de `rdd-gh-issue-creator`/`rdd-gh-pr-creator` (issues/PRs) |
| Jev runtime | tool `jev_classify` disponível na sessão (o executor confirma; não há binário nem config em arquivo) | camada semântica do RDD funcional (`rdd-jev-classifier`, calibração em `rdd-decision-audit`/`rdd-quality-gates`) |

Repos ausentes: **não clone automaticamente** — liste os comandos
`git clone` sugeridos no relatório para o usuário decidir.

Jev ausente: **não bloqueia o setup** — registre como pendência no relatório
("runtime Jev indisponível — skills de calibração semântica degradam para
opinião do modelo") e siga; as skills afetadas já possuem fallback sem Jev.

### Passo 6b — Packs (opcional)

Se `rules/client-profile.md` declarar `packs:` (lista `<id>@<faixa>`),
instale cada pack. Sem `packs:` no perfil → pule silenciosamente. Falha de
um pack **não bloqueia os demais** (registre pendência — padrão do Passo
PIA). Contrato completo em `PACK_SCHEMA.md`; compatibilidade em
`BREAKING-CHANGES.md`.

Para cada pack:

1. **Clone:** `git clone <repo-do-pack> packs/<id>/` no runtime
   (`~/.config/opencode/`; `packs/` é gitignored pelo core). Já existe →
   `git -C packs/<id> fetch` e prossiga.
2. **`requires-core`:** leia o `pack.yaml` do clone e valide a faixa contra
   a versão local do core (campo `version` do `registry.yaml`). Mismatch →
   leia `BREAKING-CHANGES.md`, registre ⚠️ com a orientação de migração e
   pule o pack.
3. **no-override:** nenhum path de `provides` pode colidir com path do core
   — colisão → NÃO instale nada deste pack e registre a pendência.
4. **Instalação:** copie os paths de `provides` do clone para o runtime
   (por cópia; `accumulation/` NUNCA é instalado) e gere/atualize a seção no
   `.gitignore` local para os paths instalados.
5. **Lockfile:** grave/atualize `.rdd/sources.yaml` com pin de commit exato
   (pack → version, commit, paths[]).

### Passo 6c — Hardening (opcional): pre-push hook de neutralidade

Instala o hook de neutralidade no core (bloqueia push de dado de cliente):

1. Verifique hooks existentes ANTES: `git config core.hooksPath` e
   `.git/hooks/` — se já houver hooks configurados, AVISE que a instalação
   **substituirá** os hooks existentes e só prossiga com confirmação.
2. Confirme que `evals/neutrality/git-hooks` existe nesta instalação.
   Não existe → pule com ⚠️ (padrão pack opcional — IMP-110).
3. Instale: `git config core.hooksPath evals/neutrality/git-hooks`.

### Passo 7 — Relatório final

```text
═══ rdd-setup — <RESULTADO> ═══

✅ Config local aplicada:
   AGENTS.md: projeto-padrao = <dir> | índice lazy rules/ = <N> refs OK
   opencode.jsonc: external_directory + overrides rdd-dev-backend/frontend

✅ Azure: completo | ⚠️ Configure via rdd-azure-setup
✅ PIA: configurado | ℹ️ Pendência opcional: rdd-pia-connect-setup
✅ GitHub (gh): autenticado | ⚠️ Pendência: rdd-gh-setup
✅ Packs: <N> instalado(s), pin em .rdd/sources.yaml | ℹ️ Sem `packs:` no perfil
✅ Hardening: hooks de neutralidade ativos | ⚠️ Pendência opcional: pre-push hook (IMP-110)

🔍 Ambiente:
| Verificação | Estado | Observação |

⚠️ Reinicie o OpenCode para a config nova valer (permission/agent não são hot-reloaded).
Próximo passo sugerido: @rdd-next no módulo em que vai trabalhar.
```

## Casos de Borda

- **Re-execução (idempotente):** itens já configurados com valor igual
  são pulados; valores diferentes pedem confirmação antes de trocar.
- **JSONC com comentários:** preserve os comentários existentes; valide
  parse após a edição (JSONC tolera `//` e blocos `/* */`).
- **Diretório de projetos diferente do exemplo:** nenhum path é fixo —
  o wizard sempre usa o valor informado; o `<!-- repositorios -->` pode
  apontar para outro clone do TM.Opencode.RDD.
- **Bloco azure completo mas stale (org mudou):** o wizard não adivinha —
  peça confirmação e então delegue o re-setup.
- **`gh` ausente ou desautenticada:** não bloqueia o setup — registre
  pendência `rdd-gh-setup` no relatório; sem ela, `rdd-gh-issue-creator`/
  `rdd-gh-pr-creator` abortam na pré-condição.
- **Sem repos clonados:** normal em máquina nova; reporte os comandos
  `git clone` do REPOSITORIES.md e marque ⚠️.
- **opencode.jsonc malformado (parse quebra após edição):** reverta a
  última edição e informe — nunca deixe a config num estado inválido.
- **Índice lazy ausente ou `rules/*.md` faltando (máquina antiga):**
  repõe a seção do índice (Passo 3.2); arquivo `rules/` ausente é
  resolvido via `rdd-self-update` (versionado no remote) — o wizard
  não inventa conteúdo de regras.
- **Perfil do cliente ausente ou stale (IMP-103):** reexecute o Passo 2b antes do Passo 4 (Azure) — nunca rode tracker com defaults hardcoded.
- **Blocos `azure-devops` no AGENTS.md (legado):** continuam suportados por compatibilidade, mas a fonte de verdade do wizard passa a ser `rules/client-profile.md` (IMP-103); sincronize o bloco a partir do perfil quando divergirem.
