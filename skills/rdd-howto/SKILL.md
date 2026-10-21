---
name: rdd-howto
description: >-
  Gera HOWTO.md ou docs/howto/*.md quando uma feature é marcada como [done].
  Documentação orientada a tarefas para suporte e usuário final.
  Use quando o usuário pedir "gerar howto", "documentar feature", "HOWTO" ou "documentação de uso".
---
# rdd-howto — Documentação de Uso

Gera `docs/howto/<feature>.md` com documentação orientada a tarefas para
as audiências de suporte e usuário final. Executado quando uma feature
é marcada como `[done]`.

## Referências

- Front matter: `docs/CONSTITUTION.md §2`

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

- `<modulo>/<projeto>/REQUIREMENTS.md` (contexto da feature)
- `<modulo>/<projeto>/specs/UI_SPEC.md` (se existir, para fluxos de tela; fallback: raiz)
- `<modulo>/<projeto>/specs/US<NNN>.md` (se existir, para linguagem do usuário; fallback: raiz)

## Gera (downstream)

- `docs/howto/<feature>.md`

## Nunca edita

- Nenhum documento de requisito ou especificação

## Tools

- `read` (ler documentos de contexto)
- `write` (escrever howto)
- `question` (confirmar escopo da documentação)

## Modo de erro

`continue` — se falhar, loga warning. Documentação pós-lançamento não bloqueia.

## Algoritmo

1. Confirme a feature marcada como `[done]` e o escopo da documentação via `question`.
2. Leia `REQUIREMENTS.md` (contexto da feature) e, se existirem, `specs/UI_SPEC.md` e `specs/US<NNN>.md` (fluxos de tela e linguagem do usuário).
3. Escreva `docs/howto/<feature>.md` com o template — objetivo, passo a passo, dicas e erros comuns — em linguagem de suporte/usuário final, não técnica.

## Formato de commit

```
docs: add howto for <feature>
```

## Template — HOWTO.md

```yaml
---
project: <NOME>
module: howto
audience: [suporte, usuario_final]
status: draft
---
```

```markdown
# How-to: [Título da Tarefa]

> **Feature:** [nome da feature]
> **Disponível desde:** [versão/data]

---

## Objetivo

[o que esta tarefa resolve para o usuário]

## Passo a Passo

1. [passo]
2. [passo]
3. [passo]

## Dicas

- [dica]

## Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
```

## Casos de Borda

- **Feature sem UI_SPEC nem US<NNN>.md**: derive o passo a passo apenas de REQUIREMENTS.md; se o fluxo de tela for ambíguo, pergunte via `question`.
- **Feature técnica sem interface de usuário** (ex: endpoint de integração): documente a tarefa do ponto de vista de quem opera/integra, mantendo a audiência [suporte, usuario_final].
- **Howto já existe para a feature**: atualize o existente em vez de criar duplicado — uma fonte única por tarefa.
- **Feature `[done]` parcial** (com pendências): documente apenas o que está disponível e indique a limitação na seção Objetivo.
