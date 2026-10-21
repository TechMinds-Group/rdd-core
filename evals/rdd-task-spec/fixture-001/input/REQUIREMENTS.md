# REQUIREMENTS — Módulo Bloqueios (fixture task-spec)

## 6. Dados e Campos

### RN-010 — Listagem de bloqueios

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| filtroNome | Texto (100) | Não | Filtro por nome do produtor |
| pagina | Número | Sim | Número da página |

### RN-011 — Aplicar bloqueio

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| idProdutor | Número | Sim | ID do produtor a bloquear |
| motivo | Texto (500) | Sim | Motivo do bloqueio |

### RN-012 — Histórico de bloqueios

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| dataInicio | Data | Sim | Início do período |
| dataFim | Data | Sim | Fim do período |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **BLOQUEIO** — registros de bloqueio (INSERT, SELECT)
- **HIST_BLOQUEIO** — histórico de alterações (INSERT)

### Rastreabilidade

- RN-010 → endpoint GET /bloqueios (lista)
- RN-011 → endpoint POST /bloqueios (criar)
- RN-012 → endpoint GET /bloqueios/historico