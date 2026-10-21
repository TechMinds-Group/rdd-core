---
name: rdd-pattern-extractor
description: >-
  Extrai padrões reutilizáveis de retrospectivas de projetos e os
  documenta no `accumulation/patterns/` do pack ativo da organização (ex.:
  `packs/<pack-ativo>/accumulation/patterns/`). Acumula referências de múltiplos
  projetos no mesmo padrão. Atualiza INDEX.md automaticamente. Invocada por
  rdd-project-retrospective ou manualmente via "extrair padrões",
  "pattern library", "documentar padrão".
---
# rdd-pattern-extractor — Extrator de Padrões

Extrai padrões reutilizáveis de retrospectivas de projetos e os
documenta na pattern library. Cada padrão é um documento em
`accumulation/patterns/<tipo>/<slug>/PATTERN.md` do pack ativo da organização
(ex.: `packs/<pack-ativo>/accumulation/patterns/`) que acumula referências de
múltiplos projetos. Tipos de padrão: **processo | arquitetura | codigo | ui | teste | dados**.

## Fronteira com stack playbooks (evitar duplicação)

- **Playbook** (`rdd-stack-dotnet-csharp`, `rdd-stack-java-quarkus`, `rdd-stack-rust`, `rdd-stack-angular`): convenções GERAIS da stack (estrutura, comandos, pitfalls) — valem sempre, lidas no dev.
- **Pattern**: solução de um CENÁRIO específico, idealmente multi-stack — consultada sob demanda.
- Regra: se vale para a stack inteira, sempre → playbook; se é resposta a um cenário → pattern.

## Resolução de destino (IMP-061/IMP-111)

Todos os `accumulation/patterns/` referidos nesta skill são relativos ao
**`accumulation/` do pack ativo da organização** (ex.: `packs/<pack-ativo>/accumulation/`
— resolução via `packs:` do client-profile), sinalizado pelo bloco
`<!-- rdd-pack-accumulation -->` do AGENTS.md global:

1. Bloco presente (pack ativo configurado) → destino =
   `packs/<pack-ativo>/accumulation/patterns/`.
2. Bloco ausente → pergunte ao usuário via `question` qual é o pack ativo
   (instalado em `packs/<id>/`) e sugira configurar o bloco. **Nunca** use
   `~/.config/opencode/docs/` como destino — a config do RDD é
   genérica/portável, sem conteúdo de negócio.
3. Exceção sandbox de eval: resolva os paths relativos à raiz do sandbox
   (fixtures usam `docs/` relativo).

## Lê (upstream)

- `docs/projects/*/RETROSPECTIVE.md` — fonte de padrões
- `accumulation/patterns/INDEX.md` do pack ativo — índice atual de padrões
- `accumulation/patterns/<tipo>/*/PATTERN.md` — padrões existentes (para merge)

## Gera (downstream)

- `accumulation/patterns/<tipo>/<slug>/PATTERN.md` do pack ativo — novo padrão ou atualização
- `accumulation/patterns/INDEX.md` do pack ativo — índice atualizado

## Nunca edita

- Retrospectivas (read-only)
- Código-fonte de projetos

## Tools

- `read`/`glob`/`grep` — ler retrospectivas e padrões existentes
- `write` — criar/atualizar padrões e índice
- `question` — perguntar ao usuário (padrão muito similar a existente; destino do acúmulo quando o pack ativo não estiver configurado — bloco `rdd-pack-accumulation` ausente — IMP-061/IMP-111)

## Workflow

### Passo 1 — Ler retrospectivas

Leia todas as retrospectivas disponíveis:
```
docs/projects/*/RETROSPECTIVE.md
```

Para cada retrospectiva, extraia a seção "Padrões extraídos".

### Passo 2 — Identificar padrões novos vs existentes

Para cada padrão extraído:
1. Classifique o **Tipo**: `processo | arquitetura | codigo | ui | teste | dados`
2. Normalizar o nome (slug: `kebab-case`)
3. Verificar se `accumulation/patterns/<tipo>/<slug>/PATTERN.md` do pack ativo já existe
4. Se existe: adicionar novo projeto de referência
5. Se não existe: criar novo padrão

### Passo 3 — Criar/atualizar padrão

**Template de padrão:**

