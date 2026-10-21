# Working tree misturado — Auth Service

Repositório `Auth-Service` (Node.js/TypeScript). O operador trabalhou em três
frentes na mesma sessão e o working tree ficou misturado:

```
 M src/auth/session.ts
 M src/auth/session.test.ts
 M src/api/client.ts
 M docs/setup.md
?? .env.local
```

Pedido: separar em commits por assunto, com mensagens no estilo do repo
(Conventional Commits), sem staging cego. `.env.local` é segredo local —
NUNCA versionar.
