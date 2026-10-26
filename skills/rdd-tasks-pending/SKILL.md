---
name: rdd-tasks-pending
description: >-
  Lista as tasks que falta concluir (pendentes/em andamento) no pipeline RDD,
  agrupadas por sistema → feature (RN-âncora) → tasks (ID RN-NNN-M, título,
  status, tipo, repo). Fontes: front matter `status` dos arquivos
  "RN-NNN — <título> — Feature.md" (IMP-093; fallback `— Tasks.md` pré-rename IMP-092) localizados por glob recursivo delivery/**/
  (IMP-092 — agnóstico ao delivery_style da CONSTITUTION.md §9), fallbacks
  legados (pasta IMP-040 com 2 arquivos, RN-*.md, TASKS*.md / TASKS.md) e,
  opcionalmente, issues abertas do GitHub via gh CLI (complemento, nunca
  bloqueante). Âncoras `PEND-NNN` em features são legado pré-IMP-094 (leitura
  ok — IMP-094); nada gera feature PEND. Read-only — nunca edita artefato,
  cria issue ou commita. Se o
  sistema NÃO for informado de antemão, questiona o operador antes de listar
  (cada sistema detectado + "Todos os sistemas") — nunca assume escopo por
  omissão (IMP-031). Use quando o usuário pedir "tasks pendentes", "listar
  tasks", "o que falta fazer", "backlog de tasks", "tasks em andamento" ou
  "tasks pendentes do <sistema>".
---
# rdd-tasks-pending — Tasks Pendentes do Pipeline RDD

Lista as tasks que FALTA concluir (pendentes/em andamento) no pipeline RDD,
agrupadas por sistema → feature (RN-âncora) → tasks. Read-only — a saída
na sessão é o único efeito; diagnostica e lista, nunca modifica nada.

## Diferenciação

| Skill | Pergunta que responde | Saída |
|-------|----------------------|-------|
| `rdd-tasks-pending` | "Quais tasks faltam concluir no sistema X?" | Tasks pendentes/em andamento por feature |
| `rdd-next` | "O que fazer agora?" | Próxima(s) skill(s) da DAG (não lista tasks) |
| `rdd-progress` | "Onde estamos?" | Dashboard de cobertura/drift/fase (não task-level) |
| `rdd-task-spec` | — (gera) | Cria as análises da feature (write, upstream desta) |
| `rdd-gh-issue-creator` | — (gera) | Cria issues das tasks (write, downstream desta) |

## Referências

- IDs RN-XXX / PEND-XXX: `CONSTITUTION.md §1`
- Estrutura de delivery IMP-092 (arquivo `RN-NNN — <título> — Feature.md` — IMP-093 — direto
  no grupo; `delivery_style` §9) e IMP-037 (nunca construir nome de
  pasta/arquivo — sempre glob)
- Ambiguidade Zero / IMP-031 (inferência por omissão é proibida)
- Perguntas agrupadas: IMP-043

## Resolução de caminhos

- **`<repo-docs>`**: resolva pelo diretório de trabalho corrente (cwd) — o
  workspace de produtos onde a sessão está posicionada. NUNCA
  hardcode o caminho da máquina.
- **`<sistema>`**: pasta com `PROJECT_CHARTER.md` diretamente sob `<repo-docs>`
  (ex.: `<repo-docs>/Salon/`). Detecte por glob, nunca construa o nome.
- Caminhos de artefato seguem IMP-011 (subpasta primeiro, fallback raiz).

## Lê (upstream)

Fontes de tasks, em ordem de prioridade (por sistema):

1. **Features IMP-092 (fonte primária):** glob recursivo
   `<sistema>/delivery/**/* — Feature.md` (fallback: `* — Tasks.md` pré-rename) → arquivo
   `delivery/<grupo>/RN-NNN — <título> — Feature.md` em qualquer
   profundidade/grupo (LEITURA agnóstica ao estilo: `YYYY-MM`, `YYYY-MM-DD`,
   nome livre, `backlog`, `now|next|later`, épico, custom — IMP-092)
   - front matter `status` do documento (`draft` = gerado para revisão;
     `in-progress` = em andamento; `implemented` = implementado/concluído;
     legados `done`/`concluido` = concluído)
   - linhas de proveniência `>` (incluindo `> Análise: ../../analysis/RN-NNN — <título>/`)
   - seção `## Resumo das tasks` (tabela `| Task | Tipo | Repo | Descrição |`)
   - headings `### RN-NNN-M. [repo] título` (tasks detalhadas)
   - tabela `## Issue principal` (linha `Repositórios` — repos GitHub mapeados
     para a feature)
