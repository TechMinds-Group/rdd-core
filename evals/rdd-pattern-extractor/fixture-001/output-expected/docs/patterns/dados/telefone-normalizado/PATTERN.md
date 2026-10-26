# Telefone Normalizado

**Categoria:** data-model
**Tipo:** dados
**Projetos que usaram:** CONTATOS (27/09/2026)
**Stacks aplicáveis:** all
**Maturidade:** novo
**Última revisão:** 2026-09-27
**Status:** ativo
**Superado por:** —
**Evidência:** Retrospectiva CONTATOS — `docs/projects/CONTATOS/RETROSPECTIVE.md`

## Cenário

Quando o sistema recebe telefones de múltiplas fontes (cadastro, importação,
integração) e precisa garantir formato consistente antes de consultar,
exibir ou indexar o número.

## Descrição

Normalizar o telefone no domínio, não no frontend: a entidade recebe o valor
já em formato canônico (somente dígitos + DDI/DDD estruturados), de modo que
qualquer camada que consuma o dado encontre a mesma forma normalizada.

## Implementação

Regra de dado (Tipo `dados` — sem código obrigatório): a normalização é
executada no setter/construtor da entidade de domínio, nunca na camada de
apresentação.

## Quando NÃO usar

- Quando o telefone é apenas exibido sem busca/indexação e a fonte já é
  confiável.
- Quando a normalização destruiria informação relevante de extensões
  corporativas (ramais).

## Variações

- Com DDI explícito (internacional) vs. DDI implícito (nacional).

## Referências

- Retrospectiva: `docs/projects/CONTATOS/RETROSPECTIVE.md`
