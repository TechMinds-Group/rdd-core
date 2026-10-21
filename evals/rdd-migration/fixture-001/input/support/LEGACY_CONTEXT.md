---
project: CONTATOS
module: legado
audience: [tecnica]
status: active
---

# Legacy Context — CONTATOS

## 2. Tabelas Legadas

| Tabela | Colunas | Registros |
|--------|---------|-----------|
| TB_CONTATOS | ID, NM_CONTATO, NR_TELEFONE | 1500 |
| TB_AGENDA | ID, ID_CONTATO, DS_EMAIL | 1500 |

## 3. Mapeamento para Novo Modelo

| Tabela Legada | Nova Tabela | Mapeamento |
|---------------|-------------|------------|
| TB_CONTATOS | Contatos | ID → Id, NM_CONTATO → Nome, NR_TELEFONE → Telefone |
| TB_AGENDA | Contatos | ID_CONTATO → Id (FK), DS_EMAIL → Email |