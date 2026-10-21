# FIGMA_TASKS_HANDOFF.md — Salon/Agendamento

Handoff gerado pela skill rdd-figma-tasks. Insumo para o rdd-task-spec
(geração de delivery/<YYYY-MM>/RN-NNN — <título>/ — IMP-040).

## 2026-10-07 12:00 — Figma Salon — Protótipo Agendamento (frame "Agendamentos v2")

- **Fonte:** fallback — notas do operador (FIGMA_DESIGN_NOTES.md); MCP Figma indisponível nesta execução
- **Delta de UI_SPEC:** proposto (ver abaixo)

### Features candidatas

| Feature | RN-âncora (sugerida) | RNs do escopo | Repo frontend | Status |
|---|---|---|---|---|
| Filtro e detalhe do agendamento | RN-010 | RN-010, RN-011, RN-012, (proposta: RN de reagendamento) | Salon.MFE | pronto |

### Delta proposto (não aplicado)
- Tela Lista de Agendamentos: adicionar filtro por status (Todos / Próximos / Cancelados) e exibir o nome do animal no card
- Tela Novo Agendamento: adicionar campo "Observações" (texto livre, opcional)
- Nova tela Detalhe do Agendamento: dados completos do agendamento com botões Cancelar (RN-012) e Reagendar

### Propostas de RN/CR
- **(proposta) RN de UI:** O tutor deve poder reagendar um agendamento futuro para outra data/horário — origem: botão "Reagendar" na tela Detalhe do Agendamento (extrapola requisitos confirmados)
- **CR sugerido:** nenhum — nenhuma RN confirmada foi alterada pelo design

### Gaps (RN confirmada sem design)
- RN-012 — o design apresenta o cancelamento apenas como botão, sem tela/estado de confirmação

### Próximo passo
Invocar o rdd-task-spec com este handoff (via @rdd-quality-orchestrator ou demanda direta):
gerar delivery/<YYYY-MM>/RN-010 — Filtro e detalhe do agendamento/ (Analise-Funcional + Analise-Tecnica).
A RN proposta de reagendamento precisa ser registrada antes (rdd-requirements) para entrar no escopo.