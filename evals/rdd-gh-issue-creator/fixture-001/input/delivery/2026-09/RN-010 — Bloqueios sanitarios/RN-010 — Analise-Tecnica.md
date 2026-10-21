---
project: BLOQUEIOS
module: delivery
audience: [tecnica]
status: draft
---

# RN-010 — Bloqueios sanitários

## Issue principal

- **Título:** Implementar gestão de bloqueios sanitários
- **Repositório:** `Acme-Group/Bloqueios-API`
- **Milestone:** MVP
- **RNs:** RN-010, RN-011, RN-012

## Resumo das tasks

| Task | Tipo | Repo | Descrição |
|------|------|------|-----------|
| RN-010-1 | Backend | Bloqueios.API | Endpoint paginado de listagem de bloqueios |
| RN-010-2 | Database | Bloqueios.API | Estrutura de bloqueios e histórico de alterações |

## Ordem de Execução

### Wave 1

- [ ] RN-010-2 — Database

### Wave 2

- [ ] RN-010-1 — Backend (depende de RN-010-2)

## Tasks

### RN-010-1. [Bloqueios.API] Criar endpoint de listagem de bloqueios

- **RNs:** RN-010
- **Descrição:** Implementar a consulta paginada de bloqueios por nome do produtor.
- **Referências:** `REQUIREMENTS.md`, `API_CONTRACTS.md`

### RN-010-2. [Database] Criar estrutura de bloqueios e histórico

- **RNs:** RN-011, RN-012
- **Descrição:** Criar as estruturas de persistência para bloqueios e histórico de alterações.
- **Referências:** `REQUIREMENTS.md`, `DATA_MODEL.md`
