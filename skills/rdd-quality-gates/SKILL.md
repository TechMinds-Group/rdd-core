---
name: rdd-quality-gates
description: >-
  Quality gates universal para qualquer stack backend e frontend Angular —
  verifica KISS, YAGNI, DRY, SOLID, Clean Code, padrões de teste, segurança
  e performance. Comandos de automação vêm do playbook da stack carregado
  (fonte única — IMP-077). Métricas: complexidade, cobertura, duplicação,
  smell-count. Carregada por rdd-dev-backend (Passo 7.1) e rdd-dev-frontend,
  ou manualmente via skill.
  Use junto com "quality gates", "qualidade de código", "SOLID", "KISS",
  "YAGNI", "DRY", "code review", "métricas". Use quando o usuário pedir
  para verificar qualidade, rodar quality checks ou auditar código.
---
# rdd-quality-gates — Checklist Universal de Qualidade de Código

Skill transversal de qualidade para qualquer stack backend. Verifica
princípios de código, padrões de teste, segurança e performance.
**Não substitui** o playbook da stack — complementa com verificações
transversais que se aplicam a qualquer linguagem.

## Lê (upstream)

- Código-fonte do repo alvo (read-only) — arquivos modificados pela task
- Playbook da stack carregado (se existir) — para comandos de verificação
- `AGENTS.md` do repo — convenções específicas

## Gera (downstream)

- Nenhum artefato de módulo — esta skill gera checklist e métricas para
  o relatório do rdd-dev-backend

## Nunca edita

- Código-fonte (read-only)
- Artefatos de spec RDD

## Tools

- `read`/`glob`/`grep` — inspecionar código (read-only)
- `bash` — executar comandos de formatação/lint da stack

## Modo de erro

`warn` — ferramenta de automação indisponível ou com falha não bloqueia a
auditoria: pule o comando, registre como "não executado" no relatório e
siga com a verificação manual das seções A-E. Quality gate `FAIL` não
aborta a skill — apenas bloqueia o `[done]` da task no rdd-dev-backend.

## A — Princípios de Código

### KISS (Keep It Simple, Stupid)

> Manter soluções o mais simples possível. Se uma solução tem mais de 2
> alternativas, escolha a mais direta e legível.

| Regra | Verificação | Severidade |
|-------|-------------|------------|
| Método com ≤ 1 nível de abstração | Cada função faz UMA coisa | error |
| Método com ≤ 30 linhas | `wc -l` ou contagem manual | error |
| Solução mais direta escolhida | Sem frameworks complexos para problemas simples | warning |
| Sem over-engineering | Classes/interfaces que não são usadas pela task atual | warning |

### YAGNI (You Ain't Gonna Need It)

> Não implemente funcionalidade futura. Só code o que a spec pede HOJE.

| Regra | Verificação | Severidade |
|-------|-------------|------------|
| Sem código "para o futuro" | Classes/métodos que não são chamados pela task | error |
| Sem abstrações genéricas prematuras | Interfaces com 1 implementação | warning |
| Sem features não solicitadas | Tudo que foi implementado mapeia para RN | error |
| Sem parametrização excessiva | Config options que ninguém usa | warning |

### DRY (Don't Repeat Yourself)

> Extraia lógica duplicada para métodos, services ou herança.

| Regra | Verificação | Severidade |
|-------|-------------|------------|
| Code duplication < 3% | Blocos > 10 linhas duplicados | error |
| Lógica de negócio não duplicada | Mesma regra em 2+ lugares → extrair | error |
| Validação não duplicada | Usar framework de validação (FluentValidation, etc.) | warning |
| Config não duplicada | Constantes centralizadas, não hardcoded em vários arquivos | warning |

### SOLID

| Princípio | Regra | Verificação | Severidade |
|-----------|-------|-------------|------------|
| **SRP** | 1 classe = 1 responsabilidade | Max 5 métodos públicos, max 3 concerns | error |
| **OCP** | Aberto para extensão, fechado para modificação | Strategy para > 3 branches no mesmo tipo | warning |
| **LSP** | Subtipos são substituíveis | Sem `NotImplementedException` em overrides | error |
| **ISP** | Interfaces pequenas | Max 5 métodos por interface | warning |
| **DIP** | Depender de abstrações | Constructor injection, nenhum `new` de serviço | error |

