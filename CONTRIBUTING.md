# CONTRIBUTING — Open Core do Workflow RDD

## Open Core: como funciona

O desenvolvimento acontece no repositório **privado** `TM.CORE.RDD` — é lá que
internos criam skills, subagents e melhorias. As releases públicas são
**snapshots limpos** do "subset essencial" (agents, skills, registry, templates,
evals e docs de contribuição) publicados no repositório **público**
`TechMinds-Group/rdd-core`.

Contribuições externas entram via **PR no `rdd-core`** (público). Os
mantenedores portam a contribuição aceita para o `TM.CORE.RDD` (privado) e
publicam a próxima release. Histórico interno (IMP, ADR, quality, reports)
nunca aparece no repositório público — cada release é um snapshot, não um
mirror do git interno.

## Contribuindo (externos)

Fluxo para contribuidores externos:

1. Faça um **fork** do `rdd-core`.
2. Crie uma **branch** para sua mudança.
3. Faça uma mudança **generalizada e anonimizada** — nada de conteúdo de
   cliente específico (o conhecimento de cliente pertence aos packs, que são
   privados).
4. Passe pelo **checklist de anonimização** (abaixo) — obrigatório no PR.
5. Rode o gate localmente: `bash evals/neutrality/scan.sh` — deve terminar com
   `neutrality: OK`. **PASS** é pré-condição do PR.
6. Faça commit com **sign-off DCO** (`git commit -s`) e abra o **PR**.

> **Nota:** skills e agents citam paths do runtime (`rules/`, `packs/`,
> `.rdd/` etc.). PRs que alteram a estrutura de componentes quebram o
> `registry.yaml` — nesse caso o PR precisa incluir o re-render das views
> (skill `rdd-registry-render`).

## Checklist de anonimização (obrigatória no PR)

Marque cada item. **Qualquer "sim" → generalize ou não envie o PR.**

- [ ] Contém nomes de clientes, organizações ou produtos reais?
- [ ] Contém URLs, domínios ou e-mails reais?
- [ ] Contém nomes de pessoas?
- [ ] Contém números de processo, contrato, CNPJ/CPF ou inscrições?
- [ ] Contém codinomes de sistemas internos ou prefixos de repo do cliente?
- [ ] Contém caminhos de rede, IPs ou credenciais/tokens (mesmo truncados)?
- [ ] Contém prints ou diagramas com marca?
- [ ] Contém datas + fatos que identifiquem um cliente?

## DCO (Developer Certificate of Origin)

