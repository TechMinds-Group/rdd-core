---
name: rdd-agents-md-sync
description: >-
  Audita e sincroniza AGENTS.md entre os repositórios de um mesmo produto
  (APM, FE, CORE e outros), separando regras comuns de regras específicas.
  Gera primeiro um relatório read-only, mostra diffs por repositório e só
  edita após confirmação explícita. Use para "sincronizar AGENTS.md",
  "alinhar instruções dos repos" ou "auditar convenções do produto".
---
# rdd-agents-md-sync — Sincronização de Instruções do Produto

Audita arquivos `AGENTS.md` de múltiplos repositórios que pertencem ao mesmo
produto, propõe uma base comum e preserva instruções específicas de cada repo.
É uma skill de governança multi-repo roteada pelo primary `rdd-doc`.

## Princípios

1. **Produto como unidade:** receba o nome do produto e todos os repos que o
   compõem. Não trate APM, FE e CORE como produtos independentes.
2. **Auditoria antes de edição:** a primeira execução é read-only e produz um
   relatório de divergências. Nunca edite durante a auditoria.
3. **Preservação por padrão:** instruções específicas de APM, frontend, CORE,
   stack, testes ou deploy não podem ser promovidas ao bloco comum sem
   confirmação explícita.
4. **Diff mínimo:** altere apenas blocos aprovados. Nunca substitua um
   `AGENTS.md` inteiro automaticamente.
5. **Evidência de origem:** cada regra proposta como comum deve indicar em
   quais repos ela foi encontrada.
6. **Hierarquia:** instruções específicas do repo continuam subordinadas apenas
   ao `AGENTS.md` global (incluindo os `rules/*.md` apontados pelo seu índice
   lazy, IMP-048) e às regras do próprio repo; a sincronização não pode
   apagar precedência local válida.

## Lê (upstream)

- Caminhos locais dos repositórios informados pelo usuário ou pelo `rdd-doc`.
- `AGENTS.md` de cada repositório do produto.
- `PROJECT_CHARTER.md`, `CONSTITUTION.md` e `INDEX.md` do produto quando
  disponíveis, para entender nome, repos e convenções documentais.
- `AGENTS.md` global e `rules/*.md` (índice lazy, IMP-048) quando necessário
  para verificar precedência.

## Gera (downstream)

- Relatório de auditoria em texto durante a primeira fase.
- Proposta de bloco comum e diffs por repositório após a auditoria.
- Alterações nos `AGENTS.md` somente depois de confirmação explícita.

## Nunca edita

- `AGENTS.md` de qualquer repositório sem relatório prévio (Passo 3) e confirmação explícita do operador.
- Segredos, tokens, credenciais ou paths de máquina específica — nunca são introduzidos nem versionados nos blocos sincronizados.
- Blocos ou arquivos locais gitignored (regras locais por máquina) — nunca entram na sincronização.

## Nunca faz

- Nunca edita código-fonte.
- Nunca sincroniza sem mostrar o diff.
- Nunca remove regras específicas sem confirmação.
- Nunca cria `AGENTS.md` ausente sem confirmação e conteúdo mínimo definido.
- Nunca presume que textos parecidos possuem o mesmo significado sem revisão.

## Estrutura recomendada

Quando houver concordância do usuário, prefira blocos delimitados:

```markdown
<!-- BEGIN PRODUCT_COMMON -->
Regras comuns do produto...
<!-- END PRODUCT_COMMON -->

<!-- BEGIN REPO_SPECIFIC -->
Regras específicas deste repositório...
<!-- END REPO_SPECIFIC -->
```

Se o arquivo não tiver marcadores, não reescreva automaticamente. Gere uma
proposta de migração para blocos e peça confirmação antes de aplicá-la.

## Workflow

### Passo 1 — Identificar produto e repos

1. Confirme o nome do produto.
2. Colete ou valide a lista de repos (`-APM`, `-FE`, `-CORE`, `-APP`, etc.).
3. Verifique se cada caminho existe.
4. Localize `AGENTS.md` em cada repo.
5. Classifique repos sem `AGENTS.md` como pendência, sem criar arquivo ainda.

