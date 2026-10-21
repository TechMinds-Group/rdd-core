# Issues Criadas (DRY-RUN) — Bloqueios

> Execução em modo dry-run: nenhuma issue foi criada no GitHub.
> Manifesto do que seria criado via `gh issue create` em `Acme-Group/Bloqueios-API`.

| # | Task | Issue | Link |
|---|------|-------|------|
| 1 | Implementar gestão de bloqueios sanitários (issue principal) | (dry-run) | (não criada) |
| 2 | [Bloqueios.API] RN-010-1 — Criar endpoint de listagem de bloqueios | (dry-run) | (não criada) |
| 3 | [Database] RN-010-2 — Criar estrutura de bloqueios e histórico | (dry-run) | (não criada) |

Milestone: MVP
Labels: enhancement, Backend, Database

## Estrutura das issues (derivado do RN-010 — Analise-Tecnica.md)

### 1. Issue principal

| Campo | Valor |
|---|---|
| Título | Implementar gestão de bloqueios sanitários |
| Labels | enhancement |
| Milestone | MVP |
| RNs | RN-010, RN-011, RN-012 |

### 2. Task RN-010-1: Criar endpoint de listagem de bloqueios

| Campo | Valor |
|---|---|
| Título | `[Bloqueios.API] RN-010-1 — Criar endpoint de listagem de bloqueios` |
| Labels | Backend |
| Milestone | MVP |
| RNs | RN-010 |
| Parent | Issue principal (#1 do manifesto) |

### 3. Task RN-010-2: Criar estrutura de bloqueios e histórico

| Campo | Valor |
|---|---|
| Título | `[Database] RN-010-2 — Criar estrutura de bloqueios e histórico` |
| Labels | Database |
| Milestone | MVP |
| RNs | RN-011, RN-012 |
| Parent | Issue principal (#1 do manifesto) |

## Corpo das issues (derivado do RN-010 — Analise-Funcional.md)

### Body — RN-010-1

```markdown
## Descrição
Permitir que o sistema registre, consulte e acompanhe bloqueios sanitários
aplicados a produtores, mantendo o histórico completo das alterações.

## Comportamento esperado
- O usuário consulta a lista de bloqueios em tela paginada, filtrando pelo
  nome do produtor.

## Regras de negócio
| # | Regra |
|---|-------|
| 1 | RN-010 — A listagem de bloqueios deve ser paginada e filtrável pelo nome do produtor. |

## O que fica de fora
- Cancelamento automático de bloqueios por prazo.
- Notificações ao produtor sobre bloqueios aplicados.

## RNs
- RN-010

## Referências
- RN-010 — Analise-Funcional.md
- RN-010 — Analise-Tecnica.md
- API_CONTRACTS.md
- UI_SPEC.md
- DATA_MODEL.md
```

### Body — RN-010-2

```markdown
## Descrição
Permitir que o sistema registre, consulte e acompanhe bloqueios sanitários
aplicados a produtores, mantendo o histórico completo das alterações.

## Comportamento esperado
- Toda alteração de bloqueio gera automaticamente um registro no histórico.

## Regras de negócio
| # | Regra |
|---|-------|
| 2 | RN-011 — Aplicar um bloqueio exige motivo preenchido e identificação do responsável. |
| 3 | RN-012 — Toda alteração de bloqueio registra histórico com data e autor da mudança. |

## O que fica de fora
- Cancelamento automático de bloqueios por prazo.
- Notificações ao produtor sobre bloqueios aplicados.

## RNs
- RN-011
- RN-012

## Referências
- RN-010 — Analise-Funcional.md
- RN-010 — Analise-Tecnica.md
- DATA_MODEL.md
```
