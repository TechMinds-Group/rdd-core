---
name: rdd-decision-audit
description: >-
  Valida integridade semântica de DECISIONS.md: verifica se decisões novas
  contradizem decisões anteriores, se IDs são sequenciais, se RNs/PENDs
  referenciados existem, e se há decisões órfãs. Complementa rdd-validate
  (que valida integridade estrutural da DAG) com foco em conflitos de
  decisões. Use quando o usuário pedir "auditar decisões", "verificar
  conflitos de decisões", "decision audit" ou "validar DECISIONS.md".
  Entradas legadas `DEC-XXX` são reconhecidas como imutáveis (não falham
  a auditoria).
---
# rdd-decision-audit — Auditoria de Decisões

Valida a integridade semântica e estrutural de `<modulo>/<projeto>/DECISIONS.md`.
Diferente do `rdd-validate` (que valida a DAG de RNs → downstreams), este skill
foca exclusivamente em **conflitos, inconsistências e integridade das decisões**.

**Diferenciação:**

| Skill | Escopo |
|-------|--------|
| `rdd-validate` | Integridade da DAG inteira (RNs → downstreams, IDs quebrados, CRs stale) |
| `rdd-decision-log` | Criação de novas decisões (merge incremental) |
| `rdd-decision-audit` | Integridade semântica de DECISIONS.md (conflitos, sequência, referências) |

## Referências

- IDs ADR-NNN: `CONSTITUTION.md §1` (entradas `DEC-XXX` pré-migração = legado imutável — reconhecidas, nunca renumerar)
- DECISIONS.md: artefato da raiz do módulo (Fase 1 — Requirements)
- Grafo de documentos: `CONSTITUTION.md §4`

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

- `<modulo>/<projeto>/DECISIONS.md` (artefato principal — todas as decisões)
- `<modulo>/<projeto>/REQUIREMENTS.md` (verificar se RNs/PENDs referenciados existem)
- `<modulo>/<projeto>/support/CHANGE_REQUESTS.md` (se existir — verificar CRs vinculados a decisões)

## Gera (downstream)

- `<modulo>/<projeto>/quality/DECISION_AUDIT_<yyyy-MM-dd-hh:mm>.md` (relatório de auditoria)

## Nunca edita

- `DECISIONS.md` (read-only — apenas diagnostica, nunca altera decisões)
- `REQUIREMENTS.md`
- Nenhum outro artefato. **Read-only absoluto.**

## Tools

- `read` (ler DECISIONS.md, REQUIREMENTS.md, CHANGE_REQUESTS.md)
- `grep` (buscar referências cruzadas, IDs RN-XXX/PEND-XXX)
- `write` (escrever DECISION_AUDIT_*.md)
- `glob` (verificar existência de arquivos)
- `bash` (exclusivo da Segunda Camada Semântica Jev — ver seção própria)

## Modo de erro

`warn` — se DECISIONS.md não existir ou estiver vazio, gere relatório
indicando "nenhuma decisão registrada" e sugira criar via `rdd-decision-log`.
Não bloqueie o pipeline.

## Formato de commit

```
docs(requirements): add decision audit <timestamp>
```

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum módulo RDD encontrado. Informe o caminho do módulo."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual módulo analisar.

### Passo 2 — Ler DECISIONS.md

Leia `<modulo>/<projeto>/DECISIONS.md` (com fallback para raiz se pré-IMP-011).

Se o arquivo não existir ou estiver vazio → gere relatório "nenhuma
decisão registrada" e encerre.

### Passo 3 — Extrair decisões

Para cada entrada — ADR atual (`## ADR-NNN: [título]`) ou legada
(`## [DEC-XXX]`) — extraia:

- **ID** (ADR-NNN; DEC-XXX = legado) e **esquema** (`adr` | `legado`)
- **Título**
- **Data**
- **Status** (ADR: Aceito | Proposto | Rejeitado | Superseded by
  ADR-YYY; legado DEC: active / superseded by DEC-YYY)
- **RNs referenciadas** (campo "RNs afetadas")
- **PENDs referenciados** (campo "PENDs resolvidos")
- **Artefatos downstream referenciados**
- **Conteúdo textual** (para análise semântica)

