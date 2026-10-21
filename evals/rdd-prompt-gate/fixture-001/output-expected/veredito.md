# 🚦 Prompt Gate — PROMPT REESCRITO

Score: 42/100 (clareza 60, completude 31, ação pronta 36, multi-intenção 0.58 sem penalidade)
Cálculo: clareza (2.41/4 → 60) e completude (1.24/4 → 31) com N=5 criteria (escala 0-4);
ação pronta = (1 - 0.64) * 100 = 36 (noul com criteria dict: p = P("precisaria perguntar")).
Sem penalidade -15 (multi-intenção 0.58 < 0.60). Calibração: jev_classify (jev-1.13.0).

Razões:
- 3 intenções não relacionadas no mesmo prompt (melhorar relatórios, corrigir erro não
  especificado, adicionar gráfico novo) — p(multi-intenção)=0.58, próximo do limiar 0.60.
- "tem coisa errada la" sem sintoma, tela, comportamento atual vs esperado nem evidência.
- Sem critérios de aceitação nem escopo — 64% de probabilidade de o agente precisar
  perguntar de volta antes de agir.

Prompt reescrito (reenviar para o fluxo):

```
No produto Salon, registrar 2 demandas de relatórios:
1. CORREÇÃO — relatório <qual>: comportamento atual <X>, esperado <Y>, exemplo/repro.
2. NOVA FEATURE — gráfico <tipo> em <relatório/tela>, dados <fonte/métrica>;
   pedido pelo cliente <nome> em <data>.
Urgência: <alta/média/baixa>. Repos afetados: <Salon-API/Salon-FE>.
```

Rota sugerida: rdd-req → rdd-clarify (confiança Jev: dev p=0.81 — intenção dominante
"dev", mas score <50 exige formalização em RNs/CR antes de task; após spec, execução
via rdd-dev). Roteamento é sugestão: roteamento fino por estado permanece no @rdd-next.