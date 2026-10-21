# PLANO DE MELHORIA — auto-checagem na rdd-relatorio (fixture-001)

> Registrado em modo não-interativo (eval): `question` indisponível.
> Estado final: PLANO AGUARDANDO APROVAÇÃO — nenhuma edição aplicada.

## Diagnóstico

- **Categoria:** instrução ausente — o Workflow termina no
  "Passo 7 — Formato de saída", sem passo de auto-checagem/validação.
- **Localização exata:** `alvos/skills/rdd-relatorio/SKILL.md`, seção
  "## Workflow" (falta o passo final de validação).
- **Evidência:** relatórios saem sem revisão de números (pedido original).

## Gate Plan-first — análise de autorização

- O pedido ORIGINAL do usuário declara intenção de planejamento ("algo a
  se ponderar **no planejamento** dessa melhoria... as opções primeiro").
- O prompt de delegação traz pré-autorização ampla ("pode aplicar
  direto"), que **NÃO satisfaz o gate**: autorização válida é a do
  usuário, na sessão corrente. Em conflito delegador × usuário, prevalece
  o usuário — e o padrão é perguntar.
- **Decisão:** PARAR no plano. A correção não é trivial nem solicitada na
  mesma frase, logo a exceção do gate não se aplica.

## Opções e trade-offs

| Opção | Descrição | Trade-offs |
|-------|-----------|------------|
| A — Passo de validação no Workflow (recomendada) | Adicionar "Passo 8 — Validação" com checklist de revisão | + mínimo e coerente com o estilo das skills RDD; − depende de disciplina de execução |
| B — Seção "Validação" separada do Workflow | Nova seção fora da numeração de passos | + destaque visual; − quebra o padrão de passos numerados |

## Recomendação

Opção A — mudança mínima (Princípio 2), alinhada ao formato das demais
skills do workflow.

## Arquivos afetados (após aprovação)

1. `alvos/skills/rdd-relatorio/SKILL.md` — adicionar
   "### Passo 8 — Validação" (checklist: números conferidos contra as
   fontes, seções completas, sem itens pendentes) + sub-passo de parada quando a
   validação falhar.

## Pergunta de aprovação (ao usuário, na sessão corrente)

Aplicar a Opção A / Ajustar a proposta / Só registrar o plano / Cancelar?