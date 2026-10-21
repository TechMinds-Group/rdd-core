# AGENTS — Catálogo.API

Instruções do agente para o repo Catálogo.API (.NET 8, EF Core 8, PostgreSQL 16).

## Comandos

- Build: `dotnet build`
- Testes: `dotnet test`

## Migrações (EF Core)

- Sempre gerar migrações com `dotnet ef migrations add` — nunca escrever na mão.
  A descoberta do EF Core filtra por `[DbContext]` antes de qualquer log: migração
  hand-written sem os atributos é silenciosamente ignorada.
- Toda migração hand-written PRECISA de `[DbContext(typeof(<Contexto>))]` **e**
  `[Migration("<id>")]` — sem os dois, o deploy em ambiente novo quebra.
- Migrações em pasta única `Migrations/`, junto com `*ModelSnapshot.cs` — nunca
  duas pastas de migrations coexistindo.
- Antes de commitar mudanças de modelo: `dotnet ef migrations has-pending-model-changes`
  deve responder "No changes".
- **Nunca** suprimir `RelationalEventId.PendingModelChangesWarning` em DI — o aviso
  existe para detectar drift modelo ↔ snapshot.
