---
name: rdd-gh-issue-creator
description: >-
  Cria issues no GitHub a partir das tasks geradas pelo rdd-task-spec (IMP-092).
  A ESTRUTURA (issue principal, IDs de tasks RN-NNN-M, labels por prefixo,
  milestone, repos) vem do arquivo delivery/<grupo>/RN-NNN — <título> — Feature.md (IMP-093),
  resolvido por glob recursivo delivery/**/ (agnóstico ao delivery_style da
  CONSTITUTION.md §9); o CORPO da issue vem do RN-NNN — Analise-Funcional.md na
  pasta de análise analysis/RN-NNN — <título>/ (linguagem de negócio).
  Fallbacks preservados (`— Tasks.md` pré-rename IMP-092; legados: pasta IMP-040 com 2 arquivos, flat
  pré-IMP-040, IMP-034, TASKS.md). Deriva labels (Database, DevOps, Frontend,
  Backend), vincula milestone e preenche o body com descrição funcional,
  regras de negócio 1..N, RNs e links para as análises e specs. Usa gh CLI
  para criar as issues em lote com confirmação prévia (dry-run). Use quando o
  usuário pedir "criar issues das tasks", "publicar tasks no GitHub",
  "criar issues a partir do Feature.md", "subir tasks para o repo".
---
# rdd-gh-issue-creator — Criação de Issues no GitHub a partir do arquivo de feature

Cria issues no GitHub correspondentes às features especificadas pelo
`rdd-task-spec` (IMP-092): análise em `analysis/RN-NNN — <título>/` (camada
ANÁLISE, 2 arquivos) e tasks no ARQUIVO
`delivery/<grupo>/RN-NNN — <título> — Feature.md` (IMP-093 — direto na pasta do grupo,
sem subpasta por feature — IMP-035/037/039/092). Divisão fixa de fonte: a
**ESTRUTURA** das issues (issue principal, IDs de tasks `RN-NNN-M`, labels,
milestone, repos) vem do arquivo `— Feature.md` (fallback: `— Tasks.md` pré-rename); o **CORPO/descrição** vem do
`RN-NNN — Analise-Funcional.md` da pasta de análise (linguagem de negócio).
Regra de ouro: dependência unidirecional tasks→análise. Cada task vira uma
issue com labels, milestone, e body contendo descrição funcional, RNs e
referências às análises e artefatos RDD.

## Pré-condições

- `gh` CLI instalada e autenticada (`gh auth status`)
- Arquivo `— Feature.md` revisado (IMP-093; fallbacks: `— Tasks.md` pré-rename e legados da seção abaixo) e
  pasta de análise correlata com o `RN-NNN — Analise-Funcional.md`
- Milestone definido (ou criação sem milestone)

## Localização do arquivo de feature (IMP-092/IMP-093/IMP-035/IMP-039)

As tasks vivem no ARQUIVO `delivery/<grupo>/RN-NNN — <título> — Feature.md`
(IMP-092/IMP-093) — direto na pasta do grupo, SEM subpasta por feature. O grupo
(`<grupo>`) depende do `delivery_style` persistido na CONSTITUTION.md §9
(`YYYY-MM` mensal, `YYYY-MM-DD`, nome livre, `backlog`, `now|next|later`,
épico, template custom) — a LEITURA é agnóstica ao estilo: resolva SEMPRE por
glob recursivo `delivery/**/`, em qualquer profundidade/grupo — NUNCA construa
o nome exato. Ao encontrar o arquivo, leia-o (ESTRUTURA) e resolva a pasta de
análise correlata (CORPO) pela linha de proveniência
`> Análise: ../../analysis/RN-NNN — <título>/` e/ou por glob de prefixo
`analysis/RN-NNN*` — NUNCA construa o nome exato da pasta; leia de dentro dela
o `RN-NNN — Analise-Funcional.md` (corpo das issues):

1. glob `<modulo>/<projeto>/delivery/**/RN-NNN — * — Feature.md` (fallback: repetir com `— Tasks.md` pré-rename — IMP-092) —
   quando a RN é conhecida (deve retornar exatamente 1 arquivo; mais de
   1 → ambiguidade: pergunte ao usuário; 0 → próximo passo)
2. Se não: glob recursivo `delivery/**/* — Feature.md` (depois `* — Tasks.md` pré-rename) — sem RN
   específica, liste todos (ou o mais recente, conforme o pedido)
3. Fallback legado IMP-040: PASTA da feature com 2 arquivos — glob de prefixo
   `delivery/[0-9][0-9][0-9][0-9]-[0-9][0-9]/RN-NNN*` (sprint corrente →
   mais recente); leia AMBOS os arquivos de dentro dela — o
   `RN-NNN — Analise-Funcional.md` (corpo das issues) e o
   `RN-NNN — Analise-Tecnica.md` (estrutura das issues)
