---
name: rdd-agent-health-monitor
description: >-
  Monitora a saúde dos subagents e skills do RDD, verificando se estão
  respondendo corretamente, se seus artefatos de saída estão dentro dos
  padrões esperados e se seguem as checklists de CHECKLISTS.md (front
  matter, permissões, registro cruzado, portabilidade) e se as skills
  citadas nos componentes existem (referências órfãs — IMP-080). Gera
  AGENT_HEALTH_REPORT_<timestamp>.md. Read-only — não edita nenhum
  artefato. Use quando o usuário pedir "health check", "verificar saúde
  do workflow", "status dos agents", "diagnóstico do RDD", "checar
  conformidade" ou "executar checklist da config".
---
# rdd-agent-health-monitor — Monitor de Saúde dos Agents

Verifica a integridade do ecossistema RDD: subagents registrados,
skills com erros, artefatos órfãos, staleness e propagation status.
Gera um relatório de saúde que pode ser usado para manutenção preventiva.

**Diferenciação:**

| Skill | Escopo |
|-------|--------|
| `rdd-validate` | Integridade da DAG de documentos (RNs → downstreams) |
| `rdd-progress` | Progresso do pipeline (cobertura, drift, pendências) |
| `rdd-agent-health-monitor` | Saúde dos componentes do workflow (agents, skills, artefatos) |

## Referências

- Subagents e skills: `~/.config/opencode/agents/*.md`, `~/.config/opencode/skills/*/SKILL.md`
- PROPAGATION_STATUS.md: `quality/PROPAGATION_STATUS.md`
- TRACEABILITY.md: `quality/TRACEABILITY.md`

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):

- **Raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
- **`specs/`:** DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, FIGMA_PROMPTS.md, COMPLIANCE.md
- **`quality/`:** TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEABILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md
- **`delivery/`:** TASKS.md, TASKS_*.md, TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md
- **`support/`:** LEGACY_CONTEXT.md, KNOWN_ERRORS.md, MIGRATION.md, CHANGE_REQUESTS.md
- **`glossaries/`:** DEV_GLOSSARY.md, BUSINESS_GLOSSARY.md, USER_GLOSSARY.md, GLOSSARY.md
- **`docs/`:** howto/*.md e documentos auxiliares
- **`meetings/`, `contracts/`:** checkpoints (inalterados)

**Regra de fallback (transição):** ao **LER** um artefato, verifique primeiro
o caminho novo (ex: `specs/DATA_MODEL.md`); se não existir, use o caminho
legado na raiz do módulo (ex: `DATA_MODEL.md`). Ao **ESCREVER/GERAR**, use
sempre o caminho novo. Módulos ainda não migrados via `rdd-restructure`
continuam legíveis durante a transição.

## Lê (upstream)

- `~/.config/opencode/agents/*.md` (subagents e primary agents registrados)
- `~/.config/opencode/skills/*/SKILL.md` (skills registradas)
- `~/.config/opencode/CHECKLISTS.md` (critérios da verificação F)
- `~/.config/opencode/PERMISSIONS.md` (verificaão H, IMP-103)
- `~/.config/opencode/AGENTS.md` + `~/.config/opencode/rules/*.md` (verificação G, IMP-048)
- `<modulo>/<projeto>/quality/PROPAGATION_STATUS.md` (se existir)
- `<modulo>/<projeto>/quality/TRACEABILITY.md` (se existir)
- `<modulo>/<projeto>/` — todos os artefatos (para verificação de staleness e integridade)
- Artefatos da DAG (specs/, quality/, delivery/, support/, glossaries/, docs/)

## Gera (downstream)

- `<modulo>/<projeto>/quality/AGENT_HEALTH_REPORT_<yyyy-MM-dd-hh:mm>.md`
  ou na raiz do workspace se nenhum módulo estiver em contexto

## Nunca edita

- Nenhum artefato RDD, nenhum agente, nenhuma skill. **Read-only absoluto.**

## Tools

- `glob` (listar agents, skills, artefatos do módulo)
- `read` (ler metadados, PROPAGATION_STATUS, TRACEABILITY, artefatos)
- grep (buscar erros de parse, referências quebradas)
- question (perguntar qual módulo analisar quando múltiplos — Passo 1)

## Modo de erro

`warn` — se algum componente não puder ser avaliado (ex: artefato ausente),
inclua no relatório como "não avaliado" em vez de falhar. O relatório
deve ser gerado mesmo com dados parciais.

## Formato de commit

```
docs(governance): add agent health report <timestamp>
```

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → gere o relatório na raiz do workspace (sem contexto de módulo).
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual módulo analisar (ou "todos").

### Passo 2 — Verificação A: Subagents Registrados

1. Use `glob` em `~/.config/opencode/agents/*.md` para listar todos os
   subagents registrados.
2. Para cada subagent, leia o front matter e verifique:
   - `name` está presente e válido
   - `description` está presente
   - `permission` está definido e coerente com a função
3. Verifique se há subagents referenciados nos primary agents (`rdd-req.md`, `rdd-doc.md`, `rdd-dev.md`) que não
   existem como arquivo (referência quebrada).
4. Leia `registry.yaml` e valide, para cada subagent, `owner`, `available_to`
   e a compatibilidade entre `registered_by` legado e `owner`.
5. Verifique se cada delegate de um primary está presente em `available_to`.
6. Verifique se as arestas primário→subagent do `ARCHITECTURE.md` (§1-§4)
   estão coerentes com `registry.yaml` (delegates ∪ available_to) —
   drift de views = ⚠️ (IMP-080; cf. drift JEV corrigido no IMP-070).

### Passo 3 — Verificação B: Skills com Erros

1. Use `glob` em `~/.config/opencode/skills/*/SKILL.md` para listar skills.
2. Para cada skill, verifique:
   - `name` == nome da pasta (convenção)
   - `description` está presente e não está vazia
   - Seções obrigatórias presentes: `## Tools`, `## Modo de erro`, `## Algoritmo`
