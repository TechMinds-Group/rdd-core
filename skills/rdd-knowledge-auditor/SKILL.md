---
name: rdd-knowledge-auditor
description: >-
  Auditoria do PAR de métricas de conhecimento (P-09) do runtime OpenCode —
  hit rate de conhecimento + tokens de conhecimento por tarefa — em MODO
  DEGRADADO: denominadores são PROXY (heurística de globs sobre tool calls
  read/grep/glob no opencode.db), não medida calibrada (calibração Jev =
  Fase 5 futura — plano v5 D12/D15/D17). Métricas global, por store
  (T1/T2/T3) e por modelo (P-11); acumula linha "Knowledge Hit Rate" no
  METRICS.md do pack ativo (merge incremental — nunca sobrescreve
  histórico). Base de fundação: knowledge/knowledge-management/KNOWLEDGE.md
  (v1.5.0). Use quando o usuário pedir "auditoria de conhecimento", "hit
  rate de conhecimento", "tokens de conhecimento por tarefa", "auditar
  consumo de conhecimento" ou "baseline do par de métricas (P-09)".
---
# rdd-knowledge-auditor — Auditor do Par de Métricas de Conhecimento (P-09, modo degradado)

Mede o **PAR de métricas** do princípio P-09 da base de conhecimento
(`knowledge/knowledge-management/KNOWLEDGE.md` v1.5.0 — Lê upstream): **(1)
hit rate** — fração de tarefas que de fato carregaram conhecimento
relevante — e **(2) tokens de conhecimento por tarefa** — quanto custa
acertar. Instrumentação barata PRECEDE decisão de infraestrutura (D8 do
plano v5).

**MODO DEGRADADO — caminho primário (D12):** denominadores são **PROXY**
(heurística de globs), não medida calibrada. Esta declaração é obrigatória
nesta skill e em **todo relatório gerado**. A calibração Jev (classificadores
`Noul`/relevância — D15) é variante FUTURA da Fase 5, condicionada ao
baseline de ≥ 2 ciclos (D17). O que o core aberto usa não pode apodrecer —
por isso o eval com golden é obrigatório.

**Decisão de escopo:** skill auditora read-only sobre o banco — **nunca**
escreve no `opencode.db`. Diferente do `rdd-perf-auditor` (que delega o
append ao `rdd-metrics-collector`), esta skill **grava diretamente** o merge
no METRICS.md do pack (contrato do plano v5, §6), com disciplina de merge
incremental.

## Diferenciação

| Skill | Escopo | Momento |
|-------|--------|---------|
| `rdd-knowledge-auditor` | PAR P-09: hit rate + tokens de conhecimento por tarefa (proxy de globs) | Ciclo mensal de métricas (§5 Governança do plano v5) ou "o roteamento de conhecimento funciona?" |
| `rdd-perf-auditor` | Latência do runtime (turn_ms, bloat, p50/p95) | Suspeita de lentidão/gap de performance |
| `rdd-metrics-collector` | Métricas de projeto (cobertura, issues, quality gate) | Pós-retrospectiva |
| `rdd-drift-detector` | Degradação temporal dos artefatos RDD | Antes de entregas |
| `rdd-agent-health-monitor` | Conformidade de agents/skills da config | Health check do workflow |

## Fonte de dados

`~/.local/share/opencode/opencode.db` — SQLite local, leitura **exclusivamente
read-only** via `node:sqlite` (`DatabaseSync` com `{ readOnly: true }`;
requer **Node ≥ 22.5**). Precedente e padrão de acesso: `rdd-perf-auditor`
(scripts/get-perf-metrics-v2.mjs). O CLI `opencode db` foi removido no
OpenCode v2.0.26 — nunca usá-lo.

**Schema descoberto nesta instalação (2026-10-21):**

- `session_v2` (id, directory, title, agent, `model` TEXT-JSON
  `{"id","providerID","variant"}`, tokens_*, time_created, time_updated, …).
- `session_message` (id, session_id, type, seq, time_created, time_updated,
  `data` JSON). Tipos: `assistant`, `user`, `idle`, `system`, `synthetic`,
  `agent-switched`, `model-switched`, `compaction`.
- **Tool calls NÃO têm tabela própria**: vivem como blocos
  `data.content[].type='tool'` das mensagens `assistant` (schema nova —
  sem `parts`), cada bloco com `{id, name, executed, state:{status:
  'running'|'completed'|'error', input:{...}}}`:
  - `read` → `state.input.path`
  - `grep` → `state.input.path` (opcional) + `pattern`
  - `glob` → `state.input.path` (opcional) + `pattern`
