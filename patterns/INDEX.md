# Índice do Hub de Patterns

Hub público de patlets cross-empresa do RDD open core — padrões
generalizados e anonimizados, validados por pelo menos uma empresa em
projeto real.

## Patterns aceites

| ID | Título | Categoria | Status | Origem | Shepherd | Warranty até |
|----|--------|-----------|--------|--------|----------|--------------|

> Vazio no MVP — patterns entram aqui com status `accepted`.

## Como ler

- **`accepted`** = validado por shepherd de empresa ≠ origem, gates verdes e
  warranty de 30 dias ativa (`warranty_ate`).
- `proposed`/`validated` vivem em PR — só entram nesta tabela no aceite.
- `superseded` permanece como histórico (`superseded_by` no front matter).

## Como promover um pattern

Do pack da empresa (`accumulation/patterns/`) para este hub:

1. Generalize e anonimize seguindo o **checklist de anonimização** do
   `CONTRIBUTING.md`.
2. Rode o gate local: `bash evals/neutrality/scan.sh` → `neutrality: OK`.
3. Crie o patlet a partir de `patterns/TEMPLATE.md` e abra o PR — o CI
   valida o front matter com `bash patterns/validate.sh`.
4. Shepherd de empresa diferente da origem revisa; o aceite entra nesta
   tabela com `warranty_ate = aceite + 30 dias`.

Fluxo completo e decisões vigentes: seção **"Promovendo patterns"** do
`CONTRIBUTING.md`.

> Mantenedor único no MVP: TechMinds (federação de TCs por domínio quando a
> 2ª empresa contribuir).