4. Fallback legado pré-IMP-040: arquivo flat `delivery/<YYYY-MM>/RN-NNN — <título>.md` na sprint (ler o arquivo direto)
5. Fallback legado IMP-034 (pré-IMP-035): `delivery/RN-*.md` na raiz de
   `delivery/`
6. Fallback legado IMP-032: sprint **mais recente** em `delivery/` (glob
   `delivery/[0-9][0-9][0-9][0-9]-[0-9][0-9]/TASKS.md`)
7. Fallback legado: `<modulo>/<projeto>/delivery/TASKS.md`
8. Fallback pré-IMP-011: `<modulo>/<projeto>/TASKS.md`

Se nenhuma existir, aborta com mensagem clara.

## Lê (upstream)

- `<modulo>/<projeto>/delivery/<grupo>/RN-NNN — <título> — Feature.md` — ESTRUTURA das issues: issue principal, IDs de tasks `RN-NNN-M`, labels por prefixo, milestone, repos (resolvido por glob recursivo — IMP-092/IMP-093; fallbacks: `— Tasks.md` pré-rename e legados preservados)
- `<modulo>/<projeto>/analysis/RN-NNN — <título>/RN-NNN — Analise-Funcional.md` — CONTEÚDO do body das issues: "O que esta entrega faz", "Comportamento esperado", "Regras de negócio" (1..N) e "O que fica de fora" (pasta resolvida por glob de prefixo `analysis/RN-NNN*` — IMP-037/IMP-092; nos fallbacks legados, `RN-NNN — Analise-Funcional.md` dentro da pasta IMP-040 da feature)
- `<modulo>/<projeto>/REQUIREMENTS.md` — RNs referenciadas nas tasks
- `<modulo>/<projeto>/specs/*.md` — specs associadas (API_CONTRACTS, UI_SPEC, DATA_MODEL)

## Gera (downstream)

- Issues no GitHub via `gh issue create`
- (Opcional) `<modulo>/<projeto>/delivery/ISSUES_CREATED.md` — resumo das issues criadas, na pasta do grupo `delivery/<grupo>/` do arquivo de feature lido (se lido de local legado, na mesma pasta do arquivo lido)

## Nunca edita

- Arquivo de feature (`— Feature.md`; fallback `— Tasks.md` pré-rename / TASKS.md — fonte primária)
- Análises (`analysis/` e pastas IMP-040)
- Artefatos de specs do módulo
- Issues já existentes (nunca duplica — checka antes)

## Tools

- `bash` (gh CLI — `gh issue create`, `gh issue list`, `gh api`)
- `read` (ler `— Feature.md`, análises, specs)
- `write` (gerar ISSUES_CREATED.md)
- `question` (confirmar dry-run antes de criar)

## Modo de erro

`interativo` — se `gh` não estiver disponível, orienta a instalação e aborta.
Se o arquivo de feature não existir em nenhuma das localizações da seção "Localização do
arquivo de feature (IMP-092/IMP-093/IMP-035/IMP-039)", aborta com mensagem clara.
Se o `— Feature.md` linkar a análise (linha `> Análise:`) mas o
`RN-NNN — Analise-Funcional.md` não existir na pasta de análise (migração
parcial), avise e use a PRÓPRIA Feature.md como fallback do corpo, sinalizando
para regenerar via `rdd-task-spec` ou migrar via `rdd-restructure`.
No fallback legado IMP-040 (pasta com 2 arquivos), se o
`RN-NNN — Analise-Funcional.md` não existir na pasta da feature (feature
pré-IMP-040 não migrada), avise e use o `RN-NNN — Analise-Tecnica.md` como
fallback do corpo com a mesma sinalização.
Se `gh auth status` falhar, orienta `gh auth login`.

## Casos de Borda

- **Issue duplicada já existente:** antes de criar, busque issue equivalente no repo (`gh issue list --search "<título/task RN-NNN-M>"`). Encontrou → pule, reporte o link e NÃO duplique.
- **Milestone inexistente no repo:** não falhe em silêncio — anuncie a criação do milestone no dry-run (Passo 4) e só crie após a confirmação do usuário.
- **Label fora da convenção de prefixo:** task sem prefixo reconhecível (`[Database]`, `[DevOps]`, ...) → use `task` e sinalize a deriva no dry-run; nunca invente label nova sem confirmação.
- **RN referenciada na task inexistente em REQUIREMENTS.md:** avise na lista do dry-run e pergunte antes de criar — pode ser typo no Feature.md.
- **Glob de feature retorna 0 ou mais de 1 arquivo:** 0 → aborta com mensagem clara (seção de localização); >1 → ambiguidade — pergunte ao usuário, nunca escolha por inferência.
- **`gh` não instalado ou sem auth (`gh auth status` falha):** aborte e encaminhe ao `rdd-gh-setup` antes de reintentar.

## Formato de commit

```
feat(tasks): create GitHub issues for <modulo>
```

