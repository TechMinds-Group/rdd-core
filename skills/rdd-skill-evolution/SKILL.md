---
name: rdd-skill-evolution
description: >-
  Evolui skills do workflow baseado em aprendizados acumulados de múltiplos
  projetos. Analisa retrospectivas, identifica padrões recorrentes e propõe
  mudanças em skills existentes. Valida mudanças com rdd-skill-eval antes
  de aplicar. Use quando o usuário pedir "evoluir skills", "aprimorar
  baseado em experiência", "melhorar workflow", ou após múltiplas
  retrospectivas com ações recorrentes.
---
# rdd-skill-evolution — Evolução de Skills por Experiência

Evolui skills do workflow baseado em aprendizados acumulados de
múltiplos projetos. Identifica padrões recorrentes nas retrospectivas
e aplica melhorias validadas.

## Lê (upstream)

- `docs/projects/*/RETROSPECTIVE.md` — ações de melhoria de cada projeto
- `_docs/patterns/INDEX.md` — padrões acumulados (repo de docs:
  `repo_docs_rdd` no AGENTS.md — IMP-061)
- `_docs/METRICS.md` — tendências de qualidade (repo de docs: `repo_docs_rdd`)
- Skills existentes (read-only) — para propor mudanças

## Gera (downstream)

- Skills editadas (com mudanças aplicadas)
- `WORKFLOW_IMPROVEMENTS.md` — IMPs registrados para cada mudança
- Relatório de evolução

## Nunca edita

- Retrospectivas (read-only)
- `DECISIONS.md` (APENAS se a mudança requer novo ADR)
- Código-fonte de projetos

## Tools

- `read`/`glob`/`grep` — analisar retrospectivas e skills
- `edit` — aplicar mudanças em skills
- `skill` — invocar rdd-skill-eval para validar
- `question` — confirmar mudanças com usuário

## Modo de erro

`interativo` — todas as mudanças requerem confirmação do usuário
antes de serem aplicadas. Nunca aplique mudanças automaticamente.

## Workflow

### Passo 1 — Agregar ações de melhoria

Leia todas as retrospectivas:
```
docs/projects/*/RETROSPECTIVE.md
```

Extraia a seção "Ações para o workflow" de cada uma.

### Passo 2 — Identificar padrões recorrentes

Agrupe as ações por tipo:
- **Skills a melhorar** — mesma skill mencionada em 2+ retrospectivas
- **Novos patterns** — padrões que surgiram em 2+ projetos
- **Checklists a ajustar** — verificações que faltaram
- **Novas skills necessárias** — funcionalidades não atendidas

### Passo 3 — Priorizar

| Ocorrências | Prioridade | Ação |
|-------------|------------|------|
| 1 | baixa | Registrar, observar |
| 2 | média | Priorizar para próxima melhoria |
| 3+ | alta | Aplicar imediatamente |

### Passo 4 — Propor mudanças

Para cada ação prioritária, proponha mudança específica:

```
══ Evolução de Skills ═══

Padrão detectado: <descrição>
Ocorrências: N projetos (<lista>)
Skill afetada: rdd-<skill>
Mudança proposta: <o que mudar>
Impacto: <baixo|médio|alto>

Aplicar esta mudança? [sim/não/adiar]
```

### Passo 5 — Aplicar (com validação)

Se o usuário aprovar:

1. **Ler a skill atual** — entender o contexto
2. **Aplicar a mudança** — via `edit`
3. **Rodar evals** — invocar `rdd-skill-eval --skill <skill>` para
   validar que a mudança não quebrou fixtures existentes
4. **Se FAIL:** reverter e reportar
5. **Se PASS/WARN:** manter mudança

### Passo 6 — Registrar IMP

Para cada mudança aplicada, registre em `WORKFLOW_IMPROVEMENTS.md`:

```markdown
## IMP-XXX — <título curto>

- **Data:** DD/MM/AAAA
- **Alvo:** `rdd-<skill>`
- **Problema:** <o que faltava na skill>
- **Causa raiz:** <categoria>
- **Correção:** <o que foi alterado>
- **Projetos que motivaram:** <lista>
- **Arquivos:** <caminhos editados>
- **Status:** aplicada
```

### Passo 7 — Reportar

```text
══ rdd-skill-evolution — relatório ═══

projetos analisados: N
padrões recorrentes: N
skills evoluídas: N
IMPs registrados: N
avaliadas (3+ ocorrências): N
```


### Revisão de calibração Jev (periódico — IMP-100)

A cada ciclo de evolução (ou sob demanda: "revisar calibração Jev"):

1. Leia `evals/jev-calibration.md` (append-only).
2. Calcule a **taxa de concordância** = Y / total (entradas `N→Y` contam
   como Y quando a correção foi de causa — o julgamento apontava problema
   real).
3. Calcule a **tendência** de over/under-confidence por faixa de p
   (p médio dos Y vs p médio dos N).
4. Inclua o resultado no relatório da evolução:

   ```text
   Calibração Jev: N julgamentos, concordância 0.XX (faixa p: ...)
   Tendência: calibrado | over-confidence | under-confidence
   ```

5. **Se concordância < 0.7:** recomende reavaliar os prompts/criteria que
   usam Jev (como as skills consomem o veredito), NUNCA ajustar o modelo.
## Lógica de Decisão

### Quando EVOLUIR uma skill

- 3+ projetos reportaram o mesmo problema
- 3+ projetos pediram a mesma funcionalidade
- Métricas mostram tendência de queda na mesma área
- Pattern library documenta padrão que a skill não cobre

### Quando NÃO evoluir

- Apenas 1 projeto reportou (pode ser caso isolado)
- Mudança contradiz decisão ADR existente
- Mudança quebraria compatibilidade com projetos anteriores
- Mudança muito específica para um projeto (não reutilizável)

### Quando criar NOVA skill

- Nenhum skill existente atende a necessidade
- A necessidade é transversal (não específica de uma stack)
- 3+ projetos reportaram a mesma lacuna

## Casos de Borda

- **Mudança que contradiz ADR:** não aplique — registre como
  "proposta de novo ADR" e encaminhe para decisão
- **Mudança que quebra evals:** não aplique — reporte qual eval
  quebrou e sugira ajuste
- **Múltiplas mudanças na mesma skill:** aplique uma vez,
  agrupando todas as mudanças
- **Projeto muito antigo:** descarte retrospectivas com > 1 ano
- **Sem retrospectivas disponíveis:** reporte
  `needs-retrospective.` — execute `rdd-project-retrospective` primeiro

## Formato de commit

```
feat(quality): evolve <skill-name> — baseado em N projetos de experiência
```
