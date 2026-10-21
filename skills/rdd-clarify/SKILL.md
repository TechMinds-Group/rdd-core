---
name: rdd-clarify
description: >-
  Questiona ambiguidades em requisitos novos usando a ferramenta question.
  Atribui score de ambiguidade (0-100) por item candidato a RN. Itens com
  score < 70 viram PEND-XXX com perguntas de follow-up. Read-only — não
  escreve arquivos de requisitos. Gera checkpoint persistente em
  <module-root>/meetings/YYYY-MM-DD-NN.md para retomada de sessão.
  IMP-094: score >= 70 vira RN nova OU CR direto (se alterar RN já
  confirmada); score < 70 vira PEND — e PEND NUNCA ancora feature (só RN
  ancora; PEND sai de aberta por promoção a RN, virar CR ou decisão).
  Use quando o usuário pedir "esclarecer requisitos", "perguntas de ambiguidade", "score de ambiguidade" ou "checkpoint de clarify".
---
# rdd-clarify — Questionamento Estruturado com Score de Ambiguidade

Antes de gerar ou atualizar `REQUIREMENTS.md`, execute este modo para
identificar lacunas, ambiguidades e suposições na descrição do usuário.
Cada item candidato a RN recebe um score de ambiguidade (0-100) que
determina se vira RN direto ou entra como PEND-XXX com follow-up.

## Referências

- Categorias de questionamento: `docs/CONSTITUTION.md §14`
- Checkpoint persistente: `docs/CONSTITUTION.md §9`
- IDs RN-XXX, PEND-XXX: `docs/CONSTITUTION.md §1`

## Lê (upstream)

- `<module-root>/meetings/` (checkpoints anteriores, para reavaliação incremental de PENDs)
- `<module-root>/REQUIREMENTS.md` (se existir, para detectar conflitos com RNs/PENDs existentes)
- `docs/CONSTITUTION.md` (para as categorias)
- `<repo_docs_rdd>/_docs/patterns/INDEX.md` — bloco `rdd-docs-repo` do AGENTS.md (condicional — IMP-047): antes de propor RNs para feature de domínio já tratado em outro produto, consultar padrões aplicáveis (Tipo `processo`)

## Gera (downstream)

- `<module-root>/meetings/YYYY-MM-DD-NN.md` (checkpoint persistente com scores, NN = próximo sequencial na pasta)

## Nunca edita

- `REQUIREMENTS.md` (read-only por definição)
- `DECISIONS.md`
- Nenhum arquivo de requisito ou decisão

## Tools

- `question` (exclusivamente — não escreve código, não gera requisitos)
- `read` (ler checkpoints anteriores, REQUIREMENTS.md existente)
- `glob` (listar meetings/ para encontrar próximo NN)

## Modo de erro

`strict` — se não conseguir perguntar, o fluxo de requisitos não pode prosseguir.

## Formato de commit

```
docs: add clarify responses for <projeto> YYYY-MM-DD
```

## Score de Ambiguidade

### Escala

Cada item candidato a RN recebe um score de **0 a 100**:

- **0** = completamente ambíguo (nenhum critério atendido)
- **100** = completamente claro (todos os critérios atendidos)

### Critérios e Pesos

| # | Critério | Peso | O que avalia |
|---|----------|------|-------------|
| C1 | Regra de negócio explícita | 30 | Descreve condição E ação (não só "o quê"). Ex: "validar CPF" sem "se inválido → rejeitar" falha. |
| C2 | Termos vagos definidos | 25 | Sem "rápido", "adequado", "quando necessário", "automaticamente" sem métrica, condição ou referência. |
| C3 | Casos de borda | 20 | Comportamento para vazio, duplicado, fora de faixa, nulo é mencionado ou claramente inaplicável. |
| C4 | Ator/origem claro | 15 | Quem realiza a ação e/ou de onde o dado vem está identificado. |
| C5 | Conflito com existente | 10 | Nenhuma contradição com RNs/PENDs em REQUIREMENTS.md ou checkpoints anteriores. |