### Clean Code

| Regra | Verificação | Severidade |
|-------|-------------|------------|
| Nomes revelam intenção | `GetOverdueOrders()` não `GetOrders()` | warning |
| Parâmetros ≤ 4 | Mais que 4 → usar record/objeto | warning |
| Early return | Evitar if/else aninhado > 2 níveis | warning |
| Funções puras quando possível | Sem side effects em lógica de negócio | warning |
| Constantes nomeadas | Sem números mágicos (`MAX_RETRY = 3` não `if (count > 3)`) | error |

## B — Checklist de Código

### Erros (error — bloqueante)

- [ ] Método > 30 linhas → refatore (Extract Method)
- [ ] Classe > 300 linhas → divida por responsabilidade
- [ ] Catch vazio (`catch { }`) → registre log ou re-throw
- [ ] `Console.WriteLine` / `print` em código de produção → remova ou use logger
- [ ] `new` direto de serviço (DI container) → use constructor injection
- [ ] `async void` (exceto event handlers) → mude para `async Task`
- [ ] TODO sem ticket → `TODO(autor): descrição [TICKET-123]`
- [ ] Código comentado removido → use git history
- [ ] Números mágicos → extraia para constante nomeada
- [ ] SQL concatenado → use parameterized queries / ORM

### Warnings (warning — informativo)

- [ ] Método com muitos níveis de abstração → extraia helpers
- [ ] Classe com muitos dependencies → aplique ISP (interfaces menores)
- [ ] Parâmetros > 4 → use record/DTO
- [ ] Método faz muita coisa → divida (SRP)
- [ ] Código duplicado em 2+ arquivos → extraia para service/shared
- [ ] Validação inline → use framework (FluentValidation, etc.)
- [ ] Magic strings → extraia para constants ou enums

## C — Padrões de Teste

### Pirâmide de Testes

```
        /\
       / E2E \          ~10% — lento, caro, frágil
      /--------\
     /Integração\       ~20% — velocidade moderada
    /--------------\
   /  Unitários     \   ~70% — rápido, isolado, barato
  /------------------\
```

### AAA (Arrange, Act, Assert)

```csharp
[Fact]
public void CalculateTotal_WithValidItems_ReturnsSum()
{
    // Arrange
    var items = new[] { new Item(10), new Item(20) };
    var calculator = new OrderCalculator();

    // Act
    var result = calculator.CalculateTotal(items);

    // Assert
    Assert.Equal(30, result);
}
```

### Naming de Testes

| Stack | Formato | Exemplo |
|-------|---------|---------|
| .NET | `Method_Scenario_ExpectedResult` | `GetUser_WithValidId_ReturnsUser` |
| Java | `should ExpectedBehavior when Condition` | `shouldReturnUserWhenIdIsValid` |
| Rust | `fn test_<scenario>_<expected>` | `fn test_get_user_valid_id_returns_user` |

### Checklist de Testes

- [ ] 1 teste por RN mínimamente
- [ ] Cenários de erro cobertos (contrato)
- [ ] Testes independentes (ordem não importa)
- [ ] Sem dependência de estado externo (mock/in-memory)
- [ ] Determinísticos (sem random, sem time-dependent)
- [ ] Nome descreve comportamento testado
- [ ] AAA pattern (sem lógica no teste)
- [ ] Assertions ≤ 3 por teste (ideal: 1 por behavior)

## D — Segurança

### OWASP Top 10 — Checklist

| # | Risco | Verificação | Severidade |
|---|-------|-------------|------------|
| A01 | Broken Access Control | Auth + AuthZ em todos os endpoints | error |
| A02 | Cryptographic Failures | Usar bibliotecas estabelecidas, sem crypto custom | error |
| A03 | Injection | Parameterized queries / ORM, nunca SQL concatenado | error |
| A04 | Insecure Design | Threat modeling para features novas | warning |
| A05 | Security Misconfiguration | Defaults seguros, config validada | warning |
| A06 | Vulnerable Components | Dependency scanning (npm audit, cargo audit, etc.) | error |
| A07 | Auth Failures | Rate limiting, password hashing seguro | error |
| A08 | Data Integrity | Commits assinados, deployments imutáveis | warning |
| A09 | Logging Failures | Logging estruturado, sem dados sensíveis nos logs | warning |
| A10 | SSRF | Validação de input, allowlist de URLs | error |