Todo commit precisa de um `Signed-off-by` — use `git commit -s`. Ao assinar,
você certifica que tem o direito de submeter a contribuição sob a licença do
projeto, conforme o [Developer Certificate of Origin](https://developercertificate.org/).

**Não usamos CLA** — a única barreira para contribuir é o sign-off DCO.

---

# CONTRIBUTING — Guia de Contribuição para o Workflow RDD

Guia para quem quer contribuir com novas skills, subagents ou melhorias no workflow RDD.

---

## Visão Geral

O workflow RDD é composto por três tipos de componentes:

| Componente | O que é | Onde vive | Exemplo |
|------------|---------|-----------|---------|
| **Primary Agent** | Persona ativa da sessão | `agents/<nome>.md` | `rdd-req.md`, `rdd-doc.md`, `rdd-dev.md` |
| **Subagent** | Orquestrador de domínio | `agents/<nome>.md` | `@rdd-intake-orchestrator` |
| **Skill** | Conhecimento de referência | `skills/<nome>/SKILL.md` | `rdd-requirements` |

---

## Pré-requisitos

1. **Conhecer o RDD**: ler `AGENTS.md`, `ARCHITECTURE.md` e `CHECKLISTS.md`
2. **Ter acesso ao repositório do workflow RDD** (branch `main`)
3. **Conhecer o OpenCode**: entender front matter, tools, permissões
4. **Ferramentas disponíveis**: `@rdd-workflow-builder` (cria componentes), `@rdd-workflow-improver` (corrige workflows)

---

## Fluxo de Contribuição

### 1. Identificar a Necessidade

Antes de criar algo novo, verifique:

- **Já existe?** Consulte `ARCHITECTURE.md` §1-§3
- **É uma correção?** Use `@rdd-workflow-improver` em vez de criar novo componente
- **É uma melhoria?** Registre em `WORKFLOW_IMPROVEMENTS.md` primeiro

### 2. Delimitar a Função

Responda:

- **O que o componente faz?** (1-2 frases)
- **Qual domínio ele pertence?** (Intake, Requisitos, Tradução Técnica, Qualidade, Azure, etc.)
- **Quem o invoca?** (primary agent ou subagent)
- **Quais skills ele usa?** (se for subagent)

### 3. Criar o Componente

Use as skills meta do RDD:

| O que criar | Skill a usar | Arquivo gerado |
|-------------|--------------|----------------|
| Nova skill | `rdd-skill-creator` | `skills/<nome>/SKILL.md` |
| Novo subagent | `rdd-subagent-creator` | `agents/<nome>.md` |
| Novo primary agent | `rdd-primary-agent-creator` | `agents/<nome>.md` |

> **Importante:** O `@rdd-workflow-builder` automatiza esse fluxo. Prefira usá-lo.

### 4. Registrar no Mapa

Todo componente novo deve ser registrado em:

| Arquivo | O que registrar |
|---------|-----------------|
| `ARCHITECTURE.md` | §1 (primary→subagents), §2 (subagent→skills), §3 (skill→domínio→acesso) |
| `ARCHITECTURE.md` | nó no diagrama Mermaid + aresta de conexão |
| `ARCHITECTURE.md` | nó + arestas de interação |
| `registry.yaml` e primary agents | manifesto e tabela de subagents (se novo subagent) |
| `AGENTS.md` | seção relevante (se mudança estrutural) |

### 5. Testar

1. Execute o componente isoladamente
2. Verifique se invoca as skills corretas
3. Verifique se as permissões estão corretas
4. Valide com `rdd-validate` se aplicável

### 6. Publicar

1. Registre a melhoria em `WORKFLOW_IMPROVEMENTS.md` (formato IMP-XXX)
2. Use `rdd-self-publish` para commit + push
3. Informe outros usuários (se aplicável)

---

## Convenções de Nomenclatura

### Skills

```
rdd-<ação>
```

Exemplos:
- `rdd-requirements` (gera/requer requisitos)
- `rdd-data-model` (gera modelo de dados)
- `rdd-validate` (valida integridade)

### Subagents

```
@rdd-<domínio>-orchestrator
```

Exemplos:
- `@rdd-intake-orchestrator` (orquestra intake)
- `@rdd-figma-orchestrator` (orquestra Figma)

Exceções (auto-contidos):
- `@rdd-next` (recomenda próxima skill)
- `@rdd-progress` (dashboard de status)
- `@rdd-cr-propagation-guard` (detecta artefatos stale)

### Primary Agents

```
rdd-<função>
```

Exemplos:
- `rdd-req` (requirements / discovery)
- `rdd-doc` (documentation / engenharia reversa)
- `rdd-dev` (development / implementação)

---

## Estrutura de uma Skill

```yaml
---
name: rdd-<nome>
description: <descrição curta>
---

# rdd-<nome>

## Lê
- <arquivos que lê>

## Gera
- <arquivos que gera>

## Nunca edita
- <arquivos que nunca edita>

## Tools
- read: allow
- write: allow
- edit: allow
- bash: deny
- webfetch: deny

## Modo de erro
- <o que fazer quando algo falha>

## Algoritmo / Workflow
1. <passo 1>
2. <passo 2>
...

## Template
<template do artefato gerado>

## Formato de commit
<convenção de commit>

## Casos de borda
- <caso 1>: <como tratar>
- <caso 2>: <como tratar>
```

---

## Estrutura de um Subagent

```yaml
---
name: @rdd-<nome>
description: <descrição curta>
tools:
  read: allow
  write: allow
  edit: allow
  bash: deny
  webfetch: deny
  skill: allow
---

# @rdd-<nome>

## Identidade
<quem é, qual seu papel>

## Princípios
- <princípio 1>
- <princípio 2>

## Lê
- <arquivos que lê>

## Gera
- <arquivos que gera>

## Nunca edita
- <arquivos que nunca edita>

## Skills disponíveis
| Skill | Quando invocar |
|-------|----------------|
| `rdd-<skill1>` | <descrição> |
| `rdd-<skill2>` | <descrição> |

## Algoritmo
1. <passo 1>
2. <passo 2>
...

## Casos de borda
- <caso 1>: <como tratar>
```

---

## Estrutura de um Primary Agent

```yaml
---
name: rdd-<nome>
description: <descrição curta>
mode: primary
tools:
  read: allow
  write: allow
  edit: allow
  bash: allow
  webfetch: allow
---

# rdd-<nome>

## Identidade
<quem é, qual seu papel>

## Princípios
- <princípio 1>
- <princípio 2>

## Subagents

| Subagent | Quando invocar |
|----------|----------------|
| `@rdd-<sub1>` | <descrição> |
| `@rdd-<sub2>` | <descrição> |

## Skills disponíveis
| Skill | Quando invocar |
|-------|----------------|
| `rdd-<skill1>` | <descrição> |

## Comportamento
<como o agente se comporta>

## Roteamento de domínio
<como roteia pedidos para subagents>
```

---

## Permissões

### Princípio do Menor Privilégio

Cada componente deve ter apenas as permissões necessárias:

| Permissão | Quando usar |
|-----------|-------------|
| `read: allow` | Sempre (leitura é segura) |
| `write: allow` | Apenas quando o componente cria/edita arquivos |
| `edit: allow` | Apenas quando o componente modifica arquivos existentes |
| `bash: allow` | Apenas quando o componente precisa de comandos Git/shell |
| `webfetch: allow` | Apenas quando o componente busca dados externos |
| `skill: allow` | Apenas quando o componente invoca outras skills |

### Exemplos de Permissões

| Componente | read | write | edit | bash | webfetch | skill |
|------------|------|-------|------|------|----------|-------|
| `rdd-requirements` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `@rdd-intake-orchestrator` | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| `@rdd-azure-orchestrator` | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| `@rdd-workflow-builder` | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| `rdd-self-update` | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |

---

## Formato de Commit

Use Conventional Commits:

```
<tipo>(<escopo>): <descrição curta>

[corpo opcional]

[footer opcional]
```

### Tipos

| Tipo | Quando usar |
|------|-------------|
| `feat` | Nova feature (skill, subagent, funcionalidade) |
| `fix` | Correção de bug |
| `docs` | Apenas documentação |
| `refactor` | Refatoração sem mudança de comportamento |
| `chore` | Manutenção, limpeza, dependências |

### Exemplos

```
feat(rdd-azure-task-creator): adicionar gate de duplicidade
fix(rdd-validate): corrigir validação de colunas de auditoria
docs(ARCHITECTURE-MAP): registrar novo subagent
refactor(rdd-workflow-builder): extrair lógica de inferência
chore: atualizar dependências
```

---

## Revisão

### Checklist para Revisão

- [ ] Componente segue a convenção de nomenclatura
- [ ] Permissões são mínimas necessárias
- [ ] Registrado em ARCHITECTURE.md
- [ ] Registrado em ARCHITECTURE.md
- [ ] Registrado em ARCHITECTURE.md
- [ ] Registrado no registry.yaml e primary agents (se subagent)
- [ ] Testado isoladamente
- [ ] WORKFLOW_IMPROVEMENTS.md atualizado (se correção)
- [ ] Formato de commit correto

### Quem Revisa

- **Skills e subagents**: revisão pelo operador do workflow
- **Primary agents**: revisão pelo operador + teste em ambiente de homologação
- **Mudanças estruturais** (AGENTS.md, DECISIONS.md): revisão obrigatória

---

## Perguntas Frequentes

### Posso criar uma skill sem usar `rdd-skill-creator`?

Sim, mas não é recomendado. A skill creator garante:
- Front matter válido
- Seções obrigatórias presentes
- Consistência com o padrão RDD

### Posso criar um subagent sem usar `@rdd-workflow-builder`?

Sim, mas não é recomendado. O builder garante:
- Registro em todos os arquivos necessários
- Inferência correta de dependências
- Zero referências quebradas

### E se eu precisar de uma skill que não se encaixa em nenhum domínio existente?

Crie um novo domínio. Registre em `ARCHITECTURE.md` §4 (Taxonomia de Domínios).

### Posso editar AGENTS.md diretamente?

Sim, mas com cuidado. AGENTS.md é a fonte de verdade para convenções. Edições devem ser:
- Bem fundamentadas
- Registradas em DECISIONS.md
- Comunicadas a outros usuários

### Como sei se minha mudança quebra algo?

1. Execute `rdd-validate` no módulo afetado
2. Verifique se alguma skill/subagent referencia o componente alterado
3. Teste o fluxo completo (Intake → Requisitos → Tradução → Qualidade)

---

*Este guia é mantido pela Quadri RDD (rdd-req, rdd-doc, rdd-dev, rdd-devops). Para dúvidas, consulte o `AGENTS.md` ou peça ajuda ao operador.*
