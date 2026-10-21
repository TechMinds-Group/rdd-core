---
name: rdd-compliance-check
description: >-
  Checklist LGPD (Lei 13.709/2018) aplicável a produtos que tratam dado pessoal.
  Gera specs/COMPLIANCE.md com o preenchimento dos 10 eixos do checklist:
  levantamento de dados, base legal, consentimento, minimização, retenção,
  direitos do titular, segurança, registros (RTD/relatório de impacto),
  terceiros/compartilhamento e internacionalização. Gatilho: charter com
  compliance: true ou demanda do operador. Use quando o usuário pedir
  "compliance", "LGPD", "checklist de dado pessoal", "COMPLIANCE.md" ou
  "verificação de conformidade".
---
# rdd-compliance-check — Checklist LGPD do Módulo

Gera `<modulo>/<projeto>/specs/COMPLIANCE.md` — o registro de conformidade
LGPD do produto, preenchido a partir das RNs, do modelo de dados e dos
contratos de API. Pragmático: cobre o que um produto de software da organização
precisa responder a um fiscal ou a um titular — não é assessoria jurídica.

## Referências

- Lei 13.709/2018 (LGPD) — artigos de base legal (Art. 7), sensíveis (Art. 11),
  direitos do titular (Art. 18), segurança (Art. 46), relatório de impacto (Art. 38)
- Estrutura de pastas: IMP-011 — o artefato `specs/COMPLIANCE.md` integra a pasta `specs/`

## Resolução de caminhos (IMP-011)

- **Raiz:** PROJECT_CHARTER.md, REQUIREMENTS.md
- **`specs/`:** COMPLIANCE.md (este artefato), DATA_MODEL.md, API_CONTRACTS.md, UI_SPEC.md, SECURITY.md
- **Regra de fallback:** ao LER, tente `specs/<artefato>.md`; se não existir, raiz. Ao ESCREVER, sempre `specs/`.

## Lê (upstream)

- `<modulo>/<projeto>/PROJECT_CHARTER.md` — flag `compliance: true` (gatilho) e contexto do produto
- `<modulo>/<projeto>/REQUIREMENTS.md` — RNs (§6 Dados e Campos indica dado pessoal)
- `<modulo>/<projeto>/specs/DATA_MODEL.md` — tabelas/colunas que persistem dado pessoal
- `<modulo>/<projeto>/specs/API_CONTRACTS.md` — endpoints que expõem dado pessoal
- `<modulo>/<projeto>/specs/UI_SPEC.md` — fluxos de aceite/consentimento na interface
- `<modulo>/<projeto>/specs/SECURITY.md` — controles de segurança já especificados
- `<modulo>/<projeto>/support/LEGACY_CONTEXT.md` — tratamento pré-existente (se houver)

## Gera (downstream)

- `<modulo>/<projeto>/specs/COMPLIANCE.md` — checklist LGPD preenchido

## Nunca edita

- REQUIREMENTS.md, DATA_MODEL.md, API_CONTRACTS.md ou qualquer artefato de origem
- Se um eixo revelar RN nova ou mudança em RN confirmada → registre como
  **candidato a RN/CR** no fim do relatório e oriente o roteamento para
  `rdd-req` (nunca edite requisitos diretamente)

## Tools

- `read` (ler charter, REQUIREMENTS, specs)
- `glob` (localizar artefatos do módulo)
- `grep` (buscar colunas/endpoints/fluxos que tratam dado pessoal)
- `write` (escrever specs/COMPLIANCE.md)
- `question` (esclarecer dúvidas de tratamento com o operador)

## Modo de erro

`interativo` — módulo sem `compliance: true` no charter → pergunte se o
produto trata dado pessoal antes de gerar (evita COMPLIANCE.md fantasma).
Artefato de origem ausente → preencha o eixo com `⚠️ Não verificável
(<artefato> ausente)` e siga; nunca invente resposta. Dúvida jurídica real
(ex: base legal ambígua entre interesse legítimo e consentimento) → marque
`❓ A decidir` e recomende validação com o DPO/jurídico do cliente — a skill
NUNCA decide base legal sozinha quando há dúvida razoável.

## Algoritmo

1. **Gatilho** — leia PROJECT_CHARTER.md: `compliance: true` presente (ou
   operador pediu explicitamente)? Se ausente e o operador pediu, siga e
   recomende atualizar o charter ao final.
2. **Inventário** — varra REQUIREMENTS.md (§6), DATA_MODEL.md, API_CONTRACTS.md
   e UI_SPEC.md e liste TODO tratamento de dado pessoal: tabela/coluna,
   endpoint, tela/fluxo. Se nada tratar dado pessoal, gere o COMPLIANCE.md
   com eixo 1 = "Não trata dado pessoal" e encerre (artefato negativo vale
   como registro).
3. **Preencha os 10 eixos** do checklist (abaixo), cada um com status
   (✅ conforme / ⚠️ parcial / ❌ lacuna / ❓ a decidir / N/A) e evidência
   (`[artefato:seção]`).
