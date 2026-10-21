---
name: rdd-client-report
description: >-
  Gera delivery/CLIENT_REPORT_<yyyy-MM|periodo>.md — relatório periódico para
  o cliente em linguagem de negócio: o que foi entregue no período, o que
  está em andamento, pendências de decisão do cliente e mudanças de escopo.
  Fecha o artefato CLIENT_REPORT_*.md da estrutura IMP-011 (antes órfão).
  Fontes read-only: SCOPE_AGREEMENT.md, bloco Resultado do rdd-progress
  (IMP-099), CLIENT_REQUIREMENTS.md e metadados das Feature.md. Read-only
  nos insumos — escreve apenas o relatório. Use quando o usuário pedir
  "relatório do cliente", "client report", "report do período" ou
  "relatório mensal do projeto".
---
# rdd-client-report — Relatório Periódico para o Cliente

Gera `<modulo>/<projeto>/delivery/CLIENT_REPORT_<periodo>.md` — relatório
periódico em **linguagem de negócio** para o cliente: entregas do período,
andamentos, pendências de decisão e mudanças de escopo. Fecha o artefato
órfão `CLIENT_REPORT_*.md` da estrutura IMP-011.

## Resolução de caminhos (IMP-011)

- **`delivery/`:** SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md (este artefato), Feature.md (IMP-093)
- **`support/`:** CHANGE_REQUESTS.md
- **Regra de fallback:** ao LER, caminho novo primeiro; raiz como fallback (módulos pré-IMP-011). Ao ESCREVER, sempre `delivery/`.

## Lê (upstream)

- `<modulo>/<projeto>/delivery/SCOPE_AGREEMENT.md` — RNs confirmadas e status de aprovação (fallback: raiz)
- `<modulo>/<projeto>/delivery/CLIENT_REQUIREMENTS.md` — visão business-only atual (fallback: raiz)
- `<modulo>/<projeto>/delivery/**/RN-NNN — <título> — Feature.md` — metadados: `status` no front matter, `entregue_em` (glob recursivo; fallback `— Tasks.md` IMP-092)
- `<modulo>/<projeto>/support/CHANGE_REQUESTS.md` — CRs do período com `Origem:` (IMP-099)
- Saída do `rdd-progress` (bloco **E. Resultado** — IMP-099): PENDs abertos/resolvidos, CRs por origem, features entregues e drift-check pendente. Se o dashboard não foi rodado nesta sessão, recomende rodá-lo antes — ou derive os mesmos dados diretamente dos artefatos (mesmas fontes do progress).
- `<modulo>/<projeto>/REQUIREMENTS.md` — proveniência de PENDs (para linguagem do cliente)

## Gera (downstream)

- `<modulo>/<projeto>/delivery/CLIENT_REPORT_<yyyy-MM>.md` — um arquivo por
  período (default: mês corrente `yyyy-MM`; operador pode passar período
  arbitrário, ex: `CLIENT_REPORT_2026-Q4.md`)

## Nunca edita

- Qualquer insumo — SCOPE_AGREEMENT, CLIENT_REQUIREMENTS, Feature.md,
  CHANGE_REQUESTS, REQUIREMENTS são **read-only** para esta skill
- IDs técnicos no corpo executivo — RN-XXX/CR-XXX/PEND-XXX ficam no
  apêndice técnico, nunca na seção "Em linguagem do cliente"

## Tools

- `read` (ler insumos)
- `glob` (localizar Feature.md e reports anteriores)
- `grep` (buscar status, entregue_em, origem de CRs)
- `write` (escrever apenas o CLIENT_REPORT)
- `question` (confirmar período e fatos destacados)

## Modo de erro

`continue` — insumo ausente → seção correspondente sai como "sem dados no
período", nunca inventada. Feature.md sem front matter `status` → trate
como "em andamento" com observação. Dado ausente → `N/A (sem dados)`
declarado (IMP-099), nunca número estimado.

## Algoritmo

1. **Período** — confirme com o operador (uma `question` se ambíguo):
   default mês corrente (`yyyy-MM`); aceite período arbitrário.
2. **Colete entregas** — glob de `delivery/**/*Feature.md` (fallback
   `— Tasks.md`); filtre as com `entregue_em` dentro do período; para cada
   uma, extraia a descrição funcional do RN-NNN — Analise-Funcional.md.
3. **Colete andamentos** — features do período com status
   `in_progress`/`approved` (não entregues); CRs do período por status e
   `Origem` (requisito-mal-capturado, evolucao, bug, decisao-cliente).
4. **Colete pendências de decisão** — PENDs abertos que aguardam o cliente
   (do progress/REQUIREMENTS) — estas são **pedidos de ação do cliente**,
   destacadas no topo.
5. **Redija em linguagem de negócio** — seção executiva "Em linguagem do
   cliente" sem IDs técnicos; apêndice técnico com a tabela de
   rastreabilidade (feature → RN → status).
6. **Compare com o report anterior** (se existir, mesmo padrão de nome) —
   não repita entregas já reportadas; destaque variação de PENDs/CRs.
7. Escreva `delivery/CLIENT_REPORT_<periodo>.md` e informe o caminho.

## Template — CLIENT_REPORT_<periodo>.md

```yaml
---
project: <NOME>
module: client_report
audience: [negocio]
status: final
period: <yyyy-MM>
---
```

```markdown
# Relatório do Projeto — [Nome do Sistema] — [período]

> **Cliente:** [nome do contratante]
> **Período:** DD/MM a DD/MM/AAAA
> **Gerado em:** DD/MM/AAAA

## ⚡ Precisamos de você

[decisões/definições que aguardam o cliente — vazio = "nenhuma pendência
de decisão neste período"]

## Em linguagem do cliente

### Entregamos neste período
- [funcionalidade em linguagem de negócio — o que o cliente passa a ter]

### Em andamento
- [funcionalidade — previsão]

### Mudanças de escopo
- [mudança pedida/aprovada em linguagem de negócio — origem: pedido do
  cliente | ajuste do nosso lado | correção]

## Panorama geral

| Frente | Situação |
|---|---|
| [tema do escopo] | ✅ concluída / 🔄 em andamento / ⏸️ aguardando decisão |

---

## Apêndice técnico (rastreabilidade)

| Feature | RN | Status | Entregue em |
|---|---|---|---|
| RN-010-M1 | RN-010 | done | 12/10/2026 |
```

## Formato de commit

```
docs: client report <periodo> for <projeto>
```

## Casos de Borda

- **Período sem entregas** — reporte com honestidade: "nenhuma entrega
  concluída no período" + o que avançou; nunca disfarce andamento como entrega.
- **Report do período já existe** — pergunte: sobrescrever (mesmo período,
  revisão) ou gerar revisão com sufixo? Nunca sobrescreva sem confirmar.
- **CR de origem `requisito-mal-capturado`** — no corpo executivo, apresente
  como "ajuste de entendimento do requisito" (sem tom de culpa); a
  classificação técnica fica só no apêndice/CHANGE_REQUESTS.
- **PEND de origem nossa vs. do cliente** — só PEND que aguarda o cliente
  entram em "Precisamos de você"; as demais vão no panorama como
  "em tratamento pela equipe".
- **Multi-repositório (produto unificado)** — o relatório é do PRODUTO
  (unidade = produto); não separe seções por repo, apenas por tema/funcionalidade.