═══ rdd-dev-qa — RN-003-1 Endpoint PATCH /bloqueios/{id} ═══
repo: Bloqueios-API (stack: java-quarkus)
veredito: REPROVADA
suíte: mvn verify — 22 passed / 2 failed
cobertura: 64% — piso: 70%
RNs em escopo: RN-003, RN-004 — falhas abaixo
falhas:
- BloqueioResourceTest.testPatchBloqueioInexistente — RN-003 (erro 422 esperado, obtido 500) — "expected 422 but was 500"
- BloqueioAuditoriaTest.testLogTentativa inexistente — RN-004 (auditoria sem teste) — teste ausente na suíte
arquivos modificados: nenhum (QA é read-only)
pendências: cobertura abaixo do piso da TEST_STRATEGY; corrigir no executor (rdd-dev-backend) — não ajustar teste para passar