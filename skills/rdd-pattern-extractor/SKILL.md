---
name: rdd-pattern-extractor
description: >-
  Extrai padrões reutilizáveis de retrospectivas de projetos e os
  documenta no `accumulation/patterns/` do pack ativo da organização (ex.:
  `packs/<pack-ativo>/accumulation/patterns/`). Acumula referências de múltiplos
  projetos no mesmo padrão. Atualiza INDEX.md automaticamente. Invocada por
  rdd-project-retrospective ou manualmente via "extrair padrões",
  "pattern library", "documentar padrão". Mantém staleness por item — coluna
  `data_ultima_revisao` (MP-03: validade temporal) e invalidação por
  contradição — `status: ativo | superado` + `superado_por` (P-05/MP-13:
  conflito invalida, idade não).
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
- `~/.config/opencode/knowledge/knowledge-management/KNOWLEDGE.md` — fundação do domínio (MP-03: staleness é atributo do ITEM, não da store)

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
4. **Detecção de conflito (P-05/MP-13 — invalidação por contradição):** se o
   padrão novo tem o MESMO domínio-problema/gatilho de um existente com
   abordagem CONTRADITÓRIA, não crie duplicado nem sobrescreva: marque o
   antigo `status: superado` + `superado_por: <novo padrão>` no PATTERN.md e
   no INDEX, preservando arquivo/histórico (Zep: `invalid_at`, nunca delete).
   Idade >6m segue sendo apenas GATILHO DE REVISÃO — conflito é o que
   invalida, não o tempo.
5. Se existe (sem conflito): adicionar novo projeto de referência **e
   atualizar `data_ultima_revisao`** para a data da revisão (AAAA-MM-DD)
6. Se não existe: criar novo padrão

### Passo 3 — Criar/atualizar padrão

**Template de padrão:**

```markdown
# <Nome do Padrão>

**Categoria:** <autenticação | paginação | erros | validação | multi-tenancy | data-model | api-design | testes | deployment | outros>
**Tipo:** <processo | arquitetura | codigo | ui | teste | dados>
**Projetos que usaram:** <lista com datas>
**Stacks aplicáveis:** <dotnet | java | rust | angular | all>
**Maturidade:** <novo | validado | consolidado>
**Última revisão:** <AAAA-MM-DD — preencher na criação; atualizar a cada revisão>
**Status:** <ativo | superado — ativo por padrão>
**Superado por:** <slug do padrão que o invalidou — `—` quando vazio (padrão)>
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

**`data_ultima_revisao` (MP-03 — validade temporal, padrão Zep):** staleness é
atributo do ITEM, não da store — preenchida na criação do padrão e atualizada
a cada revisão; nunca removida (merge incremental preserva entradas). É a
coluna que permite identificar no INDEX padrões sem revisão há mais de 6 meses.

**`status` / `superado_por` (P-05 — invalidação por contradição; MP-13):** a
verdade do padrão resolve-se por CONTRADIÇÃO, não por idade: padrão novo com
o mesmo domínio-problema/gatilho e abordagem contraditória marca o antigo
como `superado` apontando `superado_por: <novo>`, com arquivo e histórico
preservados (Zep: `invalid_at`, nunca delete). Idade >6m
(`data_ultima_revisao`) é apenas gatilho de revisão — nunca veredito de
verdade.

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
> Staleness (MP-03): idade (`data_ultima_revisao` > 6m) = GATILHO de revisão,
> nunca veredito de verdade (P-05). Verdade resolve-se por invalidação por
> contradição: conflito detectado marca o antigo `status: superado` +
> `superado_por` — histórico preservado, nunca delete (MP-13).

## Índice

| Padrão | Tipo | Categoria | Projetos | Maturidade | data_ultima_revisao | status |
|--------|------|-----------|----------|------------|---------------------|--------|
| [jwt-auth](codigo/jwt-auth/PATTERN.md) | codigo | autenticação | Arbor, Salon | consolidado | 2026-01-15 | ativo |
| [api-pagination](codigo/api-pagination/PATTERN.md) | codigo | api-design | Arbor | novo | 2026-02-01 | ativo |
| [adaptacao-produto-irmao](processo/adaptacao-produto-irmao/PATTERN.md) | processo | outros | Salon | novo | 2026-02-10 | ativo |

## Por Tipo

### Processo
- [adaptacao-produto-irmao](processo/adaptacao-produto-irmao/PATTERN.md) — reaproveitar design de produto-irmão (revisão: 2026-02-10)
- <padrão invalidado> — <descrição> (revisão: AAAA-MM-DD) [superado por <novo-padrão>]

### Arquitetura
- <padrão> — <descrição> (revisão: AAAA-MM-DD)

### Código
- [jwt-auth](codigo/jwt-auth/PATTERN.md) — JWT com refresh token (revisão: 2026-01-15)

### UI
- <padrão> — <descrição> (revisão: AAAA-MM-DD)

### Teste
- <padrão> — <descrição> (revisão: AAAA-MM-DD)

### Dados
- [api-pagination](codigo/api-pagination/PATTERN.md) — Paginação offset/cursor (revisão: 2026-02-01)
```

Convenção de invalidação no INDEX: a coluna `status` da tabela principal
registra `ativo | superado`; as listagens Por Tipo e Por Categoria marcam o
padrão invalidado com o sufixo `[superado por <slug>]` quando aplicável — o
arquivo do padrão superado é preservado (nunca delete).

### Passo 6 — Reportar

Exiba resumo:
```
══ rdd-pattern-extractor ═══
padrões analisados: N
novos padrões: N
padrões atualizados: N
total na library: N
stale (>6m sem revisão): N
superados (conflito): N
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
- **Padrão obsoleto (nenhum projeto recente usa):** sinalize como candidato
  a revisão no relatório — `status` só registra `ativo | superado`
  (invalidação por contradição); idade não muda status
- **Padrão novo contradiz existente (mesmo domínio-problema, abordagem
  oposta):** marque o antigo `status: superado` + `superado_por: <novo>`
  (Passo 2.4); pergunte ao usuário apenas se a contradição for duvidosa
- **Padrão sem revisão há mais de 6 meses:** identifique pela coluna
  `data_ultima_revisao` do INDEX e sinalize como candidato a revisão no
  relatório (Passo 6); nunca delete — merge incremental preserva entradas

## Formato de commit

```
docs(patterns): add <nome-do-padrao> — extraído de <projeto>
```
