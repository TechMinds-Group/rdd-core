# Diff da task (fixture rdd-dev-reviewer — eixo compliance IMP-102)

- **Repo:** VibeCut-APP — diff main...feature/rn-002-exclusao-conta (4 arquivos)
- **Task:** RN-002-1 — Exclusão de conta
- **RNs em escopo:** RN-002
- **Charter:** compliance: true — specs/COMPLIANCE.md presente

## Arquivos do diff

- src/.../ContaService.java (novo - exclui USUARIO e dados associados após carência de 30 dias) — RN-002
- src/.../ContaController.java (novo - endpoint DELETE /conta) — RN-002
- src/test/java/.../ContaServiceTest.java (novo) — RN-002

## Observação compliance

specs/COMPLIANCE.md (eixo 6 — Direitos do titular) exige que a exclusão
grave registro da solicitação do titular (quem pediu, quando). O diff
grava EXCLUIDO_EM mas não registra a solicitação do titular — item
aplicável do checklist violado.