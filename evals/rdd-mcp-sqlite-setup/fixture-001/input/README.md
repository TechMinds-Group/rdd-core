# Estoque Local

App desktop de controle de estoque. Armazenamento em arquivo SQLite único
(`estoque.db`), acesso direto pelo time em inspeções de dados.

## Contexto

O banco fica no diretório de dados do app (`.db` local, sem servidor). O agente
precisa inspecionar schema e rodar queries de leitura durante o suporte.
O MCP SQLite ainda não está configurado neste projeto — pedir o setup ao operador.