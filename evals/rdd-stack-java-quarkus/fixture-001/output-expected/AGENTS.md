# AGENTS — Pedidos.API

Instruções do agente para o repo Pedidos.API (Java 21, Quarkus, Oracle, Panache).

## Comandos

- Build + testes: `mvn verify`

## Migrações (Flyway)

- Toda mudança de schema **sempre** via Flyway versionado em
  `src/main/resources/db/migration/V<n>__<descricao>.sql` — **nunca DDL manual**
  (arquivo solto ou execução direta no banco).
- Antes de `mvn verify`, conferir que o JDK do PATH é o mesmo Java do `pom.xml`
  (pitfall: JAVA_HOME divergente).
- Suíte `mvn verify` inteira verde antes de concluir — não só os testes novos.
