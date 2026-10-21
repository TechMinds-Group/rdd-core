# Calibração Jev — log de decisões (IMP-100)

Registro de cada julgamento do modelo Jev (TypeSafe System One) usado
pelo workflow RDD, com o veredito humano correspondente. Alimenta a
"Revisão de calibração Jev" periódica do `rdd-skill-evolution`.

Formato (append-only, nunca reescrever linhas antigas):

| Data | Decisão | Julgamento Jev (choice, p) | Veredito humano | Concordou (Y/N) | Nota |

## Entradas

| Data | Decisão | Julgamento Jev (choice, p) | Veredito humano | Concordou (Y/N) | Nota |
|------|---------|---------------------------|-----------------|-----------------|------|
| 17/10/2026 | Exceção registry×2 (skills fora do registry) | atencao (p≈0.73) | manter exceção documentada, consistente | Y | humano validou que a exceção era legítima; decisão mantida |
| 17/10/2026 | Referência órfã menor (skill citada não registrada) | backlog / não-crítico (p≈0.8) | concordar e corrigir no mesmo ciclo | Y | humano concordou com severidade e corrigiu o registro |
| 17/10/2026 | Saúde do registry (delta disco↔registry) | atencao (p=0.73) | não concordou com o estado | N→Y | discordância-que-virou-concordância: humano corrigiu a CAUSA (registrou 6 skills no domínio `utilitarios`), Jev passou a saudavel (0.98) — modelo calibrado, causa era real |
| 17/10/2026 | Diagnóstico de staleness de artefatos pós-CR | consistente / sem conflito semântico (p≈0.75) | validar e propagar | Y | segunda validação registry — humano confirmou consistência |

## Como ler

- **Taxa de concordância** = Y / total (entradas `N→Y` contam como Y se a
  correção foi de causa — o julgamento apontava problema real).
- **Tendência:** comparar p médio das entradas Y vs N. p alto nas N =
  over-confidence; p baixo nas Y = under-confidence.
- **Ação se concordância < 0.7:** recomendar reavaliar os prompts/criteria
  que usam Jev (como skill/criteria consomem o veredito) — **nunca ajustar
  o modelo**.