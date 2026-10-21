---
project: CONTATOS
module: health-report
audience: [tecnica]
status: draft
generated_at: "2026-09-21T19:00:00Z"
---

# Agent Health Report — CONTATOS

> **Gerado em:** 21/09/2026 19:00

## Scores

| Componente | Score | Observação |
|---|---|---|
| Subagents | ✅ 100% | 3/3 com front matter válido |
| Skills | ✅ 100% | 5/5 com SKILL.md e registro cruzado |
| Registro cruzado | ✅ OK | Todos os agentes/skills referenciados existem |
| Portabilidade | ✅ OK | Paths relativos, sem hardcode de caminho absoluto |

## Checklist

- ✅ Front matter válido em todos os agents
- ✅ Permissões definidas (princípio do menor privilégio)
- ✅ Registro cruzado (registry.yaml ↔ agents/ + skills/)
- ✅ Portabilidade (paths relativos, sem hardcode)