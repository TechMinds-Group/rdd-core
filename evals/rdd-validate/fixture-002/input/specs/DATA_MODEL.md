---
project: BLOQUEIOS-SANITARIO
module: modelo-dados
audience: [tecnica]
status: draft
---

# Modelo de Dados — Bloqueios Sanitários

> **Derivado de:** REQUIREMENTS.md (RN-001, RN-002, RN-003, RN-004)
> **Última atualização:** 20/09/2026

---

## 1. Diagrama Entidade-Relacionamento

```mermaid
erDiagram
    BLOQUEIO {
        NUMBER(10) COD_BLOQUEIO PK
        NUMBER(10) COD_PRODUTOR
        VARCHAR2(500) TXT_MOTIVO
        CHAR(1) FLG_ATIVO
        DATE CTR_DTH_INC
        NUMBER(8) CTR_USU_INC
    }

    HIST_BLOQUEIO {
        NUMBER(10) COD_HIST PK
        NUMBER(10) COD_BLOQUEIO FK
        VARCHAR2(20) TIP_EVENTO
        VARCHAR2(500) TXT_DETALHE
        DATE CTR_DTH_INC
    }

    BLOQUEIO }o--|| HIST_BLOQUEIO : "gera eventos"
```

---

## 2. Tabelas

### 2.1 BLOQUEIO

Tabela nova para bloqueios de produtores (RN-001, RN-002, RN-003, RN-004).

**Identificação:** PK via sequence (nominal `SEQ_BLOQUEIO`)

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| COD_BLOQUEIO | NUMBER(10) | Sim | PK | ID do bloqueio (sequence) |
| COD_PRODUTOR | NUMBER(10) | Sim | — | Produtor bloqueado |
| TXT_MOTIVO | VARCHAR2(500) | Sim | — | Motivo do bloqueio |
| FLG_ATIVO | CHAR(1) | Sim | — | S/N — bloqueio ativo (CK: IN ('S','N')) |
| DTH_INICIO | DATE | Sim | — | Início do bloqueio |
| DTH_FIM | DATE | Não | — | Fim do bloqueio (encerramento) |
| TXT_MOTIVO_FIM | VARCHAR2(500) | Não | — | Motivo do encerramento |
| CTR_DTH_INC | DATE | Sim | — | Auditoria |
| CTR_USU_INC | NUMBER(8) | Sim | — | Auditoria |

**Check constraints:**
- `FLG_ATIVO IN ('S', 'N')`

**Índices relevantes:**
- `FK_BLOQUEIO_PRODUTOR` (COD_PRODUTOR)

### 2.2 HIST_BLOQUEIO

Tabela nova para histórico de eventos (RN-001, RN-004).

**Identificação:** PK via sequence (nominal `SEQ_HIST_BLOQUEIO`)

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| COD_HIST | NUMBER(10) | Sim | PK | ID do evento (sequence) |
| COD_BLOQUEIO | NUMBER(10) | Sim | FK → BLOQUEIO | Bloqueio referenciado |
| TIP_EVENTO | VARCHAR2(20) | Sim | — | Tipo do evento (CK: IN ('CRIADO','ENCERRADO')) |
| TXT_DETALHE | VARCHAR2(500) | Não | — | Detalhe do evento (ex: motivo do fim) |
| CTR_DTH_INC | DATE | Sim | — | Auditoria |
| CTR_USU_INC | NUMBER(8) | Sim | — | Auditoria |

**Check constraints:**
- `TIP_EVENTO IN ('CRIADO', 'ENCERRADO')`

---

## 3. Decisão de armazenamento

| Opção | Status | Motivo |
|---|---|---|
| Criar `BLOQUEIO` e `HIST_BLOQUEIO` novas | **Adotado** | Sistema novo, sem tabelas legadas. |
