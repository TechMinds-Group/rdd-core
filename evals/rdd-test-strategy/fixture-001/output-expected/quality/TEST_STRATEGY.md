---
project: BLOQUEIOS-SANITARIO
module: estrategia-testes
audience: [tecnica]
status: draft
---

# Estratégia de Testes — Bloqueios Sanitários

> **Derivado de:** specs/ACCEPTANCE_CRITERIA.md (RN-001..RN-004), specs/API_CONTRACTS.md, specs/ERROR_CATALOG.md, REQUIREMENTS.md

---

## 1. Objetivos

Verificar que as regras de negócio do módulo (RN-001..RN-004) comportam-se
conforme os critérios de aceitação, com cobertura especial para os casos de
erro do catálogo (BLOQ_DUPLICADO e afins).

## 2. Níveis de Teste

| Nível | Escopo | Derivado de |
|---|---|---|
| Unitário | Validações de campo (motivo ≤ 500, obrigatórios), regra de duplicidade | RN-001, RN-004 (validações de AC) |
| Integração de API | Os 4 endpoints de API_CONTRACTS.md: POST /bloqueios, GET /bloqueios, GET /bloqueios/gta-status/{id}, POST /bloqueios/{id}/encerramento | API_CONTRACTS.md |
| Teste de erro | Cada código do ERROR_CATALOG.md com request que o dispara | ERROR_CATALOG.md |
| E2E | Fluxos UC-01 (aplicar), UC-02 (consultar), UC-03 (encerrar) | REQUIREMENTS.md §7 |
| Segurança | Operador pode escrever; Consultor somente leitura (UI_SPEC §1) | REQUIREMENTS.md §2 |

## 3. Casos de Teste de Erro (do catálogo)

| Código | Request de disparo | HTTP esperado |
|---|---|---|
| BLOQ_DUPLICADO | POST /bloqueios para produtor já bloqueado | 409 |
| PRODUTOR_INEXISTENTE | POST /bloqueios com id inexistente | 404 |
| BLOQUEIO_INEXISTENTE | POST /bloqueios/{id}/encerramento com id inexistente | 404 |
| BLOQUEIO_JA_ENCERRADO | Encerrar bloqueio já encerrado | 409 |
| VALIDACAO_CAMPO | motivo vazio ou > 500 caracteres | 400 |

## 4. Dados de Teste

- Produtores fictícios (com e sem bloqueio ativo)
- Bloqueios nos 2 status (ativo, encerrado) — cobre o cenário de re-bloqueio (AC RN-002)
- Motivos nas fronteiras: vazio, 1 char, 500 chars, 501 chars

## 5. Critérios de Sucesso

- 100% dos cenários de ACCEPTANCE_CRITERIA.md automatizados
- 100% dos erros do catálogo com teste de contrato
- Nenhum cenário de regra bloqueante (RN-002, RN-003) sem teste negativo
