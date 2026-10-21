---
name: rdd-perf-auditor
description: >-
  Auditoria de performance (read-only, pós-hoc) do runtime OpenCode — mede
  latência por turno, latência de interação user→resposta, context bloat e
  agrega p50/p95/max por dia, agente e modelo a partir do SQLite local.
  OpenCode v2: coleta via `node:sqlite` (scripts/get-perf-metrics-v2.mjs —
  requer Node ≥ 22.5). OpenCode v1: via `opencode db` (fallback —
  scripts/get-perf-metrics.ps1). Gera quality/PERF_REPORT_<timestamp>.md
  e alimenta o `accumulation/metrics/` do pack ativo via rdd-metrics-collector.
  Use quando o
  usuário pedir "auditoria de performance", "latência", "tempo de
  resposta", "context bloat", "mensurar performance", "gap de performance"
  ou "performance do opencode".
---
# rdd-perf-auditor — Auditor de Performance do Runtime OpenCode

Auditoria pós-hoc, read-only, da latência de resposta do OpenCode na
interação com a IA. Lê o SQLite local do OpenCode e detecta gaps de
performance causados por excesso de contexto (context bloat) ou outras
causas.

**Decisão de escopo:** somente skill auditora — **não** existe plugin de
telemetria em tempo real (decisão do usuário) e a skill **nunca** escreve
no `opencode.db`.

## Diferenciação

| Skill | Escopo | Momento |
|-------|--------|---------|
| `rdd-perf-auditor` | Latência do runtime OpenCode (turn_ms, tok_in, context bloat) | Ao suspeitar de lentidão/gap de performance |
| `rdd-metrics-collector` | Métricas de projeto (cobertura, issues, quality gate) | Pós-retrospectiva |
| `rdd-drift-detector` | Degradation temporal da qualidade dos artefatos | Antes de entregas |
| `rdd-agent-health-monitor` | Conformidade de agents/skills (front matter, permissões) | Health check do workflow |
| `rdd-progress` | Progresso do pipeline RDD (cobertura de RNs, fase) | Reunião de status |

## Fonte de dados

**OpenCode v2 (padrão — IMP-104):**

- `~/.local/share/opencode/opencode.db` — SQLite local; schema v2 com as
  tabelas `session_v2` (id, directory, title, agent, model,
  tokens_input/output, time_created, time_updated) e `session_message`
  (session_id, type `user`/`assistant`, time_created, `data` JSON com
  `$.time.created`, `$.time.completed`, `$.tokens.input`,
  `$.tokens.output`, `$.agent`, `$.model`).
- **Acesso exclusivamente leitura** via `node:sqlite` (`DatabaseSync` com
  `{ readOnly: true }`) — script oficial
  `scripts/get-perf-metrics-v2.mjs`. Requer **Node ≥ 22.5**
  (`node --version`).
- O CLI `opencode db` foi **removido no OpenCode v2.0.26** (breaking
  change — evidência: `ERROR Unrecognized flag: --format`). Nunca usá-lo
  no v2.

**OpenCode v1 (fallback — detectar com `opencode --version`):**

- Mesmo banco, schema v1: tabela `message` (`session_id`, `time_created`,
  `data` com `$.role`, `$.time.created`, `$.time.completed`,
  `$.tokens.input`, `$.tokens.output`, `$.modelID`) + `session` (agent).
- Acesso via `opencode db "<SELECT>" --format json` (CLI embutido do v1;
  `sqlite3` externo NÃO está instalado — nunca usá-lo), script
  `scripts/get-perf-metrics.ps1`.

**Detecção de schema:** a presença da tabela `session_v2` indica banco v2;
`message` sem `session_v2` indica v1. O script v2 detecta via
`sqlite_master` e sai com exit 2 orientando o fallback.

**Fatos verificados nesta máquina:**

- TTFT indisponível nos dois schemas (`time.first` null no v1; o v2 não
  expõe) — não usar.
