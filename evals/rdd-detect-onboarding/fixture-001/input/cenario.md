Cenario: Sessao nova do OpenCode numa maquina onde ~/.config/opencode/AGENTS.md existe com o bloco <!-- projeto-padrao --> preenchido (C:\Projetos\Acme), mas o glob de PROJECT_CHARTER.md retorna 3 modulos. Nao existe flag .no_onboarding.

Tarefa variante de borda avaliada: e se .no_onboarding existir com data de 45 atras (expirada > 30 dias)?

Tarefa: diagnosticar se o operador precisa de onboarding, retornando o veredito no formato padrao, sem editar nenhum arquivo.