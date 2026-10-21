# Metricas Acumuladas - EVAL

## Por Projeto

| Projeto | Data | Skills | Issues | Cobertura | Quality Gate | IMPs |
|---------|------|--------|--------|-----------|--------------|------|
| EVAL | 2026-10 | 5 | 1 | 80% | PASS | 1 |

## Outcome Metrics

| Data | Resolucao PENDs | CRs por origem (rmc/evo/bug/dec) | Retrabalho req. | Tempo medio/feature | Tokens medios/feature | Drift-check pendentes | Fonte/Periodo |
|------|-----------------|----------------------------------|-----------------|---------------------|-----------------------|-----------------------|----------------|
| 17/10/2026 | 50% | 1/1/0/0 | 50% | 12 min | 310000 | 1 | rdd-progress Bloco E + PERF_REPORT 2026-10-17 / janela 30d |
| 17/10/2026 | N/A (sem dados) | N/A (sem dados) | N/A (sem dados) | N/A (sem dados) | N/A (sem dados) | N/A (sem dados) | fonte nao coletada - metrica sem fonte = nao coletada (nunca zero fingido) |

Invariantes IMP-099: cada metrica declara fonte e periodo; metrica sem
fonte declarada = N/A (sem dados), nunca zero fingido. CR sem campo
Origem = N/A. Tempo/tokens por feature sao aproximados (join heuristico).
