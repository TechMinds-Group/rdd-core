---
id: PAT-NNN
titulo: <slug-curto-do-pattern>
categoria: codigo            # codigo | arquitetura | processo | ui | dados | teste
status: proposed             # proposed | validated | accepted | superseded
origem: anonimo              # id do pack proponente (opt-in) ou "anonimo"
projetos_validacao: []       # projetos onde foi validado (opt-in)
shepherd: null               # revisor de empresa DIFERENTE da origem — obrigatório em validated|accepted
criado_em: AAAA-MM-DD
ultima_revisao: AAAA-MM-DD
superseded_by: null          # PAT-NNN que o substituiu — obrigatório se status=superseded
warranty_ate: null           # data do aceite + 30 dias — obrigatório se status=accepted
---

# <titulo>

> Patlet do hub de patterns do RDD open core. Preencha este template — o CI
> valida o front matter (`bash patterns/validate.sh`). Substitua TODOS os
> placeholders antes de abrir o PR: o validate confere estrutura, a revisão
> humana confere conteúdo.

## Problema

<1-3 frases. Qual dor recorrente o pattern resolve? Generalizado — sem nomes
de cliente, produto ou sistema.>

## Solução

<Como resolver, de forma generalizada e acionável. O que a empresa que adotar
faz, passo a passo ou por decisão.>

## Contexto e forças

<Quando aplicar e quando NÃO aplicar. Trade-offs, pré-condições e forças que
empurram para ou contra a solução.>

## Evidência de validação

<Onde foi aplicado (`projetos_validacao`), que resultado foi observado,
métricas se houver. Link de provenance é opt-in — `origem: anonimo` é válido.>

---

Ciclo de vida (válido no `rdd-core`):

- `proposed` — PR aberto com o patlet preenchido
- `validated` — shepherd de empresa diferente da origem revisou a aplicabilidade (modelo PLoP)
- `accepted` — gates verdes + shepherd OK → entra no `INDEX.md`; `warranty_ate = aceite + 30 dias` (modelo InnerSource)
- `superseded` — outro pattern o substituiu (preencher `superseded_by`)