---
project: BLOQUEIOS-SANITARIO
module: definition-of-done
audience: [tecnica]
status: draft
---

# Definition of Done — Bloqueios Sanitários

> **Derivado de:** ACCEPTANCE_CRITERIA.md, TEST_STRATEGY.md

Uma task está **Done** quando todos os itens abaixo estão verificados:

## Código

- [ ] Implementação cobre os endpoints/campos da task (contrato em API_CONTRACTS.md)
- [ ] Validações de campo implementadas (obrigatoriedade, tamanhos)
- [ ] Auditoria CTR_* preenchida em toda escrita (REQUIREMENTS.md §9)

## Testes

- [ ] Cenários de aceitação da RN relacionados passam (ACCEPTANCE_CRITERIA.md)
- [ ] Teste de contrato para cada código de erro tocado pela task
- [ ] Teste negativo para regras bloqueantes (RN-002 duplicidade, RN-004 motivo obrigatório)

## Regras de Negócio

- [ ] RN-001: bloqueio registra data, hora e usuário
- [ ] RN-002: duplicidade ativa rejeitada com BLOQ_DUPLICADO (409)
- [ ] RN-003: status GTA reflete bloqueio ativo
- [ ] RN-004: encerramento registra motivo no HIST_BLOQUEIO

## Entrega

- [ ] Code review aprovado
- [ ] Sem TODO/FIXME no código da task
- [ ] Documentação (specs) atualizada se o contrato mudou
