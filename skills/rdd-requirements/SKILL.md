---
name: rdd-requirements
description: >-
  Gera ou atualiza <modulo>/<projeto>/REQUIREMENTS.md a partir da transcricao
  de uma reuniao de negocios. Cobre criacao inicial e merge incremental.
  Registra decisoes em DECISIONS.md e gera CHANGELOG.md como efeito colateral.
  Le o checkpoint de rdd-clarify como entrada. IMP-094: promove PEND a RN
  (nova RN sequencial com proveniência da PEND de origem) — a RN ancora
  feature; PEND nunca ancora feature.
  Use quando o usuário pedir "gerar requisitos", "atualizar
  REQUIREMENTS.md", "registrar RNs de reunião" ou "regras de negócio".
---
# rdd-requirements — Gerenciamento de REQUIREMENTS.md

Gera ou atualiza `<modulo>/<projeto>/REQUIREMENTS.md` a partir de transcrição
de reunião de negócios. Faz merge incremental, nunca reescreve do zero.

## Referências

- EARS: `docs/CONSTITUTION.md §3`
- Front matter: `docs/CONSTITUTION.md §2`
- IDs RN-XXX, PEND-XXX: `docs/CONSTITUTION.md §1`
- Template de 11 seções: `docs/CONSTITUTION.md` (aqui embutido por praticidade)
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

