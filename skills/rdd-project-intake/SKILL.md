---
name: rdd-project-intake
description: >-
  Cria PROJECT_CHARTER.md a partir da primeira conversa com cliente.
  Suporta dois modos: completo (projetos novos) e simplificado (projetos
  existentes com código pronto/em desenvolvimento). Inclui campos legado e
  sistema_existente para decidir se LEGACY_CONTEXT.md será gerado.
  Use quando o usuário pedir "novo projeto", "criar charter",
  "termo de abertura", "iniciar módulo no RDD" ou "aplicar RDD em projeto existente".
---
# rdd-project-intake — Project Charter

Gera `<modulo>/<projeto>/PROJECT_CHARTER.md` a partir da primeira conversa
com o cliente.

## Referências

- Convenções de IDs, front matter, EARS, MADR: `docs/CONSTITUTION.md`
- Estrutura de pastas: `docs/CONSTITUTION.md §15`

## Lê (upstream)

- Nenhum (primeiro documento do projeto)
- `<repo_docs_rdd>/_docs/patterns/INDEX.md` — bloco `rdd-docs-repo` do AGENTS.md (condicional — IMP-047): ao levantar o escopo, consultar padrões aplicáveis — especialmente Tipo `processo` (ex: existe produto-irmão de domínio cujas features podem ser adaptadas?)

## Gera (downstream)

- `<modulo>/<projeto>/PROJECT_CHARTER.md`

## Nunca edita

- Nenhum (não há documentos anteriores)

## Tools

- `question` (para coletar informações do cliente)
- `write` (para criar o arquivo)
- `read` (para ler CONSTITUTION.md)

## Modo de erro

`strict` — se o charter não for gerado, o projeto não pode começar.

## Formato de commit

```
docs: add project charter for <nome>
```

## Estratégia de Perguntas

### Regras gerais

1. **Agrupe perguntas relacionadas** — nunca pergunte um campo por vez.
   Máximo de 3 blocos de perguntas para todo o intake.

2. **NUNCA inclua "Digitar agora", "Outro" ou "Custom" como opção.**
   O `question` tool já adiciona "Type your own answer" automaticamente
   quando o usuário quiser digitar livremente.

3. **Para campos de texto livre** (nome do projeto, cliente, patrocinador,
   contexto, objetivo): forneça 2-3 exemplos ilustrativos como opções
   para guiar o usuário, não para limitar. Ex:

   ```js
   // BOM: exemplos reais que orientam o formato
   question({
     header: "Nome do projeto",
     options: [
       { label: "SISAGRO", description: "Sistema de Inspeção Agropecuária" },
       { label: "SICAF", description: "Sistema de Cadastro de Fornecedores" },
     ]
   })
   // Se o usuário quiser outro nome, usa "Type your own answer"

   // RUIM: "Digitar agora" como opção
   // RUIM: pergunta única "Qual o nome?" sem contexto
   ```

4. **Para perguntas categóricas** (tipo de projeto, sim/não): forneça
   opções reais e mutuamente exclusivas. Ex:

   ```js
   question({
     header: "Tipo de projeto",
     options: [
       { label: "Greenfield", description: "Sistema novo, sem legado" },
       { label: "Migração", description: "Substituição de sistema existente" },
     ]
   })
   ```

5. **Use descrições contextuais** nas opções — em vez de "Sim"/"Não",
   explique o que cada escolha significa.

### Modo simplificado para projetos existentes

Quando o usuário já tem um projeto com código implementado ou em
desenvolvimento, use este fluxo alternativo que pula os blocos 2 e 3
(contexto/escopo e stakeholders) — eles serão preenchidos naturalmente
durante a geração de REQUIREMENTS.md.

#### Detecção

Se o usuário pedir "iniciar documentação de projeto existente", "aplicar
RDD em projeto que já existe", "tenho código pronto", "meu projeto já
está em desenvolvimento", ou similar, ative o modo simplificado.

#### Fluxo simplificado (2 blocos no máximo)

**Bloco 1 — Identificação rápida** (1 pergunta):
- Nome do projeto (com exemplos)
- Repositório existente (URL ou nome)
- Já existe REQUIREMENTS.md ou outros docs RDD? (Sim / Não)

**Bloco 2 — Contexto mínimo** (1 pergunta):
- O que já foi implementado (resumo rápido, 1-2 linhas)
- O que falta documentar
- Se há sistema legado a documentar (produção / legado / novo)
- Se o produto trata dado pessoal (Sim / Não — se sim, `compliance: true` no charter — IMP-102)

#### Resultado

