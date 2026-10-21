---
name: rdd-architecture
description: >-
  Gera ARCHITECTURE.md e SECURITY.md a partir do DATA_MODEL.md e RNs técnicas.
  Define decisões arquiteturais, stack, padrões, e análise de segurança.
  Use quando o usuário pedir "gerar arquitetura", "ARCHITECTURE", "análise de segurança" ou "SECURITY".
---
# rdd-architecture — Arquitetura e Segurança

Gera `<modulo>/<projeto>/specs/ARCHITECTURE.md` e `<modulo>/<projeto>/specs/SECURITY.md`
com as decisões arquiteturais e análise de segurança do sistema.

## Referências

- MADR (decisões arquiteturais): `docs/CONSTITUTION.md §4`
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

- `<modulo>/<projeto>/specs/DATA_MODEL.md` (tabelas, colunas, PKs, FKs, relacionamentos; fallback: raiz do módulo)
- `<modulo>/<projeto>/REQUIREMENTS.md` §2 (atores e permissões), §3 (estrutura)
- `<modulo>/<projeto>/DECISIONS.md` (se existir)
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` (se existir; fallback: raiz do módulo)
- `<modulo>/<projeto>/support/LEGACY_CONTEXT.md` (se existir, para stack legada; fallback: raiz do módulo)

## Gera (downstream)

- `<modulo>/<projeto>/specs/ARCHITECTURE.md`
- `<modulo>/<projeto>/specs/SECURITY.md`

## Nunca edita

- `REQUIREMENTS.md`
- `DATA_MODEL.md`
- `DECISIONS.md`

## Tools

- `read` (ler documentos upstream)
- `write` (escrever ARCHITECTURE.md, SECURITY.md)
- `question` (para decisões arquiteturais não definidas)

## Modo de erro

`skip` — se falhar, loga warning. Arquitetura é tier completo, não bloqueia o fluxo básico.

## Algoritmo

1. Leia `specs/DATA_MODEL.md` (fallback: raiz) — tabelas, PKs, FKs e relacionamentos definem volume e complexidade do backend.
2. Leia `REQUIREMENTS.md` §2 (atores e permissões) e §3 (estrutura) — definem autenticação, autorização e módulos.
3. Leia `DECISIONS.md`, `specs/API_CONTRACTS.md` e `support/LEGACY_CONTEXT.md` (se existirem) — ADRs, contratos e stack legada restringem as escolhas.
4. Defina stack tecnológica, diagrama de arquitetura, padrões, módulos e fluxo de dados (template ARCHITECTURE.md).
5. Derive a análise de segurança dos atores/permissões e dos dados do modelo (template SECURITY.md: autenticação, autorização, dados sensíveis, auditoria).
6. Em decisão arquitetural não definida, use `question` antes de escrever.
7. Escreva `specs/ARCHITECTURE.md` e `specs/SECURITY.md`.
8. Aponte o próximo passo natural: fechado o conjunto de specs do módulo, a camada seguinte da DAG é a de features — proponha gerá-la com `rdd-task-spec` (análise `analysis/RN-NNN — <título>/` + `delivery/<grupo>/RN-NNN — <título> — Feature.md` — IMP-092/093) ou confirme a ordem com `rdd-next`.

## Propagação de confiança (legado)

- Afirmações derivadas de RN induzida de engenharia reversa **herdam a marca de confiança da RN de origem** (campo `**Confiança:**` em REQUIREMENTS.md).
- Escala: Alta → 🟢 CONFIRMADO · Média → 🟡 INFERIDO · Baixa → 🔴 GAP.
- **Regra de ouro:** na dúvida, nível mais baixo.
- Quando disponível, anexe a evidência da análise reversa (`[arquivo:linha]` ou `@<hash>`) — **afirmação sem evidência nunca recebe 🟢**.

## Formato de commit

```
docs: add architecture and security for <projeto>
```

## Template — ARCHITECTURE.md

```yaml
---
project: <NOME>
module: arquitetura
audience: [tecnica]
status: draft
---
```

```markdown
# Architecture — [Nome do Sistema]

> **Última atualização:** DD/MM/AAAA

---

## 1. Stack Tecnológica

| Camada | Tecnologia | Versão |
|---|---|---|
| Backend | | |
| Frontend | | |
| Banco | | |
| Cache | | |

## 2. Diagrama de Arquitetura

[Descrição textual ou Mermaid diagram]

## 3. Padrões

- [padrão de arquitetura, ex: Clean Architecture]
- [padrão de código, ex: Repository + Service]

## 4. Módulos

| Módulo | Responsabilidade | Depende de |
|---|---|---|

## 5. Fluxo de Dados

[Descrição do fluxo de dados entre módulos/sistemas externos]
```

## Template — SECURITY.md

```yaml
---
project: <NOME>
module: seguranca
audience: [tecnica]
status: draft
---
```

```markdown
# Security — [Nome do Sistema]

> **Última atualização:** DD/MM/AAAA

---

## 1. Autenticação

| Método | Provedor | Escopo |
|---|---|---|

## 2. Autorização

| Papel | Permissões | RN |
|---|---|---|

## 3. Dados Sensíveis

| Campo | Classificação | Proteção |
|---|---|---|

## 4. Auditoria

| Tabela | O que audita | Retenção |
|---|---|---|
```

## Casos de Borda

- **Módulo sem backend próprio** (só consome APIs existentes): documente a stack de frontend e o consumo das APIs; não invente camada de backend — marque a dependência no fluxo de dados.
- **Monolito vs MFE**: se o projeto já tem MFEs (módulos irmãos), siga o padrão de Module Federation; se for monolito legado, documente a estratégia de convivência/migração.
- **Stack legada conflitante com a stack alvo (LEGACY_CONTEXT.md)**: registre a estratégia (ex: Strangler Fig) na seção de padrões — não omita o conflito.
- **ADR conflitante sobre stack em DECISIONS.md**: resolva com `question` antes de escrever e registre a decisão final no ARCHITECTURE.md.
- **Dado sensível sem classificação em DATA_MODEL.md**: derive a classificação das RNs de §2/§3; se permanecer ambíguo, pergunte via `question`.