- `data.model` do assistant = objeto `{id, providerID, variant}` (o mesmo
  JSON serializado como string em `session_v2.model`).

Se o schema não expuser tool calls/paths (versão futura diferente), degradar
para o proxy mais próximo disponível e **documentar o limite** — nunca
inventar números.

## Heurística degradada (PROXY declarado em todo lugar)

| Conceito | Proxy (glob) | Limite declarado |
|----------|--------------|------------------|
| Sessão que **precisava** de conhecimento | ≥ 1 tool call de leitura (read/grep/glob, status `completed`) com path em artefato T4 de engenharia: segmento `specs/`, `analysis/`, `delivery/` ou arquivo `REQUIREMENTS.md` (qualquer módulo sob o diretório de projetos) | Necessidade real de conhecimento não é observável — é inferência de atividade |
| **Hit** de conhecimento | tool call de leitura com path em `knowledge/**` (T1), `patterns/INDEX.md` ou `**/PATTERN.md` (T2), `rules/**.md` (T3) | Acionamento do bloco `knowledge-routing` em prosa NÃO é observável no db; `rules/*.yaml` e invocações da tool `skill` não contam |
| **Tokens de conhecimento por tarefa** | soma aproximada (bytes/4, ASCII) dos arquivos de conhecimento LIDOS (tool `read`) por sessão ÷ sessões que precisavam | Tamanho no disco HOJE (não no momento da leitura); leitura parcial (offset/limit) conta como arquivo inteiro; 1ª leitura por sessão+arquivo |

Regras de contagem:

- Só tool calls com `state.status='completed'` (running/error fora —
  contados como `blocks_skipped_status`).
- Dedupe de forks pela assinatura `t_created|block_id` (análogo IMP-062).
- grep/glob sem `path` → contador `unclassified_paths` (nunca classificar
  por chute).
- Hit rate global = sessões que precisavam **E** tiveram hit ÷ sessões que
  precisavam (mantém o rate em [0,100%] — hits fora de contexto que precisava
  são contados à parte como `sessions_hit_outside`, sinal de roteamento sem
  demanda observável).
- Sobreposição rara de stores (path casa 2 globs) resolve por prioridade
  T1 > T2 > T3.
- Modelo por sessão: `session_v2.model` normalizado ao `id`
  (`{"id","providerID"}` → `id`); null → `desconhecido`. Sessões
  multi-modelo são limite declarado (o OpenCode reescreve o modelo da
  sessão — ver rdd-perf-auditor §Casos de Borda).

## Lê (upstream)

- `~/.local/share/opencode/opencode.db` (read-only — v2 via `node:sqlite`)
- `knowledge/knowledge-management/KNOWLEDGE.md` — **base de fundação do
  domínio** (v1.5.0): P-09 (par de métricas), P-10 (granularidade), P-11
  (hit rate por modelo), AP-11 (biblioteca morta), AP-13 (gatilho otimista)
  — fonte canônica de critérios de interpretação
- `packs/<pack>/accumulation/knowledge/plano-arquitetura-conhecimento-rdd.md`
  — plano v5 (D8/D12/D15/D17/D18, §6 spec desta skill)
- `packs/<pack>/accumulation/metrics/METRICS.md` — alvo do merge incremental
- `~/.config/opencode/skills/rdd-perf-auditor/SKILL.md` — precedente do
  padrão de acesso ao db

## Gera (downstream)

- `packs/<pack>/accumulation/metrics/KNOWLEDGE_AUDIT_<yyyy-MM-dd-HHmm>.md`
  — relatório completo (declaração PROXY, contadores, hit rate global/por
  store/por modelo, tokens/tarefa, metodologia)
- Linha acumulada na seção `## Knowledge Hit Rate` do
  `packs/<pack>/accumulation/metrics/METRICS.md` — **merge incremental**:
  cria a seção (cabeçalho + tabela) se não existir; senão insere a linha
  após a última da tabela; **nunca** reescreve/apaga histórico
- `scripts/get-knowledge-metrics-v2.mjs` — coletor (JSON agregado +
  relatório + merge; interface abaixo)

## Nunca edita

- `opencode.db` — **nunca** (sem INSERT/UPDATE/DELETE/DDL; o coletor abre
  com `readOnly: true`)
- `knowledge/**` (bases T1 — inclusive as nuances do pack)
- Artefatos de módulo RDD (REQUIREMENTS, DATA_MODEL, TRACEABILITY, etc.)
- Skills, agents e config do OpenCode
- Seções pré-existentes do METRICS.md (merge é apenas inserir linha/criar
  seção nova)

