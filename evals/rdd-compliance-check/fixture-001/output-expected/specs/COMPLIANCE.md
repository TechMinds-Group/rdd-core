---
project: VIBECUT
module: compliance
audience: [tecnica, negocio]
status: final
---

# Compliance LGPD — VibeCut

> **Data:** 18/10/2026
> **Gatilho:** charter `compliance: true`
> **Veredito:** ⚠️ Conforme com lacunas (1)

## 1. Levantamento de tratamento

| Dado | Categoria | Sensível? | Onde (tabela/endpoint/tela) | RN |
|---|---|---|---|---|
| E-mail | Contato | Não | USUARIO.EMAIL | RN-001 |
| Aceite ToU/PP | Registro de consentimento | Não | USUARIO.ACEITE_VERSAO, ACEITE_DATA | RN-001 |

**Titular inclui menor?** Não
**Produto trata dado pessoal?** Sim

## 2. Base legal por tratamento

| Tratamento | Base legal (Art. 7/11) | Justificativa | Status |
|---|---|---|---|
| Armazenar e-mail e aceite | Consentimento (Art. 7, I) | titular aceita ToU/PP versionado no 1º acesso | ✅ |
| Exclusão de dados | Obrigação legal (Art. 7, II) — direito do titular (Art. 18, VI) | cumprimento de pedido de exclusão | ✅ |

## 3. Consentimento

| Eixo | Status | Evidência |
|---|---|---|
| Aceite versionado | ✅ | RN-001 (versão + timestamp persistidos) |
| Granular por finalidade | ✅ | aceite único cobre apenas a finalidade do serviço |
| Revogável | ⚠️ | revogação via exclusão de conta (RN-002); sem revogação granular |

## 4. Minimização e finalidade

Somente e-mail e registro de aceite são coletados (USUARIO) — ✅ minimizado.

## 5. Retenção e descarte

Carência de 30 dias antes da exclusão definitiva (RN-002) — ✅.

## 6. Direitos do titular (Art. 18)

| Direito | Cobertura |
|---|---|
| Exclusão | RN-002 (fluxo de exclusão de conta) |
| Acesso/correção/portabilidade | ❓ A decidir — sem RN correspondente |

## 7. Segurança (Art. 46)

Criptografia em trânsito e controle de acesso especificados em
specs/SECURITY.md — referenciado, não duplicado.

## 8. Registros (RTD / RIPD)

Tratamento de baixo risco e sem dado sensível — RIPD N/A; RTD a cargo do
controlador (cliente).

## 9. Terceiros e compartilhamento

Sem compartilhamento com processadores além da infraestrutura de nuvem.

## 10. Internacionalização

Dados hospedados no Brasil — sem transferência internacional (N/A).

## Plano de lacunas

| # | Eixo | Lacuna | Ação corretiva | Resolve via |
|---|---|---|---|---|
| 1 | 6 | Acesso/correção/portabilidade sem RN | Criar RN de autoatendimento de dados do titular | rdd-req (RN nova) |

## Candidatos a RN/CR

- RN nova: consulta e portabilidade de dados do titular (eixo 6, Art. 18)