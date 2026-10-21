---
name: rdd-stack-dotnet-csharp
description: >-
  Playbook de stack .NET C# para os executors de dev do RDD
  (rdd-dev-backend). Comandos de build/test (dotnet CLI), estrutura de
  projeto Clean Architecture (Api/Application/Domain/Infrastructure),
  padrões dominantes (MediatR CQRS, FluentValidation, EF Core, Result
  pattern), convenções de teste (xUnit, Moq, FluentAssertions) e pitfalls
  (DI lifecycle, async/await, nullable refs, EF tracking). Carregada via
  skill tool quando o repo alvo detecta *.csproj ou *.sln.
  Use junto com "dotnet", "csharp", "csproj", "sln", "efcore", "mediatr",
  "fluentvalidation", "xunit". Use quando o repo alvo for .NET detectado
  (*.csproj/*.sln), ao rodar "dotnet build"/"dotnet test" ou ao implementar
  APIs REST com C#.
---
# rdd-stack-dotnet-csharp — Playbook de Stack .NET C#

Playbook de conhecimento para executors de dev do RDD que implementam
código em repos .NET C# (backends API). Contém o
**como** da stack — comandos, estrutura e padrões. O **o quê** (task,
contrato, RNs) vem de TASKS.md/API_CONTRACTS.md/REQUIREMENTS.md; as
convenções específicas do repo vêm do `AGENTS.md` do repo (precedência
sobre este playbook).

## Escopo

- **Aplica-se a:** repos backend .NET (C#, ASP.NET Core, EF Core)
- **Não se aplica a:** repos frontend (Angular/React), consoles simples, bibliotecas de class library pura
- **Camada sobre:** `rdd-dev-backend` — carrega este playbook quando detecta `*.csproj` ou `*.sln` no repo alvo
- **Fonte de verdade de versões:** `*.csproj` do repo (não este playbook) — TargetFramework define .NET 6/7/8/9

## Lê (upstream)

- `AGENTS.md` do repo alvo — convenções específicas do repo (precedência sobre este playbook)
- Código-fonte do repo (read-only) — `*.csproj`, `*.sln`, `Program.cs`, `appsettings.json`, `Directory.Build.props`, source code, testes existentes
- Artefatos de spec do módulo referenciados pela task: TASKS.md, API_CONTRACTS.md, ERROR_CATALOG.md, ACCEPTANCE_CRITERIA.md, REQUIREMENTS.md

## Gera (downstream)

- Nenhum artefato de módulo — este playbook só orienta a implementação aplicada pelos executors de dev (`rdd-dev-backend`): código C#, testes xUnit e relatório da task

## Nunca edita

- Artefatos de spec RDD (REQUIREMENTS.md, DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, ACCEPTANCE_CRITERIA.md, COMPLIANCE.md, TASKS.md) — read-only
- `AGENTS.md` do repo alvo

## Tools

- `read`/`glob`/`grep` — inspecionar código-fonte, `*.csproj` e configs (read-only)
- `bash` — executar `dotnet build`, `dotnet test`, `dotnet ef` e verificar SDK

## Modo de erro

`warn` — repo sem `*.csproj`/`*.sln` (stack desconhecida): sinalizar `needs-stack-playbook.`, seguir as convenções do `AGENTS.md` do repo e encerrar com orientação — não aplicar padrões .NET por inferência. .NET SDK divergente do TargetFramework não bloqueia: ajuste a versão e registre no relatório.

## Comandos de build e verificação

| Ação | Comando |
|------|---------|
| Build + testes (verificação padrão) | `dotnet build && dotnet test && dotnet format --verify-no-changes` |
| Teste por nome/classe | `dotnet test --filter "FullyQualifiedName~<TestName>"` |
| Formatar / verificar formato | `dotnet format` / `dotnet format --verify-no-changes` |
| Run (app) | `dotnet run --project <Project>.Api` |
| Cobertura | `dotnet test /p:CollectCoverage=true` |
| Restaurar / limpar | `dotnet restore` / `dotnet clean` |

### EF Core — Migrações

| Ação | Comando |
|------|---------|
| Adicionar migração | `dotnet ef migrations add <Name> --project <Project>.Infrastructure` |
| Listar / aplicar / remover | `dotnet ef migrations list` / `database update` / `migrations remove` |
| Script SQL da migração | `dotnet ef migrations script --project <Project>.Infrastructure` |

**Pré-verificação de ambiente:** confirme `dotnet --version` ≥ TargetFramework do `*.csproj` (ex: .NET 8 para net8.0). SDK divergente é pitfall comum — ajuste antes de buildar.

**Convenção de migrações (crítica):**

- Sempre gerar migrações com `dotnet ef migrations add` — nunca escrever na mão.
  A descoberta do EF Core (`MigrationsAssembly.AddMigrationsFromAssembly`) filtra por
  `[DbContext]` **antes** de qualquer log: migração hand-written sem os atributos é
  silenciosamente ignorada (classe morta — invisível para `Database.MigrateAsync()`,
  `dotnet ef migrations list` e designer).
- Toda migração hand-written PRECISA de `[DbContext(typeof(<Contexto>))]` **e**
  `[Migration("<id>")]`. Sem os dois, o deploy em ambiente novo quebra
  (tabelas/colunas aplicadas só no histórico `__EFMigrationsHistory`, sem fonte no repo).
- Migrações em **pasta única** `Migrations/`, junto com `*ModelSnapshot.cs` —
  nunca duas pastas de migrations coexistindo.
- Antes de commitar mudanças de modelo: `dotnet ef migrations has-pending-model-changes`
  deve responder "No changes".
- **Nunca** suprimir `RelationalEventId.PendingModelChangesWarning` em DI —
  o aviso existe para detectar drift modelo ↔ snapshot.
- `dotnet watch` ignora mudanças sem delta de IL: em container de dev, rodar
  `docker exec <container> dotnet build <projeto>.csproj` antes de reiniciar.

## Estrutura de projeto típica (Clean Architecture)

```
<Repo>/
├── <Solution>.sln
├── Directory.Build.props              # nullable, implicit usings, treatments
├── <Project>.Api/                     # Apresentação
│   ├── Program.cs                     # Entry point + DI composition
│   ├── Controllers/V1/ V2/            # REST versionado ([ApiVersion])
│   ├── Middleware/                    # Exception, CorrelationId, Tenant
│   ├── Extensions/                    # DI extensions por camada
│   └── appsettings.json
├── <Project>.Application/             # Negócio (CQRS)
│   ├── DependencyInjection.cs
│   ├── Abstractions/                  # ICommand/IQuery, Result<T>, PagedResult
│   ├── Behaviors/                     # ValidationBehavior, LoggingBehavior
│   ├── Features/<Feature>/            # Command/Handler/Validator/Dto por feature
│   └── Mappings/                      # AutoMapper profiles
├── <Project>.Domain/                  # Primitives, Interfaces, Exceptions, Enums
├── <Project>.Infrastructure/          # Persistence (DbContext, Configurations), Observability
├── <Project>.UnitTests/               # Testes por feature (xUnit)
└── <Project>.IntegrationTests/        # Fixtures (se existir)
```

## Padrões dominantes

### CQRS com MediatR
- Commands (escrita) e queries (leitura) como `record ... : ICommand<T>/IQuery<T>`
- Handler `IRequestHandler<TCommand, Result<TDto>>`; persiste via `IApplicationDbContext`
- Registro: `services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(...))` + validators por assembly

### Result Pattern (não exceptions para business logic)
- `Result`/`Result<T>` com `IsSuccess`/`Error(Code, Message)`; controller retorna
  `CreatedAtAction` ou `BadRequest(result.Error)` — sem throw para fluxo normal

### FluentValidation
- Um validator por command/query (`AbstractValidator<T>`), registrado via
  `AddValidatorsFromAssemblyContaining<>()`; disparado pelo `ValidationBehavior`
  (pipeline MediatR — validação ANTES de logging na ordem de registro)

### EF Core
- `IEntityTypeConfiguration<T>` por entity, aplicados via
  `ApplyConfigurationsFromAssembly` no `OnModelCreating`
- DbContext em Infrastructure com DI: `AddDbContext<AppDbContext>(o => o.UseSqlServer(...))`

### API Versioning + Middleware
- Controller: `[ApiController]`, `[ApiVersion("1.0")]`, rota `v{version:apiVersion}/[controller]`
- Pipeline Program.cs: correlation id → middleware custom → auth → controllers → health

### DI por camada
- Extension methods `AddApplicationServices`/`AddInfrastructureServices` — um por projeto

## Testes

- **Stack:** xUnit + Moq + FluentAssertions; naming `Method_Scenario_ExpectedResult`
  (ex: `GetUser_WithValidId_ReturnsUser`); AAA sem lógica no teste
- **Handler:** mock de `IApplicationDbContext` (Moq), verify de `Add`/`SaveChanges`;
  `[Theory]/[InlineData]` para cenários de erro do contrato
- **Validator:** `TestValidate` + `ShouldHaveValidationErrorFor` (FluentValidation.TestExtensions)
- **Pacotes (UnitTests.csproj):** xunit, xunit.runner.visualstudio, Microsoft.NET.Test.Sdk,
  Moq, FluentAssertions, FluentValidation.TestExtensions

## Pitfalls

1. **DI lifecycle mismatch** — `AddSingleton` com service `Scoped` (ex: DbContext) quebra thread-safety; confira lifecycle por dependência
2. **Sync-over-async** — nunca `.Result`/`.Wait()`/`.GetAwaiter().GetResult()` em contexto async (deadlock em ASP.NET Core)
3. **Nullable reference types** — `<Nullable>enable</Nullable>` em `Directory.Build.props`; `?` em opcionais, `!` só com certeza
4. **EF tracking** — `AsNoTracking()` em queries de leitura; sem lazy loading em APIs
5. **EF N+1** — `Include()`/`ThenInclude()` para eager loading
6. **Retorno de endpoint** — `IActionResult` com tipos explícitos; `TypedResults` em minimal APIs
7. **Versioning inconsistente** — `[ApiVersion]` + rota versionada; não misturar versões no mesmo controller
8. **Segredos** — User Secrets em dev, Variable Groups em prod; nunca commit segredo real
9. **MediatR registration order** — behaviors rodam na ordem registrada; validação antes de logging
10. **EF migration sem snapshot** — `*ModelSnapshot.cs` atualizado antes de nova migração
11. **Testes sem cleanup** — `IClassFixture<T>` para estado compartilhado; `IAsyncLifetime` para cleanup assíncrono
12. **Controller sem `[ApiController]`** — validação automática e `[FromBody]` deixam de funcionar
13. **Migrações órfãs no histórico** — migração em `__EFMigrationsHistory` sem fonte no repo indica hand-written ignorada/perdida; cruzar `dotnet ef migrations list` com o histórico antes de deploy em ambiente novo

## Quality Checks

### Automação

| Check | Comando | O que verifica |
|-------|---------|----------------|
| Formatação | `dotnet format --verify-no-changes` | Estilo, espaçamento, arranging |
| Build warnings | `dotnet build -warnaserror` | warnings do compilador |
| Lint (se habilitado) | Roslyn analyzers via build | Code analysis rules |
| Testes | `dotnet test --verbosity normal` | Suíte completa verde |
| Cobertura | `dotnet test /p:CollectCoverage=true` | Line/branch coverage |

### Padrões da stack

- **Naming:** `PascalCase` para classes/métodos, `_camelCase` para fields privados, `SCREAMING_SNAKE_CASE` para constantes
- **Testes:** `Method_Scenario_ExpectedResult` (ex: `GetUser_WithValidId_ReturnsUser`)
- **Estrutura:** Clean Architecture (Api → Application → Domain → Infrastructure)
- **DI:** Extension methods por camada (`AddApplicationServices`, `AddInfrastructureServices`)

### Limites

| Check | Limite | Severidade |
|-------|--------|------------|
| Método | ≤ 30 linhas | error |
| Classe | ≤ 300 linhas | error |
| Parâmetros | ≤ 4 | warning |
| Complexidade ciclomática | ≤ 10 | warning |
| Depenedências por classe | ≤ 7 | warning |

## Algoritmo

1. **Detectar stack:** confirme `*.csproj` ou `*.sln` no repo alvo. Sem eles → `warn` (ver Modo de erro).
2. **Carregar convenções:** leia o `AGENTS.md` do repo (precedência sobre este playbook) e confira TargetFramework no `*.csproj`.
3. **Contextualizar a task:** leia os artefatos de spec referenciados (TASKS.md, API_CONTRACTS.md, ERROR_CATALOG.md) para saber o **o quê**.
4. **Antes de codar — verificar se o repo é vazio:** chame `rdd-stack-boilerplate` para clonar o boilerplate curado em vez de scaffold genérico:
   - Se o repo tiver menos que 3 arquivos (só README, .gitignore, LICENSE), está vazio → carregue `rdd-stack-boilerplate` (ou invoque-a direto).
   - Se o boilerplate for aplicado com sucesso, pule o scaffold manual (repos populados com .NET 10 + PostgreSQL + Docker + CI + Clean Architecture + MediatR + EF Core). Siga os padrões do boilerplate (estrutura, convenções, DI), que têm precedência sobre o playbook.
   - Se o boilerplate não se aplicar (stack sem template no registry, repo já populado, ou falha), siga o passo 5 normalmente.
5. **Aplicar na implementação:** use os padrões deste playbook (Clean Architecture, CQRS/MediatR, Result, FluentValidation, EF Core) ao codar.
6. **Verificar:** rode `dotnet build && dotnet test && dotnet format --verify-no-changes` com a suíte inteira verde.
7. **Relatar:** arquivos tocados, testes verdes, decisões tomadas, RNs cobertas.

## Casos de Borda

- **Repo multi-solution (`.sln` em subpasta):** usar `dotnet build <path>/<Solution>.sln`; reportar se há múltiplos `.sln` sem clareza qual usar
- **Projeto com Docker:** testar build dentro do container se `Dockerfile` existir — `docker build -f <Project>.Api/Dockerfile.dev .`
- **Projeto com testes de integração:** usar TestContainers ou banco de teste separado; não testar contra banco de dev
- **Versioning de API:** se o projeto não tem versioning configurado, usar `[ApiVersion("1.0")]` e documentar como decidido
- **EF Core sem migrations:** se não há `Migrations/` folder, criar `InitialCreate` migration antes de implementar
- **`.editorconfig` ausente:** perguntar ao operador sobre convenções de formatação (tabs vs spaces, naming)
- **Projeto legado (.NET Framework):** se `TargetFramework` é `net4*`, não é .NET Core — reportar `needs-stack-playbook.`

## Formato de commit

```
feat(<modulo>): <descricao-curta> — refs RN-XXX
```

(Convenção final pertence ao AGENTS.md do repo — este playbook só
sugere o estilo dominante.)