**Score por item** = soma dos pesos dos critérios atendidos.
Ex: C1(30) + C2(25) + C4(15) = 70/100.
Ex: C1(30) + C3(20) + C4(15) + C5(10) = 75/100.

### Limiar

| Score | Classificação | Ação |
|-------|--------------|------|
| >= 70 | ✅ Claro | Vira RN candidato em REQUIREMENTS.md — ou **CR direto** (via `rdd-change-request`) quando o item altera RN já confirmada (IMP-094 R3) |
| < 70 | ❌ Ambíguo | Vira PEND-XXX com perguntas de follow-up (clarifica primeiro; depois vira CR por R2 ou RN por promoção — IMP-094) |

**Limiar default: 70.** Este valor pode ser ajustado por projeto (ex:
projetos críticos podem exigir 85; provas de conceito podem aceitar 50).
Para alterar, o usuário informa o limiar desejado no início da execução.

### Regras por Critério (detalhamento)

**C1 — Regra de negócio explícita (peso 30)**
O item descreve não apenas O QUE deve acontecer, mas QUANDO/COMO.
- ✅ "Se o CPF for inválido, exibir mensagem de erro e bloquear o salvamento"
- ❌ "O sistema deve validar o CPF"

**C2 — Termos vagos definidos (peso 25)**
Palavras como "rápido", "automaticamente", "adequado", "necessário",
"intuitivo", "simples" precisam de âncora.
- ✅ "O sistema deve exibir loading até 3s; acima disso, exibir timeout"
- ❌ "A resposta deve ser rápida"
- ❌ "Gerar automaticamente" (sem gatilho: em que momento?)

**C3 — Casos de borda (peso 20)**
O item cobre ou declara inaplicáveis os cenários de exceção.
- ✅ "Se o campo estiver vazio, manter valor anterior. Se duplicado, rejeitar."
- ✅ Aplica-se apenas se o critério fizer sentido (item sem casos de borda
  relevantes, ex: "o botão deve ser azul" não tem edge cases relevantes) →
  conta como atendido.
- ❌ A validação não menciona o que acontece se o campo vier vazio,
  duplicado ou fora do intervalo esperado.

**C4 — Ator/origem claro (peso 15)**
O agente da ação e a origem do dado estão identificados.
- ✅ "O MV Cadastrado informa o CPF no campo X. O sistema consulta a
  API de pessoas."
- ❌ "O campo deve ser validado" (quem valida? o frontend? o backend?
  o usuário?)

**C5 — Conflito com existente (peso 10)**
Compara com `REQUIREMENTS.md` e checkpoints anteriores.
- ✅ Item novo, sem contradição com conteúdo existente
- ❌ "O campo deve ser editável" contradiz RN-018 "Data bloqueada na edição"
- ✅ Conflito identificado mas já registrado como PEND-XXX existente
  (não é penalizado de novo)

## Reavaliação Incremental

Quando uma reunião subsequente fornece respostas para um `PEND-XXX`
existente:

1. Leia o checkpoint anterior que criou o PEND-XXX.
2. Compare as novas respostas com as perguntas de follow-up registradas.
3. **Recalcule o score apenas para este item**, usando os mesmos 5 critérios.
4. Se o novo score >= 70 → item promovido a RN candidato. Marque no
   checkpoint como `[PEND-XXX → RN-NNN]`. Se a resposta revelar que o ponto
   é **alteração em RN já confirmada**, o destino é CR (via
   `rdd-change-request`) — IMP-094 R2. A feature nasce da RN/CR — nunca da
   PEND (IMP-094 R1: PEND não ancora feature).
5. Se o novo score < 70 → PEND permanece. Incremente o contador de
   tentativas (ex: "2ª tentativa") e registre as novas perguntas.

**Itens não revisitados** mantêm o score e status anteriores — não são
reavaliados do zero.

## Destinos de PEND Aberta (IMP-094)

Uma PEND-XXX aberta **NUNCA ancora feature** (IMP-094 R1) — o arquivo de
feature só nasce com âncora RN (`RN-NNN — <título> — Feature.md`). A PEND
sai do estado aberta SOMENTE por um destes destinos:

