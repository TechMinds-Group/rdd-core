# Remoção Explícita

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

Quando o DDL do banco não define foreign key entre entidades relacionadas e
a exclusão do registro pai pode deixar filhos órfãos.

## Descrição

Quando o DDL não tem FK, remover dependentes explicitamente no código: a
operação de exclusão do agregado elimina (ou arquiva) os registros
dependentes em transação, garantindo integridade que o banco não assegura.

## Implementação

Regra de dado (Tipo `dados` — sem código obrigatório): a exclusão em cascata
é responsabilidade da camada de aplicação, dentro da mesma transação da
exclusão do registro pai.

## Quando NÃO usar

- Quando é possível adicionar a FK no banco (prefira integridade declarativa).
- Com soft-delete generalizado: a remoção explícita perde sentido se nada é
  fisicamente removido.

## Variações

- Remoção física vs. arquivamento dos dependentes antes da exclusão do pai.

## Referências

- Retrospectiva: `docs/projects/CONTATOS/RETROSPECTIVE.md`
