# Design TypeSafe — Triagem automática de tickets de suporte

## Contexto

~400 tickets/dia chegam sem categoria nem prioridade; a triagem é manual.
O workflow (buscar ticket, gravar no banco, rotear fila, SLA) fica em CÓDIGO.
O que pede entendimento semântico vira **judgments** de um modelo
**System One** (Jev): respostas tipadas com probabilidades, não texto livre.

## Decisões de Design

### D1 — Categoria como Choice (e não geração de texto)

- Primitiva: Choice com criteria {billing, bug, feature_request, account, other}.
- Estado: `ticket.subject`, `ticket.body`, `ticket.customer.plan`.
- Include o outcome "other" para o caso sem encaixe — a fila "other" existe no roteamento.
- Por que Choice: o contrato tipado garante que o código só lida com os cinco
  valores do enum; prompt-and-parse ficaria sujeito a variação de texto.

### D2 — Urgência como Score (e não um Noul por nível)

- Primitiva: Score com níveis descrevendo situações concretas
  ("cliente impedido de operar" = alta; "dúvida de uso" = baixa).
- Usar o MESMO critério de níveis para todos os tickets — Score é comparável
  entre itens e ordena a fila (ranking) de forma consistente.

### D3 — Vazamento de dados como Noul dedicado

- Primitiva: Noul ("o ticket menciona vazamento de dados?") sobre o mesmo estado.
- Por quê separado de D1/D2: rótulo independente e útil; um Choice não expressa
  dois atributos de uma vez.
- Threshold de escala definido sobre dados reais do helpdesk: Noul < 0.55
  vai para revisão humana imediata (não usar o valor de exemplo do cookbook).

### D4 — Probabilidade comanda a rota, nunca a ação

- Reembolso e bloqueio de conta continuam 100% em regra de negócio no código.
- Confidence da Choice mede concentração da distribuição, não "permissão para agir".
- Baixa confidence em escolha de preferência não bloqueia fluxo inofensivo.

## Composição

As três perguntas (D1, D2, D3) rodam juntas sobre o mesmo estado — são
independentes e paralelizam sem se verem. Uma segunda chamada só acontece se
um answer anterior precisar construir estado novo (hoje, não precisa).

## Verificação

- Conjunto de teste: 200 tickets rotulados por triagem humana; medir calibração
  por categoria e a taxa de escala do D3 no domínio alvo.
- Falha de triagem: inspecionar o estado exato (ticket completo), a pergunta,
  os candidatos e o resultado — separar falta de evidência, erro de modelo e
  erro de código.
- Credenciais da API TypeSafe somente no servidor.