| Destino | Quando | Como |
|---|---|---|
| **(a) Promover a RN** | A resolução esclarecida define requisito novo (ou complemento que não altera RN confirmada) | Nova RN sequencial em REQUIREMENTS.md (nunca reusa o número PEND) com nota de proveniência `> Promovida de PEND-NNN em <data>` + origem `requisito-mal-capturado` (IMP-099) — mecanismo na `rdd-requirements`; a RN ancora a feature |
| **(b) Virar CR** | A resolução, ao ser trabalhada, revela-se **alteração em RN já confirmada** (IMP-094 R2) | Registrar via `rdd-change-request`. Com score >= 70 o CR nasce direto (R3); com score < 70 nasce PEND e o ciclo recomeça |
| **(c) Encerrar como decisão** | A discussão encerra o ponto sem gerar requisito | Mover para §10 (Decisões) com `[confirmado] (data)` — sem RN nem CR |

**Orientação padrão ao operador (R1):** "promova a PEND a RN primeiro (nova
RN sequencial em REQUIREMENTS.md citando a origem), depois gere com a RN
como âncora" — `rdd-task-spec` aborta âncora PEND.

## Detecção de Conflito

Antes de pontuar C5, faça:

1. Leia `REQUIREMENTS.md` existente (se houver) e extraia todas as RNs.
2. Leia checkpoints anteriores e extraia PENDs abertos.
3. Para cada item candidato novo, verifique se há contradição semântica
   com RNs ou PENDs existentes.
4. Se conflito detectado:
   - C5 falha (peso 0 para este item).
   - Gere pergunta de esclarecimento sobre o conflito.
   - Registre o conflito no checkpoint.
5. Se o conflito já estava registrado como PEND-XXX em aberto, não
   penalize de novo — o item já é conhecido.

## Estratégia de Perguntas

### Regras gerais (aplicam-se a todo `question`)

1. **Agrupe por afinidade** — pergunte no máximo 3 blocos de 2-3 perguntas
   cada. NUNCA uma pergunta por vez.

2. **NUNCA inclua "Digitar agora", "Outro" ou "Custom" como opção.**
   O `question` tool já adiciona "Type your own answer" automaticamente.

3. **Use exemplos reais nas opções** — em vez de opção genérica, mostre
   um exemplo do domínio do usuário. Ex:

   ```js
   // BOM: exemplo contextual
   { label: "CPF do produtor", description: "Validar CPF no cadastro de produtores rurais" }

   // RUIM: opção abstrata
   { label: "Sim", description: "Campo obrigatório" }
   ```

4. **Não pergunte todas as 11 categorias** — selecione apenas as
   categorias onde há ambiguidade real. Pule as que já estão claras
   na descrição do usuário.

5. **Contextualize** — mostre o trecho da descrição que gerou a dúvida.

6. **Não pergunte o óbvio** — pule categorias totalmente cobertas.
   Se o usuário já disse "precisa de login", não pergunte sobre autenticação.

### Blocos sugeridos (máx 3)

**Bloco 1 — Escopo e atores** (se ambíguo):
- Dentro/fora do escopo, papéis envolvidos

**Bloco 2 — Regras e dados** (se ambíguo):
- Regras de negócio não óbvias, campos obrigatórios

**Bloco 3 — Estratégia de exposição** (se ambíguo):
- A feature será exposta como tela-only, REST API, ou ambos?
- Se REST API: qual API de destino?
- Se tela-only: como os dados serão consumidos?
- A feature precisa ser consumida por sistemas externos ou apenas pelo frontend?
- Existe API existente que já cobre parte da funcionalidade?

**Bloco 4 — Fluxo e legado** (se ambíguo):
- Fluxo principal, integrações, migração

### O que fazer se não houver ambiguidade

Se a descrição do usuário já for completa e clara em todas as categorias
relevantes, pule o clarify inteiro (não force perguntas desnecessárias).
Registre no checkpoint que não houve perguntas e que o score de todos os
itens foi >= 70.