## Tools disponíveis

- `bash` — executa o coletor:
  `node <skills>/rdd-knowledge-auditor/scripts/get-knowledge-metrics-v2.mjs --days <N>`
  (defaults escrevem relatório + merge no pack ativo resolvido do
  `pack_ativo` do AGENTS.md)
- `read` — KNOWLEDGE.md da fundação, plano v5, METRICS.md do pack
- `question` — confirmar parâmetros não default (janela, db alternativo)
- `skill` — invocar `rdd-progress`/`rdd-perf-auditor` quando o operador
  quiser cruzar com outras telemetrias (opcional)

## Modo de erro

`warn` — banco ausente, ilegível ou schema incompatível **não bloqueiam**:
o coletor emite o código de erro (`DB_MISSING`, `DB_UNOPENABLE`,
`SCHEMA_V1`, `SCHEMA_UNKNOWN`), gera relatório com o erro **declarado**,
contadores **zerados explícitos** e métricas **N/A** ("sem dados") — nunca
números inventados — e **não faz merge** no METRICS.md. Janela sem dados
(0 sessões observáveis) segue o mesmo caminho. Exit 0 em todos esses casos;
exit 1 só para uso incorreto do script. Nunca interrompe a sessão.

## Formato de commit

```
docs(metrics): knowledge audit <yyyy-MM-dd HH:mm> — hit rate <X>% (<veredito>)
```

## Algoritmo

### Passo 1 — Confirmar parâmetros

Janela (`--days`, default **7** — como perf-auditor), db (default
`~/.local/share/opencode/opencode.db`). Defaults escrevem no pack ativo
resolvido do `pack_ativo` do AGENTS.md (fallback `<pack-ativo>`). Use `question`
apenas se o operador pediu algo não default.

### Passo 2 — Rodar o coletor

```bash
node "<skills>/rdd-knowledge-auditor/scripts/get-knowledge-metrics-v2.mjs" --days 7
```

Critérios verificáveis: stdout traz a linha
`sessões=<N> precisavam=<N> hit=<N> rate=<X>% tokens/tarefa=<X>` e os
caminhos de relatório/merge. `AVISO (warn…)` + "sem dados" = Caso de borda
(banco/schema) — o relatório de erro já foi gerado; apresente e encerre.

### Passo 3 — Interpretar contra a fundação (P-09/P-11/AP-11/AP-13)

- Hit rate baixo com store existente → suspeita de **biblioteca morta**
  (AP-11) ou **gatilho otimista** para o modelo em uso (AP-13/P-11) —
  compare o rate POR MODELO antes de concluir.
- `sessions_hit_outside` alto → roteamento acionando sem demanda T4
  observável (revisar gatilhos).
- Tokens/tarefa crescente com hit rate estável → granularidade (AP-12/P-10)
  — candidato a split de base (Fase 4 do plano v5, condicionada ao baseline).
- **Nunca decida infraestrutura com menos de 2 ciclos medidos (D17).**

### Passo 4 — Apresentar o resultado

Caminho do relatório, linha acumulada no METRICS.md, hit rate global e por
modelo, tokens/tarefa, e o lembrete obrigatório: **denominadores são PROXY**
(modo degradado; calibração Jev = Fase 5, condicionada ao baseline D17).

## Script auxiliar — scripts/get-knowledge-metrics-v2.mjs

- **Interface:** `node get-knowledge-metrics-v2.mjs [--days 7] [--db <path>]
  [--out-file <path>] [--report-file <path>|none] [--metrics-file <path>|none]`
  (defaults: db do homedir; JSON em `<tmp>/knowledge-metrics-v2.json`;
  relatório `KNOWLEDGE_AUDIT_<ts>.md` + merge no METRICS.md do pack ativo).
- **Faz:** abre o banco read-only → detecção de schema → SELECT (apenas)
  das mensagens assistant da janela → extrai blocos tool read/grep/glob
  `completed` → dedupe forks → classifica paths pelos globs PROXY → agrega
  (global, por store, por modelo, por dia) → estima tokens (stat bytes/4)
  → escreve JSON + relatório + merge no METRICS.md (somente com dados).
- **Invariantes (obrigatórios):** read-only absoluto; nunca inventar números
  (erro ⇒ contadores zerados + N/A); nenhum `%` em relatório sem dados;
  nenhum merge sem dados; dedupe `t_created|block_id`; apenas status
  `completed`; sem paths de máquina hardcoded (IMP-016); UTF-8 sem BOM;
  requer Node ≥ 22.5.

