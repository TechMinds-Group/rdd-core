---
project: BLOQUEIOS-SANITARIO
module: validacao
audience: [tecnica]
status: draft
---

# Relatório de Validação — Bloqueios Sanitários

> **Executado em:** 21/09/2026
> **Escopo:** módulo completo (REQUIREMENTS, specs/DATA_MODEL, specs/API_CONTRACTS, specs/UI_SPEC, quality/TRACEABILITY)

---

## 1. RN sem downstream esperado

**Nenhuma lacuna.** As 4 RNs possuem downstream em todos os documentos
aplicáveis, conforme matriz abaixo e TRACEABILITY.md:

| RN | DATA_MODEL | API_CONTRACTS | UI_SPEC | ACCEPTANCE_CRITERIA |
|---|---|---|---|---|
| RN-001 | ✅ | ✅ POST /bloqueios | ✅ Aplicar bloqueio | ✅ |
| RN-002 | ✅ | ✅ 409 BLOQ_DUPLICADO | ✅ Mensagem duplicado | ✅ |
| RN-003 | ✅ | ✅ gta-status | ✅ Badge GTA | ✅ |
| RN-004 | ✅ | ✅ encerramento | ✅ Modal encerrar | ✅ |

## 2. IDs quebrados

Nenhum. RN-001..RN-004 consistentes em todos os documentos.

## 3. CRs aprovados sem reflexo

Nenhum CR registrado no módulo.

---

## Resumo

| Severidade | Quantidade |
|---|---:|
| Erro | 0 |
| Warning | 0 |
| Info | 0 |

**Status do módulo: íntegro.** Grafo de documentos sem lacunas de
downstream, sem IDs quebrados e sem CRs pendentes de reflexo.
