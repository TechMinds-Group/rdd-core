---
name: rdd-core-publish
description: >-
  Publica as melhorias da config local do workflow RDD (~/.config/opencode/)
  no repositório remoto da config via git commit + push (branch main), fechando o
  ciclo de publicação após o @rdd-workflow-improver corrigir ou o @rdd-workflow-builder
  criar componentes. Contrato híbrido de aprovação (IMP-090): pedido explícito de
  publicação + tema único + nada fora do escopo + gates verdes = execução direta
  (0 perguntas); qualquer anomalia = 1 question consolidada com o pacote completo
  (temas + arquivos + mensagens + push) — aprovação do pacote, nunca commit cego.
  Nunca git add -A / git add . (só paths explícitos), roda git pull --ff-only antes
  do push e nunca força push. Use quando o usuário pedir "subir alterações do workflow",
  "publicar melhorias do RDD", "dar push na
  config", "commitar as melhorias do workflow", "publicar IMP-XXX" ou "push das
  mudanças na config do opencode".
---

# rdd-core-publish — Publicação segura das melhorias da config RDD

Responde "como publicar as melhorias aplicadas na config RDD local para os demais
ambientes?" — o espelho inverso do `rdd-core-update` (que apenas traz do remote via
pull; esta skill apenas empacota e envia via commit + push). Diferente do
`@rdd-workflow-improver` (corrige o workflow) e do `@rdd-workflow-builder` (cria
componentes) — esta skill **não edita nada**; publica o que já está no working tree.

## Contexto do repositório

- **Repo alvo:** `~/.config/opencode/` (é o próprio diretório de config
  (~ = path da config local do OpenCode na SUA máquina — se a sua instalação usar outro local, confirme no bloco local do AGENTS.md via rdd-setup)
  do OpenCode — contém `.git/`)
- **Remote (origin):** derivado do próprio repo — `git -C $HOME/.config/opencode remote get-url origin` (IMP-105: zero hardcode de org/repo; exemplos ilustrativos podem citar a org do operador).
- **Branch:** `main`
- **Escopo de versionamento:** o `.gitignore` do repo versiona apenas
  `agents/rdd-*.md`, `skills/rdd-*/SKILL.md`, `ARCHITECTURE.md` e
  `WORKFLOW_IMPROVEMENTS.md`.

## Lê (upstream)

- Estado do working tree via `git status --porcelain` (repo alvo)
- `HEAD` local vs `origin/main` (via `git fetch` + comparação de refs)
- Diff a publicar via `git diff` / `git diff --cached --stat`
- `evals/trends/trends.json` e `evals/reports/EVAL_REPORT_*.md` (Golden Set
  Gate — frescor e regressão dos evals das skills a publicar)
- `evals/<skill>/fixture-*/criteria.yaml` (verificação de cobertura)

## Gera (downstream)

- Commits no repo alvo (mensagens Conventional Commits, atômicos quando houver
  mudanças distintas) e push para `origin/main`. Saída textual na sessão:
  status (publicado/abortado), commits criados e orientações. **Não persiste
  arquivos de artefato.**

## Nunca edita

- **Nunca** cria, edita ou remove arquivos da config — empacota apenas o que já
- **Exceção ÚNICA:** `MANIFEST.sha256` (IMP-103) — este é o ÚNICO arquivo que esta skill escreve (regenerado a cada publicação); todo o resto permanece intocado.
  existe no working tree (trabalho de improver/builder).
