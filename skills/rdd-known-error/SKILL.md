---
name: rdd-known-error
description: >-
  Gera ou atualiza KNOWN_ERRORS.md a partir de incidentes de suporte reais.
  Reativo — NUNCA proativo. Cada entrada documenta sintoma, causa,
  workaround e status.
  Use quando o usuário pedir "known error", "registrar incidente de
  suporte", "workaround de erro" ou "KNOWN_ERRORS.md".
---
# rdd-known-error — Erros Conhecidos

Registra incidentes de suporte reais em `<modulo>/<projeto>/support/KNOWN_ERRORS.md`.
Reativo — nunca proativo. Só executado quando há um incidente real.

## Referências

- Fronteira ERROR_CATALOG vs KNOWN_ERRORS: `docs/CONSTITUTION.md §7`

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

- `<modulo>/<projeto>/support/KNOWN_ERRORS.md` (se existir, para merge; fallback: raiz)
- `<modulo>/<projeto>/specs/ERROR_CATALOG.md` (se existir, para evitar duplicação; fallback: raiz)

## Gera (downstream)

- `<modulo>/<projeto>/support/KNOWN_ERRORS.md`

## Nunca edita

- `ERROR_CATALOG.md`

## Tools

- `read` (ler KNOWN_ERRORS.md existente, ERROR_CATALOG.md)
- `write` (escrever/atualizar KNOWN_ERRORS.md)
- `question` (coletar detalhes do incidente)

## Modo de erro

`continue` — se falhar, loga warning. Não bloqueia suporte.

## Algoritmo

1. Colete os detalhes do incidente com o usuário via `question` (sintoma, data, contexto, quem reportou)
2. Verifique se o erro já existe em `specs/ERROR_CATALOG.md` — se sim, referencie em vez de duplicar
3. Leia `support/KNOWN_ERRORS.md` existente e determine o próximo ID `KE-XXX` sequencial
4. Redija a entrada com sintoma, causa, workaround e status (template)
5. Faça merge incremental no KNOWN_ERRORS.md — nunca remova nem renumere entradas existentes

## Formato de commit

```
docs: add known error for <sintoma>
```

## Regras

1. NUNCA gere entradas proativamente — só quando houver um incidente real
2. Se o erro já existe em ERROR_CATALOG.md, referencie-o em vez de duplicar
3. Faça merge incremental com KNOWN_ERRORS.md existente
4. Inclua workaround sempre que possível

## Template — KNOWN_ERRORS.md

```yaml
---
project: <NOME>
audience: [suporte, usuario_final]
status: draft
---
```

```markdown
# Known Errors

> Incidentes de suporte reais. Erros de API previstos em contrato vão em
> ERROR_CATALOG.md (ver CONSTITUTION.md §7).

---

## [KE-XXX] — [Sintoma resumido]

**Data do incidente:** DD/MM/AAAA
**Status:** aberto | em_andamento | resolvido | workaround

**Sintoma:**
[descrição do que o usuário reportou]

**Causa:**
[causa raiz, se conhecida]

**Workaround:**
[passo a passo para contornar até resolução definitiva]

**Resolução definitiva:**
[se resolvido, como foi corrigido]
```

## Casos de Borda

- **Erro já catalogado em ERROR_CATALOG.md** — não duplique; crie KE apenas se for incidente real distinto do erro previsto em contrato.
- **Incidente sem causa conhecida** — registre com causa "em investigação" e status `aberto`; workaround opcional.
- **Incidente já resolvido** — status `resolvido` com "Resolução definitiva" preenchida; registre mesmo assim (histórico de suporte).
- **KNOWN_ERRORS.md inexistente** — crie o arquivo com front matter e cabeçalho do template antes da primeira entrada.