### Passo 4 — Validações

Execute as 7 categorias de validação abaixo.

### Passo 5 — Gerar relatório

Monte o relatório com o template e salve em `quality/DECISION_AUDIT_<timestamp>.md`.

## Categorias de Validação

### 1. Sequência de IDs

Verifique se os IDs ADR-NNN são sequenciais e ininterruptos (a sequência
ADR é independente das entradas legadas DEC-XXX).

- **Erro:** ADR-003 pulou para ADR-005 (ADR-004 ausente)
- **Erro:** ADR-002 registrado depois de ADR-003 (ordem cronológica invertida)
- **Warning:** IDs não começam em ADR-001 (pode ser intencional se módulo pré-RDD)

### 2. Status consistente

Verifique se o campo `Status` está presente e válido em cada entrada.
Valores válidos — ADR: `Aceito`, `Proposto`, `Rejeitado`, `Superseded
by ADR-YYY`; legado DEC: `active`, `superseded by DEC-YYY`.

- **Erro:** ADR sem campo Status
- **Erro:** Status com valor inválido (fora dos valores válidos do seu esquema)
- **Erro:** ADR marcada como `Superseded by ADR-YYY` mas ADR-YYY não
  existe (idem par legado: `superseded by DEC-YYY` sem DEC-YYY)
- **Erro:** entrada marcada como `Superseded`/`superseded` mas ainda é
  referenciada como ativa em outro lugar

### 3. Conflitos semânticos

Analise o **conteúdo textual** de cada decisão ativa (ADR ou DEC legada)
em pares para detectar contradições.

Estratégia de detecção:
1. Para cada par de decisões ativas, compare os campos "Decisão" e
   "Consequências" (legado: "Justificativa")
2. Busque por termos opostos: "usar X" vs "não usar X", "simplificar" vs "complexificar"
3. Busque por referências ao mesmo RN/PEND com decisões opostas
4. Busque por artefatos downstream conflitantes (ex: ADR-001 diz "usar PostgreSQL" e ADR-005 diz "usar MySQL")

- **Erro:** Duas decisões ativas contradizem explicitamente uma à outra
- **Warning:** Duas decisões ativas tratam do mesmo tema com abordagens diferentes (pode ser intencional — sinalizar para revisão humana)

### 4. Referências quebradas

Para cada decisão, verifique se os IDs referenciados existem nos documentos de origem.

- `RN-XXX` → deve existir em `REQUIREMENTS.md` §6 (Regras de Negócio)
- `PEND-XXX` → deve existir em `REQUIREMENTS.md` §8 (Pendências)
- `ADR-YYY` (em "Superseded by") → deve existir em `DECISIONS.md`
  (par legado: `DEC-YYY` em "superseded by")
- `CR-XXX` → deve existir em `CHANGE_REQUESTS.md` (se aplicável)

- **Erro:** ADR-003 referencia RN-099 mas RN-099 não existe em REQUIREMENTS.md
- **Warning:** ADR-002 referencia PEND-007 que está marcado como "resolvido" — verificar se a resolução está correta

### 5. Decisões sem impacto

Verifique se há decisões ativas (ADR) sem nenhuma referência a RN, PEND ou artefato downstream.

- **Warning:** ADR-004 não referencia nenhuma RN, PEND ou artefato — pode estar incompleta ou desatualizada

### 6. Decisões órfãs (sem traceability)

Verifique se há RNs/PENDs que deveriam ter uma DEC vinculada mas não têm.

1. Leia REQUIREMENTS.md e extraia todas as RNs ativas
2. Para cada RN, verifique se há pelo menos uma decisão (ADR ou DEC
   legada) que a referencia
3. Identifique RNs sem decisão vinculada

- **Warning:** RN-012 não é referenciada por nenhuma decisão — pode precisar de uma decisão formal
- **Info:** RNs com apenas 1 decisão referenciando são "bem documentadas"; RNs com múltiplas decisões podem ter conflito

### 7. Decisões obsoletas (stale)

