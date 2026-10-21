---
name: rdd-skill-eval
description: >-
  Executa testes de regressão (evals) em skills RDD a partir de fixtures
  armazenadas em evals/<skill>/fixture-N/. Cada fixture contém input de
  exemplo e criteria.yaml com checks esperados. A skill alvo é invocada
  com os inputs da fixture, o output gerado é verificado contra os criteria,
  e um relatório EVAL_REPORT_<skill>_<ts>.md é gerado com PASS/FAIL por check.
  Use quando o usuário pedir "testar skill X", "rodar evals", "verificar
  regressão", "golden path", ou automaticamente via @rdd-workflow-improver
  e @rdd-workflow-builder após edições em skills.
---
# rdd-skill-eval — Testes de Regressão para Skills RDD

Executa evals (testes de regressão) em skills RDD. Cada skill tem
fixtures em `evals/<skill>/fixture-N/` com:
- `input/` — arquivos de exemplo que a skill lê (REQUIREMENTS.md, etc.)
- `criteria.yaml` — checagens que o output gerado deve atender

## Runner determinístico

A verificação de checks NÃO precisa de agente: os scripts `evals/run-evals.ps1`
(Windows) e `evals/run-evals.sh` (Linux/Git-Bash) leem os criteria.yaml e
executam todos os tipos de check diretamente, com relatório e trends.
Prefira-os para rodar evals (`--all`, `--skill X`, `--changed`, `--golden`); a execução
da SKILL alvo dentro do sandbox continua sendo fluxo de agente.

O modo `--registry` (IMP-027) valida a consistência do `registry.yaml`
contra o disco: ids de primary_agents/subagents/skills vs arquivos em
`agents/` e `skills/`, referências resolvidas (`delegates`, `invokes`,
`available_to`, `owner`, `registered_by`, `orchestrator`; `null` é legítimo)
— 5 checks de config, independente de fixtures. Roda no CI junto com `--all`.

## Lê (upstream)

- `evals/<skill>/fixture-N/input/*.md` — inputs de exemplo para a skill
- `evals/<skill>/fixture-N/criteria.yaml` — critérios de avaliação
- A skill alvo (ex: `skills/rdd-data-model/SKILL.md`) — para entender o workflow
- (Opcional) `evals/<skill>/fixture-N/output-expected/` — outputs de referência

## Gera (downstream)

- `<config-root>/evals/reports/EVAL_REPORT_<skill>_<timestamp>.md`
- `<config-root>/evals/trends/trends.json` (append-only, histórico de scores)
- Sandbox temporário em `%TEMP%/opencode-eval/<skill>/<fixture>/` (destruído após o eval)

## Nunca edita

- Skills ou agents (read-only)
- Fixtures (são versionados, nunca alterados pelo eval)
- Artefatos de módulo RDD
- registry.yaml
- **`evals/golden-human/` (IMP-100) é intocado por agents** - golden set humano: leitura ok; escrita SOMENTE pelo operador humano; exceção única (seed inicial) já consumida. Fixtures de agents vivem em `evals/<skill>/fixture-N/`.

## Tools

- `read` (ler fixtures, criteria.yaml, skills alvo)
- `glob` (listar fixtures por skill)
- `grep` (verificar presença/ausência de padrões no output)
- `question` (confirmar modo dry-run ou execução)
- `write` (escrever relatório de eval)
- `skill` (opcional — invocar a skill alvo com os inputs da fixture)

## Modo de erro

`interativo` — se uma fixture não tiver criteria.yaml ou inputs, pula com
warning. Se a skill alvo não existir, erro. Se o gh CLI falhar (para
rdd-gh-* skills), orienta mas não bloqueia.

## Modos de execução

| Modo | Flag | Comportamento |
|------|------|---------------|
| Todas as skills | `--all` | Roda fixtures de todas as skills com evals |
| Skill específica | `--skill rdd-data-model` | Roda só fixtures da skill |
| Fixture específica | `--fixture rdd-data-model/fixture-002` | Roda fixture exata |
| Apenas alteradas | `--changed` | Detecta skills modificadas (git diff) e roda só elas |
| Golden set humano | `--golden` | Roda só `evals/golden-human/case-*` (IMP-100); `--all` o inclui, junto do selftest do runner (`evals/runner-selftest/` — critérios com `expect: fail`: o check DEVE falhar; PASS = runner não discriminou = FAIL do eval) |

