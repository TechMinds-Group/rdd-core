---
name: rdd-legacy-context
description: >-
  Gera LEGACY_CONTEXT.md a partir da análise de sistema/banco existente.
  Só é executada se PROJECT_CHARTER.md contiver legado: true ou sistema_existente: true.
  Use quando o usuário pedir "análise de legado", "contexto de sistema
  existente", "documentar sistema em produção" ou "banco legado".
---
# rdd-legacy-context — Análise de Legado

Gera `<modulo>/<projeto>/support/LEGACY_CONTEXT.md` com a análise do sistema,
banco de dados ou API existente que será evoluído, migrado **ou apenas
documentado como está** (sistema vivo/em produção).

## Referências

- Convenções: `docs/CONSTITUTION.md`
- Campos `legado: true/false` e `sistema_existente: true/false`: `docs/CONSTITUTION.md §11`

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

- `<modulo>/<projeto>/PROJECT_CHARTER.md` (para confirmar `legado: true` ou `sistema_existente: true`)

## Gera (downstream)

- `<modulo>/<projeto>/support/LEGACY_CONTEXT.md`

## Nunca edita

- `PROJECT_CHARTER.md`

## Tools

- `read` (ler código-fonte, schemas de banco, APIs existentes)
- `grep` (buscar padrões no código legado)
- `glob` (encontrar arquivos relevantes)
- `write` (escrever LEGACY_CONTEXT.md)
- `question` (perguntar ao usuário sobre pontos não encontrados)

## Modo de erro

`skip` — se o legado não for encontrado, pula com log warning.

## Algoritmo

1. Confirme no PROJECT_CHARTER.md que `legado: true` ou `sistema_existente: true` — se não, encerre (skill condicional)
2. Inspecione o sistema existente: stack, arquitetura, banco de dados (tabelas, volumes), APIs e regras vigentes
3. Use `grep`/`glob` no código e schemas legados; use `question` para pontos não encontrados na análise
4. Preencha as seções do template (stack, arquitetura, banco, APIs, regras, armadilhas, glossário de equivalência)
5. Escreva `support/LEGACY_CONTEXT.md`

## Formato de commit

```
docs: add legacy context for <nome>
```

## Template — LEGACY_CONTEXT.md

```yaml
---
project: <NOME>
module: legado
audience: [tecnica]
status: draft
---
```

> **Regra de idioma:** Documento em português brasileiro (PT-BR). Títulos, descrições de tabelas, fluxos e regras em PT-BR. Apenas nomes de classes Java, colunas de banco e identificadores técnicos permanecem no original.

```markdown
# Contexto Legado — [Sistema Existente]

## 1. Stack Tecnológica

| Componente | Tecnologia | Versão |
|---|---|---|
| Backend | | |
| Frontend | | |
| Banco de dados | | |
| Servidor | | |

## 2. Arquitetura Atual

[Descrição da arquitetura, diagramas se necessário]

## 3. Banco de Dados

### 3.1 Tabelas Principais

| Tabela | Finalidade | Estimativa de linhas |
|---|---|---|
| | | |

### 3.2 Queries Relevantes

```sql
-- queries que serão reutilizadas ou adaptadas
```

## 4. APIs e Endpoints

| Endpoint | Método | Finalidade | Reutilizar? |
|---|---|---|---|
| | | | Sim/Não/Adaptar |

## 5. Regras de Negócio Existentes

| Código legado | Descrição | Vai mudar? |
|---|---|---|
| | | |

## 6. Armadilhas Conhecidas

- [ponto de atenção, risco de migração]

## 7. Glossário de Equivalência

| Termo legado | Termo novo | Observação |
|---|---|---|
| | | |
```

## Casos de Borda

- **`legado: false` e `sistema_existente: false`** — skill não se aplica; encerre com `skip` (Modo de erro).
- **Legado sem acesso a código/banco** — documente a partir de fontes secundárias (docs, relato do usuário) e marque as seções não verificadas.
- **Sistema em produção (`sistema_existente`)** — destaque na seção de Armadilhas os riscos de mudar comportamento vigente; a análise documenta, não substitui.
- **Tabela/API legada reaproveitada** — marque na coluna "Reutilizar?" (`Sim/Não/Adaptar`); o `rdd-data-model` usa essa marcação para FKs e constraints herdados.
