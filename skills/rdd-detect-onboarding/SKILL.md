---
name: rdd-detect-onboarding
description: >-
  Skill read-only de diagnóstico de onboarding. Verifica se o operador precisa
  de onboarding (máquina nova, sem módulos RDD, recusou anteriormente) com base
  em 5 critérios. Invocada automaticamente pelos primary agents no primeiro turno
  da sessão — não invocar manualmente.
---

# rdd-detect-onboarding — Diagnóstico de Onboarding

Skill read-only que diagnostica se o operador precisa de onboarding no primeiro
turno da sessão. Substitui o bloco inline duplicado nos 4 primary agents
(rdd-req, rdd-doc, rdd-dev, rdd-devops).

## Lê (upstream)

- `~/.config/opencode/AGENTS.md` — bloco `<!-- projeto-padrao -->`
- `<diretorio-projetos>/**/PROJECT_CHARTER.md` — módulos RDD existentes
- `~/.config/opencode/.no_onboarding` — flag de supressão (se existir)

## Gera (downstream)

- Diagnóstico no chat: "SUPRIMIDO" | "MÁQUINA NOVA" | "SEM PROJETOS" | "OPERANDO"
  + evidência (qual critério falhou/passou).

## Nunca edita

- Qualquer arquivo — skill exclusivamente read-only.
- Flag `.no_onboarding` — quem toca é o orquestrador ao receber recusa.

## Tools

- `read` — ler AGENTS.md e `.no_onboarding`
- `glob` — descobrir PROJECT_CHARTER.md
- Bash permitido apenas: `Test-Path` para `.no_onboarding`

## Algoritmo

5 critérios avaliados em ordem:

1. **Flag de supressão ativa?** `~/.config/opencode/.no_onboarding` existe e foi
   modificado há < 30 dias? → retorne **SUPRIMIDO** — não ofereça onboarding.
   Operador pode pedir manualmente.
2. **AGENTS.md legível?** bloco `<!-- projeto-padrao -->` presente?
3. **Bloco tem valor?** diretório de projetos preenchido?
4. **Projetos existem?** `glob <diretorio>/**/PROJECT_CHARTER.md` retorna 1+?
5. **Contagem de charters?** quantos módulos RDD existem?

### Veredito

| Resultado | Condição | Ação |
|-----------|----------|------|
| SUPRIMIDO | Flag `.no_onboarding` < 30 dias | Não oferecer. Operador invoca manualmente. |
| MÁQUINA NOVA | AGENTS.md ausente ou sem bloco projeto-padrao | Oferecer onboarding (área 1 → 2) |
| SEM PROJETOS | Bloco ok, 0 PROJECT_CHARTER.md | Oferecer onboarding (área 2 → 3) |
| OPERANDO | 1+ charters | Não oferecer onboarding automático. Fluxo normal. |

## Modo de erro

`warn` — se AGENTS.md não for legível, trate como MÁQUINA NOVA (default seguro).
Se o glob falhar, trate como SEM PROJETOS (não bloqueia onboarding).

## Casos de Borda

- **Flag `.no_onboarding` expirada** (> 30 dias) → ignorar a flag e reavaliar os
  outros critérios do zero.
- **Operador pediu onboarding manualmente** → chamar o orquestrador diretamente;
  esta skill não entra no caminho manual.
- **Flag corrompida** (arquivo vazio ou datas inválidas) → tratar como expirada
  e reavaliar.

## Formato de saída

```text
rdd-detect-onboarding: <SUPRIMIDO | MÁQUINA NOVA | SEM PROJETOS | OPERANDO>
Flag supressão: <ativo/expirado/ausente>
AGENTS.md: <ok/ausente/sem-bloco>
PROJECT_CHARTERs: <N>
```