Verifique se há decisões ativas que referenciam artefatos que não existem mais ou foram renomeados.

- **Erro:** ADR-001 referencia `schema_antigo.md` que não existe mais
- **Warning:** ADR-003 foi criada há mais de 90 dias e não foi atualizada — pode estar desatualizada

## Template — DECISION_AUDIT_<timestamp>.md

```yaml
---
project: <NOME_DO_MODULO>
module: decision-audit
audience: [requirements, governanca]
status: draft
generated_at: "YYYY-MM-DDTHH:mm:ssZ"
decisions_analyzed: N
---
```

```markdown
# Decision Audit — <nome-do-modulo>

> **Gerado em:** DD/MM/AAAA HH:MM
> **Decisões analisadas:** N (X ativas, Y superseded, Z legadas DEC-XXX)
> **Resultado Geral:** ✅ Sem problemas | ⚠️ Warnings | ❌ Erros encontrados

---

## Resumo

| Categoria | Erros | Warnings | Info |
|-----------|-------|----------|------|
| 1. Sequência de IDs | N | N | N |
| 2. Status consistente | N | N | — |
| 3. Conflitos semânticos | N | N | — |
| 4. Referências quebradas | N | N | — |
| 5. Decisões sem impacto | — | N | — |
| 6. Decisões órfãs | — | N | N |
| 7. Decisões obsoletas | N | N | — |
| 8. Legado (DEC-XXX) | — | — | N |
| **Total** | **N** | **N** | **N** |

---

## 1. Sequência de IDs

<lista de problemas de sequência ou "✅ Sequência OK">

---

## 2. Status Consistente

<lista de entradas com status inconsistente ou ausente>

---

## 3. Conflitos Semânticos

### ADR-XXX vs ADR-YYY

**ADR-XXX:** <resumo da decisão>
**ADR-YYY:** <resumo da decisão>
**Conflito:** <descrição do conflito>
**Prob. Jev:** <0.00-1.00 — só quando a Segunda Camada rodou>
**Recomendação:** <ação sugerida — revisar ambas, manter apenas uma, etc.>

<ou "✅ Nenhum conflito semântico detectado">

---

## 4. Referências Quebradas

| ADR | Referência | Tipo | Status |
|-----|-----------|------|--------|
| ADR-003 | RN-099 | RN | ❌ Não existe |
| ADR-002 | PEND-007 | PEND | ⚠️ Já resolvido |

<ou "✅ Todas as referências são válidas">

---

## 5. Decisões sem Impacto

| ADR | Título | Observação |
|-----|--------|------------|

<ou "✅ Todas as decisões têm impacto mapeado">

---

## 6. Decisões Órfãs (RNs sem DEC)

| RN | Título | Observação |
|----|--------|------------|

<ou "✅ Todas as RNs têm pelo menos uma DEC vinculada">

---

## 7. Decisões Obsoletas

| ADR | Última atualização | Dias | Observação |
|-----|-------------------|------|------------|

<ou "✅ Nenhuma decisão obsoleta detectada">

---

## 8. Legado (DEC-XXX)

Entradas pré-migração no esquema DEC-XXX — **imutáveis**, listadas apenas
para inventário. Não geram erro nem warning.

| ID legado | Título | Observação |
|-----------|--------|------------|
| DEC-001 | <título> | <ex: referenciada por ADR-002> |

<ou "✅ Nenhuma entrada legada DEC-XXX">

---

## Recomendações

| Prioridade | Ação | Decisão afetada |
|-----------|------|-----------------|
| ❌ Alta | <ação> | ADR-XXX |
| ⚠️ Média | <ação> | ADR-YYY |
| ℹ️ Baixa | <ação> | ADR-ZZZ |
```

## Segunda Camada Semântica (Jev — opcional, não bloqueante)