- Crie o diretório `<modulo>/<projeto>/`
- Gere PROJECT_CHARTER.md com `sistema_existente: true`
- Se há sistema legado, recomende `rdd-legacy-context` como próximo passo
- Se não há, vá direto para `rdd-requirements`

#### Exemplo de Bloco 1 (modo simplificado)

```js
question({
  header: "Projeto existente",
  question: "Qual o nome do produto e quais repositórios ele possui?",
  options: [
    { label: "Salon", description: "Sistema de agendamento — repos: Salon-API, Salon-FE" },
    { label: "ZUMM", description: "Plataforma de mobilidade — repos: ZUMM.Motorista-FE, ZUMM.Passageiro-FE, ZUMM.DesignSystem-FE" },
  ]
})
```

#### Exemplo de Bloco 2 (modo simplificado)

```js
question({
  header: "Contexto do projeto",
  question: "O que já existe nesse projeto e o que falta documentar?",
  options: [
    { label: "API pronta", description: "Backend implementado, falta documentar requisitos e contratos" },
    { label: "Sistema em produção", description: "Sistema vivo, preciso documentar o que existe para evolutiva" },
    { label: "Começando agora", description: "Tenho repo vazio, quero definir requisitos antes de codar" },
  ]
})
```

### Blocos de perguntas (3 no máximo — fluxo completo)

**Bloco 1 — Identificação e tipo** (1 pergunta):
- Nome do projeto (com exemplos)
- Cliente / contratante (texto livre)
- Tipo de projeto (greenfield / migração / integração / documentação de sistema existente)
- **Número da demanda no REDMINE** (ex: `#123123`) — obrigatório se houver demanda registrada pelo cliente
- **Já existe repositório do projeto?** — se sim, registrar nome e URL
- **O módulo documenta algo que já existe?** — sistema vivo/em produção, código já implementado (Sim / Não — greenfield puro)
- **O produto trata dado pessoal?** — coleta dados de usuários/cidadãos (cadastro, contato, localização, pagamento, saúde...)? (Sim / Não). **Se sim, marque `compliance: true` no charter** — gatilho do domínio Compliance (IMP-102): checklist LGPD via `rdd-compliance-check`, eixo no `rdd-dev-reviewer` e finding no `rdd-validate`

**Bloco 2 — Contexto e escopo** (1 pergunta):
- Descrição do problema (texto livre com exemplos)
- Principais funcionalidades (lista curta)
- O que está fora do escopo

**Bloco 3 — Stakeholders e riscos** (1 pergunta):
- Patrocinador (sponsor), PO, lead técnico
- Premissas importantes
- Riscos percebidos

### Origem do projeto (repositório / sistema existente)

Se o usuário informar repositório existente ou que o módulo documenta algo
já implementado (sistema vivo/em produção):

1. **Registre TODOS os repositórios na §1 do charter** — `| Repositórios | \`repo1\`, \`repo2\` |`
2. **Marque na §5** a opção **Documentação de sistema existente** (não
   greenfield puro)
3. **Recomende `rdd-legacy-context`** — o gatilho agora é `legado: true`
   **ou** `sistema_existente: true`. Distinção:
   - `legado` = sistema que será **substituído/migrado**
   - `sistema_existente` = documentar sistema **vivo/em produção como está**
4. **Nunca crie pastas por camada** — se o usuário pedir "criar Salon-API",
   pergunte se há frontend e crie `Salon/` unificado

### Exemplo completo de Bloco 1

```js
question({
  header: "Identificação",
  question: "Qual o nome do produto e o cliente?",
  options: [
    { label: "Salon", description: "Sistema de agendamento — repos: Salon-API, Salon-FE" },
    { label: "ZUMM", description: "Plataforma de mobilidade — repos: ZUMM.Motorista-FE, ZUMM.Passageiro-FE" },
    { label: "AcmeHub", description: "Plataforma central — repos: AcmeHub-API, AcmeHub-FE" },
  ]
})
```

Após obter as respostas dos 3 blocos, escreva o charter.
Não invente dados não fornecidos pelo usuário.

## Regra de Escopo — Unidade é o Produto

> **⚠️ REGRA FUNDAMENTAL:** Crie UM charter por **produto**, não por **camada técnica**.
> Um produto pode ter N repos (API, FE, CORE, BATCHS, etc.), mas as regras
> de negócio são do produto inteiro. Nunca criar `Salon-API/` e `Salon-FE/`
> como projetos separados — o correto é `Salon/` com todos os repos listados.

### Como aplicar

