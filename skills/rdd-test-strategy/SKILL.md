---
name: rdd-test-strategy
description: >-
  Gera TEST_STRATEGY.md e DEFINITION_OF_DONE.md a partir dos critérios de
  aceitação e arquitetura. Define estratégia, níveis de teste, ferramentas
  e a definição de done do módulo.
  Use quando o usuário pedir "estratégia de testes", "plano de teste",
  "definition of done" ou "DoD do módulo".
---
# rdd-test-strategy — Estratégia de Testes

Gera `<modulo>/<projeto>/quality/TEST_STRATEGY.md` e `<modulo>/<projeto>/quality/DEFINITION_OF_DONE.md`
com a estratégia de testes e a definição de done para o módulo.

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

- `<modulo>/<projeto>/specs/ACCEPTANCE_CRITERIA.md` (se existir; fallback: raiz)
- `<modulo>/<projeto>/specs/ARCHITECTURE.md` (se existir, para stack de teste; fallback: raiz)
- `<modulo>/<projeto>/specs/SECURITY.md` (se existir, para requisitos de segurança; fallback: raiz)
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` (se existir, para testes de API; fallback: raiz)
- `<modulo>/<projeto>/specs/ERROR_CATALOG.md` (se existir, para casos de teste de erro; fallback: raiz)
- `<modulo>/<projeto>/REQUIREMENTS.md` (para contexto)

## Gera (downstream)

- `<modulo>/<projeto>/quality/TEST_STRATEGY.md`
- `<modulo>/<projeto>/quality/DEFINITION_OF_DONE.md`

## Nunca edita

- `ACCEPTANCE_CRITERIA.md`
- `ARCHITECTURE.md`

## Tools

- `read` (ler documentos upstream)
- `write` (escrever TEST_STRATEGY.md, DEFINITION_OF_DONE.md)
- `question` (para decisões de estratégia)

## Modo de erro

`skip` — tier completo, baixa frequência, não bloqueia.

## Algoritmo

1. Leia `specs/ACCEPTANCE_CRITERIA.md` (se existir) para derivar os níveis de teste necessários
2. Leia `specs/ARCHITECTURE.md` e `specs/SECURITY.md` (se existirem) para stack, ferramentas e requisitos de segurança testáveis
3. Leia `specs/API_CONTRACTS.md` e `specs/ERROR_CATALOG.md` (se existirem) para testes de contrato e de erro
4. Preencha o template de TEST_STRATEGY.md (níveis, ferramentas, dados de teste, CI/CD)
5. Derive o checklist de DEFINITION_OF_DONE.md a partir dos critérios de aceitação e da estratégia
6. Escreva ambos em `quality/`
7. Aponte o próximo passo natural: fechado o conjunto de specs do módulo, a camada seguinte da DAG é a de features — proponha gerá-la com `rdd-task-spec` (análise `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-092/093) ou confirme a ordem com `rdd-next`.

## Formato de commit

```
docs: add test strategy and dod for <projeto>
```

## Template — TEST_STRATEGY.md

```yaml
---
project: <NOME>
module: testes
audience: [tecnica]
status: draft
---
```

```markdown
# Test Strategy — [Nome do Sistema]

> **Última atualização:** DD/MM/AAAA

---

## 1. Níveis de Teste

| Nível | Responsável | Ferramenta | Cobertura esperada |
|---|---|---|---|
| Unitário | Dev | | > 80% |
| Integração | Dev | | Fluxos críticos |
| API (contrato) | Dev | | Todos endpoints |
| E2E | QA | | Fluxos principais |

## 2. Ferramentas

| Finalidade | Ferramenta |
|---|---|

## 3. Dados de Teste

| Origem | Estratégia |
|---|---|

## 4. CI/CD

| Pipeline | Gatilho | Ações |
|---|---|---|
```

## Template — DEFINITION_OF_DONE.md

```yaml
---
project: <NOME>
module: dod
audience: [tecnica]
status: draft
---
```

```markdown
# Definition of Done — [Nome do Sistema]

> **Última atualização:** DD/MM/AAAA

---

## Checklist (todos devem ser true para considerar "done")

- [ ] Código revisado por pelo menos 1 par
- [ ] Testes unitários passando
- [ ] Testes de integração passando
- [ ] Documentação atualizada (REQUIREMENTS, API_CONTRACTS, UI_SPEC)
- [ ] Critérios de aceitação validados
- [ ] Sem alertas de segurança críticos
- [ ] CHANGELOG.md atualizado
```

## Casos de Borda

- **Sem ACCEPTANCE_CRITERIA.md** — derive os níveis das RNs em REQUIREMENTS.md e sinalize que os critérios formais ainda não existem.
- **Projeto API-only (sem UI)** — marque E2E de interface como não aplicável; mantenha unitário, integração e API.
- **Stack não informada** — pergunte via `question` antes de fixar ferramentas.
- **Módulo sem CI/CD definido** — registre a seção correspondente como "a definir" em vez de inventar pipeline.
