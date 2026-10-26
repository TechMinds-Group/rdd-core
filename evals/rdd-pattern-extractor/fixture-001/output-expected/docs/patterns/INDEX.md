# Pattern Library

> Padrões reutilizados extraídos de retrospectivas de projetos.
> Atualizado automaticamente por `rdd-pattern-extractor`.
> Staleness (MP-03): idade (`data_ultima_revisao` > 6m) = GATILHO de revisão,
> nunca veredito de verdade (P-05). Invalidação por contradição: conflito
> detectado marca o antigo `status: superado` + `superado_por` — histórico
> preservado, nunca delete (MP-13).

## Índice

| Padrão | Tipo | Categoria | Projetos | Maturidade | data_ultima_revisao | status |
|--------|------|-----------|----------|------------|---------------------|--------|
| [autenticacao-jwt](codigo/autenticacao-jwt/PATTERN.md) | codigo | autenticação | CATALOGO (20/09/2026) | novo | 2026-09-20 | ativo |
| [telefone-normalizado](dados/telefone-normalizado/PATTERN.md) | dados | data-model | CONTATOS (27/09/2026) | novo | 2026-09-27 | ativo |
| [remocao-explicita](dados/remocao-explicita/PATTERN.md) | dados | data-model | CONTATOS (27/09/2026) | novo | 2026-09-27 | ativo |

## Por Tipo

### Código

- [autenticacao-jwt](codigo/autenticacao-jwt/PATTERN.md) — JWT com refresh token (revisão: 2026-09-20)

### Dados

- [telefone-normalizado](dados/telefone-normalizado/PATTERN.md) — normalizar no domínio, não no frontend (revisão: 2026-09-27)
- [remocao-explicita](dados/remocao-explicita/PATTERN.md) — remover dependentes explicitamente quando o DDL não tem FK (revisão: 2026-09-27)