1. Se o usuário pedir "criar doc da API X" ou "criar doc do frontend Y", pergunte se faz parte de um produto maior
2. Se sim, crie o charter do **produto** (ex: `Salon/`) listando todos os repos
3. Se não (projeto isolado, sem par), crie como produto único (ex: `FasTo-API/`)
4. O campo `Repositórios` do charter deve listar todos os repos do produto

### Exemplo

```
Usuário: "criar doc do Salon API"
Skill: "O Salon API faz parte de um produto maior? Há frontend ou outros componentes?"
Usuário: "Sim, tem o Salon-FE também"
Skill: cria Salon/PROJECT_CHARTER.md com | Repositórios | Salon-API, Salon-FE |
```

## Workflow

1. **Detecte o modo:** Se o projeto já existe (usuário menciona código pronto, repo existente, "aplicar RDD"), use o **modo simplificado** (2 blocos). Caso contrário, use o **fluxo completo** (3 blocos).
2. **Verifique se é produto composto:** Se o usuário mencionar API + FE (ou outras camadas) para o mesmo produto, crie UM charter unificado. Pergunte se há mais componentes antes de criar.
3. Pergunte usando os blocos correspondentes ao modo detectado
4. Crie a pasta `<modulo>/<projeto>/` (nome do PRODUTO, não da camada)
5. Escreva `PROJECT_CHARTER.md` com todos os repos listados
6. Liste os arquivos em `<modulo>/<projeto>/meetings/`, encontre o maior número sequencial no padrão `YYYY-MM-DD-NN.md` e escreva `<modulo>/<projeto>/meetings/YYYY-MM-DD-NN.md` (NN = próximo sequencial) com o resumo das informações coletadas + perguntas e respostas
7. **Encadeie automaticamente:** Após criar o charter e o meeting, invoque a skill `rdd-init` via `skill` tool para criar `CONSTITUTION.md` e `INDEX.md`. Não aguarde solicitação do usuário — o init é parte integrante do fluxo de intake.

## Template — PROJECT_CHARTER.md

```yaml
---
project: <NOME_EM_MAIUSCULAS>
module: charter
audience: [negocio, tecnica]
status: draft
---
```

> **Regra de idioma:** Todos os documentos são em português brasileiro (PT-BR). Títulos, descrições, perguntas e conteúdo do charter em PT-BR. Apenas identificadores técnicos (SOE, API, SDA, SOAP) permanecem no original.

```markdown
# Termo de Abertura — [Nome do Sistema]

## 1. Identificação

| Campo | Valor |
|---|---|
| Nome do projeto | |
| Cliente / contratante | |
| REDMINE | # |
| Repositórios | \`repo1\`, \`repo2\` — listar todos os repos do produto |
| Data de início | DD/MM/AAAA |

## 2. Contexto

[Descrição do problema ou oportunidade, em linguagem de negócio]

## 3. Objetivo

[O que o projeto entrega, critério de sucesso, métricas]

## 4. Escopo

Dentro do escopo:

- [item]

Fora do escopo:

- [item]

## 5. Tipo de projeto

- [ ] Novo sistema (greenfield)
- [ ] Evolutiva / migração de sistema existente
- [ ] Integração com terceiros
- [ ] Documentação de sistema existente (sistema vivo/em produção, sem migração)

**Legado:** ✅ Sim — sistema existente será analisado (gera LEGACY_CONTEXT.md)
**Legado:** ❌ Não — projeto novo, sem sistema anterior
**Sistema existente:** ✅ Sim — documentação de sistema vivo/em produção (gera LEGACY_CONTEXT.md)
**Sistema existente:** ❌ Não — greenfield puro

**Compliance:** ✅ Sim — `compliance: true` (produto trata dado pessoal — checklist LGPD obrigatório: `specs/COMPLIANCE.md`; finding no `rdd-validate` se ausente)
**Compliance:** ❌ Não — produto não trata dado pessoal

## 6. Stakeholders

| Papel | Nome | Contato |
|---|---|---|
| PO / Negócio | | |
| Lead técnico | | |

## 7. Premissas

- [premissa]

## 8. Riscos iniciais

- [risco, probabilidade, impacto, mitigação]
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

# Intake — DD/MM/AAAA

**Resumo:** [descrição concisa do projeto e objetivos]

## Perguntas e Respostas

### [pergunta]

**Resposta:** [resposta]
```

## Regra de Localização de Artefatos RDD

**⚠️ REGRA ABSOLUTA: Artefatos RDD NUNCA devem ser criados em pastas de código fonte.**

### Contexto

