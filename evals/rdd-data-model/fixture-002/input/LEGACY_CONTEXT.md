# LEGACY_CONTEXT — Sistema Legado (fixture de reuso)

## Tabelas legadas

### SDA_BLOQUEIO (Oracle)

Tabela existente em produção, a ser reaproveitada pelo novo módulo.

| Coluna | Tipo | Obrigatório | PK/FK | Descrição |
|---|---|---|---|---|
| NRO_INT_BLOQUEIO | NUMBER(10) | Sim | PK | ID do bloqueio (SEQ_SDA_BLOQUEIO) |
| NRO_INT_PRODUTOR | NUMBER(10) | Sim | — | Produtor bloqueado (IDX_BLOQ_PRODUTOR) |
| TXT_MOTIVO | VARCHAR2(400) | Não | — | Motivo do bloqueio |
| DTH_INICIO | DATE | Sim | — | Início (default SYSDATE) |
| DTH_FIM | DATE | Não | — | Fim do bloqueio |
| FLG_SITUACAO | CHAR(1) | Sim | — | `A` = ativo, `E` = encerrado (CK_FLG_SIT) |
| CTR_DTH_INC | DATE | Sim | — | Auditoria |
| CTR_USU_INC | NUMBER(8) | Sim | — | Auditoria |

**Constraints:** PK_SDA_BLOQUEIO, CK_FLG_SIT IN ('A','E')
**Índices:** IDX_BLOQ_PRODUTOR (NRO_INT_PRODUTOR)
**Sequence:** SEQ_SDA_BLOQUEIO

> RN-001 usa DTH_INICIO/DTH_FIM; TXT_MOTIVO tem 400 no legado (novo usa 500).
