# AGENTS — Config OpenCode (gerado a partir do AGENTS.template.md — IMP-105)

<!--
TEMPLATE VERSIONADO E NEUTRO (IMP-105). Este arquivo NÃO roda direto: o
`rdd-setup` copia este template para `AGENTS.md` (gitignored, local) e
preenche os placeholders `<preenchido pelo rdd-setup>` a partir do
`rules/client-profile.md` (IMP-103). Nada de organização/registry/DNS/canal/
OS/tracker no template — a base publicada fica 100% neutra.

Blocos marcadores reconhecidos pelo rdd-setup (substituição idempotente):
  <!-- azure-devops --> ... <!-- /azure-devops -->   tracker do cliente
  <!-- org-pack --> ... <!-- /org-pack -->           identidade da org (pack lazy)
  <!-- projeto-padrao --> ... <!-- /projeto-padrao --> diretório de projetos
  <!-- rdd-pack-accumulation --> ... <!-- /rdd-pack-accumulation -->  destino do acúmulo (pack ativo)
-->

<!-- azure-devops -->
<preenchido pelo rdd-setup a partir do client-profile>
Tracker do cliente: org/projeto/repos-padrão/usuário (IMP-103). Ler
`rules/client-profile.md` ANTES de qualquer operação de tracker; nunca usar
repos de outros setores/produtos como padrão. O perfil é gitignored —
template em `rules/client-profile.template.md`.
<!-- /azure-devops -->

<!-- org-pack -->
<preenchido pelo rdd-setup quando o cliente tiver pack de organização>
Identidade da organização (org GitHub/registry, nomenclatura de repos,
produtos, infraestrutura validada) vive no pack lazy da org — ex.:
`rules/<pack-da-organizacao>.md`). Ler o pack AO criar repos, pipelines de
deploy ou operar a infra da organização. Sem pack registrado, este bloco
fica vazio e o perfil do cliente responde pelos defaults.
<!-- /org-pack -->

### Primary Agents RDD (selecionáveis via Tab)
- **`rdd-req`:** descoberta de negócio, clarificação, `REQUIREMENTS.md`, escopo, Change Requests (`CR-XXX`).
  - **Triagem de PENDs (IMP-031):** nunca classificar PEND como "dev direto" sem aprovação explícita do usuário. Inferência por omissão é proibida.
- **`rdd-doc`:** engenharia reversa multi-repo, `specs/`, fechamento da DAG.
- **`rdd-dev`:** implementação de código a partir de tasks aprovadas.
- **`rdd-devops`:** infraestrutura e deploy da empresa — setup de VPS (OS/registry/DNS/canal do perfil), pipeline CI/CD e troubleshooting guiado (skills `rdd-vps-setup` / `rdd-vps-troubleshoot` / `rdd-cicd-workflow` / `rdd-observability`).

### Hierarquia de Convenções
AGENTS.md Global → AGENTS.md do Projeto → Primary Agent → Subagent → Skill.
Perguntas "o que fazer agora" / "próxima skill" → skill `rdd-next` (não analise o estado você mesmo).

## OUTPUT STYLE: concise
- Bullet points over paragraphs
- Skip filler words and hedging ("I think", "probably", "it seems")
- 1-sentence explanations max, then code/action
- No repeating what the user said

## Regras de Interação e Delegação (IMP-043)
- Perguntas ao usuário: agrupe TODAS as decisões pendentes numa única chamada de `question` (nunca 1 por vez quando houver N pendências). Pergunta de decisão é bem-vinda — com contexto e opções concretas.
- Encerramento de turno (anti-idle, IMP-085): se restar APENAS decisão do operador, emita UMA `question` agrupada e ENCERRE o turno — a resposta do operador é o próximo evento. Nunca emita tool calls de preenchimento/idle (ex.: bash trivial em loop) enquanto aguarda. Responder no chat e parar é ação válida e completa.
- Pedágio ≠ pergunta: o que se minimiza é a espera mecânica de permissão de tool; decisão de negócio/arquitetura nunca é suprimida.
- Delegação de alta fidelidade (R1): todo prompt de `task` carrega insumos (paths), decisões já tomadas, formato de retorno esperado e restrições. Nunca delegue esperando que o subagente adivinhe. Cole só o essencial; o resto o subagente lê.
- Retomada (R2): continuação do mesmo trabalho = resume via `task_id` (memória do subagente retomada); sessão nova só para trabalho novo.
- Paralelismo (R3): tasks independentes em paralelo (uma message, N calls) — nunca escrita concorrente no mesmo arquivo.
- Determinístico (R4): script apenas para lista fechada (evals, registry render, SQL de stats) — julgamento permanece agêntico.

<!-- projeto-padrao -->
<preenchido pelo rdd-setup a partir do client-profile>
diretorio_projetos: <caminho>
<!-- /projeto-padrao -->

<!-- rdd-pack-accumulation -->
<preenchido pelo rdd-setup a partir do client-profile>
Destino do ACÚMULO do workflow (patterns/, metrics/, reverses/) é o
`accumulation/` do pack ativo da organização (ex.: `packs/<pack-ativo>/accumulation/`),
resolvido via `packs:` do client-profile — IMP-111. Skills de negócio NUNCA
gravam em ~/.config/opencode/.
<!-- /rdd-pack-accumulation -->

## Índice de Referências — lazy loading
CRITICAL: os arquivos abaixo NÃO são carregados automaticamente. Leia com o Read tool APENAS quando a tarefa atual exigir — nunca preventivamente. Quando lidos, trate como instruções obrigatórias que sobrescrevem defaults.

- `rules/context7.md` — ANTES de responder sobre library/framework/SDK/CLI/cloud (ctx7 CLI; não confie na memória).
- `rules/<pack-da-organizacao>.md` — pack da organização (org/repos/produtos/infra validada; nome definido pelo rdd-setup) — AO editar repos da org, criar pipelines de deploy ou operar infra. Existe somente quando o cliente tem pack (garantido pelo rdd-setup; cada organização recebe o seu no mesmo padrão).
- `rules/projeto-<nome>.md` — AO consultar o banco de um projeto específico via postgres MCP (regra de PROJETO — existe só em máquinas que operam esse projeto).
- `rules/stack-templates.yaml` — Registry de boilerplates RDD por stack (.NET, React, Angular, Rust, Java). A org vem de `boilerplate_org` no client-profile. Carregado pelo rdd-stack-boilerplate antes de scaffold de novo projeto; editar para adicionar/atualizar templates e recomendar o PR no .config do workflow.
- `rules/client-profile.md` — ANTES de qualquer operação Azure DevOps/tracker/GitHub org/deploy (org, projeto, repos, usuário, registry, DNS, canal — IMP-103/IMP-105). Gravado pelo rdd-setup; nunca versionado — template em `rules/client-profile.template.md`.
- `packs/<pack-ativo>/accumulation/patterns/INDEX.md` (bloco `rdd-pack-accumulation` acima; pack ativo resolvido via `packs:` do client-profile) — AO levantar/desenhar/implementar feature de domínio já tratado em outro produto ou cenário recorrente (pattern library: processo/arquitetura/codigo/ui/teste/dados).