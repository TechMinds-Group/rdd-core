---
name: rdd-handover
description: >-
  Resumo de estado de um módulo para alguém novo assumir o projeto: veredito
  (finalizado/em andamento/bloqueado/não iniciado) com justificativa, guia de
  leitura, decisões-chave, stakeholders, pendências, definição de done e
  erros/migração. Persiste o veredito em HANDOVER_LOG.md para rastreabilidade.
  Use quando o usuário pedir "handover", "resumo para assumir o módulo", "veredito do módulo" ou "estado do projeto para alguém novo".
---
# rdd-handover — Resumo de Estado para Assunção de Módulo

Responde "o que alguém novo precisa saber para assumir este módulo?" —
diferente do `rdd-progress` ("onde estamos", KPIs) e do `rdd-next`
("o que fazer agora", próximas skills).

## Diferenciação

| Aspecto | rdd-progress | rdd-next | rdd-handover |
|---------|-------------|----------|--------------|
| Pergunta | "Onde estamos?" | "O que fazer agora?" | "O que alguém novo precisa saber?" |
| Saída | 4 blocos de KPIs | 3-5 ações priorizadas | Veredito + contexto + guia de leitura |
| Foco | Saúde em reuniões de status | Auto-routing da DAG | Assunção de módulo (handover) |
| Persistência | Opcional via --save | Nunca | Nunca (só texto) |

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

Todas as fontes são **opcionais** — ausência vira "não disponível":

- `<module-root>/PROJECT_CHARTER.md` (escopo, stakeholders, legado, REDMINE)
- `<module-root>/CONSTITUTION.md` (DAG do módulo, convenções de ID)
- `<module-root>/REQUIREMENTS.md` (RNs, §11 PENDs abertos)
- `<module-root>/quality/TRACEABILITY.md` (matriz RN → artefatos, gaps; fallback: raiz)
- `<module-root>/quality/PROPAGATION_STATUS.md` (drift stale; fallback: raiz)
- `<module-root>/support/CHANGE_REQUESTS.md` (CRs aprovados/pendentes; fallback: raiz)
- `<module-root>/DECISIONS.md` (ADRs)
- `<module-root>/quality/DEFINITION_OF_DONE.md` (se existir; fallback: raiz)
- `<module-root>/support/KNOWN_ERRORS.md` e `<module-root>/support/MIGRATION.md` (se existirem; fallback: raiz)
- `<module-root>/delivery/SCOPE_AGREEMENT.md` (alinhamento com cliente; fallback: raiz)
- Artefatos da DAG (specs/DATA_MODEL, specs/API_CONTRACTS, specs/UI_SPEC, etc.) para fase atual — com fallback para a raiz

## Gera (downstream)

- Saída textual na sessão (exibida ao usuário)
- `<module-root>/delivery/HANDOVER_LOG.md` (append-only, com timestamp) — para rastreabilidade

## Nunca edita

- Nenhum artefato técnico. Read-only absoluto.

## Tools

- `glob` (descobrir módulos, listar artefatos existentes)
- `read` (ler charter, requirements, decisões, DoD, etc.)
- `grep` (contar RNs, detectar PEND-XXX, parsear status na matriz)
- `question` (se múltiplos módulos, perguntar qual)

## Modo de erro

`warn` — se uma fonte não existir, o bloco correspondente mostra
"não disponível" em vez de falhar ou mostrar zero sem contexto.

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum projeto RDD encontrado. Execute rdd-project-intake."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual. Sem resposta, analise
  todos e mostre resumos separados.

### Passo 2 — Coletar dados

1. **PROJECT_CHARTER.md**: nome, REDMINE, status, legado, stakeholders.
2. **Fase DAG**: verifique a existência de cada artefato por fase
   (mesma tabela do `rdd-progress` Bloco D).
3. **TRACEABILITY.md**: totais de RNs completas/parciais/gaps (seção
   "## 4. Resumo" ou contagem na matriz).
4. **PROPAGATION_STATUS.md**: entradas stale pendentes.
5. **REQUIREMENTS.md §11**: PENDs abertos (sem `[resolvido]`/`[bloqueado]`).
6. **DECISIONS.md**: lista de ADRs com status (Aceito/Proposto/Rejeitado).
7. **DEFINITION_OF_DONE.md**: checklist de done (se existir).
8. **KNOWN_ERRORS.md / MIGRATION.md**: existência e resumo de 1 linha.

### Passo 3 — Determinar veredito

Avalie na ordem. A primeira condição que casar define o veredito:

| Veredito | Condição |
|----------|----------|
| **NÃO INICIADO** | Só PROJECT_CHARTER.md (e talvez CONSTITUTION.md) — sem REQUIREMENTS.md |
| **EM ANDAMENTO** | REQUIREMENTS.md existe, mas faltam artefatos de tradução/qualidade, ou há PENDs abertos, ou TRACEABILITY tem gaps |
| **BLOQUEADO** | PENDs com `[bloqueado]` (3+ tentativas), ou PROPAGATION_STATUS com stale antigo sem ação recente |
| **FINALIZADO** | Intake 4/4 + Requirements 3/3 + Translation 7/7 + Quality 4/4, sem PENDs abertos, sem drift stale, TRACEABILITY sem gaps |

