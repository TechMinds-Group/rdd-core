---
name: rdd-change-request
description: >-
  Registra mudança solicitada em requisito já confirmado. CHANGE_REQUESTS.md
  com status pending/approved/rejected/implemented. Gate de score (IMP-094
  R3): a solicitação passa por clarify/score de ambiguidade antes de
  registrar — >= 70 nasce CR direto; < 70 nasce PEND (clarifica primeiro;
  depois vira CR por R2 ou RN por promoção). Se aprovado, pode executar
  skills de tradução técnica para re-propagar o delta.
  Use quando o usuário pedir "registrar mudança", "change request", "CR" ou "alterar requisito confirmado".
---
# rdd-change-request — Gerenciamento de Mudanças

Registra mudanças em requisitos existentes em `CHANGE_REQUESTS.md`.
Toda alteração em RN confirmada deve passar por este fluxo.

## Referências

- IDs CR-XXX: `docs/CONSTITUTION.md §1`
- Processo de aprovação: `docs/CONSTITUTION.md §5`
- Quem aprova: `docs/CONSTITUTION.md §5.3`

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

- `<modulo>/<projeto>/REQUIREMENTS.md` (para identificar RNs afetadas)
- `<modulo>/<projeto>/quality/TRACEABILITY.md` (se existir, para identificar downstreams afetados; fallback: raiz do módulo)

## Gera (downstream)

- `<modulo>/<projeto>/support/CHANGE_REQUESTS.md`
- Após aprovação: opcionalmente executa `rdd-data-model`, `rdd-api-contracts`, `rdd-ui-spec` com escopo restrito ao delta

## Nunca edita

- `REQUIREMENTS.md` diretamente (a mudança só é refletida lá após aprovação)

## Tools

- `read` (ler REQUIREMENTS.md, TRACEABILITY.md existentes)
- `write` (escrever CHANGE_REQUESTS.md)
- `question` (para confirmar aprovação com o usuário)

## Modo de erro

`strict` — se o CR não for registrado, a mudança não pode prosseguir.

- **Score de ambiguidade < 70 (IMP-094 R3)**: NÃO registre CR — registre
  PEND em REQUIREMENTS.md §11 (com perguntas de follow-up) e oriente nova
  tentativa após clarificação; solicitação ambígua nasce PEND, não mudança
  formal. Nenhum arquivo de CR é criado neste caso.

## Formato de commit

```
docs: add CR-XXX for <título>
```

## Estratégia de Perguntas

### Regras

1. **NUNCA inclua "Digitar agora" como opção.** O `question` tool já
   adiciona "Type your own answer" automaticamente.

2. **Agrupe perguntas relacionadas.** Máximo 2 blocos para todo o CR.

3. **Use exemplos contextuais** nas opções, nunca opções genéricas.

### Blocos (máx 3)

**Bloco 0 — Validação de Abordagem** (obrigatório antes de registrar o CR):
- **Repositório/sistema alvo**: onde deve ser implementado? (ex: `<nome>.API`, sistema externo)
- **Abordagem arquitetural**: endpoint novo, adaptação, serviço externo?
- **Atores e permissões**: quem usa? autenticado, público, admin?
- **Alternativas**: outras abordagens consideradas?
- **Confirmação**: "A abordagem está correta? Posso prosseguir?"

**Bloco 1 — Dados da mudança** (única pergunta):
- Descrição resumida da mudança
- RNs afetadas (já identificadas na leitura de REQUIREMENTS.md)
- Justificativa
- **Origem** da mudança (IMP-099): `requisito-mal-capturado | evolucao | bug | decisao-cliente` — perguntar via `question` (opções com as 4 origens); em modo não-interativo, inferir do contexto e registrar a inferência no campo `Origem` do CR
**Bloco 2 — Aprovação** (única pergunta):
- A mudança está aprovada?
- Se sim, deseja repropagar downstreams?

## Workflow

