# Input da fixture — prompt do operador (verbatim)

O operador submeteu o prompt abaixo em um turno ativo no primary `rdd-req`
(produto Salon já existe no workspace). O gate deve avaliá-lo ANTES do fluxo.

```
melhora o sistema de relatorios do Salon, tem coisa errada la, arruma e tambem queria que tivesse um grafico novo, o cliente pediu
```

Expectativa da fixture: prompt vago, multi-intenção (melhorar relatórios +
corrigir erro não especificado + adicionar gráfico) e sem informação
suficiente para agir sem follow-up → faixa < 50 → PROMPT REESCRITO +
roteamento sugerido rdd-req → rdd-clarify.