3. Busque por padrões de erro comum (case-insensitive): `TODO`, `FIXME`, `PLACEHOLDER`,
   `<descrição>`, `[NÃO IMPLEMENTADO]` no corpo.

### Passo 4 — Verificação C: Artefatos Órfãos

1. Liste todos os artefatos RDD no módulo (usando a estrutura IMP-011).
2. Para cada artefato, verifique se é referenciado em pelo menos um
   outro artefato (usando `grep`).
3. Artefatos não referenciados por ninguém são "órfãos".

### Passo 5 — Verificação D: Staleness dos Artefatos

1. Para cada artefato RDD, verifique a data da última modificação
   (`git log -1 --format=%ai -- <arquivo>` se em Git).
2. Classifique por idade:
   - < 7 dias → ✅ Fresco
   - 7-30 dias → ⚠️ Stale
   - > 30 dias → ❌ Muito stale

### Passo 6 — Verificação E: Propagation Status

1. Leia `quality/PROPAGATION_STATUS.md` (se existir).
2. Conte entradas pendentes (CRs aprovados sem reflexo).
3. Verifique se há CRs antigos (> 7 dias) ainda pendentes.

### Passo 7 — Verificação F: Conformidade com CHECKLISTS.md

Execute automaticamente os itens verificáveis das checklists de
`~/.config/opencode/CHECKLISTS.md` contra cada componente:

**Para cada skill (`skills/rdd-*/SKILL.md`):**
1. Front matter: `name` == pasta, lowercase-hyphen, ≤ 64; `description`
   com triggers; campo proibido `tools:` ausente
2. Seções obrigatórias presentes (Lê/Gera/Nunca edita/Tools/Modo de
   erro/Algoritmo ou Workflow/Casos de Borda)
3. Caminhos IMP-011 na seção Lê (subpasta primeiro, fallback raiz)

**Para cada subagent (`agents/*.md` com `mode: subagent`):**
4. `name` casa com arquivo, ≤ 64 chars; `mode: subagent`; temp 0.1/0.2
5. Campo proibido `tools:` ausente; `permission:` presente
6. `edit`/`write` nunca `allow` amplo (deny/ask/restrito)
7. **Portabilidade (IMP-016):** nenhum path de máquina absoluto no front
   matter (padrões `C:/...`, `D:/...` com usuário/sistema → violação)
