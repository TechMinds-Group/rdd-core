---
name: rdd-acceptance-criteria
description: >-
  Gera ACCEPTANCE_CRITERIA.md a partir das RNs em REQUIREMENTS.md.
  Cada RN vira um ou mais critérios de aceitação no formato Dado-Quando-Então.
  Use quando o usuário pedir "gerar critérios de aceitação", "ACCEPTANCE_CRITERIA" ou "critérios de aceitação".
---
# rdd-acceptance-criteria — Critérios de Aceitação

Gera `<modulo>/<projeto>/specs/ACCEPTANCE_CRITERIA.md` com critérios de aceitação
derivados das regras de negócio no formato Dado-Quando-Então (Gherkin).

## Referências

- EARS: `docs/CONSTITUTION.md §3`
- IDs RN-XXX: `docs/CONSTITUTION.md §1`

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

- `<modulo>/<projeto>/REQUIREMENTS.md` §5 (Regras de Negócio)
- `<modulo>/<projeto>/glossaries/` (se existir, para consistência terminológica; fallback: raiz do módulo)

## Gera (downstream)

- `<modulo>/<projeto>/specs/ACCEPTANCE_CRITERIA.md`

## Nunca edita

- `REQUIREMENTS.md`

## Tools

- `read` (ler REQUIREMENTS.md)
- `write` (escrever ACCEPTANCE_CRITERIA.md)
- `question` (para ambiguidades de critério)

## Modo de erro

`skip` — tier completo, não bloqueia.

## Algoritmo

1. Leia `REQUIREMENTS.md` §5 e liste todas as RNs (IDs RN-XXX).
2. Para cada RN, classifique o tipo EARS (ubíqua, evento, estado, opcional, indesejado) usando a tabela "Regras de Derivação: EARS → Gherkin".
3. Derive um ou mais cenários Gherkin (Dado-Quando-Então) por RN, cobrindo o fluxo principal e as variações previstas na RN.
4. Em caso de ambiguidade de critério, use `question` antes de escrever o cenário.
5. Escreva `specs/ACCEPTANCE_CRITERIA.md` com o front matter e a estrutura do template — uma seção `## RN-XXX` por regra, com os cenários abaixo dela.

## Formato de commit

```
docs: add acceptance criteria for <projeto>
```

## Regras de Derivação: EARS → Gherkin

| Tipo EARS (pt-BR) | Tradução Gherkin |
|---|---|---|
| Ubíqua (`O sistema deve...`) | Cenário: sempre válido. Dado que o sistema está operacional, Quando... |
| Evento (`Quando..., então o sistema deve...`) | Cenário: trigger. Quando [evento]... |
| Estado (`Enquanto..., o sistema deve...`) | Background: Dado que o sistema está em [estado]... |
| Opcional (`Caso..., o sistema deve...`) | Cenário: condicional. Dado que [funcionalidade] está habilitada... |
| Indesejado (`Se..., então o sistema deve...`) | Cenário: exceção. Quando [indesejado]... Então [resposta] |

## Template — ACCEPTANCE_CRITERIA.md

```yaml
---
project: <NOME>
module: aceitacao
audience: [tecnica]
status: draft
---
```

```markdown
# Acceptance Criteria — [Nome do Sistema]

> **Derivado de:** REQUIREMENTS.md
> **Última atualização:** DD/MM/AAAA

---

## RN-XXX: [descrição]

### Cenário: [nome do cenário]

- Dado que [contexto]
- Quando [ação]
- Então [resultado esperado]

### Cenário: [variação]

- Dado que [contexto]
- E [condição adicional]
- Quando [ação]
- Então [resultado]

---

## RN-YYY: [descrição]

...
```

## Casos de Borda

- **RN ubíqua sem gatilho** (`O sistema deve...`): gere um único cenário "sempre válido" — não invente evento que a RN não prevê.
- **RN com múltiplas variações** (opcional + indesejado na mesma regra): gere um cenário por variação, todos sob a mesma seção `## RN-XXX`.
- **RN de estado** (`Enquanto...`): use `Background` para a pré-condição e cenários separados para o comportamento decorrente.
- **REQUIREMENTS.md sem §5 ou sem RNs**: não gere arquivo vazio — reporte a ausência e encerre (modo `skip`).
- **Termo ambíguo no critério** (ex: "rápido", "adequado"): use `question` antes de escrever — não transporte a ambiguidade para o Gherkin.