## Workflow

### Passo 1 — Validar ambiente

```bash
gh auth status 2>&1
```

Se falhar → orientar `gh auth login` e abortar.

### Passo 2 — Ler o arquivo de feature

Localize o arquivo `— Feature.md` (fallback: `— Tasks.md` pré-rename) conforme a seção "Localização do arquivo de
feature (IMP-092/IMP-093/IMP-035/IMP-039)". Do `RN-NNN — <título> — Feature.md`
(ESTRUTURA), identifique:

- Issue principal (título, milestone, repo)
- Tasks filhas (`### RN-NNN-M`): título, RNs, prefixo (`[Database]`, `[DevOps]`, `[<repo>]`)

Depois resolva a pasta de análise correlata (linha `> Análise:` da
proveniência e/ou glob de prefixo `analysis/RN-NNN*`) e leia o
`RN-NNN — Analise-Funcional.md` (CONTEÚDO do body), extraindo: "O que esta
entrega faz", "Comportamento esperado", "Regras de negócio" (numeração 1..N)
e "O que fica de fora". Nunca use trechos técnicos (endpoints, tabelas,
frameworks) no corpo — eles permanecem apenas na referência.

### Passo 3 — Derivar labels

| Prefixo no título | Label |
|-------------------|-------|
| `[Database]` | `database` |
| `[DevOps]` | `devops` |
| `[Backend]` ou `<repo>.API` | `backend` |
| `[Frontend]` ou `<repo>.MFE/FE` | `frontend` |
| `[<repo>.CORE]` | `core` |
| Sem prefixo claro | `task` |

### Passo 4 — Dry-run (confirmação)

Exiba a lista completa de issues que serão criadas no formato:

```
⚠️ Dry-run — NADA foi criado ainda.

Issues a criar em <org/repo>:
1. [<label>] <título>
   RNs: RN-001, RN-002
   Body: <descrição>
   Milestone: <milestone>

Total: <N> issues

Criar? (sim/não)
```

Use `question` para confirmar. Se o usuário disser não, aborta.

### Passo 5 — Criar issues

Para cada task no Feature.md:

```bash
gh issue create \
  --repo "<org>/<repo>" \
  --title "[<prefixo>] <descrição>" \
  --label "<label>" \
  --milestone "<milestone>" \
  --body "<body>"
```

**Body da issue** — as seções funcionais vêm do `RN-NNN — Analise-Funcional.md`
(da pasta de análise `analysis/RN-NNN — <título>/`; nos legados, da pasta
IMP-040 da feature); `## RNs` vem do campo **RNs** das tasks do `— Feature.md`
(nos legados, do `Analise-Tecnica.md`):

```markdown
## Descrição
<parágrafo "O que esta entrega faz" do Analise-Funcional.md>

## Comportamento esperado
<bullets da seção "Comportamento esperado" do Analise-Funcional.md>

## Regras de negócio
<tabela numerada 1..N da seção "Regras de negócio" do Analise-Funcional.md>

## O que fica de fora
<bullets da seção "O que fica de fora" do Analise-Funcional.md>

## RNs
- RN-XXX
- RN-YYY

## Referências
- [RN-NNN — Analise-Funcional.md](<link> — analysis/RN-NNN — <título>/)
- [RN-NNN — <título> — Feature.md](<link> — delivery/<grupo>/)
- [API_CONTRACTS.md](<link>)
- [UI_SPEC.md](<link>)
- [DATA_MODEL.md](<link>)

## Especificação completa
Ver `RN-NNN — Analise-Tecnica.md` na pasta de análise e artefatos em `<modulo>/<projeto>/`
```

Se o milestone não existir, criar primeiro:

```bash
gh api repos/<org>/<repo>/milestones -f title="<milestone>"
```

### Passo 6 — Registrar ISSUES_CREATED.md

Após criar todas as issues, gere `delivery/<grupo>/ISSUES_CREATED.md`
(pasta do grupo do arquivo de feature lido; se lido de local legado, na
mesma pasta do arquivo lido):

```markdown
# Issues Criadas — <módulo>

> Criadas em <data> via rdd-gh-issue-creator

| # | Task | Issue | Link |
|---|------|-------|------|
| 1 | <título> | #<número> | <url> |
| 2 | <título> | #<número> | <url> |

Milestone: <milestone>
Labels: <labels usadas>
```

## Exemplo de uso

```
Usuário: "criar issues das tasks do módulo bloqueios"
rdd-req / rdd-doc → @rdd-github-orchestrator → rdd-gh-issue-creator

Saída:
✔ Issue #42 criada: [Bloqueios.API] Criar endpoint GET /bloqueios
✔ Issue #43 criada: [Bloqueios.MFE] Criar tela de listagem de bloqueios
✔ Issue #44 criada: [Database] Criar tabela BLOQUEIO

Total: 3 issues criadas em Acme-Group/arbor-api
```