8. **Referências de skills (IMP-080 — família IMP-067/069/072):** para
   cada skill `rdd-*`/`mcp-*` citada no arquivo (tabela de skills, seção
   Lê, Tools, Algoritmo/Workflow, Skills Transversais) — de subagents E
   primary agents:
   - Existe pasta `~/.config/opencode/skills/<nome>/`? **Não** → a citação
     está qualificada como project-local/condicional ("quando existir no
     projeto", "project-local", "(se existir)")? Sim → ⚠️ registrar como
     dependência externa; não → ❌ referência órfã
   - Existe mas NÃO está no `registry.yaml`? → ❌ não registrada
   - Está no registry mas a pasta não existe (ou vice-versa)? → ❌ drift

**Para cada primary (`mode: primary`):**
9. Sem campo `name:`; `temperature: 0.3`; permissão ampla; seções
   (Identidade, Precedência, Subagents, Roteamento, Comportamento)

**Integridade estrutural de front matter (IMP-086) — transversal a todo `agents/*.md` e `skills/*/SKILL.md`:**

10. **Delimitadores íntegros:** a 1ª linha do arquivo deve ser exatamente
    `---` e deve existir linha de fechamento exatamente `---` após o bloco
    YAML (antes de qualquer conteúdo). Malformado (` --`, `—`, trailing
    space, ausente) = ❌ FINDING **crítico** (não warning): o parser do
    OpenCode descarta o front matter INTEIRO em silêncio — `permission:`,
    `mode` e `temperature` caem nos defaults do runtime, sem erro nenhum.
    Caso real (IMP-086): ` --` na linha 24 do `rdd-req.md` derrubou o
    `question: allow` do agente.
10b. **BOM no início do arquivo (IMP-097):** o arquivo NÃO deve começar com
    BOM UTF-8 (`EF BB BF` / U+FEFF) — o primeiro byte legível deve ser o `---`
    do front matter. BOM presente = FINDING **crítico** (mesma classe do
    IMP-086: o parser pode não reconhecer o `---` com BOM como delimitador e
    descartar o front matter em silêncio). Caso real (IMP-097): os 3 primaries
    (`rdd-dev`, `rdd-doc`, `rdd-req`) foram reescritos pelo runtime com BOM
    durante a instalação da skill `rdd-detect-onboarding`. Verificação barata:
    ler os 3 primeiros bytes (`[IO.File]::ReadAllBytes` — `Get-Content`
    mascara o BOM) ou testar se o 1º caractere é U+FEFF.
11. **YAML parseável:** o bloco entre delimitadores deve ter estrutura
    `chave: valor` consistente — tabs, indentação quebrada ou chave solta
    sem valor onde mapping é esperado = ❌ FINDING.
12. **Permissões declaradas (agents):** o bloco `permission:` deve existir
    dentro dos delimitadores, com as chaves esperadas do componente. Lembrar:
    as checagens 1-9 acima leem o ARQUIVO e podem parecer conformes mesmo
    quando o runtime descarta o front matter — as checagens 10-12 são o que
    tornam o defeito DETECTÁVEL no texto.
13. **Confirmação em runtime (prova definitiva, quando disponível):**
    `opencode debug agent <nome>` — se o campo `prompt` do JSON começa com
    o YAML cru (`---...`), o front matter NÃO foi parseado; se `mode` ou
    `temperature` no JSON divergirem do declarado no arquivo, idem.
    Registrar como ❌ confirmado em runtime (aplica-se só a agentes
    carregáveis — arquivos avulsos fora de `agents/` ficam nas checagens
    textuais 10-12).

**Itens não automatizáveis** (qualidade de conteúdo, smoke test) ficam
como "revisão humana" no relatório.

Saída: tabela por componente — ✅ conforme | ⚠️ item com exceção a
justificar | ❌ violação.

### Passo 7b — Verificação G: Índice lazy do AGENTS.md global (IMP-048)

1. Leia `~/.config/opencode/AGENTS.md` e extraia as entradas do índice
   "Índice de Referências — lazy loading" (padrão: `` `rules/<arquivo>.md` ``).
2. Para cada entrada, verifique se o arquivo existe em
   `~/.config/opencode/rules/` → **referência quebrada = ❌**.
3. Para cada arquivo em `rules/`, verifique se está referenciado no
   índice → arquivo órfão = ⚠️ (nunca será carregado).
4. Verifique a seção "Hierarquia de Convenções" (referenciada por
   `agents/rdd-dev.md` e `skills/rdd-primary-agent-creator`) → ausente = ❌.
5. Tamanho do AGENTS.md global: > 60 linhas = ⚠️ (teto do IMP-048: 40;
   absorve variação de blocos locais azure/repositorios/credenciais).
6. Marcadores `<!-- azure-devops -->` e `<!-- projeto-padrao -->`
   presentes (compat `rdd-setup`) → ausentes = ⚠️.

Saída: tabela entrada ↔ arquivo ↔ status + contagem de linhas.


### Passo 7c — Verificação H: coerência front matter <-> PERMISSIONS.md (IMP-103)

1. Leia `~/.config/opencode/PERMISSIONS.md` (matriz agent x permissão com justificativa e status).
2. Para cada `agents/rdd-*.md`, extraia o bloco `permission:` do front matter e compare com a linha correspondente da matriz.
3. Divergência = finding:
   - severity `error` se o front matter for MAIS restritivo que a matriz documentada (matriz desatualizada) OU se a matriz for MAIS restritiva que o front matter (permissão real escapando do menor privilégio documentado);
   - severity `warning` se for divergência apenas de nota/justificativa.
4. Arquivo `PERMISSIONS.md` ausente = ⚠️ (matriz não mantida — criar via @rdd-workflow-improver).
5. Correção: atualizar a matriz OU o front matter via @rdd-workflow-improver — nunca "consertar" a matriz para refletir allow amplo sem justificativa.

### Passo 8 — Montar e salvar relatório

Combine as 8 verificações (A-H) num relatório único com resumo executivo,
seções detalhadas e recomendações. Salve em
`<modulo>/<projeto>/quality/AGENT_HEALTH_REPORT_<timestamp>.md`.

## Template — AGENT_HEALTH_REPORT_<timestamp>.md

```yaml
---
project: <NOME_DO_MODULO>
module: agent-health-report
audience: [governanca, tecnica]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
---
```

```markdown
# Agent Health Report — <nome-do-modulo>

> **Gerado em:** DD/MM/AAAA HH:MM
> **Resultado Geral:** ✅ Saudável | ⚠️ Atenção necessária | ❌ Crítico

---

## Resumo

| Verificação | Status | Detalhes |
|-------------|--------|----------|
| A. Subagents | ✅/⚠️/❌ | N/N/N |
| B. Skills | ✅/⚠️/❌ | N/N/N |
| C. Artefatos Órfãos | ✅/⚠️/❌ | N órfãos |
| D. Staleness | ✅/⚠️/❌ | N stale |
| E. Propagation | ✅/⚠️/❌ | N pendentes |
| F. Conformidade (checklists) | ✅/⚠️/❌ | N conformes / N violações |
| G. Índice lazy (AGENTS.md) | ✅/⚠️/❌ | N refs OK / N quebradas |

---

## A. Subagents Registrados

| Subagent | Name | Description | Permission | Status |
|----------|------|-------------|------------|--------|

**Referências quebradas:** <lista ou "nenhuma">

---

## B. Skills

| Skill | Front Matter | Seções | Placeholders | Status |
|-------|-------------|--------|--------------|--------|

**Skills com problemas:** <lista detalhada>

---

## C. Artefatos do Módulo

| Artefato | Existe | Referenciado | Última atualização | Staleness |
|----------|--------|-------------|--------------------|-----------|

**Artefatos órfãos:** <lista>

---

## D. Staleness

| Faixa | Quantidade | Artefatos |
|-------|-----------|-----------|
| ✅ < 7d | N | <lista> |
| ⚠️ 7-30d | N | <lista> |
| ❌ > 30d | N | <lista> |

---

## E. Propagation Status

<se PROPAGATION_STATUS.md existir, listar entradas pendentes;
senão, "Não avaliado — PROPAGATION_STATUS.md não encontrado">

---

## F. Conformidade com CHECKLISTS.md

| Componente | Tipo | Front Matter | Permissões | Portabilidade | Seções | Registro | Status |
|------------|------|--------------|------------|---------------|--------|----------|--------|

**Violações:** <lista com componente, item da checklist, o que corrigir>
**Não automatizáveis (revisão humana):** <lista>

---

## G. Índice lazy do AGENTS.md global (IMP-048)

| Entrada no índice | Arquivo existe | Tamanho | Status |
|-------------------|----------------|---------|--------|

**Referências quebradas:** <lista ou "nenhuma">
**Arquivos rules/ órfãos:** <lista ou "nenhuma">
**AGENTS.md global:** <N> linhas (teto: 40 + blocos locais; ⚠️ se > 60)

---


## H. Coerência PERMISSIONS.md (IMP-103)

| Agent | Front matter | Matriz | Status |
|-------|--------------|--------|--------|

**Divergências:** <lista ou "nenhuma">

## Recomendações

1. <ação sugerida 1>
2. <ação sugerida 2>
3. <ação sugerida 3>
```

## Casos de Borda

- **Nenhum módulo RDD encontrado:** gere relatório genérico apenas com
  verificações A e B (agents e skills do workspace).
- **Módulo pré-IMP-011 (sem subpastas):** verifique artefatos na raiz
  e note no relatório que o módulo ainda não foi migrado.
- **Verificação D sem Git:** pule a verificação de staleness por data
  e marque como "Não avaliado — sem acesso a Git".
- **Dados parciais:** gere o relatório mesmo com verificações incompletas.
  Cada verificação não avaliada é marcada como "N/A".
- **Relatório anterior existe:** não sobrescreva — gere um novo com
  timestamp diferente (permite diff entre execuções).
