---
name: rdd-cr-propagation-guard
description: >-
  Detecta artefatos técnicos desatualizados (stale) após aprovação ou
  implementação de Change Requests. Varre CHANGE_REQUESTS.md, identifica RNs
  afetadas, verifica presença nos downstreams e persiste o estado em
  PROPAGATION_STATUS.md. Não bloqueia — apenas sinaliza.
  Use quando o usuário pedir "propagação de CR", "verificar artefatos stale",
  "detectar staleness" ou "atualizar PROPAGATION_STATUS".
---
# rdd-cr-propagation-guard — Guard de Propagação de CRs

Monitora se os artefatos técnicos derivados de `REQUIREMENTS.md` estão
atualizados após mudanças registradas em `CHANGE_REQUESTS.md`.

## Referências

- `CONSTITUTION.md §4` (DAG de documentos)
- `CONSTITUTION.md §5` (Ciclo de Vida)
- `CONSTITUTION.md §8` (Fluxo de Decisão — CR aprovado → re-execução de skills)
- IDs RN-XXX: `CONSTITUTION.md §1`

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

- `<module-root>/support/CHANGE_REQUESTS.md` (CRs com status, RNs, datas; fallback: raiz)
- `<module-root>/quality/PROPAGATION_STATUS.md` (se existir, para merge incremental; fallback: raiz)
- `<module-root>/specs/DATA_MODEL.md` (fallback: raiz)
- `<module-root>/specs/API_CONTRACTS.md` (fallback: raiz)
- `<module-root>/specs/UI_SPEC.md` (fallback: raiz)
- `<module-root>/specs/ARCHITECTURE.md` (fallback: raiz)
- `<module-root>/glossaries/DEV_GLOSSARY.md`, `<module-root>/glossaries/BUSINESS_GLOSSARY.md`, `<module-root>/glossaries/USER_GLOSSARY.md` (ou `<module-root>/glossaries/GLOSSARY.md` se existir como arquivo único; fallback: raiz)
- `<module-root>/specs/ACCEPTANCE_CRITERIA.md` (fallback: raiz)

## Gera (downstream)

- `<module-root>/quality/PROPAGATION_STATUS.md` (cria ou atualiza)

## Nunca edita

- `CHANGE_REQUESTS.md` (só lê)
- Nenhum artefato técnico (só sinaliza staleness, nunca modifica)

## Tools

- `read` (ler CHANGE_REQUESTS.md, PROPAGATION_STATUS.md, artefatos técnicos)
- `write` (escrever/atualizar PROPAGATION_STATUS.md)
- `grep` (buscar RN-XXX dentro dos artefatos)
- `glob` (descobrir módulos, arquivos de glossário)
- `bash` (git log para timestamps de arquivos)
- `question` (perguntar qual módulo escanear, se ambíguo)

## Modo de erro

`warn` — se o guard encontrar problemas, ele reporta mas não bloqueia.
Nenhuma skill do pipeline falha por causa de staleness detectada.

## Formato de commit

```
docs: guard - update PROPAGATION_STATUS.md for <module>
```

## Algoritmo de Detecção

### Passo 1 — Descobrir módulo

Se o caminho do módulo não for fornecido, use `glob` para encontrar
diretórios que contêm `CHANGE_REQUESTS.md` (ou `support/CHANGE_REQUESTS.md`
no layout IMP-011). Se houver múltiplos, use `question` para perguntar ao
usuário qual escanear. Se houver um único, use-o automaticamente.

Um **módulo** é um diretório que contém `CHANGE_REQUESTS.md` (raiz ou
`support/`) e `REQUIREMENTS.md`.

### Passo 2 — Ler estado atual

Leia `<module-root>/quality/PROPAGATION_STATUS.md` se existir (fallback:
raiz do módulo). Isso fornece o estado anterior (entradas pendentes e
resolvidas) para merge incremental.

Se não existir, comece do zero.

### Passo 3 — Ler CHANGE_REQUESTS.md

Parseie cada entrada CR-XXX no arquivo. Para cada CR, extraia:

| Campo | Fonte | Exemplo |
|-------|-------|---------|
| ID do CR | `## CR-NNN:` | `CR-002` |
| Status | `**Status:**` | `approved` |
| RNs afetadas | `**RN afetada:**` | `RN-020, RN-021, RN-025` |
| Data de aprovação | `**Aprovação:**` | `Operador RDD, <data>` |
| Data de criação | `**Data:**` | `28/07/2026` |
| Downstreams declarados | `**Downstreams afetados:**` | `DATA_MODEL, API_CONTRACTS` |

**Formato do campo `**RN afetada:**`:** pode conter:
- Uma ou mais RNs separadas por vírgula: `RN-020, RN-021, RN-025`
- `N/A` ou texto descritivo sem RNs: `N/A (mudança técnica, não de negócio)`
- RNs em formato livre dentro do texto