- `session.agent`/`session_v2.agent` é **mutável** em sessão ativa — usar
  `data.agent` da mensagem quando presente (o script v2 faz isso).
- Turno em andamento tem `time.completed` null (filtrar).
- `turn_ms` é wall-clock: inclui tools, subagentes, `question` humano e
  **suspenção de máquina** (evidência: turnos de 12 h com tok_in 0).
- Fonte secundária opcional: `opencode stats --days N` (tokens/custo — só
  contexto qualitativo do relatório).

## Resolução de caminhos (IMP-049)

O PERF_REPORT é telemetria do **domínio do workflow** (não é documentação
de produto nem acúmulo — nunca escrever no `accumulation/` do pack ativo nem
em repos de produto):

- Destino fixo: `~/.config/opencode/quality/PERF_REPORT_<yyyy-MM-dd-hh:mm>.md`
  (ao lado de `WORKFLOW_IMPROVEMENTS.md`)
- **Exceção sandbox de eval:** quando o runner fornece module root, escrever
  em `<sandbox>/quality/` para verificação determinística.

## Lê (upstream)

- `~/.local/share/opencode/opencode.db` (read-only — v2 via `node:sqlite`,
  v1 via `opencode db`)
- `~/.config/opencode/skills/rdd-metrics-collector/SKILL.md` — contrato do
  schema do METRICS.md do acúmulo
- `accumulation/metrics/METRICS.md` do pack ativo (`packs:` do client-profile —
  IMP-061/IMP-111; se existir — alvo do hand-off de append)

## Gera (downstream)

- `~/.config/opencode/quality/PERF_REPORT_<timestamp>.md` (IMP-049)
- Bloco `## Performance do Runtime (OpenCode)` destinado ao
  `accumulation/metrics/METRICS.md` do pack ativo — **entregue via hand-off ao
  `rdd-metrics-collector`**
  (a escrita do METRICS.md é do coletor; ver §Hand-off)

## Nunca edita

- `opencode.db` — **nunca** (sem INSERT/UPDATE/DELETE; o script v2 abre o
  banco com `readOnly: true`, o v1 só faz SELECT via `opencode db`)
- Logs do OpenCode
- `accumulation/metrics/METRICS.md` diretamente (o append é responsabilidade do
  `rdd-metrics-collector`)
- Artefatos de módulo RDD (REQUIREMENTS, DATA_MODEL, TRACEABILITY, etc.)
- Skills, agents e config do OpenCode

## Tools

- `bash` — executa o coletor via Node (v2):
  `node <skills>/rdd-perf-auditor/scripts/get-perf-metrics-v2.mjs --days <N> --out-file <temp>/perf-metrics-v2.json`;
  fallback v1: `powershell -File <skills>/rdd-perf-auditor/scripts/get-perf-metrics.ps1 -Days <N>`
- `read` — `skills/rdd-metrics-collector/SKILL.md`, `accumulation/metrics/METRICS.md` do pack ativo
- `write` — gerar `~/.config/opencode/quality/PERF_REPORT_<timestamp>.md`
- `skill` — invocar `rdd-metrics-collector` para o hand-off
- `question` — confirmar hand-off

## Modo de erro

`warn` — falhas (banco indisponível, script com erro) não bloqueiam o
pipeline: a skill reporta o motivo com mensagem acionável e encerra sem
gerar relatório incompleto. Janela sem dados gera relatório marcado
"sem dados" com veredito `N/A`. Nunca interrompe a sessão. Exit 2 do
script v2 = banco schema v1 → reexecutar com o fallback `.ps1`.

## Thresholds (defaults — ajustáveis na invocação)