2. **Legado (fallback, em ordem):** pasta IMP-040
   `<sistema>/delivery/<YYYY-MM>/RN-NNN — <título>/RN-NNN — Analise-Tecnica.md`
   (2 arquivos; front matter `status`, `## Resumo das tasks`, headings,
   `**Rastreamento:**`) → arquivos flat `RN-*.md` (pré-IMP-040 e IMP-034) →
   `<sistema>/delivery/<YYYY-MM>/TASKS*.md` (sprint legado) →
   `<sistema>/delivery/TASKS.md` e `TASKS.md` na raiz do sistema (pré-IMP-034).
   Status é textual (`done`, `feito`, `✅`) ou via issues complementares.
3. **Bloqueios visíveis nos artefatos:** `<sistema>/REQUIREMENTS.md` §11
   (PEND-XXX abertos — sem `[resolvido]` nem `[bloqueado]`).
4. **Issues GitHub (complemento opcional, NUNCA bloqueante):** repos mapeados
   na tabela "Issue principal" (linha `Repositórios`) de cada `— Feature.md`
   (nos legados, de cada Analise-Tecnica), consultados via
   `gh issue list --state all`.

## Gera (downstream)

- Nada — a saída é textual, exibida na sessão. Read-only.

## Nunca edita

- Qualquer artefato de módulo (delivery/, analysis/, specs/, quality/...) — read-only.
- Nunca cria, fecha, comenta ou edita issues (isso é papel da
  `rdd-gh-issue-creator` via `@rdd-github-orchestrator`).
- Nunca commita, pusha ou cria branch.

## Tools

- `glob` (detectar sistemas, grupos de delivery e features; sempre glob recursivo — nunca construir nome, IMP-037)
- `read` (front matter, Resumo das tasks, headings, PENDs)
- `grep` (localizar status, marcadores de conclusão, PEND-XXX)
- `question` (sistema não informado → escolher sistema; agrupar demais decisões, IMP-043)
- `bash` (SOMENTE leitura): `gh issue list/view`, `gh repo view`, `gh auth status`, `git status/log` — nunca comandos de escrita

## Modo de erro

`warn` — fonte ausente ou ilegível (ex.: Feature.md sem tabela de tasks, doc
corrompido) não bloqueia: reporte "dado não disponível" para o sistema/feature
afetada e siga com o resto. `gh` indisponível ou sem auth → pula o
complemento de issues, registra nota de advertência na saída e segue apenas
com o filesystem. Nenhuma condição é `strict` — diagnóstico nunca trava o fluxo.

## Algoritmo

### Passo 1 — Detectar sistemas

`glob` em `<repo-docs>/*/PROJECT_CHARTER.md`. Cada diretório retornado é um
sistema. Zero sistemas → "Nenhum produto RDD encontrado em <repo-docs>.
Execute rdd-project-intake." e pare.

### Passo 2 — Roteamento do escopo (Ambiguidade Zero, IMP-031)