## Workflow

1. Leia `docs/CONSTITUTION.md` para as categorias de questionamento.
2. Leia `<module-root>/meetings/` (checkpoints anteriores para detectar
   PENDs existentes e reavaliação incremental).
3. Leia `<module-root>/REQUIREMENTS.md` (se existir, para detectar
   conflitos em C5).
4. Receba a descrição/transcrição da reunião do usuário.
5. Identifique os **itens candidatos** na transcrição — cada ponto de
   requisito que poderia virar uma RN.
6. Separe os itens em dois grupos:
   - **Reavaliação**: PENDs existentes que receberam novas respostas na
     reunião atual. Recalcule score apenas para estes (Passo 7).
   - **Novos**: itens que não existiam antes. Calcule score do zero
     (Passo 7).
7. Para cada item (reavaliação ou novo), aplique os 5 critérios:
   - C1: Regra de negócio explícita (peso 30)
   - C2: Termos vagos definidos (peso 25)
   - C3: Casos de borda (peso 20)
   - C4: Ator/origem claro (peso 15)
   - C5: Conflito com existente (peso 10)
   - Score = soma dos pesos onde o critério foi atendido.
8. Classifique cada item pelo score:
   - **Score >= 70**: marca como RN candidato.
   - **Score < 70**: gere um conjunto de perguntas de follow-up
     específicas para os critérios que falharam. Estas perguntas devem
     ser direcionadas (ex: "Se o campo vier vazio, qual comportamento
     esperado?") — nunca genéricas (ex: "explique melhor").
9. Faça perguntas usando `question` — no máximo 3 blocos. Priorize
   perguntas sobre itens com score < 70 e sobre conflitos detectados.
10. Registre as respostas e **recalcule** os scores dos itens afetados
    pelas respostas.
11. Gere o checkpoint:
    - Liste checkpoints existentes em `<module-root>/meetings/`.
    - Encontre o maior número sequencial (NN).
    - Escreva `<module-root>/meetings/YYYY-MM-DD-NN.md` com o template
      abaixo, incluindo scores, critérios, perguntas de follow-up para
      cada PEND, e indicando quais itens são RN candidatos.

## Categorias de Questionamento

Ver `docs/CONSTITUTION.md §14` para a lista completa de 11 categorias.

## Formato do Checkpoint

Arquivo: `<module-root>/meetings/YYYY-MM-DD-NN.md` (NN = próximo sequencial)

```markdown
---
project: <NOME>
module: meeting
audience: [tecnica, negocio]
status: draft
---

# Clarify — DD/MM/AAAA

**Resumo:** [breve descrição das ambiguidades identificadas]

## Itens de Requisito

### Item 1: [título descritivo do requisito]

**Score:** 85/100 ✅ | **Resultado:** RN candidato

| Critério | Peso | Status | Observação |
|----------|------|--------|------------|
| C1 — Regra de negócio explícita | 30 | ✅ | Condição e ação claramente definidas |
| C2 — Termos vagos definidos | 25 | ✅ | Sem termos subjetivos |
| C3 — Casos de borda | 20 | ✅ | Comportamento para vazio/nulo definido, ou inaplicável |
| C4 — Ator/origem claro | 15 | ✅ | Ator identificado no contexto |
| C5 — Conflito com existente | 10 | ✅ | Sem contradições |

---

### Item 2: [título descritivo do requisito]

**Score:** 45/100 ❌ | **Resultado:** PEND-XXX

| Critério | Peso | Status | Observação |
|----------|------|--------|------------|
| C1 — Regra de negócio explícita | 30 | ❌ | Descreve o que fazer mas não o comportamento em caso de erro |
| C2 — Termos vagos definidos | 25 | ✅ | Termos específicos |
| C3 — Casos de borda | 20 | ❌ | Não menciona o que acontece se o campo estiver vazio |
| C4 — Ator/origem claro | 15 | ❌ | Não fica claro quem realiza a ação |
| C5 — Conflito com existente | 10 | ✅ | Sem contradições |

**Perguntas de follow-up:**
1. Qual comportamento esperado se a validação falhar?
2. Quem dispara essa validação? O sistema ou o usuário?
3. O que acontece se o campo vier vazio?

---

### Item 3: [reavaliação de PEND-001]

**Score:** 80/100 ✅ (anterior: 40/100) | **Resultado:** PEND-001 → RN-NNN (promovido)

| Critério | Peso | Status | Observação |
|----------|------|--------|------------|
| ... | | | |

---

### Item 4: [reavaliação de PEND-002, 2ª tentativa]

**Score:** 50/100 ❌ (anterior: 35/100) | **Resultado:** PEND-002 (permanece)

**Ainda pendente após 2ª tentativa.** Critérios que ainda falham:
- C1: A resposta continua vaga sobre a condição de erro
- C3: Caso de borda de campo vazio ainda não foi abordado

**Perguntas de follow-up (nova tentativa):**
1. [pergunta reformulada de forma diferente da 1ª tentativa]
2. [pergunta adicional]

---

## Perguntas e Respostas

### [pergunta]

**Resposta:** [resposta]

### [pergunta]

**Resposta:** [resposta]
```

## Casos de Borda

### Item completo sem ambiguidade

Se um item atende todos os 5 critérios (score = 100), não force
perguntas desnecessárias. Um enum fechado sem casos de borda não é
penalizado — C3 conta como atendido quando inaplicável.

### Reunião de atualização com contradição

Se o cliente contradiz uma RN existente em `REQUIREMENTS.md`:
- C5 falha para este item (score reduzido em 10).
- Gere uma pergunta de esclarecimento: "A nova descrição contradiz
  RN-NNN vigente. A RN deve ser atualizada ou é um caso diferente?"
- Registre o conflito no checkpoint.
- **Não sobrescreva** a RN antiga silenciosamente.

### PEND sem resolução após múltiplas tentativas

Se um PEND-XXX permanece pendente após nova rodada de perguntas:
- Incremente o contador de tentativas no checkpoint.
- Reformule as perguntas de follow-up (abordagem diferente).
- Nunca entre em loop infinito — após 3 tentativas sem avanço,
  registre como `[bloqueado]` e permita seguir para
  `rdd-requirements` mesmo assim, com nota explícita no checkpoint.

### Mesmo item mencionado por várias fontes

Se a mesma ambiguidade aparece em itens diferentes, não duplique
perguntas. Agrupe em uma pergunta única e referencie os itens afetados.

### Reavaliação sem novas respostas

Se uma reunião não trouxe respostas para um PEND-XXX existente, o
PEND permanece com o score anterior. Não é reavaliado.

## Compatibilidade com rdd-requirements

O checkpoint gerado por esta skill é consumido por `rdd-requirements`.
A seção "Itens de Requisito" fornece dados estruturados que a skill
de requisitos pode usar para:

- Itens com score >= 70 → gerar como RNs em REQUIREMENTS.md §5.
- Itens com score < 70 → gerar como PENDs em REQUIREMENTS.md §11,
  incluindo perguntas de follow-up.
- Itens com `[PEND-XXX → RN-NNN]` → resolver o PEND e criar a RN.
- Itens com `[bloqueado]` → criar PEND com nota de bloqueio.

## Triagem de PENDs Existentes

Quando o usuário já possui PENDs documentados em `REQUIREMENTS.md` e deseja
classificá-los (e não está trazendo novos requisitos), execute este fluxo
alternativo em vez do Workflow principal.

### Gatilho

- Usuário diz "triar PENDs", "classificar PENDs", "o que fazer com os PENDs"
- `rdd-next` recomenda triagem de PENDs
- Usuário tem PENDs abertos e pergunta "qual o próximo passo"

### Workflow de Triagem

1. Leia `<module-root>/REQUIREMENTS.md` e extraia todos os PENDs abertos
   (seção §11 — Pendências).
2. Leia checkpoints anteriores em `<module-root>/meetings/` para histórico
   de tentativas anteriores de triagem.
3. **Apresente cada PEND individualmente** ao usuário com:
   - O ID do PEND (ex: PEND-001)
   - A descrição/resumo do PEND
   - Opções explícitas de classificação:
     a. **🔧 Dev direto** — ação técnica clara, não precisa de decisão de negócio
     b. **❓ Aguarda decisão** — precisa de decisão de PO/cliente/arquitetura
     c. **✅ Já resolvido** — já foi resolvido ou decidido em reunião anterior
     d. **📋 Outro (explicar)** — o usuário digita a classificação manualmente
4. **NUNCA infira classificação por omissão.** Se o usuário não selecionar
   um PEND em uma pergunta multi-select, pergunte explicitamente sobre ele
   em vez de assumir "dev direto".
5. **Confirmação explícita:** Após classificar todos os PENDs, apresente
   um resumo da classificação completa e peça confirmação do usuário antes
   de finalizar.
6. Registre a classificação no checkpoint com:
   - Timestamp da classificação
   - Responsável pela decisão (nome do usuário/PO)
   - Para PENDs "Aguarda decisão": a pergunta específica que precisa ser respondida
   - Para PENDs "Dev direto": a ação técnica resumida
   - Para PENDs "Já resolvido": o desfecho e data
7. Gere o checkpoint seguindo o template da seção "Formato do Checkpoint",
   incluindo a seção "Triagem de PENDs" com a classificação completa.

### Regras de Triagem

1. **Ambiguidade Zero:** Toda classificação deve ser explícita. Nenhum PEND
   pode ser classificado sem que o usuário tenha visto e escolhido seu destino.
2. **Individualidade:** Cada PEND é apresentado individualmente ou em lotes
   de no máximo 3, com opções individuais. Nunca agrupe PENDs em uma única
   pergunta onde a não-seleção implica classificação.
3. **Rastreabilidade:** A classificação de cada PEND é registrada com
   timestamp e responsável, permitindo auditoria posterior.
4. **Re-triagem:** Se o usuário já triou PENDs anteriormente, apresente
   apenas os PENDs ainda não classificados ou cuja classificação mudou.
5. **PEND não ancora feature (IMP-094 R1):** nenhuma classificação gera
   feature com âncora PEND. "Dev direto" que resultar em feature exige
   promoção prévia da PEND a RN (nova RN sequencial em REQUIREMENTS.md
   citando a origem) — ver "Destinos de PEND Aberta (IMP-094)".

### Template — Seção de Triagem no Checkpoint

Adicione ao checkpoint, após a seção "## Perguntas e Respostas":

```markdown
## Triagem de PENDs

### PEND-001 — [título descritivo]

**Classificação:** 🔧 Dev direto
**Responsável:** [nome] — DD/MM/AAAA HH:mm
**Ação:** [descrição resumida da ação técnica]

---

### PEND-003 — [título descritivo]

**Classificação:** ❓ Aguarda decisão
**Responsável:** [nome] — DD/MM/AAAA HH:mm
**Pergunta:** [pergunta específica que precisa ser respondida pelo PO/cliente]

---

### PEND-011 — [título descritivo]

**Classificação:** ✅ Já resolvido
**Responsável:** [nome] — DD/MM/AAAA HH:mm
**Desfecho:** [descrição do desfecho e data]
```

### Origem da PEND (IMP-099)

PENDs nascidos de ambiguidade carregam proveniência de origem
`requisito-mal-capturado`. Quando a PEND sai de aberta, a origem acompanha
a resolução:

- **Promoção PEND→RN (destino a):** a nota de proveniência da RN nova
  inclui a origem — `> Promovida de PEND-NNN em <data> — origem:
  requisito-mal-capturado` — mecanismo na `rdd-requirements`.
- **PEND→CR (destino b, IMP-094 R2):** o CR registrado via
  `rdd-change-request` recebe o campo `**Origem:** requisito-mal-capturado`.

Invariante (IMP-099): CR sem campo origem = registro incompleto — a
agregação de métricas de resultado trata como N/A, nunca inventa.