## Workflow

### Passo 1 — Determinar alvo

Use `glob` para listar `evals/<skill>/fixture-*/criteria.yaml`.
Filtre conforme o modo (`--skill`, `--fixture`, `--changed`).

### Passo 2 — Para cada fixture, executar:

#### 2a. Ler criteria.yaml

Leia o arquivo de critérios. Identifique:
- `inputs_required`: arquivos que devem existir em `input/`
- `checks`: lista de verificações

#### 2b. Ler inputs

Confirme que todos os `inputs_required` existem em `input/`.
Se faltar algum, a fixture é SKIPPED (não aborta o eval inteiro).

#### 2c. Executar a skill alvo em sandbox (OBRIGATÓRIO)

Toda fixture executável roda em **sandbox isolado**. NUNCA invocar a skill
apontando para artefatos reais de módulos. Para skills com dependência
externa inacessível (gh CLI sem auth, etc.), use dry-run declarado no relatório.

**Algoritmo de sandbox:**

1. **Criar sandbox:** `SANDBOX = %TEMP%/opencode-eval/<skill>/<fixture>/module`
   - Remover o diretório se existir (run anterior)
   - Copiar TODO o conteúdo de `input/` para dentro de `SANDBOX`
     preservando a estrutura (REQUIREMENTS.md fica na raiz do módulo sandbox)
2. **Invocar a skill:** carregue a skill alvo via `skill` tool e instrua:
   - Module root = `SANDBOX` (workdir absoluto)
   - Ler inputs de `SANDBOX`/`<arquivo>`
   - Escrever outputs relativos ao module root (ex: `SANDBOX/specs/DATA_MODEL.md`)
   - Modo não-interativo: NÃO usar `question`; em ambiguidade, gerar PEND-XXX
     no output como a skill faria em produção
3. **Coletar outputs:** tudo que existe em `SANDBOX` e não existia em `input/`
4. **Verificar checks:** resolver os paths de `criteria.yaml` contra `SANDBOX`
5. **Preservar em caso de FAIL:** se houver check `error` quebrado, mova o
   sandbox para `evals/reports/sandbox-<skill>-<fixture>-<ts>/` para
   depuração; caso contrário, destrua o sandbox

**Paths dos checks são sempre relativos ao module root** (`specs/DATA_MODEL.md`
significa `SANDBOX/specs/DATA_MODEL.md`).

#### 2d. Verificar checks

Para cada check em `criteria.yaml`, avalie:

| Tipo | Método de verificação |
|------|----------------------|
| `file_exists` | O arquivo de output foi gerado no caminho especificado |
| `section_exists` | O output contém a seção markdown exata |
| `contains` | O output contém o texto/pattern (grep) |
| `not_contains` | O output NÃO contém o texto/pattern (grep) |
| `table_has_columns` | A tabela markdown tem as colunas listadas |
| `no_todos` | Output não contém nenhum dos patterns (TODO, FIXME, etc.) |
| `frontmatter_valid` | Output começa com `---\n` e termina com `\n---` |
| `reference_match` | Output difere do baseline em `output-expected/` além de tolerâncias |
| `id_sequence` | IDs (RN-XXX etc.) aparecem em ordem crescente de primeira aparição |
| `cross_ref` | Todo ID citado no output existe nos arquivos de origem |
| `mermaid_valid` | Blocos mermaid têm tipo declarado, cercas fechadas e chaves balanceadas |
| `line_count_range` | Output tem entre min e max linhas (pega truncamento e alucinação) |
| `section_order` | Seções obrigatórias existem E aparecem na ordem especificada |
| `dir_has_files` | O diretório contém pelo menos 1 arquivo (para outputs com data no nome, ex: meetings/YYYY-MM-DD-NN.md) |
| `not_file_exists` | O arquivo NÃO foi gerado (contrato de abort/não-invenção: skill deve recusar criar artefato) |

