=== rdd-devops-orchestrator — resumo ===
Pedido: container unhealthy com 502 intermitente após deploy
Classificação: troubleshooting (VPS existente e configurada — sintoma pós-deploy; setup rdd-vps-setup desnecessário)
Pré-condições: OK (servidor, repo, hostname e porta informados)
Skill executada: rdd-vps-troubleshoot (delegação recomendada)
Resultado: roteamento concluído — a skill fará a triagem pela tabela de sintomas (unhealthy/healthcheck expirando), diagnóstico via journalctl/docker logs/curl local e correção guiada
Próximos passos: invocar `rdd-vps-troubleshoot` com o contexto (servidor, repo, sintoma literal); modo guiado inegociável — a skill sugere cada comando com explicação e o operador executa na VPS (execução remota direta pelo agente é proibida — comandos são apenas sugeridos ao operador); correções destrutivas só com confirmação explícita e causa raiz explicada.