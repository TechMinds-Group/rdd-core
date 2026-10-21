---
name: rdd-incident-postmortem
description: >-
  Gera documentação pós-incidente (post-mortem) a partir de um incidente
  reportado. Cria INCIDENT_<modulo>_<yyyy-MM-dd-hh:mm>.md com timeline,
  causa raiz, impacto, ações corretivas e lições aprendidas. Complementa
  rdd-known-error — o post-mortem é upstream (incidente → causa raiz →
  known error documentado).
  Use quando o usuário pedir "post-mortem", "documentar incidente", "análise de incidente" ou "INCIDENT".
---
# rdd-incident-postmortem — Documentação Pós-Incidente

Gera um post-mortem estruturado para incidentes de suporte reais.
Cria `<modulo>/<projeto>/support/INCIDENT_<modulo>_<yyyy-MM-dd-hh:mm>.md`
com timeline, causa raiz, impacto, ações corretivas e lições aprendidas.

**Relação com rdd-known-error:** o post-mortem é upstream — documenta o
incidente em profundidade. Ao final, sugere uma entrada para
`rdd-known-error` como follow-up (o known error é o registro persistente
do erro enquanto o post-mortem é a análise do evento pontual).

## Referências

- Fronteira ERROR_CATALOG vs KNOWN_ERRORS: `docs/CONSTITUTION.md §7`
- Estrutura de suporte (IMP-011): `support/`

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

- `<modulo>/<projeto>/PROJECT_CHARTER.md` (contexto do módulo, sistemas afetados)
- `<modulo>/<projeto>/REQUIREMENTS.md` (regras de negócio, para entender impacto)
- `<modulo>/<projeto>/support/KNOWN_ERRORS.md` (se existir — verificar se o erro já é conhecido)
- Descrição do incidente fornecida pelo usuário (via `question`)

## Gera (downstream)

- `<modulo>/<projeto>/support/INCIDENT_<modulo>_<yyyy-MM-dd-hh:mm>.md`

## Nunca edita

- `KNOWN_ERRORS.md` (apenas sugere entrada — a criação é feita por `rdd-known-error`)
- Artefatos técnicos (DATA_MODEL, API_CONTRACTS, UI_SPEC, etc.)
- `REQUIREMENTS.md`

## Tools

- `read` (ler PROJECT_CHARTER.md, REQUIREMENTS.md, KNOWN_ERRORS.md existente)
- `question` (coletar detalhes do incidente: timeline, impacto, causa percebida)
- `write` (criar o arquivo INCIDENT_*.md)
- `glob` (verificar se KNOWN_ERRORS.md existe, descobrir módulo)

## Modo de erro

`warn` — se PROJECT_CHARTER.md ou REQUIREMENTS.md não existirem, gere
o post-mortem com contexto limitado (não bloqueie a documentação de
um incidente urgente por falta de artefatos upstream).

## Formato de commit

```
docs(support): add post-mortem for <sintoma-resumido>
```

## Algoritmo

### Passo 1 — Descobrir módulo

Use `glob` para encontrar diretórios com `PROJECT_CHARTER.md`.

- Se nenhum → "Nenhum módulo RDD encontrado. Informe o caminho do módulo."
- Se 1 → use-o.
- Se múltiplos → `question` para perguntar qual módulo foi afetado.

### Passo 2 — Coletar detalhes do incidente

Use `question` para coletar as seguintes informações (em bloco único ou
iterativo, conforme a urgência):

1. **Data/hora do incidente** (quando começou, quando foi detectado)
2. **Severidade** (crítica / alta / média / baixa)
3. **Duração total** (tempo entre detecção e resolução)
4. **Descrição do que aconteceu** (sintoma reportado pelo usuário ou monitoramento)
5. **Timeline resumida** (detecção → contenção → resolução — marcos)
6. **Usuários/funcionalidades afetados** (impacto)
7. **Causa percebida** (hipótese inicial do responsável)
8. **Ações imediatas tomadas** (o que foi feito para conter)
9. **Ações corretivas planejadas** (curto e longo prazo, com responsável)
10. **Lições aprendidas** (o que funcionou, o que poderia ser melhor)

### Passo 3 — Verificar known errors existentes

Leia `KNOWN_ERRORS.md` (se existir). Se o erro já tiver uma entrada
`KE-XXX` correspondente, referencie-a no post-mortem em vez de duplicar.

### Passo 4 — Montar o post-mortem

