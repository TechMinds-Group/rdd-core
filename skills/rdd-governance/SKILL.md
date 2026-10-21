---
name: rdd-governance
description: >-
  Revisa CONSTITUTION.md e PRODUCT_GOAL.md. Baixa frequência — só quando
  os princípios do produto precisam ser atualizados. Não cria do zero,
  apenas revisa o existente.
  Use quando o usuário pedir "revisar CONSTITUTION", "atualizar princípios do produto", "governança do RDD" ou "revisar PRODUCT_GOAL".
---
# rdd-governance — Governança do Produto

Revisa `CONSTITUTION.md` e `PRODUCT_GOAL.md` na raiz do repo de docs do produto (`repo_docs_rdd`) quando os princípios
do produto ou convenções do workflow precisam ser atualizados.

## Referências

- CONSTITUTION.md: raiz do repo de docs do produto (`repo_docs_rdd` — bloco `<!-- rdd-docs-repo -->` do AGENTS.md global)
- Registry de skills: `registry.yaml` (raiz da config do OpenCode — fonte da verdade, IMP-027)

## Lê (upstream)

- `CONSTITUTION.md` na raiz do repo de docs do produto (o que será revisado)
- `PRODUCT_GOAL.md` na raiz do repo de docs do produto (se existir, o que será revisado)
- `registry.yaml` (para verificar se skills novas precisam de convenções)

## Gera (downstream)

- `CONSTITUTION.md` na raiz do repo de docs do produto (revisão, não criação)
- `PRODUCT_GOAL.md` na raiz do repo de docs do produto (revisão, não criação)

## Nunca edita

- Nenhum documento de projeto específico

## Tools

- `read` (ler CONSTITUTION.md, PRODUCT_GOAL.md, registry.yaml)
- `write` (atualizar CONSTITUTION.md, PRODUCT_GOAL.md)
- `question` (propor mudanças, obter aprovação)

## Modo de erro

`skip` — se falhar, loga warning. Governança não bloqueia nenhum fluxo.

## Formato de commit

```
docs: update governance documents
```

## Workflow

1. Leia CONSTITUTION.md e PRODUCT_GOAL.md atuais
2. Leia registry.yaml — identifique skills novas que podem precisar de convenções
3. Proponha mudanças usando `question`
4. Apenas após aprovação, escreva as alterações

## Template

Não há template — esta skill revisa documentos existentes, não cria novos.

## Casos de Borda

- **Skill nova sem convenção correspondente na CONSTITUTION.md**: proponha a convenção via `question` antes de escrever — não corrija a skill para burlar a convenção.
- **Mudança proposta conflita com princípio existente**: apresente o conflito ao usuário; alterar o princípio exige aprovação explícita antes de escrever.
- **PRODUCT_GOAL.md não existe**: não crie do zero — a skill apenas revisa o existente; reporte a ausência.
- **Mudança na CONSTITUTION.md impacta skills existentes**: liste no proposal quais skills/comportamentos são afetados, para re-execução ou correção posterior.