## Template — KNOWLEDGE_AUDIT_<timestamp>.md

```markdown
# Knowledge Audit — Hit Rate + Tokens de Conhecimento (MODO DEGRADADO)

> **Gerado em:** DD/MM/AAAA
> **Janela: últimos N dias**
> **Fonte:** opencode.db v2 (read-only)
> **Modo:** DEGRADADO — denominadores são PROXY (heurística de globs)

## Declaração PROXY (obrigatória)
<as 4 declarações — heurística de globs, limite do routing em prosa, bytes/4, Fase 5>

## Contadores brutos
| Contador | Valor |  (sessões observáveis/precisavam/com hit, hits, reads T4, unclassified, skipped status, unstatable)

## Hit Rate Global
| Hit rate global | X.X% (hits/necessitantes) |
| Tokens de conhecimento por tarefa (média) | X.X |
| Tokens de conhecimento (total da janela) | X.X |

## Hit Rate por Store
| Store | Local | Hits | Sessões com hit |  (T1 knowledge/** · T2 patterns/INDEX.md + **/PATTERN.md · T3 rules/**.md)

## Hit Rate por Modelo (P-11)
| Modelo | Sessões que precisavam | Sessões com hit | Hit rate | Tokens | Tokens/tarefa |

## Tokens de Conhecimento por Tarefa (P-09)

## Janela por Dia

## Metodologia e Limitações
```

## Linha acumulada no METRICS.md (contrato de merge)

Seção `## Knowledge Hit Rate` (criada se ausente, ao final do arquivo, com
a nota de fonte e o cabeçalho abaixo); se existente, nova linha após a
última da tabela — **histórico crescente, nunca reescrito**:

```markdown
| Data | Janela (dias) | Sessões que precisavam | Sessões com hit | Hit rate global | Hits fora de contexto | Tokens conhecimento/tarefa | Modelos |
|------|---------------|------------------------|-----------------|-----------------|-----------------------|----------------------------|---------|
| DD/MM/AAAA | N | N | N | X.X% | N | X.X | N |
```

Preservar intactas todas as outras seções do METRICS.md. Relatório "sem
dados" **nunca** faz merge.

## Ciclo de baseline (plano v5 — Fase 3)

1. **Ciclo 1:** rode a skill com a janela do período (ex.: `--days 7`);
   anote a linha do METRICS.md.
2. **Ciclo 2:** após ~1 semana de uso normal do workflow, rode de novo.
3. Com 2 linhas acumuladas, o **baseline do par de métricas** está
   publicado — é ele que decide (D17) se as Fases 4 (split de base) e 5
   (calibração Jev ponto a ponto) têm gap que justifique ativação.
4. Frequência de regime: par de métricas **mensal** (§5 Governança do
   plano v5).

## Casos de Borda

- **Banco ausente / ilegível / schema v1 ou desconhecido:** warn —
  relatório de erro ("sem dados", contadores zerados, `Hit rate: N/A`,
  nenhum `%`), sem merge. SCHEMA_V1 orienta migrar para OpenCode v2.
- **Janela vazia (0 sessões observáveis):** idem — "sem dados", N/A,
  sem merge.
- **grep/glob sem `path` no input:** contador `unclassified_paths` — nunca
  classificar por chute.
- **Arquivo de conhecimento apagado/renomeado desde a leitura:** stat falha
  → `files_unstatable`, custo 0 — contado, nunca estimado.
- **Sessão multi-modelo (troca via `model-switched`):** o modelo usado é o
  de `session_v2.model` (último estado) — limite declarado; comparar
  agregados globais primeiro.
- **Forks de sessão:** dedupe por `t_created|block_id` evita dupla contagem.
- **Leitura parcial (offset/limit):** coletor não distingue — conta arquivo
  inteiro (superestima; P-10 — limite declarado).
- **`rules/*.yaml` e invocações de skill que carregam conhecimento:** não
  observáveis como hit — limite declarado.
- **Bloco `knowledge-routing` acionado em prosa (sem tool call):**
  invisível para este auditor — por isso o modo é PROXY (Fase 5 = Jev).
- **Node < 22.5 (sem `node:sqlite`):** atualizar o Node (ver `node --version`).
- **Volume grande de mensagens:** o coletor agrega em memória; nunca despeje
  rows brutos no contexto — passe apenas o resumo/JSON.
- **Alias PowerShell:** proibido em comandos derivados (colisão com cmdlets
  destrutivos).