4. **Plano de lacunas** — para cada ❌/⚠️, liste ação corretiva sugerida e
   quem resolve (RN nova via rdd-req, spec via rdd-doc, decisão do cliente).
5. Escreva `specs/COMPLIANCE.md`.

## Os 10 eixos do checklist

1. **Levantamento** — o produto trata dado pessoal? Quais categorias
   (identificação, contato, financeiro, localização, uso do serviço)?
   Inclui dado pessoal **sensível** (Art. 11: origem racial, religião,
   saúde, biometria...)? O titular inclui **menor de idade** (consentimento
   específico de responsável, Art. 14)?
2. **Base legal por tratamento** — para cada categoria de tratamento,
   qual base do Art. 7 (consentimento, obrigação legal, execução de
   contrato, interesse legítimo...)? Sensíveis: só as bases do Art. 11.
3. **Consentimento** — quando a base for consentimento: aceite **versionado**
   (qual versão do ToU/PP o titular aceitou, com timestamp)? **Granular**
   (finalidades separadas, não pacote único)? **Revogável** (caminho tão
   fácil quanto dar)? Padrão de referência: aceite versionado com sync
   offline (VibeCut/PEND-008).
4. **Minimização e finalidade** — cada campo coletado tem finalidade
   declarada? Há coleta "por se um dia precisar" (violação do Art. 6, I e III)?
5. **Retenção e descarte** — prazo de retenção definido por dado? O que
   acontece com o dado após o fim da relação (exclusão, anonimização)?
6. **Direitos do titular (Art. 18)** — existem fluxos/endpoints para
   acesso, correção, exclusão, portabilidade e informação sobre
   compartilhamento? Em qual RN/spec cada direito está coberto?
7. **Segurança (Art. 46)** — criptografia em trânsito/repouso para dado
   pessoal? Controle de acesso por papel? Log de acesso a dado pessoal?
   (cruze com SECURITY.md — não duplique, referencie).
8. **Registros** — há registro das operações de tratamento (RTD — registro
   das operações, Art. 37)? Relatório de impacto (RIPD, Art. 38) é
   necessário (tratamento de alto risco: sensível, monitoramento, escala)?
9. **Terceiros e compartilhamento** — o dado é compartilhado com
   processadores (nuvem, gateway de pagamento, analytics)? Há contrato de
   operador (Art. 39)? Quem é o **controlador** e existe **DPO/encarregado**
   (do cliente ou da organização)?
10. **Internacionalização** — o dado sai do Brasil (transferência
    internacional, Art. 33)? Para qual país e com qual salvaguarda?

## Template — COMPLIANCE.md

```yaml
---
project: <NOME>
module: compliance
audience: [tecnica, negocio]
status: draft
---
```

```markdown
# Compliance LGPD — [Nome do Sistema]

> **Data:** DD/MM/AAAA
> **Gatilho:** charter `compliance: true` | demanda direta
> **Veredito:** ✅ Conforme | ⚠️ Conforme com lacunas (N) | ❌ Não conforme (N)

## 1. Levantamento de tratamento

| Dado | Categoria | Sensível? | Onde (tabela/endpoint/tela) | RN |
|---|---|---|---|---|

**Titular inclui menor?** Sim | Não
**Produto trata dado pessoal?** Sim | Não (artefato negativo — registro de que a análise foi feita)

## 2. Base legal por tratamento

| Tratamento | Base legal (Art. 7/11) | Justificativa | Status |
|---|---|---|---|

## 3. Consentimento

| Eixo | Status | Evidência |
|---|---|---|
| Aceite versionado | | |
| Granular por finalidade | | |
| Revogável | | |

## 4. Minimização e finalidade
## 5. Retenção e descarte
## 6. Direitos do titular (Art. 18)
## 7. Segurança (Art. 46)
## 8. Registros (RTD / RIPD)
## 9. Terceiros e compartilhamento
## 10. Internacionalização

## Plano de lacunas

| # | Eixo | Lacuna | Ação corretiva | Resolve via |
|---|---|---|---|---|

## Candidatos a RN/CR

- [lista de achados que exigem mudança em requisito — rotear via rdd-req]
```

## Formato de commit

```
docs: compliance LGPD check for <projeto>
```

## Casos de Borda

- **Produto não trata dado pessoal** — gere o artefato negativo (eixo 1 +
  declaração); ele registra que a análise foi feita e silencia o finding do
  `rdd-validate`.
- **Charter sem flag `compliance`** (módulos pré-IMP-102) — pergunte ao
  operador antes de gerar; se sim, recomende adicionar `compliance: true`.
- **Dado pessoal no legado** — cruze com LEGACY_CONTEXT.md; tratamento
  pré-existente entra no inventário com a marcação "legado".
- **Eixo não aplicável** — marque N/A com justificativa de 1 linha
  (ex: sem transferência internacional).
- **Conflito entre SECURITY.md e este checklist** — não decida; registre
  no plano de lacunas e sinalize para `rdd-doc`.