Use o template abaixo. Preencha todas as seções — nunca deixe placeholders
sem resposta (use "Não informado" ou "N/A" se o dado não estiver disponível).

### Passo 5 — Sugerir follow-up KNOWN_ERROR

Ao final do post-mortem, inclua a seção "Follow-up" com uma entrada
sugerida para `rdd-known-error` no formato KNOWN_ERRORS.md. Orientação
para o usuário: "Execute `rdd-known-error` para registrar este erro
como conhecido."

## Template — INCIDENT_<modulo>_<timestamp>.md

```yaml
---
project: <NOME_DO_MODULO>
module: incident-postmortem
audience: [suporte, tecnica]
status: draft
incident_date: "YYYY-MM-DD"
severity: <critica|alta|media|baixa>
duration: <Xh Ymin>
---
```

```markdown
# Post-Mortem — <Título curto do incidente>

> **Data do incidente:** DD/MM/AAAA HH:MM
> **Severidade:** Crítica | Alta | Média | Baixa
> **Módulo afetado:** <nome-do-modulo>
> **Duração total:** Xh Ymin (detecção → resolução)
> **Status:** Resolvido | Em investigação

---

## 1. Resumo Executivo

<2-3 frases: o que aconteceu, impacto principal, como foi resolvido>

---

## 2. Timeline do Incidente

| Hora | Evento | Responsável |
|------|--------|-------------|
| HH:MM | Detecção — <como foi detectado> | <nome/equipe> |
| HH:MM | Contenção — <ação de contenção> | <nome/equipe> |
| HH:MM | Diagnóstico — <causa identificada> | <nome/equipe> |
| HH:MM | Resolução — <correção aplicada> | <nome/equipe> |
| HH:MM | Verificação — <confirmação de estabilidade> | <nome/equipe> |

---

## 3. Impacto

**Usuários afetados:**
- <descrição: ex: "todos os usuários do módulo de rastreabilidade">

**Funcionalidades impactadas:**
- <lista de funcionalidades que ficaram indisponíveis ou degradadas>

**Período de impacto:**
- De HH:MM até HH:MM (total: Xh Ymin)

**Dados afetados:**
- <se houve perda, corrupção ou indisponibilidade de dados>

---

## 4. Causa Raiz

**Técnica:**
<descrição detalhada da causa técnica — o que no código/infra/configuração
causou o incidente>

**Organizacional (se aplicável):**
<descrição de causas processuais — falta de monitoramento, deploy sem
rollback, etc.>

---

## 5. Ações Corretivas

### Curto prazo (até 1 semana)

| # | Ação | Responsável | Prazo | Status |
|---|------|-------------|-------|--------|
| 1 | <ação> | <nome> | DD/MM | Pendente |
| 2 | <ação> | <nome> | DD/MM | Pendente |

### Longo prazo (até 1 mês)

| # | Ação | Responsável | Prazo | Status |
|---|------|-------------|-------|--------|
| 1 | <ação> | <nome> | DD/MM | Pendente |
| 2 | <ação> | <nome> | DD/MM | Pendente |

---

## 6. Lições Aprendidas

**O que funcionou bem:**
- <lista>

**O que poderia ter sido melhor:**
- <lista>

**Ações preventivas para o futuro:**
- <lista>

---

## 7. Follow-up: Known Error

> **Ação recomendada:** Execute `rdd-known-error` para registrar este
> erro como conhecido em KNOWN_ERRORS.md.

**Entrada sugerida:**

- **Data do incidente:** DD/MM/AAAA
- **Status:** aberto
- **Sintoma:** <descrição curta do que o usuário vê>
- **Causa:** <causa raiz resumida>
- **Workaround:** <se houver; senão: "Nenhum workaround disponível no momento">
- **Resolução definitiva:** <em andamento — ver ações corretivas>
```

## Casos de Borda

- **Incidente sem causa raiz identificada:** documente "Em investigação"
  na seção 4 e deixe a seção 5 com ações de diagnóstico (ex: "Adicionar
  logs", "Configurar alerta").
- **Múltiplos módulos afetados:** crie um post-mortem unificado listando
  todos os módulos na seção "Módulo afetado" e impacto consolidado.
- **KNOWN_ERRORS.md não existe:** gere o post-mortem normalmente. Na
  seção 7, oriente que o `rdd-known-error` também criará o arquivo.
- **Incidente recorrente (mesmo erro):** referencie o post-mortem anterior
  na seção "Resumo Executivo" e indique que ações corretivas anteriores
  podem ter sido insuficientes.