Extraia apenas os IDs que casam o padrão `RN-\d{3}`. Ignore entradas
sem nenhum ID de RN.

### Passo 4 — Filtrar CRs relevantes

Considere apenas CRs com status **`approved`** ou **`implemented`**.

- CRs com status `draft`, `pending`, `rejected`, `cancelled`:
  - Se existem entradas pendentes para este CR no PROPAGATION_STATUS.md
    atual, **remova-as** (o CR não está mais ativo).
  - Se existem entradas resolvidas deste CR, mantenha-as no histórico.

### Passo 5 — Para cada RN afetada, escanear artefatos

Para cada CR relevante e cada RN listada no CR:

1. Para cada artefato técnico na lista abaixo:
   - Se o arquivo **não existe** → ignore silenciosamente
   - Se o arquivo **existe**:
     a. Use `grep` com regex `RN-\d{3}` (ou especificamente `RN-XXX`
        para a RN atual) para verificar se a RN aparece no arquivo.
     b. Se a RN **não aparece** no artefato → classifique como
        `"nao_traduzido"` (não é staleness — a RN nunca foi propagada
        para este artefato). Não inclua em nenhuma seção.
     c. Se a RN **aparece** no artefato → verifique staleness:
        - Use `bash` com `git log -1 --format=%ci -- <caminho-do-artefato>`
          para obter a data do último commit que modificou o artefato.
        - Compare com a data de aprovação do CR.
        - Se artefato foi modificado **depois** da aprovação do CR →
          classifique como `"resolved"`.
        - Se artefato foi modificado **antes** ou **na mesma data** da
          aprovação do CR → classifique como `"stale"`.
        - Se o arquivo não tem commits (nunca foi versionado) → use
          `(Get-Item <caminho>).LastWriteTime.ToString('yyyy-MM-dd')`
          do filesystem como fallback.

**Artefatos a escanear (6 tipos):**

| # | Nome do artefato | Arquivo(s) — IMP-011 (fallback: raiz) |
|---|-----------------|------------|
| 1 | DATA_MODEL | `specs/DATA_MODEL.md` |
| 2 | API_CONTRACTS | `specs/API_CONTRACTS.md` |
| 3 | UI_SPEC | `specs/UI_SPEC.md` |
| 4 | ARCHITECTURE | `specs/ARCHITECTURE.md` |
| 5 | GLOSSARY | `glossaries/DEV_GLOSSARY.md`, `glossaries/BUSINESS_GLOSSARY.md`, `glossaries/USER_GLOSSARY.md`, ou `glossaries/GLOSSARY.md` (único) |
| 6 | ACCEPTANCE_CRITERIA | `specs/ACCEPTANCE_CRITERIA.md` |

Para GLOSSARY: use `glob` para encontrar quais arquivos existem. Escaneie
todos que existirem, mas na tabela de staleness o nome do artefato é
simplesmente "GLOSSARY" (não importa qual variante).

### Passo 6 — Determinar staleness por CR

A data de referência para staleness é:

- Para CR `approved`: use a data mais recente entre `**Aprovação:**`
  e `**Data:**` (priorize aprovação).
- Para CR `implemented`: use a data de aprovação (já que o CR precisou
  ser aprovado antes de implementado). A guard reavalia o estado atual
  neste momento para detectar se a implementação de fato atualizou os
  artefatos.

**Comparação de datas:** ambas as datas (CR e artifact) são convertidas
para `YYYY-MM-DD` para comparação. Se o artefato foi modificado em data
posterior (`artifact_date > cr_date`) → resolved. Caso contrário → stale.

### Passo 7 — Montar a estrutura de dados

Para cada (CR, RN) relevante, monte:

```json
{
  "cr": "CR-002",
  "rn": "RN-020",
  "status": "approved",
  "approvalDate": "2026-07-28",
  "staleArtifacts": ["DATA_MODEL", "API_CONTRACTS"],
  "resolvedArtifacts": [
    {"artifact": "UI_SPEC", "resolvedDate": "2026-07-29"}
  ]
}
```

Onde:
- `staleArtifacts` = artefatos classificados como `"stale"` no passo 5c
- `resolvedArtifacts` = artefatos classificados como `"resolved"` no
  passo 5c, que estavam stale na execução anterior

### Passo 8 — Merge com estado anterior

Leia `PROPAGATION_STATUS.md` atual (se existir):

1. **Entradas pendentes existentes** que ainda são relevantes (CR ainda
   está approved/implemented) e cujos artefatos ainda estão stale →
   mantenha com a data de detecção original (não sobrescreva).

2. **Entradas pendentes existentes** cujo CR mudou de status para
   rejected/cancelled → remova da seção Pendentes.

3. **Artefatos que estavam stale e agora estão resolved** → mova para
   a seção Resolvidos com a data de resolução (data de hoje).

