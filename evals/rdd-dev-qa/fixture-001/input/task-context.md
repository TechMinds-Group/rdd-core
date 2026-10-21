# Contexto da task (fixture rdd-dev-qa)

- **Repo:** Acme-Group/Bloqueios-API (stack: java-quarkus, playbook mvn)
- **Task:** RN-003-1 — Endpoint PATCH /bloqueios/{id}
- **RNs em escopo:** RN-003, RN-004
- **Estratégia:** quality/TEST_STRATEGY.md exige cobertura mínima 70% e teste de contrato do erro 422
- **DoD:** quality/DEFINITION_OF_DONE.md — suíte verde + lint + cobertura

## Saída da suíte (mvn verify)

Tests run: 24, Failures: 2
- BloqueioResourceTest.testPatchBloqueioInexistente: expected 422 but was 500
- BloqueioAuditoriaTest.testLogTentativa: RN-004 sem teste correspondente