### Validação de Input

- Usar framework de validação (FluentValidation, Jakarta Validation, etc.)
- Validar no handler/command, não no controller
- Limits de tamanho em strings (MaximumLength)
- Tipos primitivos validados (não confiar em casting)

### Secret Management

- [ ] Nenhum segredo hardcoded no código
- [ ] Segredos via environment variables ou secret manager
- [ ] `appsettings.json` sem segredos reais
- [ ] `.gitignore` exclui arquivos com segredos

## E — Performance

### N+1 Queries

```csharp
// ERRADO: N+1 queries
var orders = await context.Orders.ToListAsync();
foreach (var order in orders)
{
    order.Customer = await context.Customers.FindAsync(order.CustomerId); // N queries!
}

// CORRETO: Eager loading
var orders = await context.Orders
    .Include(o => o.Customer)
    .ToListAsync(); // 1 query
```

| Check | Severidade |
|-------|------------|
| Queries em loop → eager loading | error |
| `ToList()` antes de filtro → filtrar antes | warning |
| `AsNoTracking()` em queries de leitura | warning |
| `Include()` faltando → N+1 | error |

### Async/Await

| Check | Severidade |
|-------|------------|
| `.Result` / `.Wait()` / `.GetAwaiter().GetResult()` → deadlock | error |
| `Task.Run()` sem necessidade → thread pool starvation | warning |
| CancellationToken não propagado → memória leak | error |
| `ConfigureAwait(false)` em libraries | warning |

### Memória

| Check | Severidade |
|-------|------------|
| IDisposable sem `using` / `await using` | error |
| Coleções estáticas crescendo ilimitado | warning |
| Streams não disposed | error |
| Event handlers não unsubscribed | warning |

### Conexões

| Check | Severidade |
|-------|------------|
| Connection pooling habilitado | warning |
| Connection string com pooling params | warning |
| HttpClient sem IHttpClientFactory | error |

## F — Automação por Stack (fonte única: playbook da stack)

Os comandos de automação **não são duplicados nesta skill** — consulte a
seção "Comandos de build e verificação" / "Quality Checks" do playbook da
stack carregado (`rdd-stack-dotnet-csharp`, `rdd-stack-java-quarkus`,
`rdd-stack-angular`, `rdd-stack-rust`), que é a **fonte única** (IMP-077).
Sem playbook carregado, aplique apenas o checklist manual (A-E) e registre
automação como "não executada".

**Interpretação de resultados frontend Angular:** budget de bundle
excedido (`angular.json` budgets) = warning; erro de compilação
TypeScript = error; componente sem spec = warning.

## G — Métricas

Colete e reporte as seguintes métricas:

### Complexidade

| Métrica | Limite | Ação |
|---------|--------|------|
| Complexidade ciclomática | ≤ 10 por método | Refatorar se > 10 |
| Complexidade cognitiva | ≤ 15 por método | Refatorar se > 15 |
| Linhas por método | ≤ 30 | Extract Method |
| Linhas por classe | ≤ 300 | Dividir responsabilidade |

### Cobertura

| Métrica | Mínimo | Ação |
|---------|--------|------|
| Line coverage (novo código) | ≥ 80% | Adicionar testes |
| Branch coverage | ≥ 75% | Testar todos os caminhos |
| Mutation score | ≥ 70% | Mutation testing |

### Duplicação

| Métrica | Limite | Ação |
|---------|--------|------|
| Code duplication rate | < 3% | Extrair método compartilhado |
| Blocos duplicados > 10 linhas | 0 | Refatorar imediatamente |

### Technical Debt

| Métrica | Limite | Ação |
|---------|--------|------|
| Debt ratio | < 5% | Corrigir issues acumuladas |
| Issue density | < 1/1000 linhas | Resolver issues críticas |

## G2 — Triagem de Severidade com Jev (opcional, não bloqueante)

