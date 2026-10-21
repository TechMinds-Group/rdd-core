---
name: rdd-stack-java-quarkus
description: >-
  Playbook de stack Java/Quarkus para os executors de dev do RDD
  (rdd-dev-backend). Comandos de build/verify (mvn), estrutura de projeto,
  padrões dominantes (REST Client, Panache/Hibernate, OpenAPI, Flyway),
  convenções de teste JUnit (@QuarkusTest, @InjectMock) e pitfalls (JDK vs
  pom.xml, form-urlencoded, config por profile). Carregada via skill tool
  quando o repo alvo detecta pom.xml/build.gradle. Use junto com "quarkus",
  "java", "mvn", "panache", "flyway", "junit", "oracle". Use quando o repo
  alvo for Java/Quarkus detectado (pom.xml/build.gradle), ao rodar
  "mvn verify"/"mvn test" ou ao implementar APIs.
---
# rdd-stack-java-quarkus — Playbook de Stack

Playbook de conhecimento para executors de dev do RDD que implementam
código em repos Java/Quarkus. Contém o
**como** da stack — comandos, padrões e pitfalls. O **o quê** (task,
contrato, RNs) vem de TASKS.md/API_CONTRACTS.md/REQUIREMENTS.md; as
convenções específicas do repo vêm do `AGENTS.md` do repo (precedência
sobre este playbook).

## Escopo

- **Aplica-se a:** repos backend Quarkus (Java, Maven)
- **Fonte de verdade de versões:** `pom.xml` do repo (não este playbook) —
  ex: `maven.compiler.version` define Java 17 ou 21; REPOSITORIES.md
  documenta o template base, mas o repo pode ter divergido.

## Lê (upstream)

- `AGENTS.md` do repo alvo — convenções específicas do repo (precedência sobre este playbook)
- Código-fonte do repo (read-only) — `pom.xml`, `application.properties`, `src/main/java/**`, `src/main/resources/` (incl. `db/migration/`), testes existentes
- Artefatos de spec do módulo referenciados pela task: TASKS.md, API_CONTRACTS.md, ERROR_CATALOG.md, ACCEPTANCE_CRITERIA.md, REQUIREMENTS.md

## Gera (downstream)

- Nenhum artefato de módulo — este playbook só orienta a implementação aplicada pelos executors de dev (`rdd-dev-backend`): código Java/Quarkus, testes JUnit e relatório da task

## Nunca edita

- Artefatos de spec RDD (REQUIREMENTS.md, DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, ACCEPTANCE_CRITERIA.md, COMPLIANCE.md, TASKS.md) — read-only
- `AGENTS.md` do repo alvo

## Tools

- `read`/`glob`/`grep` — inspecionar código-fonte, `pom.xml` e configs (read-only)
- `bash` — executar `mvn verify`, `mvn test` e ajustar `JAVA_HOME`

## Modo de erro

`warn` — repo sem `pom.xml`/`build.gradle` (stack desconhecida): sinalizar `needs-stack-playbook.`, seguir as convenções do `AGENTS.md` do repo e encerrar com orientação — não aplicar padrões Quarkus por inferência. JDK divergente do `pom.xml` não bloqueia: ajustar `JAVA_HOME` e registrar no relatório.

## Comandos de build e verificação

| Ação | Comando |
|------|---------|
| Build completo + testes | `mvn verify` |
| Testes de um módulo | `mvn -pl <module> test` |
| Teste único | `mvn test -Dtest=<ClasseTest>` |
| Dev mode | `mvn quarkus:dev` (não usar em CI) |
| Wrapper sem Maven no PATH | `./mvnw <comando>` (Linux) / `.\mvnw.cmd <comando>` (Windows) |
| Empacotar nativo (raro) | `mvn package -Dnative` |

**Pré-verificação de ambiente:** confirme `java -version` ≥ versão do
`pom.xml`. JDK divergente no PATH (ex: JDK 11 com projeto Java 21) é
pitfall comum — ajuste `JAVA_HOME` antes de `mvn verify` e registre no
relatório.

## Estrutura de projeto típica

```
src/main/java/com/org/quarkus/
├── infra/<integracao>/          # pacote por integração (pnib, soe, ...)
│   ├── <Int>RestClient.java     # REST Client (@RegisterRestClient)
│   ├── Criar<Entidade><Int>Service.java
│   ├── <Int>TokenCacheService.java (quando há auth)
│   └── <Int>AuthRestInterceptor.java (quando há auth)
├── infra/<dominio>/             # entities Panache, repositories
├── resource/ ou api/            # endpoints REST (JAX-RS)
└── ...                          # DTOs, mappers, exceptions
src/main/resources/
├── application.properties       # config + profiles %dev/%prod
├── db/migration/                # Flyway (V<NN>__<descricao>.sql)
└── config/security.yaml         # segredos via env var (NUNCA hardcoded)
src/test/java/...                # testes espelhando a estrutura main
```

## Padrões dominantes

### REST Client externo
- `@RegisterRestClient` + interface com `@POST`/`@GET`/`@Path`
- Config em `application.properties`: `<base-uri>` + `mp-rest/*`
- Content-Type por contrato (ex: `application/x-www-form-urlencoded`
  para OAuth2 token, **não** JSON)

### Tratamento de erro de chamada externa
- Envolver chamadas em executor padronizado do projeto — não deixar exceção crua subir
- 401/403: log ERROR e **sem retry automático** (política por contrato)
- Mapear erros síncronos do provedor para ERROR_CATALOG do módulo

### Persistência
- Hibernate ORM com Panache (entities estendem `PanacheEntity` ou usam
  `PanacheRepository`)
- Oracle como banco; dialect e datasource em `application.properties`
- Migrações **sempre** via Flyway versionado — nunca DDL manual

