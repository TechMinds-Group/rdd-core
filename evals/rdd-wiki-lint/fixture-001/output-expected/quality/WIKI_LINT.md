---
project: BLOQUEIOS-SANITARIO
module: wiki-lint
audience: [tecnica]
status: draft
---

# Wiki Lint — Bloqueios Sanitários

> **Executado em:** 21/09/2026
> **Artefatos analisados:** 4 (REQUIREMENTS.md, DATA_MODEL.md, DECISIONS.md, input support)

---

## 1. Localização de artefatos (convenção IMP-011)

| Arquivo | Encontrado em | Esperado em | Status |
|---|---|---|---|
| DATA_MODEL.md | raiz do módulo | specs/DATA_MODEL.md | ❌ fora do lugar |
| REQUIREMENTS.md | raiz | raiz | ✅ |
| DECISIONS.md | raiz | raiz | ✅ |

**Detalhe:** DATA_MODEL.md está na raiz (layout pré-IMP-011). A skill de
data-model segue o fallback de leitura, mas toda escrita vai para `specs/` —
recomenda-se mover para `specs/DATA_MODEL.md` (ou executar `rdd-restructure`).

## 2. Placeholders não preenchidos

| Arquivo | Pattern | Linha aproximada |
|---|---|---|
| REQUIREMENTS.md | `TODO` (seção §9 Persistência e Auditoria) | ~52 |

**Detalhe:** "TODO: definir volume de dados e política de retenção do
histórico." — substituir por decisão registrada ou mover para PEND.

## 3. Front matter

| Arquivo | Status |
|---|---|
| REQUIREMENTS.md | ✅ válido |
| DATA_MODEL.md | ✅ válido |
| DECISIONS.md | ❌ ausente |

**Detalhe:** DECISIONS.md não inicia com bloco YAML `---`. As skills de
downstream (decision-audit, traceability) esperam front matter válido.

## 4. Referências cruzadas e links

Nenhum link interno quebrado. IDs RN-001..RN-004 referenciados em
REQUIREMENTS.md existem no próprio documento.

## Resumo

| Severidade | Quantidade | Itens |
|---|---|---|
| Avisos estruturais | 3 | DATA_MODEL fora do lugar; TODO em REQUIREMENTS; front matter ausente em DECISIONS |

**Ações recomendadas:** mover DATA_MODEL.md para `specs/`, resolver o TODO
da §9 (ou converter em PEND-002), adicionar front matter em DECISIONS.md.