### Passo 2 — Auditoria read-only

Para cada arquivo:

1. Separe front matter, instruções globais, regras de produto e regras de repo.
2. Mdentifique regras duplicadas ou semanticamente equivalentes.
3. Mdentifique conflitos, versões diferentes e instruções ambíguas.
4. Preserve comandos e paths específicos como regras locais até revisão humana.

Classifique cada achado como:

- `COMMON_CANDIDATE` — aparece de forma equivalente em dois ou mais repos;
- `REPO_SPECIFIC` — depende da camada, stack ou processo daquele repo;
- `CONFLICT` — regras incompatíveis entre repos;
- `MISSING` — repo sem `AGENTS.md` ou sem bloco esperado;
- `AMBIGUOUS` — texto semelhante, mas sem evidência suficiente para unificar.

### Passo 3 — Relatório

Retorne:

```markdown
# AGENTS.md Audit — [Produto]

## Repositórios analisados
| Repo | AGENTS.md | Status |
|---|---|---|

## Candidatos a regra comum
| Regra | Evidência | Repos | Confiança |
|---|---|---|---|

## Regras específicas preservadas
| Repo | Regra | Motivo |
|---|---|---|

## Conflitos e ambiguidades
| ID | Repos | Problema | Decisão necessária |
|---|---|---|---|

## Pendências
- PEND-001: ...
```

Não proponha edição antes de apresentar esse relatório.

### Passo 4 — Proposta de sincronização

Após o usuário revisar o relatório:

1. Pergunte quais `COMMON_CANDIDATE` devem ser promovidos.
2. Gere a proposta de bloco `PRODUCT_COMMON`.
3. Gere o bloco `REPO_SPECIFIC` individual de cada repo.
4. Mostre um diff separado por arquivo.
5. Destaque inclusões, remoções e alterações semânticas.

### Passo 5 — Confirmação e aplicação

1. Peça confirmação explícita para aplicar os diffs.
2. Se algum arquivo não tiver marcadores, confirme a conversão para blocos.
3. Edite somente os arquivos confirmados.
4. Não altere arquivos sem diff aprovado.
5. Informe os paths modificados e as regras preservadas.

### Passo 6 — Validação pós-edição

Verifique:

- Todos os repos continuam com suas regras específicas;
- O bloco comum é idêntico entre os arquivos sincronizados;
- Não há marcadores duplicados ou não fechados;
- Nenhum path ou comando específico foi movido para o bloco comum por engano;
- Repos sem `AGENTS.md` permanecem explicitamente pendentes;
- O resultado segue a precedência do `AGENTS.md` global e do repo.

## Tools

- `read` — ler `AGENTS.md` e contexto do produto;
- `glob` — localizar repos e arquivos `AGENTS.md`;
- `grep` — comparar regras, markers e referências;
- `question` — confirmar classificação e aplicação;
- `edit` — aplicar apenas diffs aprovados;
- `write` — permitido somente para criar arquivo após confirmação explícita.

## Modo de erro

`interativo` — interrompa antes de qualquer edição se houver conflito,
arquivo ausente, ausência de markers ou classificação ambígua. Retorne o
relatório parcial e peça uma decisão específica.

## Formato de commit

```text
docs(governance): sync product AGENTS instructions
```

O commit nunca é criado automaticamente pela skill.

## Casos de borda

- **Repo sem `AGENTS.md`:** reporte `MISSING`; não crie automaticamente.
- **Markers ausentes:** proponha a conversão, mas não faça sem confirmação.
- **Conflito entre regras:** mantenha ambas como específicas e gere pendência.
- **Regra comum com paths específicos:** divida a regra ou mantenha local.
- **Produto com muitos repos:** faça a auditoria por lote, mas aplique em
  diffs pequenos e confirmáveis.
- **Repo fora do produto informado:** pare e peça confirmação antes de incluir.
