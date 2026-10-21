---
project: MIGRACAO-BLOQUEIOS
module: legado
audience: [tecnica]
status: draft
---

# Contexto Legado — Sistema Desktop de Bloqueios

> **Derivado de:** legado/schema.sql (amostra Oracle), PROJECT_CHARTER.md (legado: true)

---

## 1. Stack Tecnológica

| Componente | Tecnologia | Versão |
|---|---|---|
| Frontend/Desktop | Delphi | (confirmar com o time) |
| Banco de dados | Oracle | (confirmar versão) |
| Acesso a dados | Conexão local | — |

## 2. Tabelas legadas

### SDA_BLOQUEIO

Tabela única de bloqueios, com situação em flag (não há tabela de histórico
de eventos — o legado não preserva trilha de alterações além das colunas CTR_*).

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| NRO_INT_BLOQUEIO | NUMBER(10) | Sim | PK | ID do bloqueio (SEQ_SDA_BLOQUEIO) |
| NRO_INT_PRODUTOR | NUMBER(10) | Sim | — | Produtor bloqueado (índice IDX_BLOQ_PRODUTOR) |
| TXT_MOTIVO | VARCHAR2(400) | Não | — | Motivo do bloqueio |
| DTH_INICIO | DATE | Sim | — | Início (default SYSDATE) |
| DTH_FIM | DATE | Não | — | Fim do bloqueio |
| FLG_SITUACAO | CHAR(1) | Sim | — | `A` = ativo, `E` = encerrado (CK_FLG_SIT) |
| CTR_DTH_INC | DATE | Sim | — | Auditoria |
| CTR_USU_INC | NUMBER(8) | Sim | — | Auditoria |

## 3. Regras vigentes no legado

- Situação do bloqueio controlada por flag `A`/`E` (equivalente ao ativo/encerrado)
- Motivo com limite de 400 caracteres no legado (o novo módulo usa 500 —
  atenção na migração de dados: textos legados cabem, sem truncamento)
- Não existe registro de quem encerrou nem motivo do encerramento —
  apenas DTH_FIM

## 4. Armadilhas para a migração

- **Divergência de limite de motivo:** 400 (legado) × 500 (novo) — migração
  direta segura, mas validações do novo sistema não podem rejeitar dados antigos
- **Sem histórico de eventos:** a trilha HIST_BLOQUEIO do novo sistema
  começa vazia na conversão; eventos históricos não são reconstituíveis
- **FLG_SITUACAO:** mapear `A` → status ativo e `E` → encerrado no novo domínio

## 5. Glossário de equivalência

| Legado | Novo módulo |
|---|---|
| SDA_BLOQUEIO | BLOQUEIO |
| NRO_INT_BLOQUEIO | COD_BLOQUEIO |
| FLG_SITUACAO ('A'/'E') | FLG_ATIVO ('S'/'N') ou status |
| TXT_MOTIVO (400) | TXT_MOTIVO (500) |
| (não existe) | HIST_BLOQUEIO |
