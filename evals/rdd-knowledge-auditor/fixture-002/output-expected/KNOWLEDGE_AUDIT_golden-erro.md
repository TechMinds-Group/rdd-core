---
project: WORKFLOW_RUNTIME
module: knowledge-audit
audience: [governanca, tecnica]
status: draft
generated_at: "2026-10-22T02:20:26.863Z"
window_days: 7
mode: degradado-proxy
---

# Knowledge Audit — Hit Rate + Tokens de Conhecimento (MODO DEGRADADO)

> **Gerado em:** 21/10/2026  
> **Janela: últimos 7 dias**  
> **Fonte:** opencode.db v2 (session_v2 + session_message, read-only)  
> **Modo:** DEGRADADO — denominadores são PROXY (heurística de globs), não medida calibrada (P-09; plano v5 D8/D12/D15/D17).

## Declaração PROXY (obrigatória — modo degradado)

- **"Sessão que precisava de conhecimento"** = sessão com >= 1 tool call de leitura (read/grep/glob) em artefato T4 de engenharia (`specs/**`, `analysis/**`, `delivery/**`, `REQUIREMENTS.md`) — **PROXY** (heurística de globs), não medida calibrada.
- **"Hit de conhecimento"** = tool call de leitura com path em `knowledge/**` (T1), `patterns/INDEX.md` ou `**/PATTERN.md` (T2), `rules/**.md` (T3) — **PROXY**. Limite declarado: acionamento do bloco `knowledge-routing` em prosa NÃO é observável no db.
- **"Tokens de conhecimento por tarefa"** = soma aproximada (bytes/4, ASCII) dos arquivos de conhecimento LIDOS (tool read) por sessão dividido pelas sessões que precisavam — **PROXY**: tamanho no disco HOJE; leitura parcial (offset/limit) conta como arquivo inteiro; 1ª leitura por sessão+arquivo apenas.
- Calibração Jev (classificadores Noul/relevância) = Fase 5 futura — D12/D15/D17 do plano v5. Este modo degradado é o caminho primário e é o baseline (P-09: instrumentação antes de decisão de infra).

## Status: sem dados

**Erro declarado:** DB_MISSING — opencode.db não encontrado em C:\Users\victo\.config\opencode\evals\rdd-knowledge-auditor\fixture-002\input\sem-banco.db

Sem dados na janela configurada: as métricas abaixo ficam **N/A** e os contadores, **zerados**. Nenhum número foi estimado ou inventado.

## Contadores zerados

| Contador | Valor |
|----------|-------|
| Sessões observáveis (>= 1 read/grep/glob concluído) | 0 |
| Sessões que precisavam (T4 — proxy) | 0 |
| Sessões com hit de conhecimento | 0 |
| Hits de conhecimento | 0 |
| Tokens de conhecimento | 0 |

| Métrica | Valor |
|---------|-------|
| Hit rate: N/A | |
| Tokens de conhecimento por tarefa: N/A | |

## Metodologia e Limitações

- Fonte: opencode.db (SQLite local, leitura exclusivamente read-only via node:sqlite — Node >= 22.5).
- O modo de erro é `warn`: banco ausente ou schema incompatível geram este relatório com erro declarado; nenhum merge é feito no METRICS.md.
- Nenhum merge no METRICS.md ocorre em relatório sem dados.