- **Nunca** `git push --force` / `--force-with-lease`.
- **Nunca** `git add -A` / `git add .` — apenas paths explícitos do escopo versionado.
- **Nunca** resolve conflitos nem faz merge/rebase automático.
- **Nunca** inclui no commit arquivos fora do escopo versionado (AGENTS.md,
  opencode.jsonc, settings.json, hooks/, plugins/, command/*, skills/agents não-rdd-*).
- **Nunca** edita artefatos de módulo de projeto (REQUIREMENTS.md etc.).
- **Nunca** aceita alteração em `evals/golden-human/` num commit publicado (IMP-100): golden set humano é intocado por agents — path explícito nesse diretório na lista de staging = **rejeitar** e sinalizar anomalia (Passo 4). O Golden Set Gate NÃO exige golden verde nesse diretório (casos são escassos e humanos).

## Tools

- `bash` — exclusivamente para comandos `git` no repo alvo:
  `git -C $HOME/.config/opencode status --porcelain`,
  `git -C ... remote -v`, `git -C ... fetch origin`,
  `git -C ... rev-parse HEAD`, `git -C ... rev-parse origin/main`,
  `git -C ... pull --ff-only`, `git -C ... add <paths explícitos do escopo>`,
  `git -C ... diff --cached --stat`, `git -C ... commit -m "<mensagem>"`,
  `git -C ... push origin main`, `git -C ... log --oneline`
- `read` (para inspecionar arquivos a publicar, se necessário)
- `question` (gate consolidado único — IMP-090: aprovação do pacote temas +
  arquivos + mensagens + push, SOMENTE em anomalia; fluxo feliz executa sem question)

## Modo de erro

`abort` — qualquer condição de risco (working tree sujo fora do escopo confirmado,
pull não fast-forward, branch divergente, push rejeitado, rede/credencial
indisponível, repo sem remote, finding crítico no Health Gate (Passo 3.5)) **aborta a operação inteira** com mensagem clara.
Anomalia não-crítica → 1 `question` consolidada com o pacote antes de commitar
(Passo 4 — IMP-090); detectada entre commit e push → abort + orientação.
A skill nunca força, nunca faz merge/rebase automático, nunca resolve conflito
sozinha e nunca força push.

## Algoritmo

### Passo 0 — Pré-condições (repo + remote)

```bash
git -C $HOME/.config/opencode status --porcelain
git -C $HOME/.config/opencode remote -v
```

- Se não é repo git (`.git` ausente) ou git indisponível → **ABORTA** e orienta.
- Se não há remote `origin` → **ABORTA** e orienta configurar
  `git remote add origin <URL do repo da config>` (URL da org do operador).

### Passo 1 — Listar mudanças e classificar o escopo (sem pergunta)

- Liste **TODAS** as mudanças (`M`/`A`/`D`/`R`/`C`/`??`).
- Separe em duas listas:
  - **Escopo versionado (publicável):** `agents/rdd-*.md`, `skills/rdd-*/SKILL.md`,
    `ARCHITECTURE-*.md`, `WORKFLOW_IMPROVEMENTS.md`.
  - **Fora do escopo (não publicável):** todo o resto — `opencode.jsonc`,
    `AGENTS.md`, `settings.json`, `hooks/`, `plugins/`, `command/*`,
    skills/agents não-rdd-*. A maioria está no `.gitignore` e nem aparece no
    status; se algo aparecer, **não incluir** e sinalizar como anomalia (Passo 4).
- Se a lista publicável estiver **vazia** → informe *"nada a publicar"* e encerre
  (working tree limpo ou só mudanças fora do escopo versionado).
- **Sem `question` neste passo** — a classificação de escopo é automática e
  alimenta a decisão única do Passo 4 (IMP-090). "Nunca commit cego" vira
  aprovação do PACOTE: pedido explícito no fluxo feliz ou 1 question
  consolidada em anomalia.

### Passo 1.5 — Golden Set Gate (evals de regressão)

Se a lista publicável incluir `skills/rdd-*/SKILL.md` ou `agents/rdd-*.md`,
verifique o estado do golden set (`evals/`) **antes** de commitar:

1. **Cobertura:** para cada skill alterada, verifique se existe
   `evals/<skill>/fixture-*/criteria.yaml`. Skill alterada sem fixture →
   **warning** (prossiga, mas avise: "skill X sem cobertura de eval").
2. **Frescor:** compare a data da última entrada de `evals/trends/trends.json`
   (ou do relatório mais recente em `evals/reports/` para a skill) com a data
   da modificação do arquivo (git diff não traz data; use timestamp do arquivo).
   Eval mais antigo que a última edição da skill → **BLOQUEIA**: *"A skill X
   foi editada após o último eval. Rode `rdd-skill-eval --skill X` antes de
   publicar."* (O eval é executado pelo improver/builder ou pelo primary —
   esta skill não executa evals, apenas verifica.)
3. **Regressão:** leia o relatório de eval mais recente da skill. Se houver
   FAIL de severity `error` (ou score menor que a entrada anterior do
   trends.json) → **BLOQUEIA** com opções: (a) corrigir a skill e reavaliar,
   (b) se a mudança de comportamento é intencional, atualizar o baseline
   (`output-expected/`) explicitamente via `rdd-skill-eval` e reavaliar.
   **Nunca publique com regressão conhecida sem decisão explícita do usuário.**

Gate read-only: usa apenas `read` (trends.json, reports, criteria.yaml).
Se `evals/` não existir, pule o gate com aviso ("golden set ausente —
considere criar fixtures para as skills alteradas").

### Passo 2 — Sincronizar com o remote (fetch + divergência)

```bash
git -C $HOME/.config/opencode fetch origin
git -C $HOME/.config/opencode rev-parse HEAD
git -C $HOME/.config/opencode rev-parse origin/main
```

- `git fetch` falhou (rede/credencial) → **ABORTA**: *"Não foi possível contatar o
  remote (rede/credencial). O estado local não foi alterado. Tente novamente mais
  tarde."* Nunca prossiga sem fetch bem-sucedido.
- **HEAD atrás de origin/main** (origin/main não está contido em HEAD) →
  `git -C ... pull --ff-only` (o local precisa estar atualizado antes do push).
  - Pull ok → prossiga.
  - Pull abortou por WIP ou divergência → **ABORTA** e orienta (ver casos de borda).
- **Branch divergente** (HEAD e origin/main têm commits que o outro não tem) →
  **ABORTA** e orienta resolução manual (ver casos de borda). Nunca força push.

### Passo 3 — Preparar e commitar (atômico por tema, sem pergunta)

- Agrupe as mudanças por tema distinto (ex.: skill nova; correção de skill;
  atualização de arquitetura) e redija a(s) mensagem(ns) Conventional Commits
  (seção "Formato de commit") — agrupar e redigir é trabalho da skill, não
  pergunta (IMP-090). Para cada tema, crie um commit atômico:
  ```bash
  git -C $HOME/.config/opencode add <paths explícitos do escopo>
  git -C $HOME/.config/opencode diff --cached --stat   # revisar staged
  git -C $HOME/.config/opencode commit -m "<mensagem>"
  ```
- **Nunca** `git add -A` / `git add .` — sempre paths explícitos.
- Um único tema → um único commit.

### Passo 3.7 — MANIFEST de integridade (IMP-103)

Regenerar `MANIFEST.sha256` na raiz do repo e incluir no push:

1. Liste os arquivos versionados: `git -C $HOME/.config/opencode ls-files` (paths relativos).
   **OBRIGATÓRIO (bug real 18/10/2026):** antes do git, definir `[Console]::OutputEncoding = [Text.Encoding]::UTF8` e usar `-c core.quotepath=false` — sem isso paths com em-dash/acento (ex.: `RN-010 — Analise-Funcional.md`) vêm escapados/octal e 19+ arquivos ficam fora do MANIFEST silenciosamente. Paths escapados (`\NNN` octal) devem ser desescapados antes do hash. `Test-Path`/`Get-FileHash` SEMPRE com `-LiteralPath`. Gravar com `[IO.File]::WriteAllLines($path, $lines, [Text.UTF8Encoding]::new($false))` — **NUNCA `Out-File -Encoding ascii`** (nem qualquer `-Encoding ascii`): mangle de não-ASCII → `?`; bug real 18/10/2026: regeneração com `-Encoding ascii` corrompeu 19 labels do MANIFEST (em-dash/acentos), detectado na 3ª auditoria de saúde (IMP-103).
2. Para cada path, calcule o sha256 do conteúdo em disco (PowerShell: `Get-FileHash -Algorithm SHA256`; Linux: `sha256sum`). Uma linha por arquivo: `<sha256>  <path-relativo>`. **INCLUIR o próprio `MANIFEST.sha256` na lista e na contagem** (prática consolidada, validada 18/10/2026: contagem 834/834 == `git ls-files`, com commit exclusivo do MANIFEST) — o hash gravado dele fica do commit anterior (auto-referência é inerente; o que importa é a COBERTURA de paths: todo arquivo versionado tem linha no MANIFEST).
3. Grave o resultado em `MANIFEST.sha256` (UTF-8 sem BOM, LF — `[IO.File]::WriteAllLines` + `UTF8Encoding($false)`; NUNCA `-Encoding ascii`, bug 18/10/2026).
4. Valide a contagem: entradas do MANIFEST == `git ls-files | count` — qualquer diferença = **ABORTA** (integridade parcial não se publica).
5. `git -C ... add MANIFEST.sha256` e commit exclusivo: `chore(rdd): atualiza MANIFEST.sha256`.
6. Falha ao calcular hash de qualquer arquivo = **ABORTA** (integridade parcial não se publica).

### Passo 3.5 — Health Gate (integridade estrutural dos arquivos alterados)

Antes de qualquer push, execute o fluxo do `rdd-agent-health-monitor`
**restrito aos arquivos alterados neste commit** (`agents/*.md` e
`skills/*/SKILL.md` publicáveis — escopo reduzido, NÃO a auditoria completa
de ~100 arquivos):

1. Para cada arquivo alterado, rode no mínimo a Verificação F itens 10-13
   do monitor (IMP-086): delimitadores de front matter (abre E fecha
   exatamente `---`), YAML parseável, `permission:` declarado (agents).
2. **Fail-closed:** QUALQUER FINDING crítico → **ABORTA o push** (commits
   locais permanecem locais), reporte os findings na sessão e oriente a
   correção via `@rdd-workflow-improver` antes de reintentar.
3. O push só prossegue com **0 findings críticos** nos arquivos alterados.
4. O resultado do gate é reportado **na sessão** (texto) — não persiste
   arquivo de relatório (esta skill não grava artefatos).

### Passo 4 — Decisão única e push seguro (IMP-090)

- **Fluxo feliz** — TODAS as condições verdadeiras → push direto, **0 questions**:
  pedido explícito de publicação ("publicar", "subir", "dar push") sem ressalva de
  escopo + **um único tema** de mudança + **nada fora do escopo** no status
  (Passo 1) + Golden Set Gate (Passo 1.5), Health Gate (Passo 3.5) e sync
  (Passo 2) verdes.

  ```bash
  git -C $HOME/.config/opencode pull --ff-only   # garantia dupla (idempotente)
  git -C $HOME/.config/opencode push origin main
  ```

  O pacote completo (tema, arquivos, mensagens) é exibido no relatório final —
  o operador aprova o PACOTE (pedido explícito), não cada etapa.
- **Anomalia** — QUALQUER condição abaixo → **1 `question` consolidada** com o
  pacote completo (temas + arquivos + mensagens + push), opções aprovar / ajustar /
  cancelar:
  - ≥ 2 temas distintos de mudança;
  - arquivo fora do escopo detectado no status (Passo 1);
  - Golden Set Gate com warning/decisão pendente (Passo 1.5);
  - Health Gate com finding não-crítico a decidir (finding crítico = abort — Modo de erro);
  - divergência com remote que admita decisão do operador (atrás = pull --ff-only
    e segue; divergência real = abort — Modo de erro);
  - pedido ambíguo ou parcial (ex.: "só prepara", "não pusha" → execute até a
    etapa pedida, reporte e encerre).
- Anomalia detectada **antes de commitar** → a question acontece antes do commit
  (nada é commitado sem o visto). Detectada **entre commit e push** (ex.: push
  rejeitado) → vale o Modo de erro (abort + orientação).
- `push` rejeitado (non-fast-forward — remote avançou desde o fetch) → **ABORTA** e
  orienta (ver casos de borda). **Nunca** `--force`.
- `push` rejeitado por branch policy (ex.: PR obrigatório) → **ABORTA** e orienta
  criar PR (ver casos de borda).

### Passo 5 — Aviso final obrigatório

Informe: *"Config não é hot-reloaded — **reinicie o OpenCode** para que as
skills/agents atualizados passem a valer na sessão. Os demais ambientes recebem
esta publicação via `rdd-core-update` (git pull --ff-only no repo do remote origin)."*

## Formato de saída

```text
═══ rdd-core-publish — <RESULTADO> ═══

📦 Repo: ~/.config/opencode/ (remote origin @ main)

✅ PUBLICADO COM SUCESSO
   Commits criados (N):
     - a11bcc0 feat(rdd): IMP-013 nova skill rdd-core-publish
     - b3c9f2e fix(rdd): rdd-azure-task-creator convenção de título
   Push: origin/main (branch atualizada)

⚠️ Reinicie o OpenCode para a nova config valer.
   Demais ambientes recebem via rdd-core-update.

── ou ──

⛔ ABORTADO — <motivo>
   Explicação + orientação de resolução manual.
   Nada foi alterado no repo.
```

## Workflow

1. Pré-condições: repo + remote (Passo 0).
2. `git status --porcelain` → lista publicável vs fora do escopo, sem pergunta
   (Passo 1).
3. **Golden Set Gate** — frescor + regressão dos evals das skills alteradas
   (Passo 1.5); bloqueia se eval pendente ou regressão sem decisão explícita.
4. `git fetch origin` + comparação HEAD vs origin/main; pull --ff-only se atrás
   (Passo 2).
5. Commit atômico por tema — a skill agrupa temas, redige mensagens e commita
   sem pergunta; `git add` explícito (Passo 3).
6. **MANIFEST de integridade** — regenera `MANIFEST.sha256` e commit exclusivo (Passo 3.7, IMP-103).
7. **Health Gate** — integridade estrutural dos arquivos alterados (Passo 3.5);
   fail-closed: qualquer FINDING crítico aborta o push (corrige via
   `@rdd-workflow-improver` antes de reintentar).
8. **Decisão única (IMP-090)** — fluxo feliz (pedido explícito + tema único +
   nada fora do escopo + gates verdes): `git pull --ff-only` + `git push origin main`
   direto, 0 questions; qualquer anomalia: 1 question consolidada com o pacote
   (Passo 4).
9. Aviso final: reiniciar OpenCode + demais ambientes via rdd-core-update (Passo 5).

## Casos de Borda

### Golden Set Gate bloqueia (eval pendente ou regressão)

**ABORTA** (antes de qualquer commit) e orienta: *"A skill X foi editada após
o último eval" (frescor) ou "o último eval da skill X tem FAIL error/score
abaixo do anterior" (regressão). Opções: (a) rodar `rdd-skill-eval --skill X`
agora, (b) se a mudança de comportamento é intencional, atualizar o baseline
via rdd-skill-eval e reavaliar, (c) cancelar a publicação.* A publicação só
prossegue após eval verde ou decisão explícita registrada do usuário.


### MANIFEST divergente no pull anterior (IMP-103)

Se o `rdd-core-update` reportou arquivos divergentes do `MANIFEST.sha256`,
resolva ANTES de publicar: commit legítimo (incluir no pacote) ou descarte
consciente pelo operador. Publicar por cima de divergência silencia o
detector de tampering.

### Health Gate bloqueia (finding crítico nos arquivos alterados)

**ABORTA o push** (commits já criados permanecem locais) e reporta os
findings — ex.: front matter com delimitador quebrado (caso real IMP-086:
` --` no lugar de `---` fez o runtime descartar permissões em silêncio).
Orientação: corrigir via `@rdd-workflow-improver` e rodar `rdd-core-publish`
de novo. Nunca publique componente com front matter quebrado.

### Repo sem remote configurado

`git fetch origin` falha por ausência de remote → **ABORTA**: *"O repo
`~/.config/opencode` não tem remote origin. Verifique `git -C ... remote -v` e
configure o remote origin com `git remote add origin <URL do repo da config>`."*

### Nada a publicar (working tree limpo ou nada no escopo)

Informe *"nada a publicar"* com o status completo e encerre sem tocar em nada.

### Arquivos fora do escopo no status

Explique que `opencode.jsonc`, `AGENTS.md`, `settings.json`, `hooks/`, `plugins/`,
`command/*` e skills/agents não-rdd-* não são versionados e **não entram no
commit**, mesmo que apareçam no status. Inclua apenas os paths do escopo versionado.

### Pull aborta por WIP (entre status e pull)

Se o `pull --ff-only` falhar por WIP local → **ABORTA**: *"Há WIP local na config —
não vou sobrescrever nem misturar. Opções: (a) commitar o WIP e rodar de novo, (b)
resolver manualmente depois de um `git stash`, (c) inspecionar os arquivos antes de
decidir."* Nunca `git reset --hard`/`checkout -- .` automaticamente.

### Branch divergente (pull --ff-only falha / push rejeitado non-fast-forward)

**ABORTA** e orienta: *"A branch local divergiu do remote. Identifique seus commits
locais com `git -C ... log origin/main..HEAD` e decida entre `git rebase
origin/main` (histórico linear) ou `git merge origin/main` (commit de merge).
Depois rode rdd-core-publish de novo."* **Nunca** `git push --force`.

### Push rejeitado por branch policy (ex.: PR obrigatório)

**ABORTA** e orienta: *"O remote rejeitou o push por branch policy. Crie um PR
manualmente: `git push origin HEAD:feature/...` e abra o PR no Azure DevOps
no remote origin)."* A skill não cria PR.

### Rede / credencial indisponível

`fetch` ou `push` falham por rede/credencial → **ABORTA**: *"Não foi possível
contatar o remote (rede/credencial). O estado local não foi alterado. Tente
novamente mais tarde."* Commits locais já criados permanecem locais — oriente
re-execução do Passo 4 quando a rede voltar.

### Git não disponível / não é repo

`git status` falha → verifique se o diretório é repo (`.git` existe) e se o git
está no PATH; informe sem alterar nada.

### Mudanças que não devem ir para o remote

Se o usuário tiver experimentos locais (ex.: skill em teste que não deve ser
publicada), **não** os inclua — liste como "não publicável" no Passo 1 e trate
como anomalia (Passo 4): a question consolidada registra a decisão explícita
do usuário.

## Formato de commit

Conventional Commits, mensagens em PT-BR descrevendo as melhorias publicadas.
Se a mudança corresponder a um IMP registrado em WORKFLOW_IMPROVEMENTS.md, cite-o:

- `feat(rdd): IMP-013 nova skill rdd-core-publish`
- `feat(rdd): IMP-012 convenção de título de task obrigatória`
- `fix(rdd): rdd-data-model seção §6`
- `docs(rdd): atualiza ARCHITECTURE-MAP com rdd-core-publish`

Múltiplas mudanças distintas → múltiplos commits atômicos (um por tema); uma única
mudança → um único commit. Nunca empacotar temas não relacionados no mesmo commit.
