---
project: BLOQUEIOS-SANITARIO
module: spec-ui
audience: [tecnica]
status: draft
---

# Especificação de UI — Bloqueios Sanitários

> **Derivado de:** REQUIREMENTS.md §2/§5/§7/§8 (RN-001, RN-002, RN-003, RN-004), specs/API_CONTRACTS.md

---

## 1. Atores e Telas

### Operador

| Tela | Casos de Uso | RNs |
|---|---|---|
| Aplicar bloqueio | UC-01 | RN-001, RN-002 |
| Gerenciar bloqueios | UC-02, UC-03 | RN-003, RN-004 |

### Consultor

| Tela | Casos de Uso | RNs |
|---|---|---|
| Consultar bloqueios (somente leitura) | UC-02 | RN-003 |

---

## 2. Telas

### 2.1 Aplicar bloqueio (Operador)

**Formulário:**

| Campo | Tipo | Obrigatório | Validação frontend | Contrato |
|---|---|---|---|---|
| Produtor | busca (autocomplete) | Sim | Seleção obrigatória | idProdutor |
| Motivo | textarea (500) | Sim | Obrigatório, máx. 500 caracteres | motivo |

**Ações:**
- `Aplicar bloqueio` → POST /bloqueios
  - 201 → mensagem de sucesso e redireciona para Gerenciar bloqueios
  - 409 BLOQ_DUPLICADO → exibe mensagem "Este produtor já possui um bloqueio ativo." (RN-002)
  - 404 PRODUTOR_INEXISTENTE → exibe mensagem do catálogo
  - 400 VALIDACAO_CAMPO → destaca campo inválido

**Regras de exibição condicional:**
- O botão `Aplicar bloqueio` fica desabilitado até produtor e motivo estarem válidos

### 2.2 Gerenciar bloqueios (Operador)

**Listagem:**

| Coluna | Origem | Observação |
|---|---|---|
| Produtor | GET /bloqueios | nome |
| Motivo | GET /bloqueios | truncado com tooltip |
| Status | GET /bloqueios | badge `Ativo` (verde) / `Encerrado` (cinza) |
| Data início | GET /bloqueios | DD/MM/AAAA |

**Ações por linha:**
- `Encerrar` (visível apenas quando status = ativo) → abre modal de encerramento (RN-004)

**Modal de encerramento:**

| Campo | Tipo | Obrigatório | Validação | Contrato |
|---|---|---|---|---|
| Motivo do encerramento | textarea (500) | Sim | Obrigatório, máx. 500 | motivoFim |

- Confirmação → POST /bloqueios/{id}/encerramento
  - 200 → atualiza listagem com status Encerrado
  - 409 BLOQUEIO_JA_ENCERRADO → mensagem do catálogo
  - 400 VALIDACAO_CAMPO → destaca campo

### 2.3 Consultar bloqueios (Consultor)

Somente leitura — mesma listagem da 2.2 sem ações de linha.
**Indicador de GTA (RN-003):** coluna extra `GTA` exibindo badge
`Impedida` quando o produtor possui bloqueio ativo, `Liberada` caso contrário
(dados de GET /bloqueios/gta-status/{idProdutor}).

---

## 3. Validações de Frontend (resumo)

| Regra | Onde | EARS |
|---|---|---|
| Motivo obrigatório, até 500 caracteres | Aplicar / Encerrar | RN-001, RN-004 |
| Rejeição de duplicado exibida com mensagem do catálogo | Aplicar | RN-002 |
| Ação encerrar só em bloqueio ativo | Gerenciar | RN-004 |
| Badge GTA reflete status de bloqueio | Consultar | RN-003 |
