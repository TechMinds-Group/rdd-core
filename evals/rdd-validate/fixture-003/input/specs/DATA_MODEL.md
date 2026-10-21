---
project: TAXAS-PEDAGIO
module: modelo-dados
audience: [tecnica]
status: draft
---

# Modelo de Dados — Taxas de Pedágio

> **Derivado de:** REQUIREMENTS.md (RN-001, RN-002)
> **Última atualização:** 13/10/2026

---

## 1. Diagrama Entidade-Relacionamento

```mermaid
erDiagram
    PASSAGEM {
        NUMBER(10) COD_PASSAGEM PK
        VARCHAR2(7) TXT_PLACA
        DATE DTH_PASSAGEM
    }

    TARIFA {
        NUMBER(10) COD_TARIFA PK
        VARCHAR2(20) TIP_TARIFA
        NUMBER(8,2) VAL_TARIFA
    }

    PASSAGEM }o--|| TARIFA : "aplica"
```

---

## 2. Tabelas

### 2.1 PASSAGEM 🟢

Tabela induzida do legado para eventos de passagem (RN-001 — Confiança Alta).

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| COD_PASSAGEM | NUMBER(10) | Sim | PK | ID da passagem (sequence) |
| TXT_PLACA | VARCHAR2(7) | Sim | — | Placa do veículo |
| DTH_PASSAGEM | DATE | Sim | — | Momento da passagem |

### 2.2 TARIFA 🟡

Tabela inferida do padrão de nomes (RN-002 — Confiança Média).

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| COD_TARIFA | NUMBER(10) | Sim | PK | ID da tarifa (sequence) |
| TIP_TARIFA | VARCHAR2(20) | Sim | — | Tipo da tarifa |
| VAL_TARIFA | NUMBER(8,2) | Sim | — | Valor da tarifa |

---

## 3. Decisão de armazenamento

| Opção | Status | Motivo |
|---|---|---|
| Reaproveitar tabelas do legado (PASSAGEM, TARIFA) | **Adotado** | Sistema existente — análise reversa das tabelas reais. |