| Métrica | ⚠️ Warning | ❌ Crítico |
|---------|-----------|-----------|
| p95 turn_ms (janela/dia) | > 30.000 ms (30 s) | > 120.000 ms (120 s) |
| Sessão context bloat | razão tok_in final/inicial > 3× **E** p95 2ª metade > 2× p95 1ª metade | idem + p95 da sessão > 120 s |
| Sessão contexto runaway (IMP-042) | qualquer turno com tok_in > 200.000 (`--runaway-tok-in`, ajustável) | idem + tok_in > 500.000 em 2+ turnos |
| Latência de interação p95 (user→1ª resposta) | > 30.000 ms | > 120.000 ms |

**Percentis:** nearest-rank — índice = `ceiling(p/100 × N)` sobre o vetor
ordenado ascendente (1-based). SQLite não tem `percentile()`: o cálculo é
sempre feito no script (v2 em JS, v1 em PS1 — determinístico, sem aliases
nativos).

## Formato de commit

```
docs(quality): perf audit <timestamp> — p95 <X>s (<veredito>)
```

## Algoritmo

### Passo 1 — Destino do relatório

Fixo: `~/.config/opencode/quality/PERF_REPORT_<timestamp>.md` (IMP-049 —
domínio do workflow; **não** há descoberta de módulo nem pergunta — a
telemetria do runtime não é artefato de produto). Em sandbox de eval,
usar `<sandbox>/quality/`.

### Passo 2 — Resolver a janela

Parâmetro `--days` (default **7**). O cutoff (epoch ms = agora − N dias)
é calculado dentro do script (`Date.now() − days × 86400000`).

### Passo 3 — Coletar métricas (script auxiliar v2)

Execute o coletor — ele abre o banco read-only (`node:sqlite`), detecta o
schema (v1 vs v2), deduplica forks (IMP-062) e faz todos os cálculos
(turn_ms, interação user→resposta, percentis, agregações, bloat, roll-up):

```bash
node "<skills>/rdd-perf-auditor/scripts/get-perf-metrics-v2.mjs" --days <N> --top-slow 10 --runaway-tok-in 200000 --out-file "<temp>/perf-metrics-v2.json"
```

Critérios verificáveis:

- exit code 0 e `has_data = true` → prossegue para o Passo 4.
- `has_data = false` → Caso de borda "janela vazia" (relatório "sem dados"
  com veredito N/A).
- exit code 2 → banco schema v1 (`message` sem `session_v2`): reexecute
  com o fallback `get-perf-metrics.ps1` (OpenCode v1).
- erro ao abrir o DB (exit ≠ 0) → encerra com `warn` (banco
  indisponível), sem relatório.

Contrato da saída JSON: `generated_at`, `days`, `cutoff_ms`, `source`,
`has_data`, `summary` (turns, sessions, p50_ms, p95_ms, max_ms, verdict,
bloat_sessions, runaway_sessions, insufficient_sessions), `by_day[]`
(day, turns, p50_ms, p95_ms, max_ms, verdict), `by_agent[]` (agent, ...),
`by_model[]` (model, ...), `top_slow[]` (session, agent, model, day,
tok_in, turn_ms + `wall_clock`/`label` quando > 10 min), `context_bloat[]`
(session, turns, tok_in_first, tok_in_last, ratio, p95_early_ms,
p95_late_ms, flag), `context_runaway[]` (session, agent, turns,
turns_over, max_tok_in, flag), `interaction` (samples_first,
p50_first_ms, p95_first_ms, samples_interaction, p50_interaction_ms,
p95_interaction_ms) e `rollup_099` (features, unmapped — IMP-099).

### Passo 4 — Avaliar thresholds

1. Classifique o p95 global e o p95 de cada dia com a tabela de Thresholds
   (`OK` / `WARNING` / `CRITICO`).
2. Marque sessões em `context_bloat` e piores agentes/modelos como
   suspeitos de gap de performance.
3. Cruze: dias `CRITICO` + agente dominante → recomendação direcionada.

### Passo 5 — Gerar o relatório

