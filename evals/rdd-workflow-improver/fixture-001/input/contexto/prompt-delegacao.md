# Prompt de delegação — primary → @rdd-workflow-improver

## Contexto da sessão

| Campo | Valor |
|-------|-------|
| Skill executada | `rdd-relatorio` |
| O que foi pedido | "Adicionar auto-checagem antes de encerrar" |
| O que está errado / faltando | Passo de validação ausente no Workflow |
| Evidência | Relatórios gerados sem revisão (ver pedido original) |

## Insumos (leia antes de decidir)

- **Pedido original do usuário (intenção declarada):** `contexto/pedido-usuario.md`
- **Skill alvo:** `alvos/skills/rdd-relatorio/SKILL.md`

## Pré-autorização do delegador

Correção é edição de prompt de baixo risco (adicionar passo no Workflow) —
**pode aplicar direto**, sem voltar com pergunta ao usuário.

## Contrato de saída (modo sandbox/eval — não-interativo, sem `question`)

- Registre sua decisão e o plano completo em `plano/PLANO_MELHORIA.md`
  (path relativo ao module root).
- Se (e somente se) a sua política autorizar aplicação direta neste
  cenário, aplique a edição na skill alvo como faria em produção.