Em workspaces com múltiplos repositórios de empresa (ex: `<diretorio_projetos>/` com `<Produto>-API/`, `<Produto>-FE/`, etc.), o OpenCode pode estar posicionado em qualquer repo. A skill DEVE detectar isso e redirecionar os artefatos para a pasta correta de documentação (`repo_docs_rdd` do perfil/bloco `<!-- rdd-docs-repo -->` no AGENTS.md).

### Detecção de Contexto

Ao iniciar o intake, verifique se o workspace atual é:
- Um repositório de código fonte (contém `src/`, `pom.xml`, `package.json`, `.csproj`, etc.)
- Uma pasta de empresa com múltiplos repos (contém subpastas com nomes de projetos/repos)
- Uma pasta dedicada de documentação (ex: `<repo_docs_rdd>/` — bloco `<!-- rdd-docs-repo -->` do AGENTS.md)

### Pergunta de Localização (quando aplicável)

Se o workspace NÃO for uma pasta de documentação dedicada, pergunte:

```js
question({
  header: "Localização da documentação",
  question: "Onde devo salvar os artefatos RDD deste projeto?",
  options: [
    { label: "<repo_docs_rdd>/<projeto>/", description: "Pasta dedicada de docs (recomendado)" },
    { label: "docs/projects/<projeto>/", description: "Pasta docs dentro do repo atual" },
  ]
})
```

### Regras de Salvamento

| Cenário | Localização correta |
|---------|---------------------|
| Workspace é pasta de empresa (ex: `<diretorio_projetos>/`) | `<repo_docs_rdd>/<produto>/` |
| Workspace é repo de código (ex: `Salon-API/`) | `<repo_docs_rdd>/<produto>/` (unificar com outros repos do mesmo produto) |
| Workspace já é pasta de docs (ex: `<repo_docs_rdd>/`) | `<produto>/` (direto) |

> **Lembrete:** A unidade é o **produto**, não a camada. Se o workspace é `Salon-API/` mas existe `Salon-FE`, crie `Salon/` na pasta de docs.

### Nunca faça

- ❌ Criar `PROJECT_CHARTER.md` na raiz de um repo de código
- ❌ Criar `meetings/` na raiz de um repo de código
- ❌ Misturar artefatos RDD com código fonte
- ❌ Assumir que o workspace atual é o local correto para docs
- ❌ Criar pastas separadas por camada (ex: `Salon-API/` e `Salon-FE/` como projetos distintos)

### Exemplo de fluxo correto

```
Usuário está em: C:\Users\...\<workspace>\<Produto>-API\
Usuário pede: "iniciar doc do Salon"

Skill detecta: workspace é repo de código (tem pom.xml)
Skill pergunta: "O Salon API faz parte de um produto maior? Há frontend?"
Usuário responde: "Sim, tem o Salon-FE"
Skill pergunta: "Onde salvar?"
Usuário escolhe: "<repo_docs_rdd>/Salon/"

Skill cria: C:\Users\...\<workspace>\<repo_docs_rdd>\<Produto>\PROJECT_CHARTER.md
Skill cria: C:\Users\...\<workspace>\<repo_docs_rdd>\<Produto>\meetings\2026-09-16-01.md
```

## Casos de Borda

- **PROJECT_CHARTER.md já existe no módulo** — não recrie; informe e sugira atualizar via `rdd-requirements` (novos requisitos) ou `rdd-change-request` (mudança em requisito confirmado).
- **Usuário não sabe responder um campo** — não invente; registre como pendência no charter e siga (o campo pode ser preenchido depois).
- **Nome de módulo/pasta duplicado** — pergunte uma variação de nome antes de criar `<modulo>/<projeto>/`.
- **Módulo documenta sistema existente** — marque `sistema_existente: true` e recomende `rdd-legacy-context` como próximo passo.
- **Cliente sem demanda REDMINE** — registre `—` (não informado) em vez de deixar `#` vazio.
- **Operador em dúvida sobre dado pessoal** — não marque `compliance: true` por omissão; registre como pendência no charter e recomende `rdd-compliance-orchestrator` para decidir com o checklist.
- **Projeto existente sem REQUIREMENTS.md** — ative modo simplificado; vá direto para `rdd-requirements` após o charter.
- **Projeto existente com REQUIREMENTS.md parcial** — ative modo simplificado; recomende `rdd-requirements` para merge incremental.
- **Workspace é repo de código fonte** — NUNCA crie artefatos RDD na raiz. Pergunte localização ou sugira `<repo_docs_rdd>/<produto>/`.
- **Usuário pede para criar por camada (API/FE)** — pergunte se faz parte de um produto maior. Se sim, crie o produto unificado. Se não (projeto isolado), crie como produto único.
