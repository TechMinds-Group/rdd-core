---
name: rdd-scope-agreement
description: >-
  Gera SCOPE_AGREEMENT.md — documento de alinhamento com o cliente em
  linguagem de negócio. Unifica escopo, RNs confirmadas, histórico de
  mudanças e status de aprovação. Deve ser atualizado a cada novo lote
  de requisitos ou CR aprovado.
  Use quando o usuário pedir "acordo de escopo", "documento de
  alinhamento com o cliente" ou "atualizar SCOPE_AGREEMENT.md".
---
# rdd-scope-agreement — Acordo de Escopo com o Cliente

Gera `<modulo>/<projeto>/delivery/SCOPE_AGREEMENT.md` — um documento vivo em
linguagem de negócio que serve como contrato de comprometimento entre
a equipe técnica e o cliente.

## Referências

- RNs em linguagem de negócio (fonte): `docs/CONSTITUTION.md §13`
- Estrutura de pastas: `docs/CONSTITUTION.md §15`

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

- `<modulo>/<projeto>/PROJECT_CHARTER.md` (identificação, escopo, riscos)
- `<modulo>/<projeto>/REQUIREMENTS.md` (RNs, PENDs, decisões)
- `<modulo>/<projeto>/support/CHANGE_REQUESTS.md` (mudanças solicitadas e aprovadas; fallback: raiz)
- `<modulo>/<projeto>/CHANGELOG.md` (histórico de adições/alterações)
- `<modulo>/<projeto>/specs/US<NNN>.md` (se existir, para linguagem do usuário; fallback: raiz)
- `<modulo>/<projeto>/delivery/SCOPE_AGREEMENT.md` (se existir, para merge incremental; fallback: raiz)

## Gera (downstream)

- `<modulo>/<projeto>/delivery/SCOPE_AGREEMENT.md`

## Nunca edita

- `REQUIREMENTS.md`
- `PROJECT_CHARTER.md`
- Nenhum documento técnico ou de requisitos

## Tools

- `read` (ler documentos upstream)
- `write` (escrever SCOPE_AGREEMENT.md)
- `grep` (buscar RNs, CRs, DECs)

## Modo de erro

`continue` — se falhar, loga warning. É documento de comunicação, não
bloqueia o fluxo técnico.

## Algoritmo

1. Leia REQUIREMENTS.md, `support/CHANGE_REQUESTS.md`, CHANGELOG.md e o SCOPE_AGREEMENT.md existente (se houver)
2. Traduza RNs e mudanças para linguagem de negócio — sem IDs internos visíveis no texto principal (IDs só na seção de rastreamento)
3. Se o documento existe, faça merge incremental (seções adicionam itens, CRs aprovados refletem, pendências resolvidas saem); se não, gere todas as seções do template
4. Atualize a data e o status da versão (`proposta` | `vigente`)
5. Escreva `delivery/SCOPE_AGREEMENT.md`

## Formato de commit

```
docs: update scope agreement for <projeto>
```

## Regras

1. **Linguagem de negócio** — NUNCA use EARS, termos técnicos ou IDs
   internos (RN-XXX) no texto principal. Use paráfrases claras.
   Os IDs internos devem ficar em nota de rodapé ou coluna separada
   apenas na seção de rastreamento.

2. **Mercado-alvo da linguagem:** o stakeholder de negócio que aprovou
   o projeto — não o usuário final, não o desenvolvedor.

3. **Última versão sempre substitui a anterior** — o SCOPE_AGREEMENT.md
   é o documento mais atualizado. Não mantém versões históricas no
   mesmo arquivo (o CHANGELOG.md cuida disso).

4. **Se existir, faça merge incremental** — preserve seções que o
   cliente já aprovou, adicione apenas o novo lote.

## Template — SCOPE_AGREEMENT.md

```yaml
---
project: <NOME>
module: escopo
audience: [negocio]
status: draft
---
```

```markdown
# Acordo de Escopo — [Nome do Sistema]

> **Cliente:** [nome do contratante]
> **Última atualização:** DD/MM/AAAA
> **Status da versão:** proposta | vigente

---

## 1. Objetivo do Projeto

[parágrafo em linguagem de negócio — o problema que o sistema resolve]

## 2. O Que Será Entregue

### 2.1 [Tema/Funcionalidade 1]

- Item de escopo em linguagem clara
- Item de escopo em linguagem clara

### 2.2 [Tema/Funcionalidade 2]

- Item de escopo em linguagem clara

## 3. O Que Não Está no Escopo

- Item fora do escopo
- Item fora do escopo

## 4. Regras de Negócio Confirmadas

| # | Regra | Status |
|---|---|---|
| 1 | [descrição em linguagem de negócio] | ✅ confirmada |
| 2 | [descrição em linguagem de negócio] | 🔄 alterada em DD/MM |

> Os detalhes técnicos de cada regra estão em REQUIREMENTS.md.

## 5. Mudanças em Andamento

| # | Mudança | Status | Data |
|---|---|---|---|
| — | Nenhuma mudança pendente | — | — |

## 6. Pendências e Definições Futuras

| Item | Previsão |
|---|---|
| [pendência](/dúvida) | [data ou vazio] |

## 7. Riscos e Premissas

- [premissa/risco relevante para o cliente]

---

> Este documento é enviado ao cliente para leitura e aprovação verbal.
> Não substitui contrato formal — é uma ferramenta de alinhamento contínuo.
```

## Seções que mudam a cada execução

Na primeira execução, gere todas as seções do template.
Nas execuções seguintes (merge incremental):

- **§2 e §4** — adicione novos itens sem remover os existentes.
  Se uma RN foi alterada por CR, marque como `🔄 alterada` em vez de
  reescrever.
- **§5** — CRs com status `pending` entram como pendentes; CRs
  `approved` entram como "em implementação"; CRs `implemented` são
  movidos para o CHANGELOG (seção §4 com status `✅ confirmada`).
- **§6** — PENDs resolvidas desde a última execução são removidas.

## Exemplo de §4 (RNs em linguagem de negócio)

```markdown
## 4. Regras de Negócio Confirmadas

| # | Regra | Status |
|---|---|---|
| 1 | Toda propriedade rural deve ter um produtor responsável vinculado | ✅ confirmada |
| 2 | O sistema deve validar CPF/CNPJ do produtor no momento do cadastro | ✅ confirmada |
| 3 | Quando uma inspeção é agendada, o produtor recebe notificação com a data | ✅ confirmada |
| 4 | Inspeções podem ser registradas offline e sincronizam automaticamente | 🔄 alterada em 22/07 |
```

## Casos de Borda

- **Primeira execução** — gere todas as seções do template; não deixe seções vazias sem o placeholder.
- **CR implementado** — mova a mudança para a seção de mudanças confirmadas com status `✅ confirmada` e remova das pendentes.
- **CR pendente** — mantenha como pendente; não antecipe aprovação.
- **RN alterada por CR** — marque `🔄 alterada em DD/MM` em vez de reescrever a linha.
- **PEND resolvida desde a última execução** — remova da seção de pendências.
