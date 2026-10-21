---
project: CONTATOS
module: decisoes
audience: [tecnica]
status: active
---

# Decisões — Contatos

## [DEC-001] — Normalização de telefone na camada de domínio

**Data:** 02/09/2026
**Responsável:** Victor Souza
**Status:** active

**Contexto:**
A RN-001 exige telefone único normalizado. Era preciso decidir onde aplicar a
normalização (frontend, API ou banco).

**Alternativas consideradas:**

1. **Normalização no frontend:** simples, mas cada cliente duplicaria a regra.
2. **Normalização na API (domínio):** ponto único, valida antes de persistir.

**Decisão:**
Normalizar na camada de domínio da API, com helper dedicado.

**Impacto:**
- **RNs afetadas:** RN-001

**Justificativa:**
Ponto único de verdade; frontend apenas formata para exibição.

## ADR-001: Exportação de contatos no formato vCard 2.1

**Status:** Aceito
**Data:** 03/09/2026
**Decisor:** Victor Souza
**Contexto:** A RN-002 exige exportação de contatos interoperável com agenda
telefônica. Havia várias opções de formato e versão. Alternativas avaliadas:
CSV (simples de gerar, mas perde campos de telefone múltiplos na importação
de agendas), vCard 3.0 (mais moderno, porém algumas agendas antigas do
público-alvo não importam) e vCard 2.1 (amplamente aceito por agendas,
inclusive antigas, com propriedades estendidas).
**Decisão:** Exportar em vCard 2.1, com propriedades estendidas X-NORMALIZED
para o telefone normalizado da RN-001.
**Consequências:** Interoperabilidade máxima com as agendas do público-alvo;
vCard 3.0 não traz benefício prático para os campos usados e reduz
compatibilidade. RNs afetadas: RN-002. Artefatos downstream: API_CONTRACTS
(endpoint de export), helpers de geração de arquivo.