Monte `quality/PERF_REPORT_<timestamp>.md` com o template abaixo,
convertendo ms → s (1 casa decimal) nas tabelas.

### Passo 6 — Hand-off para rdd-metrics-collector

Gere o bloco no formato do §Hand-off e invoque `rdd-metrics-collector`
via `skill` tool pedindo o append no `accumulation/metrics/METRICS.md` do pack
ativo. Se o coletor não
puder ser invocado, deixe o bloco íntegro dentro do PERF_REPORT e
instrua o usuário a invocá-lo depois.

### Passo 7 — Resumo de saída

Apresente: caminho do relatório, veredito, p50/p95/max, nº de sessões com
context bloat e estado do hand-off (anexado / pendente).

## Queries de coleta (referência v2 — executadas pelo script)

```sql
-- Detecção de schema (v1 vs v2)
SELECT name FROM sqlite_master
WHERE type = 'table' AND name IN ('session_v2', 'message');

-- Sessões (metadados; agent é mutável — só fallback)
SELECT id, directory, title, agent, model, tokens_input, tokens_output,
       time_created, time_updated
FROM session_v2;

-- Mensagens da janela (data é JSON — parse no script)
SELECT session_id, type, time_created, data
FROM session_message
WHERE type IN ('user', 'assistant')
  AND time_created >= :cutoff_ms   -- epoch ms = agora − days × 86400000
ORDER BY session_id, time_created;
```

- `assistant` sem `data.time.completed` é turno em andamento — filtrado.
- Dedupe de forks pela assinatura `t_created|t_completed|type` (IMP-062).
- Agente do turno = `data.agent` quando presente; senão
  `session_v2.agent`.
- (O SQL v1 de referência permanece documentado no próprio
  `get-perf-metrics.ps1`.)

## Script auxiliar v2 — scripts/get-perf-metrics-v2.mjs

- **Interface:** `node get-perf-metrics-v2.mjs [--days 7] [--top-slow 10]
  [--runaway-tok-in 200000] [--out-file <path>]` (default do out-file:
  `<os.tmpdir()>/perf-metrics-v2.json` — `%TEMP%` com fallback
  `os.tmpdir()`).
- **Faz:** `node:sqlite` `DatabaseSync { readOnly: true }` → detecção de
  schema → SELECT (apenas) → parse do JSON `data` → dedupe IMP-062 →
  turn_ms por turno → interação user→resposta → percentis nearest-rank →
  agregações por dia/agente/modelo → top-N lentos → bloat/runaway →
  roll-up heurístico IMP-099 → JSON no `--out-file` (UTF-8 sem BOM) +
  resumo no stdout.
- **Invariantes (obrigatórios):** read-only absoluto (nunca abrir sem
  `readOnly: true`; nenhum comando de escrita no script); percentis
  nearest-rank; turnos sem `completed` filtrados; bloat só em sessões
  com ≥ 4 turnos; sessões não mapeadas contadas e nunca atribuídas
  (IMP-099); outlier > 10 min etiquetado wall-clock; saída UTF-8 sem
  BOM; sem paths de máquina hardcoded (IMP-016); requer Node ≥ 22.5.
- **Fórmulas:**
  - `turn_ms = data.time.completed − data.time.created` (assistant;
    null/negativos descartados)
  - `first_response_ms = t_completed do primeiro assistant concluído com
    t_completed ≥ user.t_created − user.t_created` (latência até a
    **CONCLUSÃO** da 1ª resposta — IMP-104; o marcador de início de
    turno, usado pelo coletor emergencial, não tem valor analítico)
  - `interaction_ms = t_completed do último assistant concluído antes do
    próximo user − user.t_created`
  - razão tok_in = `tok_in(último turno) / tok_in(primeiro turno)` da
    sessão (≥ 4 turnos; primeiro = 0 → N/A)
  - flag bloat = razão > 3 **E** `p95(2ª metade) > 2 × p95(1ª metade)`
  - runaway (IMP-042) = qualquer turno da sessão com
    `tok_in > --runaway-tok-in` (default 200.000); `turns_over` = nº de
    turnos acima do limite, `max_tok_in` = pico
  - veredito = p95 > 120.000 → `CRITICO`; > 30.000 → `WARNING`; senão `OK`

