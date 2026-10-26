---
name: rdd-domain-research
description: >-
  Pesquisa e registra a base de conhecimento de um domínio ANTES da criação
  da camada/componente que o consome (knowledge-first). Gera
  ~/.config/opencode/knowledge/<dominio>/KNOWLEDGE.md a partir de fontes
  primárias atuais (OWASP ASVS/Code Review Guide, WCAG, livros canônicos,
  docs oficiais — sempre com URL e data de acesso) e atualiza
  knowledge/INDEX.md (merge incremental). Gatilho obrigatório do
  @rdd-workflow-builder para domínio de conhecimento novo ou base stale.
  Use quando o usuário pedir "fundação de conhecimento", "base de
  conhecimento do domínio X", "KNOWLEDGE.md", "pesquisar domínio" ou
  "knowledge-first".
---
# rdd-domain-research — Fundação de Conhecimento de Domínio

Pesquisa fontes atuais e registra a **base de conhecimento canônica** de um
domínio (ex: security review → OWASP; qualidade de código → Clean
Code/SOLID/design patterns; acessibilidade → WCAG) ANTES da criação da
camada/componente que o consome. Princípio: **conhecimento antes de
componente** — a camada nasce de base pesquisada, não de critérios de
improviso embutidos no prompt.

## Diferenciação

| Skill | Faz |
|-------|-----|
| `rdd-domain-research` | Funda a BASE de conhecimento de um domínio (`knowledge/<dominio>/KNOWLEDGE.md`) |
| `rdd-skill-creator` | Cria a skill/componente que CONSUME a base |
| `rdd-pattern-extractor` | Extrai padrões de retrospectivas de projetos (acúmulo pós-projeto, não fundação) |

## Lê (upstream)

- Pedido do operador/builder: **nome do domínio + escopo** (ex: "security review de código/solução", "qualidade de código", "revisão de acessibilidade")
- `~/.config/opencode/knowledge/INDEX.md` — bases existentes (reuso de domínio já fundado; merge incremental)
- `~/.config/opencode/knowledge/<dominio>/KNOWLEDGE.md` — base anterior (quando re-pesquisa por staleness)
- `rules/context7.md` — regra de pesquisa de docs oficiais (não confie na memória)
- Fontes externas via `websearch` / `find-docs` / `ctx7` — sempre fontes primárias e atuais

## Gera (downstream)

- `~/.config/opencode/knowledge/<dominio>/KNOWLEDGE.md` — a base (template fixo abaixo)
- `~/.config/opencode/knowledge/INDEX.md` — entrada do domínio (merge incremental — nunca deleta entradas; cria o arquivo se for a primeira fundação)
- (Opcional, só com confirmação) `packs/<pack-ativo>/accumulation/knowledge/<dominio>-nuances.md` — nuances/aplicação da organização no clone do pack; lembre o operador de publicar via `rdd-pack-publish` (esta skill NÃO publica)

## Nunca edita

- Componentes do workflow (`agents/`, `skills/`, `registry.yaml`, `ARCHITECTURE.md`, `AGENTS.md`)
- Artefatos de módulo RDD (REQUIREMENTS.md, DATA_MODEL.md, etc.) e código de aplicação
- Bases de OUTROS domínios em `knowledge/` (só o domínio alvo + INDEX)
- `evals/golden-human/` (IMP-100) — intocado por agents

## Tools disponíveis

- `websearch` (pesquisar fontes atuais — allow)
- `read` / `glob` / `grep` (ler INDEX, base anterior e regra context7 — allow)
- `bash` (somente leitura — ex: `Get-Date` para data de pesquisa/revisão)
- `write` / `edit` (restritos a `~/.config/opencode/knowledge/**`; pack da organização sob ask)
- `question` (esclarecer escopo ambíguo; confirmar gravação no pack)

Perfil de permissão (menor privilégio, aplicado no agente invocador):
read/glob/grep/websearch allow; edit/write só em
`~/.config/opencode/knowledge/**` (+ `packs/**/accumulation/knowledge/**`
sob ask); bash só leitura. Nenhuma outra escrita é permitida.

## Modo de erro

`strict` — sem fundação não há camada. Fonte sem URL + data de acesso não
entra na base (bloqueia a gravação até corrigir). Domínio já fundado e
válido (`proxima_revisao` no futuro) → não re-pesquisa sem pedido: retorna
o caminho da base para reuso direto (idempotência).

## Algoritmo

### Passo 1 — Delimitar domínio e escopo

Confirme com o invocador (normalmente o @rdd-workflow-builder, que já
validou o gatilho na fase de Fundação de Conhecimento):

1. **Nome do domínio**: lowercase-hyphen (ex: `security-review`,
   `code-quality`, `acessibilidade`), ≤ 64 chars.
