---
project: WORKFLOW_RUNTIME
module: knowledge-audit
audience: [governanca, tecnica]
status: draft
generated_at: "2026-10-22T02:22:05.600Z"
window_days: 3650
mode: degradado-proxy
---

# Knowledge Audit — Hit Rate + Tokens de Conhecimento (MODO DEGRADADO)

> **Gerado em:** 21/10/2026  
> **Janela: últimos 3650 dias**  
> **Fonte:** opencode.db v2 (session_v2 + session_message, read-only)  
> **Modo:** DEGRADADO — denominadores são PROXY (heurística de globs), não medida calibrada (P-09; plano v5 D8/D12/D15/D17).

## Declaração PROXY (obrigatória — modo degradado)

- **"Sessão que precisava de conhecimento"** = sessão com >= 1 tool call de leitura (read/grep/glob) em artefato T4 de engenharia (`specs/**`, `analysis/**`, `delivery/**`, `REQUIREMENTS.md`) — **PROXY** (heurística de globs), não medida calibrada.
- **"Hit de conhecimento"** = tool call de leitura com path em `knowledge/**` (T1), `patterns/INDEX.md` ou `**/PATTERN.md` (T2), `rules/**.md` (T3) — **PROXY**. Limite declarado: acionamento do bloco `knowledge-routing` em prosa NÃO é observável no db.
- **"Tokens de conhecimento por tarefa"** = soma aproximada (bytes/4, ASCII) dos arquivos de conhecimento LIDOS (tool read) por sessão dividido pelas sessões que precisavam — **PROXY**: tamanho no disco HOJE; leitura parcial (offset/limit) conta como arquivo inteiro; 1ª leitura por sessão+arquivo apenas.
- Calibração Jev (classificadores Noul/relevância) = Fase 5 futura — D12/D15/D17 do plano v5. Este modo degradado é o caminho primário e é o baseline (P-09: instrumentação antes de decisão de infra).

## Contadores brutos

| Contador | Valor |
|----------|-------|
| Sessões observáveis (>= 1 read/grep/glob concluído) | 5 |
| Sessões que precisavam (T4 — PROXY) | 2 |
| Sessões que precisavam E tiveram hit | 1 |
| Sessões com hit FORA de contexto que precisava | 2 |
| Hits de conhecimento (tool calls) | 4 |
| Leituras T4 (calls que marcaram necessidade) | 3 |
| Leituras read em conhecimento (custo de tokens) | 3 |
| Calls grep/glob sem path (não classificáveis — contados, nunca inventados) | 0 |
| Blocos tool ignorados por status (running/error) | 1 |
| Arquivos de conhecimento não statáveis no disco (custo 0) | 0 |

## Hit Rate Global

| Métrica | Valor |
|---------|-------|
| Hit rate global | 50% (1/2) |
| Tokens de conhecimento por tarefa (média) | 75 |
| Tokens de conhecimento (total da janela) | 150 |

## Hit Rate por Store

| Store | Local | Hits | Sessões com hit |
|-------|-------|------|-----------------|
| T1 | knowledge/** (bases de domínio + nuances do pack) | 2 | 2 |
| T2 | patterns/INDEX.md + **/PATTERN.md (acúmulo da org) | 2 | 1 |
| T3 | rules/**.md (rules lazy) | 0 | 0 |

Hits por tool: read = 3 · grep = 0 · glob = 1

## Hit Rate por Modelo (P-11)

| Modelo | Sessões que precisavam | Sessões com hit | Hit rate | Tokens conhecimento | Tokens/tarefa |
|--------|------------------------|-----------------|----------|---------------------|---------------|
| modelA | 1 | 1 | 100% | 150 | 150 |
| modelB | 1 | 0 | 0% | 0 | 0 |
| modelC | 0 | 0 | N/A | 0 | N/A |

## Tokens de Conhecimento por Tarefa (P-09)

- Média da janela: **75** tokens de conhecimento por tarefa que precisava (PROXY bytes/4).
- Sessões com hit fora de contexto que precisava: 2 (ses_cccc3333, ses_eeee5555) — roteamento acionado sem demanda T4 observável.

## Janela por Dia

| Dia | Hits | Leituras T4 |
|-----|------|-------------|
| 2026-10-22 | 4 | 3 |

## Metodologia e Limitações

- Fonte: opencode.db v2 — tool calls vivem como blocos `content[].type='tool'` no `data` das mensagens assistant (sem tabela própria; schema descoberta 2026-10-21).
- Só tool calls `read`/`grep`/`glob` com `state.status = 'completed'` contam; running/error ignorados (contados).
- Dedupe de forks pela assinatura `t_created|block_id` (análogo IMP-062).
- Modelo por sessão: `session_v2.model` (normalizado `{providerID}/{id}` para `id`); sessões multi-modelo são um limite declarado.
- `rules/*.yaml` (ex.: stack-templates.yaml) e invocações da tool `skill` NÃO contam como hit — limite declarado.
- Sobreposição rara de stores resolve por prioridade T1 > T2 > T3.
- Leitura exclusivamente read-only; nenhum dado é gravado no opencode.db.
- **Interpretação:** hit rate baixo com store existente = biblioteca morta (AP-11) ou gatilho otimista para o modelo em uso (AP-13/P-11). Rodar >= 2 ciclos antes de qualquer decisão de infra (D17).
