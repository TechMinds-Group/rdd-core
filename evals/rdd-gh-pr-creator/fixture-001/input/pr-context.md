# Contexto do PR (fixture gh-pr-creator)

- **Repo:** Acme-Group/Bloqueios-API
- **Branch head:** feature/rn-002-bloqueio-duplicado
- **Base:** main
- **Issue relacionada:** #12
- **Título sugerido:** RN-002 — Rejeitar bloqueio duplicado com BLOQ_DUPLICADO

## Descrição

Implementa a validação de duplicidade no POST /bloqueios: se o produtor
possuir bloqueio com status ativo, retorna 409 BLOQ_DUPLICADO. Inclui
teste de contrato do erro e testes negativos.

## RNs cobertas

- RN-002 ✅ (validação + erro 409)
- RN-001 ✅ (auditoria no registro do bloqueio negado — log de tentativa)

## Checklist

- [x] Testes verdes (mvn verify)
- [x] Lint aprovado
- [x] Código segue padrões da stack
- [x] Nenhuma spec foi editada
