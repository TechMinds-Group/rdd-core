=== rdd-dev-orchestrator — roteamento ===
Task: RN-042-2 — Implementar endpoint POST /clientes/{id}/bloqueio (repo TM.Vendas-API)
Stack/executor: @rdd-dev-backend (quarkus) — implementação já concluída
Fase do ciclo: revisão
Pré-condições: OK (QA independente cumprida — @rdd-dev-qa veredito APROVADA, cobertura 87% ≥ piso 80%)
Próximo passo: delegar revisão formal pré-PR ao @rdd-dev-reviewer — passar no prompt: task literal (RN-042-2), branch feature/rn-042-2-bloqueio, módulo e caminhos do Feature.md e da Análise-Técnica. O revisor cruza RNs × diff, roda quality gates (rdd-quality-gates), checa specs/SECURITY.md e docs vivas. Veredito approve/request-changes.

Notas de ciclo:
- PR NÃO é o próximo passo: exige veredito approve do revisor E pedido explícito do operador; quando solicitado, rotear via @rdd-github-orchestrator (rdd-gh-pr-creator registra reviewed: true).
- O orquestrador roteia, não executa — nenhuma linha de código é escrita nesta fase.