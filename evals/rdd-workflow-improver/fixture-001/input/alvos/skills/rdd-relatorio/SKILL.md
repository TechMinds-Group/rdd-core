---
name: rdd-relatorio
description: >-
  Gera RELATORIO_MENSAL.md a partir dos dados consolidados do módulo.
  Use quando o usuário pedir "relatório mensal", "consolidado do mês" ou
  "RELATORIO_MENSAL".
---
# rdd-relatorio — Relatório Mensal Consolidado

Gera `RELATORIO_MENSAL.md` consolidando as métricas do módulo no mês de
referência. Read-only nas fontes — escreve apenas o relatório final.

## Lê (upstream)

- `docs/METRICS.md` — métricas acumuladas
- `TRACEABILITY.md` — cobertura de requisitos
- `CHANGELOG.md` — entregas do período

## Gera (downstream)

- `RELATORIO_MENSAL.md` (cria ou atualiza o mês de referência)

## Nunca edita

- Artefatos de requisitos (REQUIREMENTS.md, DATA_MODEL.md, etc.)
- Código de aplicações

## Workflow

### Passo 1 — Determinar mês de referência

Do pedido do usuário ou o mês corrente.

### Passo 2 — Coletar fontes

Leia os 3 arquivos upstream. Fonte ausente → registre "N/D" no relatório,
nunca invente número.

### Passo 3 — Consolidar métricas

Some/prome médias por dimensão (skills usadas, issues, cobertura).

### Passo 4 — Redigir sumário executivo

Máximo 5 bullets, linguagem de negócio.

### Passo 5 — Montar tabelas

Uma tabela por dimensão, colunas estáveis entre meses.

### Passo 6 — Escrever RELATORIO_MENSAL.md

Merge incremental — nunca apague meses anteriores.

### Passo 7 — Formato de saída

Confirme o mês e resuma as fontes usadas.

## Casos de Borda

- **Primeiro relatório:** crie o arquivo com cabeçalho e o mês corrente.
- **Fonte parcialmente ausente:** "N/D" por campo, com nota de rodapé.

<!-- fixture-marker: rdd-relatorio v1 — integridade da fixture (não remover) -->