- `<modulo>/<projeto>/PROJECT_CHARTER.md` (para REDMINE #, escopo, stakeholders)
- `<modulo>/<projeto>/REQUIREMENTS.md` (se existir)
- `<modulo>/<projeto>/DECISIONS.md` (se existir)
- `<modulo>/<projeto>/meetings/` (checkpoints do rdd-clarify e meetings anteriores)
- `<modulo>/<projeto>/LINGUAGEM_UBIQUA.md` (opcional — se existir, use os termos canônicos; termo divergente na transcrição vira nota de rodapé)

## Gera (downstream)

- `<modulo>/<projeto>/REQUIREMENTS.md`
- `<modulo>/<projeto>/DECISIONS.md` (se houver novas decisões)
- `<modulo>/<projeto>/CHANGELOG.md` (efeito colateral automático)
- `<modulo>/<projeto>/meetings/YYYY-MM-DD-NN.md` (resumo da reunião + perguntas/respostas, NN = próximo sequencial na pasta)

## Nunca edita

- `support/CHANGE_REQUESTS.md` (mudança em RN existente só por CR; fallback: raiz)
- `PROJECT_CHARTER.md`

## Tools

- `read` (ler arquivos existentes)
- `write` (escrever/atualizar REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md)
- `question` (para ambiguidades não cobertas pelo CLARIFY)

## Modo de erro

`strict` — se REQUIREMENTS.md não for gerado/atualizado, o fluxo para.

## Algoritmo

1. Leia o checkpoint mais recente em `meetings/` (saída do `rdd-clarify`) e o REQUIREMENTS.md existente, se houver
2. Extraia da transcrição: RNs candidatas, PENDs, decisões (com decisor), campos, atores e escopo
3. Se o arquivo existe, faça merge incremental (novas RNs/PENDs sequenciais a partir da última; PENDs resolvidas movem para a seção de resolvidas; PENDs promovidas a RN seguem a seção "Promoção de PEND a RN (IMP-094)"); se não, gere do template
4. Registre novas decisões em DECISIONS.md e atualize o CHANGELOG.md como efeito colateral
5. Escreva o checkpoint da reunião em `meetings/YYYY-MM-DD-NN.md` (NN = próximo sequencial)
6. Se houver ambiguidade não coberta pelo clarify, use `question` antes de registrar
7. **Portão de cobertura downstream (IMP-046):** ao fechar um lote de RNs novas (≥ 3 RNs), verifique antes de encerrar se cada RN nova tem downstream previsto — rode `rdd-traceability` (ou verifique os gaps na matriz) e reporte explicitamente: `RN sem downstream em DATA_MODEL/API_CONTRACTS/UI_SPEC = pendência do lote`. Um lote NÃO está encerrado enquanto houver RN nova sem destino downstream declarado (ou justificativa explícita de por que não aplica). Isso evita repetir gaps reais já vistos em retrospectivas (lote de RNs de uma feature sem seção dedicada no DATA_MODEL — ver retrospectivas do produto).
8. **Confiança de RNs induzidas (legado):** quando a fonte é relatório de engenharia reversa do `@rdd-reverse-orchestrator` (módulo com `sistema_existente: true`), cada RN induzida carrega no corpo a tag de confiança da análise reversa: `**Confiança:** Alta` | `Média` | `Baixa` (escala: Alta→🟢 CONFIRMADO, Média→🟡 INFERIDO, Baixa→🔴 GAP; na dúvida, registre o nível mais baixo). RN com confiança **Baixa** que não passar por validação humana segue a regra IMP-094 (vira PEND — nunca ancora feature).

### Segunda camada Jev (opcional) — passo 8

- Antes de gravar a tag de confiança de cada RN induzida de legado, submeta ao `@rdd-jev-classifier`: `text` = corpo da RN + evidência citada (`[arquivo:linha]` / `@hash`); `questions` = JSON TypeSafe, ex.: `{"classificacao": {"type": "choice", "criteria": {"confirmada": "Evidencia citada confirma diretamente a afirmacao", "inferida": "Afirmacao e deducao de padrao, nao leitura direta", "lacuna": "Evidencia insuficiente para julgar"}}}`.
- **Regra conservadora:** se o Jev retorna `confirmada` com probabilidade < 0.7 (ou retorna `inferida`/`lacuna`), **rebaixe** um nível (Alta→Média→Baixa) e anote no corpo da RN: `Jev: inferida (p=0.55)` — o Jev **só rebaixa, nunca eleva** o grau.
- Agrupe as chamadas em lote (uma sessão do subagent para todas as RNs do lote), nunca 1 sessão por RN.
- O Jev é **opcional** — nunca gate bloqueante; se indisponível/falhar, grave a tag original e siga sem ele (avise no checkpoint da reunião).

### Contradição semântica no merge (Jev, opcional) — passo 3

- RN induzida nova de re-análise reversa que toque no mesmo domínio de RN confirmada existente → submeta o PAR (texto antigo, texto novo) ao `@rdd-jev-classifier` com criteria `{consistente, contraditoria, incomparavel}`.
- `contraditoria` com p >= 0.7 → **NÃO sobrescrever silenciosamente**: registre como candidato a Change Request (CR) em `support/CHANGE_REQUESTS.md` e sinalize no CHANGELOG.md, seguindo o fluxo de CR existente.
- O Jev é **opcional** — se indisponível/falhar, siga o merge normal (regra geral 2) e registre o aviso; nunca bloqueie.

## Formato de commit

```
docs: add/update requirements from meeting YYYY-MM-DD
```

## Regras Gerais

0. **Propague o REDMINE do PROJECT_CHARTER.md** — leia o campo REDMINE no charter e inclua `> **REDMINE:** #[numero]` no REQUIREMENTS.md. Se não houver REDMINE, omita.

1. **Não invente** — definições, prazos, regras ou valores que não estiverem na transcrição. Se algo não estiver claro, use `question`.

2. **Se o arquivo já existe**, leia-o primeiro e faça merge incremental:
   - Nunca reescreva do zero
   - Novas RNs seguem numeração sequencial a partir da última existente
   - Novas PENDs seguem numeração sequencial a partir da última existente
   - PENDs resolvidas na reunião atual → mover para seção 10 (Decisões) com marcação `[confirmado] (data da reunião)`
   - Contradições com o existente → use `question` em vez de corrigir

3. **Se o arquivo não existe**, gere do zero seguindo o template.

4. **Toda RN nova deve ser registrada no CHANGELOG.md** como efeito colateral.

5. **Tabelas markdown: o número de segmentos `|---|` no separador deve ser idêntico ao número de colunas do cabeçalho.** Conte manualmente. Exemplo: 4 colunas → `|---|---|---|` (4 segmentos). 3 colunas → `|---|---|` (3 segmentos). Um segmento a mais ou a menos quebra a renderização.

6. **Decisões de design/escopo** mencionadas na reunião devem ser registradas em DECISIONS.md no formato MADR:
   - Extraia da transcrição **quem decidiu** (autor/decisor da decisão). Pode ser uma pessoa, um papel ('Lead Técnico', 'Cliente') ou múltiplos nomes separados por vírgula.
   - Se o decisor não estiver explícito na transcrição, use `question` para perguntar ao usuário.
   - Persista o decisor no campo `Decisor:` de cada novo ADR (ver template abaixo).
   - Novos ADRs seguem numeração sequencial a partir do último existente; nunca renumerar ADRs antigos.
   - ADRs existentes sem o campo `Decisor:` devem ser preservados inalterados (merge incremental; não adicione `Decisor:` retroativamente).

7. **LINGUAGEM_UBIQUA.md** — se existir no módulo, use exatamente os termos definidos nele. Termo divergente na transcrição: use o termo canônico e registre a variante em nota de rodapé.

8. **Gatilho de divisão do documento** — se o REQUIREMENTS.md resultante ultrapassar ~600-700 linhas, ou a transcrição cobrir mais de uma funcionalidade/módulo independente, avise o usuário que pode fazer sentido dividir em múltiplos arquivos (ex. `REQUIREMENTS_VACINACAO.md`) e pergunte antes de decidir. Nunca divida automaticamente sem confirmação.

9. **Regra removida com relevância externa** — se uma RN deixou de se aplicar mas tem relevância externa (ex.: referenciada em tarefa do Azure DevOps), marque como `[removido]` com uma frase breve do motivo em vez de apagar silenciosamente. Se era puramente interna e nunca referenciada fora do documento, pode remover a linha — na dúvida, marque como removido.

10. **Promoção de PEND a RN (IMP-094)** — PEND sai do estado aberta por promoção a RN, por virar CR (altera RN confirmada — `rdd-change-request`) ou por encerrar como decisão; PEND NUNCA ancora feature. Ao promover, siga a seção "Promoção de PEND a RN (IMP-094)".

## Promoção de PEND a RN (IMP-094)

PEND sai do estado aberta SOMENTE por promoção a RN (resolução define
requisito novo/complementar), por virar CR (resolução revela alteração em
RN já confirmada — via `rdd-change-request`, IMP-094 R2) ou por encerrar
como decisão. PEND NUNCA ancora feature (IMP-094 R1) — a feature nasce da
RN.

Ao promover uma PEND-NNN a RN:

1. **Numeração sequencial NOVA** — a RN recebe o próximo número sequencial
   de RNs de REQUIREMENTS.md; NUNCA reutilize o número da PEND.
2. **Conteúdo derivado da PEND** — texto da resolução esclarecida
   (respostas do checkpoint de clarify / decisão do cliente), no padrão
   EARS das demais RNs, com tag `[confirmado]` e data.
3. **Proveniência obrigatória** — logo abaixo da linha da RN nova, inclua:
   `> Promovida de PEND-NNN em DD/MM/AAAA.`
4. **Marque a PEND de origem na §11** — mantenha a linha da PEND com a
   marcação `**Promovida a RN-XXX em DD/MM/AAAA**` (nunca apague a linha
   silenciosamente — rastreabilidade).
5. **Registre no CHANGELOG.md** — efeito colateral padrão (RN adicionada).
6. **A RN promovida é uma RN comum** — qualquer alteração posterior passa
   por CR (`rdd-change-request`); nunca edite a RN promovida diretamente.

A RN criada é a âncora legítima da feature: `rdd-task-spec` gera a análise
e o Feature.md com a RN como âncora (IMP-094 R1).

## Template — REQUIREMENTS.md (11 seções)

```yaml
---
project: <NOME>
module: requisitos
audience: [tecnica, negocio]
status: draft
---
```

```markdown
# [Nome do Sistema] — [Subtítulo descritivo]

> **REDMINE:** #[numero]
> **Última atualização:** DD/MM/AAAA
> **Objetivo:** [descrição concisa]

---

## 1. Escopo

- [item dentro do escopo]

> Fora do escopo:
> - [item fora]

---

## 2. Atores e Permissões

| Papel | Pode fazer | Não pode fazer |
|---|---|---|

---

## 3. Estrutura da Aplicação

[descrição textual]

---

## 4. Conceitos de Domínio

| Termo | API | Descrição |
|---|---|---|

---

## 5. Regras de Negócio

### [Tema]

- **RN-XXX** `[confirmado]` (DD/MM/AAAA) — `[tipo EARS]` [frase]

---

## 6. Dados e Campos

### [Entidade]

| Campo | Obrigatório | Formato | Comportamento |
|---|---|---|---|

---

## 7. Casos de Uso / Fluxos

1. [passo]

---

## 8. Saídas e Integrações

---

## 9. Persistência e Auditoria

| Entidade | Tabela | Finalidade | Rastreabilidade |
|---|---|---|---|

---

## 10. Decisões e Fora do Escopo

| Item | Decisão | Motivo |
|---|---|---|

---

> **Regra de idioma:** Requisitos em português brasileiro (PT-BR). Títulos de seção, descrições de RNs, UCs e campos em PT-BR. Apenas notação EARS (shall, must, should), identificadores (RN-001, UC-001) e termos técnicos do domínio permanecem no original.

## 11. Pendências e Dúvidas em Aberto

- **PEND-XXX** (DD/MM/AAAA) — [descrição]
- **PEND-YYY** (DD/MM/AAAA) — [descrição] `**Promovida a RN-ZZZ em DD/MM/AAAA**`
```

## Template — Meeting (Checkpoint)

Arquivo: `<modulo>/<projeto>/meetings/YYYY-MM-DD-NN.md` (NN = próximo sequencial)

```markdown
---
project: <NOME>
module: meeting
audience: [tecnica]
status: draft
---

# Requisitos — DD/MM/AAAA

**Resumo:** [descrição concisa do que foi discutido e incorporado]

## Perguntas e Respostas

### [pergunta]

**Resposta:** [resposta]
```

## Template — CHANGELOG.md

```markdown
# Histórico de Mudanças

## [data] — [descrição curta]

### Adicionado
- RN-XXX: [descrição]

### Alterado
- RN-YYY: [descrição da mudança]

### Removido
- RN-ZZZ: [descrição]
```

## Template — DECISIONS.md

```markdown
# Architecture Decision Records — [Nome do Módulo]

## ADR-NNN: [título curto]

**Status:** Aceito | Proposto | Rejeitado | Superseded
**Data:** DD/MM/AAAA
**Decisor:** [nome do decisor/autor da decisão] | Não informado
**Contexto:** [censo que levou à decisão]
**Decisão:** [o que foi decidido — usar linguagem direta]
**Consequências:** [impactos positivos, negativos, riscos, dívidas técnicas]
```

## Exemplo de Commit

```bash
git add <modulo>/<projeto>/REQUIREMENTS.md <modulo>/<projeto>/DECISIONS.md <modulo>/<projeto>/CHANGELOG.md <modulo>/<projeto>/meetings/
git commit -m "docs: update requirements from meeting 2026-07-21

- Add RN-027 `[evento]` and RN-028 `[indesejado]` for batch validation
- Move PEND-001 para Decisoes (confirmado)
- Record decision on autocadastro workflow (Decisor: [nome])"
```

## Casos de Borda

- **Transcrição sem RNs novas** — atualize apenas o que mudou (escopo, decisões); não gere seções vazias.
- **Contradição com RN existente** — não corrija silenciosamente; use `question` e, se confirmada, registre CR em `support/CHANGE_REQUESTS.md` (nunca edite a RN diretamente).
- **Documento ultrapassando ~600-700 linhas** — avise sobre divisão em múltiplos arquivos e pergunte antes.
- **Linguagem ubíqua divergente da transcrição** — use o termo canônico e registre a variante em nota (regra geral).
- **RN com relevância externa deixando de se aplicar** — marque `[removido]` com motivo em vez de apagar.
- **Promoção de PEND a RN (IMP-094)** — resolução de PEND define requisito: crie RN sequencial NOVA com proveniência `> Promovida de PEND-NNN em <data>` e marque a PEND na §11 (nunca reutilize o número da PEND; nunca edite a RN promovida sem CR). Se a resolução altera RN já confirmada, o destino é CR (`rdd-change-request`), não RN nova.
