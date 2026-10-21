# Feature — Triagem automática de tickets de suporte

O helpdesk recebe ~400 tickets/dia. Hoje, dois analistas fazem a triagem
manual (categoria, urgência, roteamento para a fila do time). Pedidos:

1. Classificar cada ticket novo em uma categoria fixa (billing, bug,
   feature_request, account, other) com roteamento automático para a fila.
2. Estimar urgência em níveis (baixa, média, alta, crítica) para ordenar a fila.
3. Sinalizar menções de "vazamento de dados" para revisão humana imediata.

Regra do produto: nenhuma ação automática de alto impacto (reembolso,
bloqueio de conta) pode ser tomada só pela IA — decisão final é humana.