0. **VALIDAÇÃO DE ABORDAGEM (NOVO)** — Antes de registrar qualquer mudança:
   - Pergunte ao usuário usando `question` — Bloco 0 (validação de abordagem)
   - Confirme ONDE (repositório/sistema alvo), COMO (arquitetura), QUEM (atores/permissões) e ALTERNATIVAS
   - **Só prossiga após a confirmação explícita da abordagem pelo usuário**
   - Registre a decisão de abordagem no CR (campo `Repositório alvo` ou similar)

1. Receba a descrição da mudança solicitada
2. Leia `REQUIREMENTS.md` para identificar as RNs afetadas
3. **GATE DE SCORE (IMP-094 R3)** — toda solicitação de mudança passa pelo
   clarify/score de ambiguidade (0-100, critérios C1-C5 da `rdd-clarify`)
   ANTES de ser registrada:
   - **Score >= 70** → a mudança nasce como **CR direto** — siga para o passo 4.
   - **Score < 70** → solicitação ambígua: NÃO registre CR. Registre/atualize
     **PEND** em REQUIREMENTS.md §11 (via `rdd-requirements`/`rdd-clarify`)
     com perguntas de follow-up e oriente retornar após clarificação — a PEND
     resolvida volta como CR (se alterar RN confirmada) ou como RN nova (IMP-094).
4. Pergunte ao usuário usando `question` — Bloco 1 (dados da mudança)
5. Registre o CR em `support/CHANGE_REQUESTS.md` com status `pending` — todo CR inclui o campo `**Origem:**` (IMP-099). CR sem campo origem = registro incompleto (a agregação de métricas de resultado trata como N/A, nunca inventa)
6. Pergunte ao usuário usando `question` — Bloco 2 (aprovação)
7. Se aprovada, atualize status para `approved` e pergunte se deseja re-propagar para downstreams
8. Se rejeitada, registre a justificativa de rejeição

## Template — CHANGE_REQUESTS.md

```yaml
---
project: <NOME>
module: mudancas
audience: [tecnica, negocio]
status: draft
---
```

```markdown
# Registro de Mudanças

## CR-XXX: [título]

**Status:** pending | approved | rejected | implemented
**Data:** DD/MM/AAAA
**Solicitante:** [nome]
**RN afetada:** RN-XXX, RN-YYY
**Origem:** requisito-mal-capturado | evolucao | bug | decisao-cliente (IMP-099)
**Descrição:** [mudança solicitada]
**Justificativa:** [por que a mudança é necessária]
**Downstreams afetados:** DATA_MODEL, API_CONTRACTS, UI_SPEC
**Aprovação:** [quem aprovou/rejeitou, data]
**Motivo de rejeição:** [se rejeitado]
```

## Casos de Borda

- **RN afetada não existe em REQUIREMENTS.md**: não registre CR apontando ID inexistente — confirme via `question` se é requisito novo (encaminhe para `rdd-requirements`) ou erro de referência.
- **CR aprovado sem re-propagação**: registre status `approved` e mantenha os downstreams no campo "Downstreams afetados" — o `rdd-cr-propagation-guard` sinaliza o stale depois.
- **Mudança afeta múltiplas RNs**: registre um único CR listando todas as RNs afetadas — não abra um CR por RN para a mesma solicitação.
- **Mudança já registrada**: verifique CHANGE_REQUESTS.md antes de criar — se já existe CR aberto para a mesma RN, atualize/referencie em vez de duplicar.
- **Bloco 0 sem confirmação explícita**: não prossiga para o registro — a validação de abordagem é obrigatória; sem aprovação, o CR não é criado.
- **Mudança originada de PEND (IMP-094 R2)**: quando a resolução de uma PEND aberta se revela alteração em RN já confirmada, registre o CR normalmente e informe a origem nos campos Descrição/Justificativa (`Promovida de PEND-NNN em <data>`); a PEND de origem deve ser marcada como resolvida no REQUIREMENTS.md com destino ao CR-XXX.

- **CR sem campo `Origem` (IMP-099)**: é registro incompleto — não conclua o fluxo sem classificar a origem (via `question` ou inferência registrada). A skill de agregação de métricas trata CR sem origem como N/A; nunca invente a origem retroativamente.
