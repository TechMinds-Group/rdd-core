---
name: rdd-glossary
description: >-
  Gera ou atualiza os 3 glossários do projeto (DEV, BUSINESS, USER) a partir
  do mesmo insumo. Faz merge incremental — nunca deleta termos existentes,
  apenas adiciona novos.
  Use quando o usuário pedir "gerar glossário", "glossário de negócio", "DEV_GLOSSARY" ou "atualizar termos do glossário".
---
# rdd-glossary — Glossários (3 níveis)

Gera 3 arquivos de glossário a partir do mesmo insumo, cada um para uma
audiência diferente. Faz merge incremental com termos existentes.

## Referências

- Front matter: `docs/CONSTITUTION.md §2`
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

- `<modulo>/<projeto>/REQUIREMENTS.md` (se existir)
- `<modulo>/<projeto>/glossaries/DEV_GLOSSARY.md` (se existir, para merge; fallback: raiz)
- `<modulo>/<projeto>/glossaries/BUSINESS_GLOSSARY.md` (se existir, para merge; fallback: raiz)
- `<modulo>/<projeto>/glossaries/USER_GLOSSARY.md` (se existir, para merge; fallback: raiz)
- Transcrição de reunião ou termos soltos

## Gera (downstream)

- `<modulo>/<projeto>/glossaries/DEV_GLOSSARY.md`
- `<modulo>/<projeto>/glossaries/BUSINESS_GLOSSARY.md`
- `<modulo>/<projeto>/glossaries/USER_GLOSSARY.md`

## Nunca edita

- `REQUIREMENTS.md`
- Qualquer outro documento de requisito

## Tools

- `read` (ler arquivos existentes)
- `write` (escrever glossários)
- `question` (para ambiguidades)

## Modo de erro

`continue` — se falhar, loga warning e segue. Glossários são enriquecimento.

## Algoritmo

1. Leia `REQUIREMENTS.md` (se existir) e a transcrição/termos fornecidos — extraia os termos candidatos.
2. Leia os 3 glossários existentes em `glossaries/` (fallback: raiz) para o merge incremental.
3. Para cada termo novo, classifique a audiência (DEV/BUSINESS/USER) e aplique o formato e a regra de idioma do glossário correspondente.
4. Aplique as regras de merge incremental: adicione apenas termos novos; em definição conflitante, use `question`.
5. Escreva/atualize `DEV_GLOSSARY.md`, `BUSINESS_GLOSSARY.md` e `USER_GLOSSARY.md` em `glossaries/`.

## Formato de commit

```
docs: add/update glossary terms for <projeto>
```

## Regras de merge incremental

1. Leia os glossários existentes antes de gerar
2. Adicione apenas termos **novos** (não presentes no existente)
3. **Nunca delete** ou sobrescreva termos existentes
4. Se um termo existente tiver definição conflitante, use `question` para perguntar

## 1. DEV_GLOSSARY.md — audiência [tecnica]

```yaml
---
project: <NOME>
module: glossario
audience: [tecnica]
status: draft
---
```

**Formato por termo:**
```markdown
## [Nome do Termo]

**Definição:** [definição técnica precisa]
**Classificação DDD:** [Aggregate Root, Value Object, Entity, Domain Event]
**Relações:** [termos relacionados]
**Não confundir com:** [termos parecidos]
```

**Regra de idioma:** o título é o termo técnico (jargão da área, frequentemente em inglês — ex.: `## Backfill`). Não traduza o título para DEV; a tradução/contexto vai na definição.

## 2. BUSINESS_GLOSSARY.md — audiência [negocio]

```yaml
---
project: <NOME>
module: glossario
audience: [negocio]
status: draft
---
```

**Formato por termo:**
```markdown
## [Termo em português (sigla/expansão em português)]

[2-4 frases, linguagem clara, sem jargão técnico]
```

**Regra de idioma:** glossário 100% em português — título e parênteses na língua da audiência (PT-BR). **Nunca use termos em inglês** (nem no título, nem entre parênteses). Parênteses apenas para siglas ou expansões em português (ex.: `## GTA (Guia de Trânsito Animal)`, `## Unidade de Exploração (UE)`). Se o conceito só existir em inglês, traduza o título e explique na definição.

## 3. USER_GLOSSARY.md — audiência [usuario_final]

```yaml
---
project: <NOME>
module: glossario
audience: [usuario_final]
status: draft
---
```

**Formato por termo:**
```markdown
## O que é [nome]

[2-4 frases, linguagem coloquial]
```

**Regra de idioma:** `[nome]` em português (língua da audiência), linguagem coloquial. Ex.: `## O que é Carga Inicial`.

## Casos de Borda

- **Termo existente com definição conflitante**: não sobrescreva — use `question` para decidir entre manter, atualizar ou registrar as duas acepções.
- **Termo que só existe em inglês**: no DEV_GLOSSARY mantenha o título técnico em inglês; no BUSINESS e no USER traduza o título e explique na definição (nunca inglês nesses dois).
- **Mesmo termo serve a várias audiências**: gere a entrada nos 3 glossários, cada uma no formato e idioma da sua audiência — não reutilize o texto do DEV no BUSINESS.
- **Glossários ainda não existem**: crie os 3 arquivos em `glossaries/` com front matter — o merge incremental passa a valer nas execuções seguintes.
- **Termo sem definição clara no insumo**: pergunte via `question` antes de escrever — não publique definição genérica.