Issues ambíguas entre níveis (ex.: número mágico que pode ser regra de
negócio oculta × simples estilo) podem receber uma **segunda opinião
calibrada** do modelo Jev antes de classificar. Uso opcional e por exceção:
apenas quando a severidade não for óbvia pelas tabelas A-F. Executor:
**o caminho via `task` ao `@rdd-jev-classifier` só existe para quem tem a
tool `task`** (ex.: primary `rdd-dev` executando inline) — subagents como o
`rdd-dev-backend` usam o curl diretamente abaixo; os dois caminhos são
equivalentes.

**Chamada (PowerShell):**

```powershell
$key = [System.Environment]::GetEnvironmentVariable("TYPESAFE_API_KEY", "User")
$state = "Issue: <descricao da issue com trecho do codigo>`nContexto: <RN ou regra relacionada, se houver>"
$body = @{
  state = $state; model = "jev-latest"
  questions = @{
    severidade = @{ type = "choice"; criteria = @{ bloqueia_release = "Violacao de regra de negocio ou risco de bug em producao"; warning = "Divida tecnica ou legibilidade, sem quebra de regra"; info = "Estilo ou sugestao, sem efeito funcional" } }
    evidencia = @{ type = "noul"; instructions = "A issue tem evidencia objetiva no codigo, sem depender de contexto adicional?" }
  }
} | ConvertTo-Json -Depth 10
$r = Invoke-RestMethod -Uri "https://api.typesafe.ai/v1/systemone" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer $key" } -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
# $r.answers.severidade.choice + .confidence ; $r.answers.evidencia.noul
```

**Regras:**

- Sem chave de API, sem rede ou confidence < 0.5 → classifique pelas
  tabelas A-F e siga (a triagem Jev não aconteceu — não mencione no relatório)
- Confidence ≥ 0.5 → use a severidade sugerida e registre no relatório:
  `severidade: <nivel> (Jev, conf. <0.00-1.00>)`
- **NUNCA** invente "(Jev, conf. ...)" sem chamada real
- Issues com violação clara das tabelas A-F (severity error explícito) não
  precisam de triagem — use o Jev apenas na zona cinzenta

## H — Formato de Relatório

O executor (rdd-dev-backend ou rdd-dev-frontend) deve incluir as métricas
no relatório final. Exemplo backend:

```text
══ rdd-dev-backend — <task> ═══
repo: <nome>.<API|CORE> (stack: <stack>)
arquivos: <path:linha> — <change> (por arquivo)
RNs cobertas: RN-XXX, RN-YYY
testes: <N novos/N alterados> — <comando verify>: <PASS|FAIL|not-verified>
métricas: complexidade:<avg>/<max> | cobertura:<N%> | duplicação:<N%> | smells:<N critical/N major> | quality-gate:<PASS|WARN|FAIL>
decisões: <trade-off>
pendências: <lista ou "nenhuma">
```

No frontend, a linha `métricas:` usa `cobertura`/`smells`/`quality-gate`
(sem `complexidade`/`duplicação` quando não coletáveis) — ver formato do
`rdd-dev-frontend`.

### Interpretação do quality-gate

| quality-gate | Significado |
|--------------|-------------|
| `PASS` | Todos os checks error passaram, warnings≤5 |
| `WARN` | Todos os error passaram, warnings>5 |
| `FAIL` | Pelo menos 1 check error falhou — NÃO reportar done |

## Algoritmo

1. **Detectar stack:** leia o playbook da stack carregado (se existir)
   para identificar comandos de verificação
2. **Rodar automação:** execute os comandos de automação do playbook da
   stack (fonte única — seção F)
3. **Verificar checklist:** passe pelo checklist das seções B+C+D+E
4. **Coletar métricas:** complexidade, cobertura, duplicação
5. **Classificar:** PASS / WARN / FAIL
6. **Reportar:** inclua métricas no relatório do rdd-dev-backend

## Casos de Borda

- **Repo sem ferramentas de análise:** pule automação, faça apenas
  verificação manual. Sinalize no relatório que faltam tools
- **Métricas indisponíveis:** se não há como coletar cobertura
  (sem testes), reporte `cobertura: N/A`
- **Stack não listada:** aplique apenas checklist manual (A-E),
  sem automação
- **Refatoração grande:** se a task exige refatoração de classe
  > 500 linhas, divida em sub-tasks

## Formato de commit

```
refactor(<modulo>): <descricao-curta> — quality gates: PASS
```
