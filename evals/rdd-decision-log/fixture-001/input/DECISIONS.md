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
