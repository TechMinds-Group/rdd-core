---
project: CONTATOS
module: migracao
audience: [tecnica]
status: draft
---

# Migration Plan — CONTATOS

> **Última atualização:** 21/09/2026
> **Status:** planejamento

---

## 1. Escopo da Migração

| Tabela Legada | Nova Tabela | Registros | Estratégia |
|---------------|-------------|-----------|------------|
| TB_CONTATOS | Contatos | 1500 | INSERT com mapeamento |
| TB_AGENDA | Contatos (email) | 1500 | UPDATE com JOIN |

## 2. Mapeamento Campo a Campo

| Campo Legado | Campo Novo | Transformação |
|--------------|------------|---------------|
| TB_CONTATOS.NR_TELEFONE | Contatos.Telefone | +55 e normalização (RN-001) |

## Script UP

```sql
INSERT INTO "Contatos" ("Id", "Nome", "Telefone")
SELECT gen_random_uuid(), NM_CONTATO, '+55' || NR_TELEFONE
FROM TB_CONTATOS;
```

## Script DOWN

```sql
DELETE FROM "Contatos";
```

## Cronograma

- Migração: 22/09/2026 22h
- Validação: 23/09/2026 08h
- Rollback: 23/09/2026 12h se validação falhar

## Riscos

- Volume de 1500 registros — janela de 2h suficiente
- Rollback via script DOWN — sem perda de dados legados