A leitura das contradições (Categoria 3) é feita pelo agente. Para pares de
decisões **ativas** com tema comum, opcionalmente obtenha uma **segunda
opinião calibrada** do modelo Jev (TypeSafe System One) antes de redigir o
bloco de conflito. A camada é **aditiva**: sem chave de API, sem rede ou em
caso de erro, siga apenas com a análise do agente (registre "Camada Jev:
não executada" no fim do relatório).

**Quando acionar:** apenas para pares candidatos a conflito identificados
na Categoria 3 — não para todos os pares (custo). Executor: delegue ao
subagent `@rdd-jev-classifier` (via task) OU execute o curl diretamente
abaixo — os dois caminhos são equivalentes.

**Chamada (PowerShell):**

```powershell
$key = [System.Environment]::GetEnvironmentVariable("TYPESAFE_API_KEY", "User")
$state = "ADR-XXX (status, decisor): <resumo da decisao 1>`nADR-YYY (status, decisor): <resumo da decisao 2>"
$body = @{
  state = $state; model = "jev-latest"
  questions = @{
    contradicao = @{ type = "noul"; instructions = "As duas decisoes acima prescrevem comportamentos ou armazenamentos incompativeis? Responda a probabilidade de contradicao." }
    impacto = @{ type = "choice"; criteria = @{ bloqueante = "Exige revogacao de uma das decisoes antes de avancar"; moderado = "Precisa alinhamento, mas nao bloqueia o fluxo"; cosmetico = "Divergencia sem impacto tecnico real" } }
  }
} | ConvertTo-Json -Depth 10
$r = Invoke-RestMethod -Uri "https://api.typesafe.ai/v1/systemone" -Method Post -ContentType "application/json" -Headers @{ Authorization = "Bearer $key" } -Body ([System.Text.Encoding]::UTF8.GetBytes($body))
# $r.answers.contradicao.noul (0-1) ; $r.answers.impacto.choice + .confidence
```

**Interpretação do noul (probabilidade de contradição):**

| Faixa | Leitura |
|---|---|
| ≥ 0.70 | Conflito provável — registrar bloco completo com **Prob. Jev** |
| 0.40 – 0.69 | Zona cinzenta — registrar como "investigar" com **Prob. Jev** |
| < 0.40 | Sem conflito material — não registrar bloco (decisões coexistem) |

**Regras:**

- **NUNCA** use a probabilidade como único critério: o agente sempre lê as
  decisões e forma o próprio juízo; o Jev é calibração, não veredito
- **NUNCA** invente valor de Prob. Jev sem chamada real — se a camada não
  rodou, omita a linha "**Prob. Jev**" do bloco
- **Se a chamada falhar com 400/422:** NÃO improvise variante do payload —
  use o snippet verbatim acima. Formas válidas de `noul` (todas verificadas
  contra jev-1.13.0 em 27/09/2026): `instructions` sozinho · `criteria` DICT
  sozinho · ambos juntos. Antes de retentar, capture o payload exato enviado
  — uma questão malformada envenena a chamada inteira e o erro da API aponta
  para o primeiro campo problemático, nem sempre o real; 3 retentativas
  cegas com o mesmo payload não diagnosticam nada.
- O eval determinístico (`rdd-skill-eval`) não valida valores de
  probabilidade (variam por execução) — apenas a presença/ausência do bloco

## Casos de Borda

- **DECISIONS.md não existe:** gere relatório "nenhuma decisão registrada"
  e sugira criar via `rdd-decision-log`. Não é erro — pode ser módulo novo.
- **Entradas legadas DEC sem campo Status:** trate como `active` (decisões
  antigas pré-padrão podem não ter o campo).
- **Conflito semântico ambíguo:** quando a detecção automática não for
  conclusiva, marque como "⚠️ Revisão humana recomendada" em vez de
  classificar como erro.
- **Módulo com muitas decisões (>50):** execute a auditoria em lotes por
  período para manter o relatório legível.
- **Entradas legadas DEC-XXX:** nunca renumere nem migre — reporte-as na
  seção "8. Legado (DEC-XXX)" do relatório; não falham a auditoria.
  Apenas valide referências internas entre DECs legadas (ex: `superseded
  by DEC-YYY` → DEC-YYY deve existir).
- **Decisões de outros módulos referenciadas:** se ADR-003 de módulo A
  referencia ADR-001 de módulo B, verifique se ADR-001 existe. Se não
  existir, marque como warning (pode ser referência cross-módulo legítima).