## Fallback v1 — scripts/get-perf-metrics.ps1

- Mantido para quem roda **OpenCode v1** (detectar:
  `opencode --version`; ou banco com tabela `message` e sem
  `session_v2` — o script v2 avisa com exit 2).
- **Interface:** `param([int]$Days = 7, [int]$TopSlow = 10,
  [int]$RunawayTokIn = 200000, [string]$OutFile = "")`
- **Faz:** `opencode db` (SELECT apenas) → mesmo pipeline de cálculo →
  mesmo contrato JSON (sem `rollup_099` — o roll-up é montado pela skill).
- **Disciplina de código (obrigatória):** PowerShell 5.1; somente cmdlets
  com **nome completo** (`Get-Content`, `Sort-Object`, `Where-Object`,
  `ForEach-Object`, `Set-Content`) — **proibido aliases nativos** (`ri`,
  `rd`, `gc`, `iex`, `select`, `sort`, `where`, `foreach`): colisão de
  alias com cmdlets destrutivos apaga arquivos. Sem `Invoke-Expression`.
  Sem paths de máquina hardcoded (portabilidade — IMP-016).

## Agregação por Feature/Primary (heurística — IMP-099)

Roll-up de tempo (turn_ms) e tokens (tok_in/tok_out) por **feature**
(RN-âncora), por **primary** e por **tier de modelo**:

1. **Join heurístico sessão ↔ módulo/feature:** mapeie cada sessão para um
   módulo/feature pelo diretório de trabalho da sessão e/ou palavras do
   título (ex.: título contém `RN-012` ou o nome do diretório do módulo).
   Sessões com mais de um módulo no histórico entram na feature dominante
   (mais turnos).
2. **Roll-up:** soma e média de turn_ms e tokens das sessões mapeadas,
   por feature, por primary e por tier de modelo.
3. **Sessões não mapeadas:** EXCLUÍDAS do roll-up e contadas na linha
   `sessões não mapeadas: N` — nunca atribuídas por chute.

**Invariante (IMP-099):** o join é heurístico e a métrica é aproximada —
declare isso explicitamente no cabeçalho da seção do relatório e no
hand-off para o `rdd-metrics-collector`. Nenhuma sessão é atribuída a uma
feature sem evidência de diretório/título.

Seção no PERF_REPORT (quando houver sessões mapeadas):

```markdown
## Roll-up por Feature/Primary (aproximado — join heurístico, IMP-099)

| Feature/RN | Sessões | Turnos | Σ turn_ms | Σ tokens | p95 (s) |
|------------|---------|--------|-----------|----------|---------|

> Sessões não mapeadas: N (excluídas do roll-up — contadas, nunca atribuídas).
```

## Template — PERF_REPORT_<timestamp>.md

```yaml
---
project: WORKFLOW_RUNTIME
module: perf-report
audience: [governanca, tecnica]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
window_days: <N>
---
```

