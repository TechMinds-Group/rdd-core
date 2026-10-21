---
project: CONTATOS
audience: [suporte, usuario_final]
status: draft
---

# Known Errors

> Incidentes de suporte reais. Erros de API previstos em contrato vão em
> ERROR_CATALOG.md.

---

## [KE-001] — Telefone aparece duplicado na listagem

**Data do incidente:** 05/09/2026
**Status:** resolvido

**Sintoma:**
Contato importado duas vezes aparece repetido na tabela de listagem.

**Causa:**
Dedup por place_id não cobria importação manual.

**Workaround:**
Excluir o contato duplicado manualmente antes da próxima importação.
