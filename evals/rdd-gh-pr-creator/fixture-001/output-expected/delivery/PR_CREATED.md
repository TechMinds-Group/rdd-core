---
project: BLOQUEIOS-SANITARIO
module: pr-criado
audience: [tecnica]
status: dry-run
---

# PR Criado (DRY-RUN) — Bloqueios Sanitários

> Execução em modo dry-run: nenhum PR foi criado no GitHub.
> Manifesto do que seria criado via `gh pr create`.

## PR

| Campo | Valor |
|---|---|
| Repo | Acme-Group/Bloqueios-API |
| Base | main |
| Head | feature/rn-002-bloqueio-duplicado |
| Título | RN-002 — Rejeitar bloqueio duplicado com BLOQ_DUPLICADO |

## Body do PR

### Descrição

Implementa a validação de duplicidade no POST /bloqueios: se o produtor
possuir bloqueio com status ativo, retorna 409 BLOQ_DUPLICADO. Inclui
teste de contrato do erro e testes negativos.

### RNs cobertas

- RN-002 ✅ (validação + erro 409)
- RN-001 ✅ (auditoria no registro — log de tentativa negada)

### Checklist

- [x] Testes verdes (mvn verify)
- [x] Lint aprovado
- [x] Código segue padrões da stack
- [x] Nenhuma spec foi editada

### Issue relacionada

Closes #12