### OpenAPI
- `@Operation`, `@Schema` (smallrye-openapi) coerentes com API_CONTRACTS.md
- DTOs com validação Bean Validation (`@NotNull`, `@Size`, ...) — as
  validações vêm do contrato, não por intuição

## Testes

- **Unitários/integração:** JUnit 5 + `@QuarkusTest`
- **Mocks de REST Client:** `@InjectMock` no RestClient ou `@RestClientMock`
  (Quarkus rest-client mocking) — escolha o padrão já usado no repo
- **Um teste por RN** mínimamente + cenários de erro do contrato
- Rodar via `mvn verify` — a suíte inteira precisa estar verde, não só
  os testes novos

## Pitfalls

1. **JDK no PATH ≠ Java do pom.xml** — verificar antes de buildar
2. **`mvn` ausente no PATH** — usar `./mvnw`; se o wrapper não estiver
   configurado, reportar `not-verified.` com motivo
3. **Segredo hardcoded** — `config/security.yaml` e `application.properties`
   só com placeholders `${ENV_VAR}`; segredo real viola RN de segurança
   (ver ACCEPTANCE_CRITERIA do módulo)
4. **Path relativo no RestClient** — `@Path("oauth/token")` sem barra
   inicial é válido com Quarkus REST Client; conferir `base-uri` no config
5. **Panache transacional** — `@Transactional` nos methods de service que
   escrevem; repository Panache não substitui a anotação

## Quality Checks

### Automação

| Check | Comando | O que verifica |
|-------|---------|----------------|
| Checkstyle | `mvn checkstyle:check` | Style guide, naming conventions |
| SpotBugs | `mvn spotbugs:check` | Bug patterns, code smells |
| Build completo | `mvn verify` | Compilação + testes |
| Cobertura | `mvn verify jacoco:report` | Line/branch coverage |
| Formatação | Google Java Format (se configurado) | Estilo de código |

### Padrões da stack

- **Naming:** `PascalCase` para classes, `camelCase` para métodos/fields, `UPPER_SNAKE_CASE` para constantes
- **Testes:** `@QuarkusTest` para integração, `@InjectMock` para mocks
- **Testes naming:** `shouldExpectedBehavior_whenCondition` ou `given_when_then`
- **Estrutura:** `src/main/java/com/org/quarkus/` com packages por concern (resource, service, repository, model)

### Limites

| Check | Limite | Severidade |
|-------|--------|------------|
| Método | ≤ 30 linhas | error |
| Classe | ≤ 300 linhas | error |
| Parâmetros | ≤ 4 | warning |
| Complexidade ciclomática | ≤ 10 | warning |
| Depenedências por classe | ≤ 7 | warning |

## Algoritmo

1. **Detectar stack:** confirme `pom.xml` (ou `build.gradle`) com Quarkus no repo alvo. Sem eles → `warn` (ver Modo de erro).
2. **Carregar convenções:** leia o `AGENTS.md` do repo (precedência sobre este playbook) e confira Java/Quarkus no `pom.xml`.
3. **Contextualizar a task:** leia os artefatos de spec referenciados (TASKS.md, API_CONTRACTS.md, ERROR_CATALOG.md) para saber o **o quê**.
4. **Aplicar na implementação:** use os padrões deste playbook (REST Client + RestExecutor, Panache/Flyway, OpenAPI, Bean Validation) ao codar.
5. **Verificar:** rode `mvn verify` com a suíte inteira verde; reporte `not-verified.`/`regressed.` conforme o caso.
5.1. **Validar schema Oracle antes de mapear `@JoinColumn` (condicional — IMP-075):** ao criar ou editar entity JPA com `@JoinColumn`, se houver client/MCP de banco disponível na sessão, validar que a coluna existe no Oracle via query `ALL_TAB_COLUMNS`:
   ```sql
   SELECT COLUMN_NAME, NULLABLE FROM ALL_TAB_COLUMNS
   WHERE OWNER = '<schema>' AND TABLE_NAME = '<tabela>' AND COLUMN_NAME = '<coluna>'
   ```
   - Sem client de banco disponível → valide pelos artefatos do repo
     (migrations Flyway em `src/main/resources/db/migration/` e seed H2
     `import.sql`) e registre `schema: not-verified (sem client SQL)` no
     relatório — não bloqueie a task por ferramenta ausente
   - Se a coluna não existir → **ERRO**: não mapear; reportar ao operador o nome correto
   - Se `NULLABLE = 'Y'` e o JOIN é obrigatório → **WARN**: o campo pode ser NULL; usar `LEFT JOIN FETCH` no JPQL
   - Nunca assumir nomes de colunas por semelhança com outras tabelas (ex: `NRO_INT_ENDERECO` ≠ `NRO_INT_ENDERECO_PRINCIPAL`)
   - Verificar também a tabela de testes H2: o seed `import.sql` deve usar o mesmo nome de coluna

## Casos de Borda

- **Repo com build.gradle (não Maven):** adaptar comandos (`gradle build`,
  `gradle test`); sinalizar divergência do template padrão no relatório
- **Repo multi-módulo:** usar `-pl <module>` para testes direcionados;
  `mvn verify` full para o relatório final
- **Quarkus versões antigas (sem rest-client-reactive):** usar o cliente
  clássico; sinalizar em `decisões:`
- **Perfil de config divergente (%dev vs %prod):** testes rodam em %dev;
  contratos de URL/segredo de %prod são responsabilidade do Variable
  Group — nunca hardcode

## Formato de commit

```
feat(<integracao>): <descricao-curta>
```

(Convenção final pertence ao AGENTS.md do repo — este playbook só
sugere o estilo dominante.)
