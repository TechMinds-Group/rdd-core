---
name: rdd-migration
description: >-
  Gera MIGRATION.md durante o período de migração de dados real. Define
  estratégia de corte, mapeamento de dados, scripts de migração e rollback.
  Só deve ser executada com trigger explícito do usuário. Use quando o usuário pedir "migração de dados", "estratégia de corte" ou "MIGRATION".
---
# rdd-migration — Estratégia de Migração

Gera `<modulo>/<projeto>/support/MIGRATION.md` com a estratégia de migração de
dados do sistema legado para o novo. Condicional — só executada quando
houver migração de dados real em andamento.

## Referências

- Documentos condicionais: `docs/CONSTITUTION.md §11`
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

- `<modulo>/<projeto>/support/LEGACY_CONTEXT.md` (tabelas, queries, dados legados; fallback: raiz)
- `<modulo>/<projeto>/specs/DATA_MODEL.md` (modelo novo; fallback: raiz)
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` (se existir; fallback: raiz)
- `<modulo>/<projeto>/REQUIREMENTS.md` (RNs de migração, se houver)

## Gera (downstream)

- `<modulo>/<projeto>/support/MIGRATION.md`

## Nunca edita

- `LEGACY_CONTEXT.md`
- `DATA_MODEL.md`

## Tools

- `read` (ler LEGACY_CONTEXT.md, DATA_MODEL.md, REQUIREMENTS.md)
- `write` (escrever MIGRATION.md)
- `question` (para decisões de estratégia de migração)

## Modo de erro

`strict` — se a migração falhar, o corte não pode prosseguir.

## Algoritmo

1. Leia `support/LEGACY_CONTEXT.md` e `specs/DATA_MODEL.md` para mapear tabelas legadas → tabelas novas
2. Defina o escopo da migração: tabelas, volume estimado e estratégia por tabela
3. Elabore o mapeamento campo a campo com transformações necessárias
4. Escreva os scripts UP (migração) e DOWN (rollback)
5. Defina cronograma, validações pós-migração e riscos
6. Escreva `support/MIGRATION.md`

## Formato de commit

```
docs: add migration plan for <projeto>
```

## Template — MIGRATION.md

```yaml
---
project: <NOME>
module: migracao
audience: [tecnica]
status: draft
---
```

```markdown
# Migration Plan — [Nome do Sistema]

> **Última atualização:** DD/MM/AAAA
> **Status:** planejamento | em_andamento | concluido | revertido

---

## 1. Escopo da Migração

| Tabela legada | Tabela nova | Volume estimado | Estratégia |
|---|---|---|---|

## 2. Mapeamento de Dados

| Campo legado | Campo novo | Transformação | Observação |
|---|---|---|---|

## 3. Scripts

### 3.1 Migração (UP)

```sql
-- script de migração
```

### 3.2 Rollback (DOWN)

```sql
-- script de reversão
```

## 4. Cronograma

| Etapa | Data | Responsável |
|---|---|---|

## 5. Validação Pós-Migração

| Verificação | Query de validação | Resultado esperado |
|---|---|---|

## 6. Riscos

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
```

## Casos de Borda

- **`support/LEGACY_CONTEXT.md` inexistente** — execute `rdd-legacy-context` antes; sem o inventário legado não há mapeamento confiável.
- **Migração parcial** — documente apenas as tabelas acordadas; liste as fora do escopo.
- **Rollback executado** — atualize o status para `revertido` e registre motivo e ponto de restauração.
- **Volume alto** — prefira migração em lotes (batches) e documente o critério de corte no cronograma.
- **Sem trigger explícito do usuário** — não execute; a skill é condicional ao período real de migração.
