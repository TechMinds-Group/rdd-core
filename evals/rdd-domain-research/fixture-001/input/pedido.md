# Pedido de fundação de conhecimento — fixture L0

Input mínimo para a skill `rdd-domain-research` (domínio FICTÍCIO, apenas para eval).

- **Domínio**: acessibilidade
- **Escopo**: revisão de acessibilidade de UI web (componentes, formulários e navegação) — a base orientará uma camada de accessibility review que fará triagem de findings em telas.
- **Contexto**: nenhum componente consome este domínio ainda; `knowledge/INDEX.md` não lista o domínio. A fundação é gatilho obrigatório da Fase 2 (Fundação de Conhecimento) do @rdd-workflow-builder antes da criação da camade que consome.

## Saída esperada (contrato)

1. `knowledge/acessibilidade/KNOWLEDGE.md` — template fixo com front matter completo (dominio, versao, data_pesquisa, proxima_revisao, fontes[] com URL e data de acesso) e seções: Princípios (com heurística de violação), Checklist aplicável, Anti-patterns (com exemplos), Classificação/Severidade, Referências.
2. `knowledge/INDEX.md` — entrada do domínio acessibilidade (merge incremental; cria o arquivo se for a primeira fundação).