```markdown
# <Nome do Padrão>

**Categoria:** <autenticação | paginação | erros | validação | multi-tenancy | data-model | api-design | testes | deployment | outros>
**Tipo:** <processo | arquitetura | codigo | ui | teste | dados>
**Projetos que usaram:** <lista com datas>
**Stacks aplicáveis:** <dotnet | java | rust | angular | all>
**Maturidade:** <novo | validado | consolidado>
**Evidência:** <repo/PR/DEC-XXX onde foi aplicado — alimenta a maturidade>

## Cenário

<para Tipo codigo/ui/teste: o cenário específico que dispara o padrão ("quando o endpoint precisa ser idempotente...") — para Tipo processo, funde com a Descrição>

## Descrição

<quando usar este padrão, qual problema resolve>

## Implementação

<para Tipo codigo/ui/teste: código compilável por stack — OBRIGATÓRIO ao menos na stack principal onde surgiu>

### <Stack 1> (ex: .NET C#)

```csharp
// código exemplo
```

### <Stack 2> (ex: Java/Quarkus)

```java
// código exemplo
```

## Quando NÃO usar

<anti-patterns, situações onde este padrão não se aplica>

## Variações

<variações do padrão por contexto>

## Referências

- Retrospectiva: `docs/projects/<projeto1>/RETROSPECTIVE.md`
- Retrospectiva: `docs/projects/<projeto2>/RETROSPECTIVE.md`
- Evidência de aplicação: repo/PR/DEC (obrigatório para promover maturidade)
- Links externos (se aplicável)
```

### Passo 4 — Classificar maturidade

| Projetos | Maturidade |
|----------|------------|
| 1 | `novo` |
| 2-3 | `validado` |
| 4+ | `consolidado` |

### Passo 5 — Atualizar INDEX.md

Gere/atualize `accumulation/patterns/INDEX.md` do pack ativo:

```markdown
# Pattern Library — <pack-ativo> (accumulation/patterns)

> Padrões reutilizados extraídos de retrospectivas de projetos.
> Atualizado automaticamente por `rdd-pattern-extractor`.

## Índice

| Padrão | Tipo | Categoria | Projetos | Maturidade |
|--------|------|-----------|----------|------------|
| [jwt-auth](codigo/jwt-auth/PATTERN.md) | codigo | autenticação | Arbor, Salon | consolidado |
| [api-pagination](codigo/api-pagination/PATTERN.md) | codigo | api-design | Arbor | novo |
| [adaptacao-produto-irmao](processo/adaptacao-produto-irmao/PATTERN.md) | processo | outros | Salon | novo |

## Por Tipo

### Processo
- [adaptacao-produto-irmao](processo/adaptacao-produto-irmao/PATTERN.md) — reaproveitar design de produto-irmão

### Arquitetura
- <padrão> — <descrição>

### Código
- [jwt-auth](codigo/jwt-auth/PATTERN.md) — JWT com refresh token

### UI
- <padrão> — <descrição>

### Teste
- <padrão> — <descrição>

### Dados
- [api-pagination](codigo/api-pagination/PATTERN.md) — Paginação offset/cursor
```

### Passo 6 — Reportar

Exiba resumo:
```
══ rdd-pattern-extractor ═══
padrões analisados: N
novos padrões: N
padrões atualizados: N
total na library: N
```

## Modo de erro

`warn` — falhas parciais não abortam a execução: entram no resumo final
como ⚠️ com orientação. Só é `strict` na escrita: sem destino resolvido
(pack ativo não configurado — bloco `rdd-pack-accumulation` ausente — e
operador não informou o pack) ou sem permissão de escrita em
`accumulation/patterns/`, a skill termina com falha clara
e nada é gravado.

## Casos de Borda

- **Retrospectiva sem seção "Padrões extraídos":** pule, avise
- **Padrão com nome muito similar a existente:** pergunte ao usuário
  se é o mesmo padrão ou um novo
- **Padrão muito específico de um projeto:** classifique como `novo`,
  espere confirmação de outros projetos para promover
- **Padrão obsoleto (nenhum projeto recente usa):** marque como
  `obsoleto` no INDEX, não delete

## Formato de commit

```
docs(patterns): add <nome-do-padrao> — extraído de <projeto>
```