**Justificativa:** 2-4 bullets com evidências (ex: "faltam
VALIDATION_REPORT.md e HOWTO; 11 PENDs abertos").

### Passo 4 — Montar saída

Monte o resumo na ordem dos blocos abaixo. Cada bloco cuja fonte não
existe mostra "não disponível" — nunca inventa dado.

## Formato de saída

```text
═══ rdd-handover — <módulo> ═══  <timestamp>

🎯 Veredito: FINALIZADO
   Justificativa: Intake 4/4, Requirements 3/3, Translation 7/7,
   Quality 4/4; sem PENDs abertos; sem drift stale.

📚 Guia de leitura (ordem sugerida):
   1. PROJECT_CHARTER.md — escopo, stakeholders, REDMINE #337747
   2. CONSTITUTION.md — DAG e convenções de ID
   3. REQUIREMENTS.md — 51 RNs, seções 5 (RNs) e 11 (PENDs)
   4. DATA_MODEL.md / API_CONTRACTS.md — estrutura técnica
   5. SCOPE_AGREEMENT.md — alinhamento com cliente

📊 Fase atual: Quality (4/4)
   Fase 0 — Intake:       4/4 ✓ | Fase 1 — Requirements: 3/3 ✓
   Fase 2 — Translation:  7/7 ✓ | Fase 3 — Quality:      4/4 ✓

📋 Cobertura: 51 RNs — 2 ✅ completas, 21 🟡 parciais, 26 ❌ gaps
   🔥 Gaps críticos: RN-013/014/016, RN-020/021, RN-044, RN-046

🗂️ Decisões-chave (DECISIONS.md): 4 ADRs
   - ADR-001: batch migração vet. externo → credenciado (Aceito)
   - ADR-004: resource REST dedicado vacinação (Proposto)

👥 Stakeholders: Sponsor <nome> | PO <projeto> | Lead Operador RDD
   Redmine: #337747 | Legado: sim (LEGACY_CONTEXT.md existe)

⏳ Pendências: 11 PENDs abertos (PEND-001 há 99d, 0 tentativas)
   → priorizar rdd-clarify (não bloqueia handover)

📌 DoD: checklist em DEFINITION_OF_DONE.md (5/8 itens ✓)
   KNOWN_ERRORS: não disponível | Migração: MIGRATION.md existe (1 fase restante)
```

## Guia de leitura (P4)

A ordem segue a DAG: começar pelo charter, depois requisitos, depois
técnico, depois qualidade. Se um documento não existe, pule para o
próximo existente. Máximo 6 itens.

## Formato de commit

```
docs: add handover log for <modulo>
```

## Casos de Borda

### Módulo pré-intake (só PROJECT_CHARTER.md)

```
🎯 Veredito: NÃO INICIADO
   Justificativa: apenas o charter existe; falta gerar CONSTITUTION.md
   e REQUIREMENTS.md.

📚 Guia de leitura: PROJECT_CHARTER.md — escopo inicial do módulo
📊 Fase atual: Intake (1/4)
```

### TRACEABILITY.md não existe

Bloco Cobertura mostra "dado não disponível. Execute rdd-traceability
primeiro." Sem inventar percentuais.

### Sem DECISIONS.md

Bloco Decisões-chave: "não disponível".

### Módulo finalizado sem pendências

Veredito FINALIZADO com justificativa limpa. Não invente sugestões de
melhoria artificialmente.

### Múltiplos módulos

Se o usuário não escolher, mostre resumos sequenciais separados por `---`.

### Veredito ambíguo (em andamento com bloqueios)

Se houver PENDs abertos E artefatos faltando, priorize o sinal mais forte:
`[bloqueado]` em PENDs → BLOQUEADO; apenas PENDs sem bloqueio + gaps →
EM ANDAMENTO com nota das pendências.

## Workflow

1. Descubra módulo(s) (Passo 1).
2. Para o módulo selecionado, colete dados (Passo 2).
3. Determine o veredito com justificativa (Passo 3).
4. Monte o resumo na ordem dos blocos (Passo 4).
5. Exiba ao usuário.
6. **Persista** o veredito em `<module-root>/delivery/HANDOVER_LOG.md` no formato append-only:

```markdown
## Handover — DD/MM/AAAA HH:MM

**Módulo:** <nome>
**Veredito:** <finalizado/em andamento/bloqueado/não iniciado>
**Justificativa:** <2-4 bullets>

---
```

Se o arquivo não existir, crie-o com front matter:
```yaml
---
project: <NOME>
module: handover-log
audience: [gestao]
status: draft
---
```
Se existir, adicione ao final (append).