**Regras do `reference_match`:** comparação linha a linha após normalização —
remover timestamps e datas em qualquer formato comum (`\d{4}-\d{2}-\d{2}`,
`\d{2}/\d{2}/\d{4}`, `\d{2}:\d{2}`), espaços à direita, múltiplos blank lines
consecutivos (colapsar em 1) e ordem de chaves em YAML front matter.
Diferenças além disso = FAIL. Se não houver baseline (`output-expected/`
ausente), o check é SKIPPED com warning.

**Parâmetros dos checks semânticos (camada 2):**

```yaml
# Ordem crescente de primeira aparição dos IDs no output.
# Uso: documentos onde as RNs são documentadas em sequência (DATA_MODEL,
# ACCEPTANCE_CRITERIA). NÃO aplicar em docs ordenados por dependência
# (TASKS) — lá a ordem das tasks não é a ordem das RNs.
- type: id_sequence
  path: "specs/DATA_MODEL.md"
  pattern: "RN-(\\d+)"        # regex com capture group do número
  allow_gaps: true            # false = não pode pular números entre aparições
  severity: error

# Todo ID citado no output deve existir em pelo menos um arquivo de origem.
# Pega RN alucinada (ex: RN-999 que não existe no REQUIREMENTS).
- type: cross_ref
  path: "specs/DATA_MODEL.md"
  pattern: "RN-(\\d+)"
  sources: ["REQUIREMENTS.md"]   # paths relativos ao module root do sandbox
  severity: error

# Blocos ```mermaid no output: tipo declarado na 1ª linha do bloco
# (erDiagram, flowchart, sequenceDiagram, etc.), cercas fechadas,
# chaves/colchetes balanceados. Não é parser completo — pega quebras óbvias.
# IMPORTANTE: linhas de relacionamento mermaid (contêm `--`, ex:
# `A }o--|| B : label`) usam `}` na sintaxe — EXCLUIR da contagem de chaves.
- type: mermaid_valid
  path: "specs/DATA_MODEL.md"
  severity: error

# Quantidade de linhas do output dentro da faixa. Pega truncamento
# (abaixo do min) e inflação/alucinação de conteúdo (acima do max).
# Definir faixa com folga a partir do baseline.
- type: line_count_range
  path: "specs/DATA_MODEL.md"
  min: 100
  max: 400
  severity: warning

# Seções obrigatórias existem E na ordem especificada (primeira aparição
# de cada seção deve ser crescente). Subconjunto de section_exists + ordem.
- type: section_order
  path: "specs/DATA_MODEL.md"
  sections:
    - "## 1. Diagrama Entidade-Relacionamento"
    - "## 2. Tabelas"
    - "## 3. Decisão de armazenamento"
  severity: error
```

Cada check pode ter severity `error` (bloqueante) ou `warning` (não bloqueante).

#### 2e. Coletar resultado

Para cada check: PASS, FAIL (error), WARN (warning), ou SKIPPED.

### Passo 3 — Gerar relatório

Escreva `evals/reports/EVAL_REPORT_<skill>_<ts>.md`:

```markdown
# EVAL REPORT — <skill>

> **Data:** DD/MM/AAAA HH:MM
> **Modo:** <all | skill | fixture>
> **Resultado geral:** ✅ PASS | ⚠️ WARNINGS | ❌ FAILURES

## Resultados por skill

### <skill> (<N> fixtures)

#### fixture-001: <nome>

| # | Check | Tipo | Resultado | Severidade |
|---|-------|------|-----------|------------|
| 1 | file_exists: specs/DATA_MODEL.md | file_exists | ✅ PASS | error |
| 2 | contains: RN-001 | contains | ✅ PASS | error |
| 3 | contains: RN-002 | contains | ❌ FAIL | error |

**Detalhes do FAIL #3:**
Pattern `RN-002` não encontrado em `specs/DATA_MODEL.md`

---

