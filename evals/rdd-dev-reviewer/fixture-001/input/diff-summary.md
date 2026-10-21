# Diff da task (fixture rdd-dev-reviewer)

- **Repo:** Bloqueios-API — diff main...feature/rn-005-auditoria (3 arquivos)
- **Task:** RN-005-1 — Auditoria de bloqueios
- **RNs em escopo:** RN-005, RN-010

## Arquivos do diff

- src/main/java/.../BloqueioAuditoriaListener.java (novo — grava log de auditoria em criação/alteração de bloqueio) → RN-005
- src/test/java/.../BloqueioAuditoriaTest.java (novo) → RN-005
- src/main/resources/db/migration/V12__auditoria_bloqueio.sql (novo) → RN-005

## Observação

Nenhum hunk do diff corresponde à RN-010 (validação de limite de bloqueios por produtor) — RN listada na task sem mudança correspondente.