```markdown
# Perf Report — Runtime OpenCode

> **Gerado em:** DD/MM/AAAA HH:MM
> **Janela:** últimos N dias
> **Fonte:** opencode.db (read-only) — N turnos, M sessões
> **Veredito:** ✅ OK | ⚠️ WARNING (p95 > 30s) | ❌ CRÍTICO (p95 > 120s)

---

## Resumo Executivo

| Métrica | Valor |
|---------|-------|
| Turnos analisados | N |
| Sessões | N |
| p50 turn_ms | X,X s |
| p95 turn_ms | X,X s |
| Max turn_ms | X,X s |
| Sessões com context bloat | N |
| Sessões com contexto runaway | N |
| p95 user→1ª resposta | X,X s |
| Veredito | ✅/⚠️/❌ |

---

## Latência por Dia

| Dia | Turnos | p50 (s) | p95 (s) | Max (s) | Veredito |
|-----|--------|---------|---------|---------|----------|

## Latência por Agente

| Agente | Turnos | p50 (s) | p95 (s) | Max (s) | Veredito |
|--------|--------|---------|---------|---------|----------|

## Latência por Modelo

| Modelo | Turnos | p50 (s) | p95 (s) | Max (s) | Veredito |
|--------|--------|---------|---------|---------|----------|

## Top-10 Turnos Mais Lentos

| # | Sessão | Agente | Modelo | Dia | tok_in | turn_ms | turn (s) | Nota |
|---|--------|--------|--------|-----|--------|---------|----------|------|

## Context Bloat (sessões candidatas)

| Sessão | Turnos | tok_in 1º | tok_in último | Razão | p95 1ª met. (s) | p95 2ª met. (s) | Flag |
|--------|--------|-----------|---------------|-------|-----------------|-----------------|------|

### Contexto Runaway (tamanho absoluto — IMP-042)

Sessões com qualquer turno cujo `tok_in` exceda `--runaway-tok-in`
(default 200.000). Diferente do bloat (que mede *crescimento*), runaway
detecta contexto gigante estático (herdado/importado/comprometido desde o
1º turno). Contexto por turno nunca deveria exceder a casa das dezenas de
k tokens — acima disso, a sessão provavelmente carrega contexto viciado
(import de sessão antiga, output de tool gigante acumulado).

| Sessão | Agente | Turnos | Turnos > limite | Max tok_in |
|--------|--------|--------|-----------------|------------|

## Latência de Interação (user → resposta)

| Métrica | p50 (s) | p95 (s) | Amostras |
|---------|---------|---------|----------|
| 1ª resposta | | | |
| Conclusão do turno | | | |

## Recomendações

| Prioridade | Achado | Ação sugerida |
|------------|--------|---------------|

## Metodologia e Limitações

- Roll-up por feature/primary é join heurístico — métrica aproximada; sessões não mapeadas excluídas e contadas (IMP-099).
- Percentis nearest-rank; turnos com `time.completed = null` (em
  andamento) filtrados.
- TTFT não é medido em nenhum schema (`time.first` null no v1; o v2 não
  expõe) — limitação da fonte.
- "1ª resposta" = latência até a CONCLUSÃO da 1ª resposta (IMP-104).
- Context bloat avaliado apenas em sessões com ≥ 4 turnos concluídos.
- `session.agent`/`session_v2.agent` é mutável — o breakdown por agente
  usa `data.agent` da mensagem quando presente; ao comparar execuções,
  compare agregados globais primeiro.
- Leitura read-only; nenhum dado é gravado no opencode.db.
- **`turn_ms` é wall-clock de turno, não latência pura do modelo:**
  inclui execução de tools, rodadas de subagente (`task`), esperas do
  `question` tool (humano) e suspensão da máquina (evidência: turnos de
  12 h com tok_in 0). Antes de classificar um outlier como gap de
  performance, verifique se o turno não contém subagente/tarefa longa
  legítima.
```

## Hand-off com rdd-metrics-collector (contrato)

O schema do METRICS.md é de propriedade do `rdd-metrics-collector`
(nunca duplicá-lo nesta skill). O destino do arquivo é o
`accumulation/metrics/` do pack ativo da organização (ex.:
`packs/<pack-ativo>/accumulation/metrics/` — resolução via `packs:` do
client-profile, bloco `rdd-pack-accumulation` do AGENTS.md; nunca
`~/.config/opencode/` — IMP-061/IMP-111). O perf-auditor produz o bloco
pronto e delega o append via `skill` tool:

```markdown
## Performance do Runtime (OpenCode)

| Data | Janela (dias) | Turnos | p50 (s) | p95 (s) | Max (s) | Bloat | Veredito |
|------|---------------|--------|---------|---------|---------|-------|----------|
| DD/MM/AAAA | 7 | N | X,X | X,X | X,X | N | ✅/⚠️/❌ |
```

Regras do append (a cargo do coletor):

1. Se a seção `## Performance do Runtime (OpenCode)` não existe → criar
   ao final do `accumulation/metrics/METRICS.md` do pack ativo.
2. Se existe → adicionar nova linha na tabela (histórico crescente;
   nunca reescrever linhas antigas).
3. Preservar intactas todas as outras seções do METRICS.md.
4. Coletor indisponível → o bloco permanece no PERF_REPORT e o usuário é
   instruído a invocar `rdd-metrics-collector` depois.

## Casos de Borda

- **Banco indisponível / DB inexistente:** `warn` — erro acionável do
  script (exit 1; verificar se o OpenCode está instalado/executado ao
  menos uma vez), não gera relatório.
- **Banco schema v1 (`message` sem `session_v2`):** o script v2 sai com
  exit 2 e orienta o fallback `get-perf-metrics.ps1` (OpenCode v1;
  detectar com `opencode --version`). O inverso — script v1 contra
  OpenCode v2 — falha com `ERROR Unrecognized flag: --format`: sinal de
  que é hora de migrar para o `.mjs`.
- **Node < 22.5 (sem `node:sqlite`):** `node --version`; atualizar o Node
  ou, em OpenCode v1, usar o fallback `.ps1`.
- **Janela sem dados (0 turnos):** gere relatório marcado "sem dados na
  janela — aumente --days" com veredito `N/A`.
- **Turno em andamento** (`time.completed` null/ausente): filtrado da
  análise.
- **TTFT (`time.first`):** não é medido em nenhum schema — documentado
  nas limitações.
- **`session.agent` null:** agrupar como `desconhecido`.
- **`session.agent` é mutável em sessão ativa (v1 e v2):** o OpenCode
  pode reescrever a coluna `agent` da sessão entre execuções — turnos
  realocam de agente e o breakdown `by_agent` é volátil para sessões em
  andamento. No v2 o script usa `data.agent` da mensagem quando presente.
  Agregados globais (p50/p95/max/veredito) permanecem estáveis; ao
  comparar duas execuções, compare sempre os agregados globais primeiro.
- **`tok_in` 0/null no primeiro turno:** razão de bloat = N/A; flag de
  latência isolada entra como "latência cresceu sem base de tokens".
- **Sessão com < 4 turnos:** context bloat não avaliado ("amostra
  insuficiente" — contabilizada em `insufficient_sessions`, não listada
  como suspeita).
- **Múltiplos módulos:** irrelevante — o relatório é do runtime (destino
  fixo no domínio do workflow, IMP-049); não há escolha de módulo.
- **Sessão atual em andamento:** último turno pode faltar — ok, filtrado
  pelo `completed`.
- **Outlier extremo (turn_ms > 10 min):** wall-clock inflado — provável
  `question`/`task` longo ou suspensão de máquina (evidência: turnos de
  12 h com tok_in 0), não latência de modelo. O script etiqueta
  (`wall_clock` + `label`); listar com a etiqueta "wall-clock inflado
  (verificar causa)" em vez de crítico direto; o veredito crítico só vale
  para o p95 da janela/dia.
- **Volume grande (dezenas de milhares de linhas):** o script agrega em
  memória; nunca despeje rows brutos no contexto da conversa — passe
  apenas o JSON agregado.
- **Alias PowerShell:** proibido no script v1 e em qualquer comando
  derivado (ver §Fallback v1) — colisão de alias com cmdlets destrutivos.
- **Sessão sem diretório/título mapeável (IMP-099):** entra na linha
  `sessões não mapeadas` — contada, nunca atribuída a feature.
