---
project: BLOQUEIOS-EVAL
module: modelo-dados
audience: [tecnica]
status: draft
---

# Modelo de Dados — Módulo Bloqueios (fixture de eval)

> **Derivado de:** REQUIREMENTS.md (RN-001, RN-002), LEGACY_CONTEXT.md (sem tabelas legadas)
> **Última atualização:** 20/09/2026

---

## 1. Diagrama Entidade-Relacionamento

```mermaid
erDiagram
    PRODUTOR {
        NUMBER(10) COD_PRODUTOR PK
        VARCHAR2(100) NOME
        VARCHAR2(14) CPF_CNPJ
        VARCHAR2(100) EMAIL
        DATE DTH_CADASTRO
        DATE CTR_DTH_INC
        DATE CTR_DTH_ATU
        NUMBER(8) CTR_USU_INC
        NUMBER(8) CTR_USU_ATU
        VARCHAR2(15) CTR_NRO_IP_INC
        VARCHAR2(15) CTR_NRO_IP_ATU
    }

    PROPRIEDADE {
        NUMBER(10) COD_PROPRIEDADE PK
        VARCHAR2(200) NOME_PROPRIEDADE
        VARCHAR2(300) TXT_ENDERECO
        NUMBER(10,2) NUM_AREA_HECTARES
        NUMBER(10) COD_PRODUTOR FK
        DATE CTR_DTH_INC
        DATE CTR_DTH_ATU
        NUMBER(8) CTR_USU_INC
        NUMBER(8) CTR_USU_ATU
        VARCHAR2(15) CTR_NRO_IP_INC
        VARCHAR2(15) CTR_NRO_IP_ATU
    }

    PRODUTOR }o--|| PROPRIEDADE : "possui"
```

- Colunas de auditoria (`CTR_*`) incluídas na visão gráfica do modelo
- Sem tabelas externas de referência

---

## 2. Tabelas

### 2.1 PRODUTOR

Tabela **nova** para cadastro de produtores (RN-001). Sistema sem tabelas
legadas (LEGACY_CONTEXT.md), portanto todas as colunas são derivadas de
REQUIREMENTS.md §6 com convenção padrão de auditoria.

**Identificação:** PK via sequence (nominal `SEQ_PRODUTOR`)

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| COD_PRODUTOR | NUMBER(10) | Sim | PK | ID do produtor (sequence) |
| NOME | VARCHAR2(100) | Sim | — | Nome completo do produtor |
| CPF_CNPJ | VARCHAR2(14) | Sim | — | CPF ou CNPJ do produtor |
| EMAIL | VARCHAR2(100) | Não | — | E-mail para contato |
| DTH_CADASTRO | DATE | Sim | — | Data de cadastro |
| CTR_DTH_INC | DATE | Sim | — | Data/hora de criação (auditoria) |
| CTR_DTH_ATU | DATE | Não | — | Data/hora da última atualização (auditoria) |
| CTR_USU_INC | NUMBER(8) | Sim | — | ID do usuário que criou (auditoria) |
| CTR_USU_ATU | NUMBER(8) | Não | — | ID do usuário da última atualização (auditoria) |
| CTR_NRO_IP_INC | VARCHAR2(15) | Sim | — | IP de origem da criação (auditoria) |
| CTR_NRO_IP_ATU | VARCHAR2(15) | Não | — | IP de origem da última atualização (auditoria) |

**Check constraints:**
- Nenhuma exigida pelos requisitos

**Índices relevantes:**
- `UK_PRODUTOR_CPF_CNPJ` (CPF_CNPJ) — único, evita duplicidade de cadastro

**Uso no módulo simplificado — colunas preenchidas:**

| Coluna | Valor | Origem |
|---|---|---|
| COD_PRODUTOR | Sequence | PK |
| NOME | Do request (`nome`) | Request |
| CPF_CNPJ | Do request (`cpfCnpj`) | Request |
| EMAIL | Do request (`email`) | Request |
| DTH_CADASTRO | Do request (`dataCadastro`) | Request |
| CTR_* | Data/hora/usuário/IP correntes | Regra de auditoria |

---

### 2.2 PROPRIEDADE

Tabela **nova** para cadastro de propriedades vinculadas a produtor (RN-002).

**Identificação:** PK via sequence (nominal `SEQ_PROPRIEDADE`)

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| COD_PROPRIEDADE | NUMBER(10) | Sim | PK | ID da propriedade (sequence) |
| NOME_PROPRIEDADE | VARCHAR2(200) | Sim | — | Nome da propriedade |
| TXT_ENDERECO | VARCHAR2(300) | Sim | — | Endereço completo |
| NUM_AREA_HECTARES | NUMBER(10,2) | Sim | — | Área em hectares |
| COD_PRODUTOR | NUMBER(10) | Sim | FK → PRODUTOR | Produtor responsável |
| CTR_DTH_INC | DATE | Sim | — | Data/hora de criação (auditoria) |
| CTR_DTH_ATU | DATE | Não | — | Data/hora da última atualização (auditoria) |
| CTR_USU_INC | NUMBER(8) | Sim | — | ID do usuário que criou (auditoria) |
| CTR_USU_ATU | NUMBER(8) | Não | — | ID do usuário da última atualização (auditoria) |
| CTR_NRO_IP_INC | VARCHAR2(15) | Sim | — | IP de origem da criação (auditoria) |
| CTR_NRO_IP_ATU | VARCHAR2(15) | Não | — | IP de origem da última atualização (auditoria) |

**Check constraints:**
- `NUM_AREA_HECTARES > 0` — área deve ser positiva

**Índices relevantes:**
- `FK_PROPRIEDADE_PRODUTOR` (COD_PRODUTOR) — acesso por produtor

**Relacionamentos:**
- N:1 com PRODUTOR (via COD_PRODUTOR) — 1 produtor possui N propriedades

**Uso no módulo simplificado — colunas preenchidas:**

| Coluna | Valor | Origem |
|---|---|---|
| COD_PROPRIEDADE | Sequence | PK |
| NOME_PROPRIEDADE | Do request (`nomePropriedade`) | Request |
| TXT_ENDERECO | Do request (`endereco`) | Request |
| NUM_AREA_HECTARES | Do request (`areaHectares`) | Request |
| COD_PRODUTOR | Do request (`idProdutor`) | Request |
| CTR_* | Data/hora/usuário/IP correntes | Regra de auditoria |

---

## 3. Decisão de armazenamento

| Opção | Status | Motivo |
|---|---|---|
| Criar `PRODUTOR` e `PROPRIEDADE` novas | **Adotado** | Sistema novo, sem tabelas legadas (LEGACY_CONTEXT.md). Sem ADRs registrados (DECISIONS.md ausente). |

Sem colunas marcadas como "não usado" — todas as colunas são preenchidas
pelo módulo.