4. **Artefatos que estavam resolved e continuam resolved** → mantenha
   na seção Resolvidos (não mova de volta).

5. **Novas entradas** (CR+RN que não existiam antes) → adicione na
   seção Pendentes com a data de hoje como detecção.

### Passo 9 — Escrever PROPAGATION_STATUS.md

Use o template abaixo. A seção Pendentes tem **uma linha por (CR, RN)**
com a lista de artefatos stale. A seção Resolvidos tem **uma linha por
(CR, RN, artefato)** com as datas de detecção e resolução.

## Casos de Borda

### RN nova, nunca traduzida

Se um CR approved referencia uma RN que não aparece em **nenhum**
artefato técnico, isso NÃO é staleness — é "traduzir pela primeira vez",
fora do escopo do guard. A RN não gera entrada em PROPAGATION_STATUS.md.

### CR revertido/cancelado após approved

Se um CR muda de `approved` para `rejected` ou `cancelled`, remova
todas as entradas pendentes associadas a este CR da seção Pendentes.
Entradas resolvidas deste CR permanecem como histórico.

### Artefato não existe

Se o arquivo do artefato não existe no filesystem, ignore-o
silenciosamente. Não gere erro nem entrada na tabela.

### RN removida de artefato durante regeneração

Se uma RN existia em um artefato e foi removida (porque o requisito
foi descontinuado), e o artefato foi modificado após a aprovação do CR,
considere como resolved (não como stale residual). O critério é: se o
artefato foi modificado após a data do CR, ele está atualizado — não
importa se a RN foi adicionada, removida ou alterada.

### Múltiplos CRs afetando mesmo artefato

Se CR-002 (RN-020) e CR-004 (RN-049) ambos tornam UI_SPEC.md stale,
cada um gera sua própria linha na tabela Pendentes:
- `RN-020 | CR-002 | UI_SPEC | 28/07/2026`
- `RN-049 | CR-004 | UI_SPEC | 29/07/2026`

Eles NÃO são colapsados em uma única linha.

### CR sem RN (mudança técnica)

Se `**RN afetada:**` contém `N/A` ou nenhum `RN-\d{3}`, ignore este CR
completamente. Mudanças puramente técnicas não acionam o guard.

### Sem acesso a git

Se `git log` falhar (ex: repositório não inicializado), use
`(Get-Item).LastWriteTime` do PowerShell como fallback para timestamp.

## Workflow

1. Descubra ou receba o caminho do módulo a escanear.
2. Leia `PROPAGATION_STATUS.md` atual (se existir).
3. Leia `CHANGE_REQUESTS.md`.
4. Para cada CR extraído, aplique os Passos 4-6 do algoritmo.
5. Monte a estrutura de dados por (CR, RN).
6. Faça merge com o estado anterior (Passo 8).
7. Escreva `quality/PROPAGATION_STATUS.md` atualizado.
8. Exiba um resumo do que foi detectado:
   - Quantos CRs ativos (approved/implemented) foram encontrados
   - Quantas RNs afetadas
   - Quantos artefatos stale detectados
   - Quantos artefatos resolvidos desde a última execução

## Template — PROPAGATION_STATUS.md

```yaml
---
project: <NOME>
module: propagation-guard
audience: [tecnica]
status: draft
---
```

```markdown
# Propagation Status

> **Última verificação:** DD/MM/AAAA HH:MM
> **Módulo:** <nome-do-modulo>

## Pendentes

| RN | CR | Artefatos Stale | Detectado em |
|---|---|---|---|
| RN-020 | CR-002 | DATA_MODEL, API_CONTRACTS | 28/07/2026 |
| RN-021 | CR-002 | ARCHITECTURE | 28/07/2026 |

## Resolvidos

| RN | CR | Artefato | Detectado em | Resolvido em |
|---|---|---|---|---|
| RN-020 | CR-002 | UI_SPEC | 28/07/2026 | 29/07/2026 |
| RN-002 | CR-003 | UI_SPEC | 28/07/2026 | 28/07/2026 |

### Legenda

| Coluna | Descrição |
|--------|-----------|
| Pendentes — RN | RN afetada pelo CR, presente no artefato mas não atualizada |
| Pendentes — CR | Change Request que aprovou/implementou a mudança |
| Pendentes — Artefatos Stale | Artefatos que contêm a RN mas não foram atualizados desde a aprovação |
| Resolvidos — Artefato | Artefato que estava stale e foi regenerado |
```

## Exemplo de uso via question

Se o módulo não for identificado automaticamente:

```
Encontrei múltiplos módulos com CHANGE_REQUESTS.md:
1. vacinacao/ (CR-001 a CR-004 ativos)
2. bloqueios/ (sem CRs ativos)

Qual módulo devo escanear?
```

Se a resposta for `vacinacao/`, prossiga com ele. Se não houver resposta,
escanee todos.