2. **Escopo**: 1-2 frases do que a camada fará com a base (ex: "security
   review de código/solução" — a base orienta triagem de findings).
3. Consulte `knowledge/INDEX.md`: se o domínio já existe e
   `proxima_revisao` está no futuro, **ENCERRE em modo reuso** — reporte o
   caminho da base, sem escrita.

### Passo 2 — Pesquisar fontes primárias (não confie na memória)

Use `websearch` (e `find-docs`/`ctx7` para docs oficiais de tecnologias do
escopo) para coletar fontes ATUAIS. Prioridade:

1. **Padrões e guias primários do domínio** (ex: OWASP ASVS + OWASP Code
   Review Guide para security; WCAG 2.2 + WAI-ARIA para acessibilidade;
   livros canônicos + design patterns para qualidade)
2. **Documentação oficial** das tecnologias citadas no escopo
3. **Referências secundárias** só para contextualizar — nunca como única fonte

Para CADA fonte registre: título, **URL**, **data de acesso** (AAAA-MM-DD) e
versão/edição quando aplicável. Fonte sem URL + data de acesso é descartada.

### Passo 3 — Sintetizar a base no template fixo

Preencha o template KNOWLEDGE.md (abaixo) com o material pesquisado:

- **Princípios** com heurística de violação (como reconhecer na prática)
- **Checklist aplicável** ao escopo declarado
- **Anti-patterns** com exemplos concretos
- **Classificação/Severidade** para triagem (Crítico/Alto/Médio/Baixo)

Cada item cita a fonte (ex: `(OWASP ASVS v4.0.3, V5)`). Nada entra na base
sem fonte citada.

### Passo 4 — Gravar a base e atualizar o INDEX

1. Escreva `~/.config/opencode/knowledge/<dominio>/KNOWLEDGE.md` — em
   re-pesquisa, merge incremental (nunca delete seções sem substituição
   explícita; incremente `versao`).
2. Atualize `~/.config/opencode/knowledge/INDEX.md` (crie com o template do
   INDEX se for a primeira fundação do ambiente) — adicione a entrada do
   domínio; **nunca remova entradas existentes**.
3. Defina `proxima_revisao` (padrão: `data_pesquisa` + 6 meses; domínios
   que evoluem rápido — ex: security — podem usar 3 meses).

### Passo 5 — Fechar o ciclo

Reporte ao invocador: caminho da base, entrada no INDEX, fontes principais
e `proxima_revisao`. O componente consumidor (criado pelo builder) deve
listar o KNOWLEDGE.md na seção "Lê (upstream)" dele como fonte canônica de
critérios. Nuances da organização: só grave no pack com confirmação
explícita do operador e lembre que a publicação é via `rdd-pack-publish`.

## Template — knowledge/<dominio>/KNOWLEDGE.md

```markdown
---
dominio: <nome-do-dominio>
versao: 1.0.0
data_pesquisa: AAAA-MM-DD
proxima_revisao: AAAA-MM-DD
escopo: <escopo em 1 linha>
fontes:
  - titulo: <título da fonte>
    url: <URL>
    acessado_em: AAAA-MM-DD
    versao: <versão/edição, quando aplicável>
---
# KNOWLEDGE — <Domínio> (<escopo em 1 linha>)

Base canônica do domínio para consumo por camadas/componentes RDD.
Fonte canônica de critérios — componentes que consomem este domínio listam
este arquivo no "Lê (upstream)" deles. Atualizar via rdd-domain-research
quando `proxima_revisao` vencer.

## Princípios

### P-01 — <princípio>
<definição em 1-3 frases>
- **Heurística de violação**: <como reconhecer a violação na prática>
- Fonte: (<fonte, seção>)

## Checklist aplicável

- [ ] <item verificável aplicado ao escopo> (ref: P-01)

## Anti-patterns

### AP-01 — <nome do anti-pattern>
<descrição + exemplo concreto de código/solução que materializa o anti-pattern>
- Viola: P-01 · Severidade: <Crítico/Alto/Médio/Baixo>

## Classificação/Severidade

| Nível | Critério | Ação na triagem |
|-------|----------|-----------------|
| Crítico | <critério> | bloqueia aprovação |
| Alto | <critério> | corrige antes de aprovar |
| Médio | <critério> | backlog priorizado |
| Baixo | <critério> | backlog comum |

## Referências

1. <título> — <URL> (acessado em AAAA-MM-DD)
```

## Template — entrada em knowledge/INDEX.md

```markdown
### <dominio>
- **Escopo**: <escopo em 1 linha>
- **Base**: knowledge/<dominio>/KNOWLEDGE.md (v<versao>)
- **data_pesquisa**: AAAA-MM-DD · **proxima_revisao**: AAAA-MM-DD
- **Fontes principais**: <1-3 fontes>
```

## Formato de commit/registro

```
chore(knowledge): add <dominio> knowledge base
```

O INDEX.md é atualizado pela própria skill (merge incremental). O registro
estrutural no `registry.yaml` NÃO é papel desta skill — é do
@rdd-workflow-builder: a skill é fundação de conteúdo, não componente novo
da árvore de delegação.

## Casos de Borda

- **Domínio sem fontes primárias claras**: pergunte ao operador com 2-3
  candidatos antes de sintetizar — nunca funde base só com fontes
  secundárias.
- **Base existe e está válida**: modo reuso — retorne o caminho, sem
  escrita (idempotência).
- **Re-pesquisa de base stale** (`proxima_revisao` vencida): atualização
  incremental — incremente `versao` (1.0.0 → 1.1.0 para acréscimos; 2.0.0
  para revisão que invalida princípios) e atualize `data_pesquisa` e
  `proxima_revisao`.
- **Conflito entre fontes**: registre as duas posições no princípio com
  nota de contexto — não escolha silenciosamente.
- **INDEX.md inexistente**: crie com cabeçalho e a entrada (primeira
  fundação do ambiente).
- **Pedido para pular a pesquisa**: recuse — sem fundação não há camada
  (contrato do gatilho do builder). Só o operador pode decidir diferente,
  e aí o componente nasce com débito de fundação declarado.
- **Escrita fora de `knowledge/`**: bloqueada pelo menor privilégio — em
  eval/sandbox, escreva relativo ao module root do sandbox
  (`knowledge/<dominio>/KNOWLEDGE.md` dentro do sandbox).