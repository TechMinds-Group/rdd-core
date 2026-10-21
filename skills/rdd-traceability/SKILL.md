---
name: rdd-traceability
description: > 
  Gera TRACEABILITY.md — matriz de rastreabilidade entre RNs e documentos
  downstream (DATA_MODEL, API_CONTRACTS, UI_SPEC). Atualizado após cada
  skill de tradução técnica rodar.
  Use quando o usuário pedir "matriz de rastreabilidade", "traceability",
  "cobertura de RNs" ou "rastreabilidade de requisitos".
---
# rdd-traceability — Rastreabilidade

Gera `<modulo>/<projeto>/quality/TRACEABILITY.md` — a matriz de rastreabilidade
que mapeia cada RN-XXX aos documentos downstream que a implementam.

## Referências

- IDs RN-XXX, CR-XXX, DEC-XXX: `docs/CONSTITUTION.md §1`
- Fonte primária de dados: `docs/CONSTITUTION.md §6`

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

- `<modulo>/<projeto>/REQUIREMENTS.md` (para lista de RNs)
- `<modulo>/<projeto>/specs/DATA_MODEL.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/specs/ERROR_CATALOG.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/specs/UI_SPEC.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/specs/ARCHITECTURE.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/specs/SECURITY.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/support/CHANGE_REQUESTS.md` (se existir, para CRs implementados; fallback: raiz do módulo)
- `<modulo>/<projeto>/quality/TRACEABILITY.md` (se existir, para merge incremental; fallback: raiz do módulo)

## Gera (downstream)

- `<modulo>/<projeto>/quality/TRACEABILITY.md`

## Nunca edita

- Nenhum documento de origem (é sink — só consome, não produz)

## Tools

- `read` (ler todos os documentos do projeto)
- `grep` (buscar referências a RN-XXX nos documentos)
- `write` (escrever TRACEABILITY.md)

## Modo de erro

`skip` — se falhar, loga warning. A rastreabilidade não bloqueia o fluxo.

## Formato de commit

```
docs: update traceability matrix for <projeto>
```

## Workflow

1. Leia `REQUIREMENTS.md` — extraia todas as RN-XXX
2. Leia cada documento downstream — identifique quais RNs cada um implementa
3. Para cada RN, marque se está coberta em cada documento
4. Identifique RNs sem cobertura (gap) — registre na seção de gaps
5. Identifique CRs aprovados e verifique se já foram refletidos nos downstreams
6. Faça merge incremental com TRACEABILITY.md existente (se houver)
7. Escreva `quality/TRACEABILITY.md`
8. Aponte o próximo passo natural: fechado o conjunto de specs do módulo, a camada seguinte da DAG é a de features — proponha gerá-la com `rdd-task-spec` (análise `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-092/093) ou confirme a ordem com `rdd-next`.

## Template — TRACEABILITY.md

```yaml
---
project: <NOME>
module: rastreabilidade
audience: [tecnica]
status: draft
---
```

```markdown
# Traceability Matrix — [Nome do Sistema]

> **Última atualização:** DD/MM/AAAA

---

## 1. Matriz RN vs Downstreams

| RN | Descrição | DATA_MODEL | API_CONTRACTS | ERROR_CATALOG | UI_SPEC | Status |
|---|---|---|---|---|---|---|
| RN-001 | Regra de exemplo | ✅ | ✅ | ✅ | ❌ | parcial |
| RN-002 | Outra regra | ✅ | ✅ | ✅ | ✅ | completo |
| RN-003 | Pendente | ❌ | ❌ | ❌ | ❌ | gap |

**Legenda:**
- ✅ = coberto, ❌ = gap, — = não se aplica

---

## 2. Gaps Detectados

| RN | Downstream faltante | Impacto |
|---|---|---|
| RN-001 | UI_SPEC | Frontend não tem especificação |

---

## 3. CRs Aprovados vs Implementados

| CR | RN afetada | Aprovado em | Refletido em downstreams |
|---|---|---|---|
| CR-001 | RN-001 | 10/07/2026 | ✅ DATA_MODEL, ❌ API_CONTRACTS |
```

Se não houver documentos downstream, a matriz fica vazia — isso é esperado para projetos novos.

## Casos de Borda

- **Sem documentos downstream** — matriz vazia é esperado em projeto novo; registre o fato, não invente cobertura.
- **RN sem cobertura (gap)** — registre com downstream faltante e impacto; nunca marque ✅ sem evidência no documento.
- **Merge incremental** — nunca remova linhas existentes da matriz; apenas atualize status e adicione RNs novas.
- **CR implementado** — verifique o reflexo nos downstreams e atualize o status por artefato.
- **Documento downstream existe mas não menciona a RN** — considere gap, mesmo com o arquivo presente.
