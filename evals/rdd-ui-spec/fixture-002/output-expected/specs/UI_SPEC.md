---
project: BLOQUEIOS-SANITARIO
module: spec-ui
audience: [tecnica]
status: draft
---

# Especificação de UI — Bloqueios Sanitários (sem API_CONTRACTS)

> **Derivado de:** REQUIREMENTS.md §2/§5/§7 (RN-001, RN-002, RN-003, RN-004)
> **Nota:** API_CONTRACTS.md ausente — campos e mensagens de erro derivados
> exclusivamente de REQUIREMENTS.md; revisar quando o contrato existir.

---

## 1. Atores e Telas

| Ator | Tela | RNs |
|---|---|---|
| Operador | Aplicar bloqueio | RN-001, RN-002 |
| Operador | Gerenciar bloqueios (encerrar) | RN-004 |
| Consultor | Consultar bloqueios | RN-003 |

---

## 2. Telas

### 2.1 Aplicar bloqueio (Operador)

| Campo | Tipo | Obrigatório | Validação |
|---|---|---|---|
| Produtor | busca | Sim | Seleção obrigatória |
| Motivo | textarea | Sim | Obrigatório |

**Comportamento (RN-002):** se o produtor já possui bloqueio ativo, o
sistema recusa e exibe mensagem de bloqueio duplicado.

### 2.2 Gerenciar bloqueios (Operador)

Listagem com status (ativo/encerrado) e ação **Encerrar** apenas para
bloqueios ativos, com modal de motivo obrigatório (RN-004).

### 2.3 Consultar bloqueios (Consultor)

Somente leitura, com indicador de situação GTA (RN-003): impedida quando
há bloqueio ativo, liberada caso contrário.

---

## 3. Validações de Frontend

| Regra | Onde | EARS |
|---|---|---|
| Motivo obrigatório | Aplicar / Encerrar | RN-001, RN-004 |
| Encerrar só em bloqueio ativo | Gerenciar | RN-004 |
| Badge GTA reflete bloqueio | Consultar | RN-003 |