#### fixture-002: <nome>
...
```

### Passo 4 — Atualizar trends.json

Append em `evals/trends/trends.json` (nunca reescrever entradas antigas):

```json
{
  "<ISO-8601-timestamp>": {
    "trigger": "manual | workflow-improver | workflow-builder | pre-publish",
    "mode": "all | skill | fixture | changed",
    "skills": {
      "<skill>": { "score": 0.92, "passed": 11, "failed": 1, "skipped": 0 }
    }
  }
}
```

`score = passed / (passed + failed)` — checks SKIPPED não entram no cálculo.

### Passo 5 — Exibir resumo

Exiba no formato compacto:

```
══════ rdd-skill-eval — relatório ══════

rdd-data-model: 2 fixtures, 8/8 PASS ✅
rdd-task-spec: 1 fixture, 6/6 PASS ✅
rdd-gh-issue-creator: 1 fixture, 3/5 PASS, 2 SKIPPED ⚠️

Geral: 4 fixtures, 17/19 PASS, 2 SKIPPED
```

Se houver FAILs com severity `error`, sugira reverter a mudança na skill
ou corrigir o prompt. FAILs com severity `warning` são informativos.

## Casos de Borda

- **Skill sem fixtures:** avise que não há cobertura de eval para a skill
- **Fixture sem criteria.yaml:** SKIP com warning
- **Input faltando:** SKIP com warning (específico qual input)
- **Múltiplas skills no mesmo eval:** processe em sequência, uma por vez
- **Skill que não pode ser executada** (dependência externa sem auth, ex: gh CLI):
  registre `execution: SKIPPED (dry-run)` no relatório e avalie apenas os
  checks estruturais do input — nunca invoque sistemas externos reais
- **Skill recusa execução em sandbox** (ex: exige CONSTITUTION.md da raiz):
  copie arquivos de suporte mínimos para o sandbox; se ainda assim falhar,
  registre `execution: FAILED (sandbox-unsupported)` — não contorna rodando
  fora do sandbox
- **--changed sem git diff disponível:** fallback para `--all` com aviso
- **Sandbox anterior órfão:** a criação do sandbox sempre começa removendo
  o diretório anterior — execução é sempre idempotente
- **Encoding:** ler TODOS os arquivos .md como UTF-8 explícito (PowerShell 5.1
  sem flag decodifica como ANSI e corrompe "ã/ç/é", quebrando checks de
  seção e reference_match falsamente)
- **Regex em array literal PowerShell:** `"a","b","c" + [char] + "d"` dentro
  de `@()` produz elementos separados (vírgula precede `+`) — construir
  strings compostas em variável antes do array
- **Variáveis PowerShell são case-insensitive:** `$R` (resultados) e `$r`
  (conteúdo de arquivo) são A MESMA variável — um `Get-Content` sobrescreve
  o array de checks e `String += PSObject` falha com `op_Addition`. Usar
  nomes distintos (ex: `$CKS` para checks, `$doc` para conteúdo)
- **NUNCA nomear funções com nomes de alias nativos** (`rd`, `ri`, `gc`,
  `gi`, `sc`, `gw`, `sal`, `saps`...): **aliases vencem funções** no
  PowerShell — `function Rd {...}` é IGNORADA e `Rd arquivo` executa
  `Remove-Item arquivo`, DELETANDO o arquivo (incidente real: 1 fixture de
  input deletada; recuperada via git checkout). Nomes seguros: `ReadDoc`,
  `AddCheck`, `GetIdList`. Após qualquer comportamento "impossível" de
  script, suspeite de colisão de alias ANTES de culpar o ambiente
- **Sandbox em %TEMP% pode ser instável** (sync/AV podem reverter arquivos
  entre invocações, identidade-específico). Base de sandbox padrão:
  `~/.local/state/opencode-eval/sandboxes/` (fora de %TEMP%). Workaround
  para arquivo teimoso: gravar com nome `.staging` e `Rename-Item`
- **Fallback documental:** se o sandbox estiver indisponível, os checks
  podem rodar contra `output-expected/` como module root (mesmo conteúdo
  congelado) — registrar `execution: baseline-mode` no relatório

## Formato de commit

```
test(eval): add skill eval report for <skill>
```