- **Sistema informado de antemão** (no pedido do operador, ex.: "tasks
  pendentes do Salon"): use-o diretamente — SEM perguntar nada.
- **Sistema NÃO informado**: emita UMA `question` ANTES de listar, com:
  (a) cada sistema detectado no Passo 1 como opção individual (com resumo
  curto: nº de features com tasks pendentes e nº de tasks pendentes);
  (b) a opção "Todos os sistemas".
  NUNCA assuma escopo por omissão — inferência por omissão é proibida.
  Agrupe nesta mesma `question` qualquer outra decisão pendente (IMP-043,
  ex.: complemento de issues).

### Passo 3 — Coletar tasks do(s) sistema(s) no escopo

Para cada sistema:

1. **Features IMP-092:** `glob` recursivo em
   `<sistema>/delivery/**/* — Feature.md` (fallback `* — Tasks.md` pré-rename; qualquer profundidade/grupo). Para
   cada arquivo:
   a. Leia o front matter → `status` do documento.
   b. `status` em {`done`, `concluido`, `implemented`} → feature concluída:
      NÃO liste tasks; conte no rodapé como concluída.
   c. Qualquer outro `status` (`draft`, `in-progress`, ...) → leia
      `## Resumo das tasks` (fallback: os headings `### RN-NNN-M.`) e colete:
      ID (RN-NNN-M), Tipo, Repo, Descrição.
   d. Status de conclusão por task, em ordem de precedência:
      i. marcador explícito no doc (`[done]`, `[concluída]`, `✅`) → concluída;
      ii. estado da issue no repo mapeado (Passo 4, se habilitado):
          `closed` → concluída; `open` → em andamento;
      iii. sem marcador e sem issue → PENDENTE (exibida).
2. **Legado:** pasta IMP-040 — `glob` em
   `<sistema>/delivery/*/RN-*/* — Analise-Tecnica.md` (2 arquivos por pasta
   de feature); depois arquivos flat `RN-*.md`, `TASKS*.md` de sprint e
   `TASKS.md` na raiz do sistema. Parseie as tabelas/listas de tasks;
   status textual ou issues complementam; sem registro → pendente.
3. **Bloqueios:** leia `<sistema>/REQUIREMENTS.md` §11; extraia PEND-XXX
   abertos. Destaque os que referenciam features no escopo.

### Passo 4 — Complemento de issues (opcional, não-bloqueante)

Só roda se o operador pedir `--issues` (ou confirmar na `question` do
Passo 2, quando agrupada) E `gh auth status` indicar sessão válida.

1. Derive `org/repo` das linhas `Repositórios` da tabela "Issue principal" de
   cada `— Feature.md` (nos legados, das Analise-Tecnicas; ex.:
   `Acme-Group/Salon-API`).
2. `gh issue list --repo <org/repo> --state all --limit 200 --json number,title,state`.
3. Case cada task ao título da issue pelo token `RN-NNN-M` (e a feature ao
   token `RN-NNN` da issue principal). Não case pelo texto livre.
4. Qualquer falha de gh (não instalado, sem auth, repo inacessível) →
   advertência na saída ("Issues: complemento NÃO aplicado") e segue com
   filesystem. Nunca crie, feche ou comente issues.

### Passo 5 — Montar e exibir a saída

Agrupe por sistema → feature (RN-âncora) → tasks, no template da seção
"Formato de saída". Destaque bloqueios (PEND-XXX) e features afetadas.
Se o escopo foi "Todos os sistemas": repita o bloco por sistema, separado
por `---`, na mesma ordem de detecção do Passo 1.

### Passo 6 — Resumo do rodapé

Por sistema: nº de features com pendência, nº de tasks pendentes/em
andamento, distribuição por repo (ex.: `Salon-API 9 · Salon-FE 5`).

## Formato de saída

```text
═══ rdd-tasks-pending — <sistema> ═══

📍 <sistema> — <N> features pendentes · <M> tasks pendentes/em andamento

[RN-082] Programa de Fidelidade (delivery/2026-09 · doc: draft)
  ⚪ RN-082-1 · Backend   · Salon-API · Migration: configs de fidelidade...
  🟡 RN-082-3 · Backend   · Salon-API · Campos de participação no CRUD (#123 aberta)
  🔴 RN-082-5 · Frontend  · Salon-FE   · Uso de pontos no wizard (bloqueada por PEND-007)
  ...

[RN-074] Lista de Espera (delivery/2026-09 · doc: draft)
  ⚪ RN-074-1 · Backend   · Salon-API · Migration + serviço de fila...

⚠️ Pendências de cliente: PEND-007 (erro 404...) — afeta RN-082
⚠️ Issues: complemento NÃO aplicado (gh indisponível) — estados podem estar defasados

Resumo: Salon-API 9 tasks · Salon-FE 5 tasks
```

Legenda: 🔴 bloqueada (PEND/bloqueado) · 🟡 em andamento (issue aberta ou doc
`in-progress`) · ⚪ pendente (sem registro) · feature concluída aparece só na
contagem.

## Formato de commit

Não se aplica — skill read-only, nunca escreve arquivos nem gera commit.

## Casos de Borda

- **Sistema sem `delivery/`** → "Nenhuma task registrada em delivery/ —
  gere as análises com rdd-task-spec (via @rdd-quality-orchestrator ou rdd-dev)."
- **Feature com doc `done`/`implemented`** → não liste tasks; conte como
  concluída (`draft` e `in-progress` listam tasks).
- **Feature.md sem front matter `status`** → trate como `draft` (tasks
  pendentes) e sinalize na saída (modo `warn`).
- **Task sem issue e sem marcador** → pendente (⚪); nunca presuma conclusão.
- **gh indisponível/sem auth** → nota de advertência; não trate como falha da skill.
- **"Todos os sistemas"** → um bloco por sistema (mesmo template), separado por `---`.
- **Módulo pré-IMP-011** (artefatos na raiz) → aplique fallback de caminhos IMP-011.
- **Nunca construir nome de pasta/arquivo** (IMP-037) → derive sempre de glob
  recursivo; mais de 1 feature com mesmo RN-âncora → pergunte.
- **PEND bloqueando feature** → destaque 🔴 na feature e nas tasks afetadas.
- **Feature com âncora PEND legada (pré-IMP-094)** → legível e listada
  normalmente (glob de leitura mantém `PEND-NNN` como legado); nada gera
  feature PEND — âncora de feature é só RN (IMP-094).
