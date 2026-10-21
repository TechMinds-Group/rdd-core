---
name: rdd-client-requirements
description: Generates or synchronizes CLIENT_REQUIREMENTS.md from an existing REQUIREMENTS.md, producing a business-only view for external/client audiences — stripped of technical identifiers, implementation detail, and internal-only pendencies. Use whenever REQUIREMENTS.md has been created or updated and the client-facing document needs to reflect it, whether CLIENT_REQUIREMENTS.md already exists or not.
license: MIT
compatibility: opencode
metadata:
  audience: analistas-e-devs
  workflow: documentacao-de-requisitos
---
## O que eu faço

Leio `REQUIREMENTS.md` (a fonte da verdade técnica) e gero ou atualizo `delivery/CLIENT_REQUIREMENTS.md` — uma vista filtrada e reescrita para consumo do cliente/stakeholder de negócio, sem vocabulário de implementação que deve ficar na pasta docs.

`REQUIREMENTS.md` é sempre a fonte. `CLIENT_REQUIREMENTS.md` é sempre derivado dele. Nunca edito `REQUIREMENTS.md` a partir desta skill, e nunca aceito informação nova que não esteja lá.

Ambos os documentos são versionados em Git. Para descobrir o que mudou desde a última sincronização, uso o histórico do Git sobre `REQUIREMENTS.md` (`git log` / `git diff` no arquivo) como fonte de verdade de mudança — não existe changelog interno em nenhum dos dois arquivos.

## Resolução de caminhos (IMP-011)

Os artefatos do módulo seguem a estrutura com subpastas (IMP-011):

- **Raiz:** PROJECT_CHARTER.md, CONSTITUTION.md, REQUIREMENTS.md, DECISIONS.md, CHANGELOG.md
- **`specs/`:** DATA_MODEL.md, API_CONTRACTS.md, ERROR_CATALOG.md, UI_SPEC.md, ARCHITECTURE.md, SECURITY.md, ACCEPTANCE_CRITERIA.md, USER_STORIES.md, US<NNN>.md, FIGMA_PROMPTS.md, COMPLIANCE.md
- **`quality/`:** TEST_STRATEGY.md, DEFINITION_OF_DONE.md, TRACEABILITY.md, VALIDATION_REPORT.md, PROPAGATION_STATUS.md, PROGRESS_REPORT.md
- **`delivery/`:** TASKS.md, TASKS_*.md, TASKS_AZURE_CONSOLIDADO.md, SCOPE_AGREEMENT.md, CLIENT_REQUIREMENTS.md, CLIENT_REPORT_*.md, HANDOVER_LOG.md
- **`support/`:** LEGACY_CONTEXT.md, KNOWN_ERRORS.md, MIGRATION.md, CHANGE_REQUESTS.md
- **`glossaries/`:** DEV_GLOSSARY.md, BUSINESS_GLOSSARY.md, USER_GLOSSARY.md, GLOSSARY.md
- **`docs/`:** howto/*.md e documentos auxiliares
- **`meetings/`, `contracts/`:** checkpoints (inalterados)

**Regra de fallback (transição):** ao **LER** um artefato, verifique primeiro
o caminho novo (ex: `specs/DATA_MODEL.md`); se não existir, use o caminho
legado na raiz do módulo (ex: `DATA_MODEL.md`). Ao **ESCREVER/GERAR**, use
sempre o caminho novo. Módulos ainda não migrados via `rdd-restructure`
continuam legíveis durante a transição.

## Quando me usar

Use esta skill sempre que `REQUIREMENTS.md` tiver sido criado ou atualizado e o documento voltado ao cliente precisar refletir isso. Cobre os dois casos automaticamente:

- **`CLIENT_REQUIREMENTS.md` não existe** → gero do zero a partir do `REQUIREMENTS.md` atual (salvo em `delivery/`).
- **`CLIENT_REQUIREMENTS.md` já existe** (em `delivery/` ou na raiz) → sincronizo apenas o que mudou em `REQUIREMENTS.md` desde a última sincronização, preservando o restante.

Entrada esperada: localizar e ler `REQUIREMENTS.md`. Se não existir, avise que não há fonte e pare. Se houver acesso ao repositório Git, verifique o histórico de commits do arquivo desde a data da última sincronização registrada no `CLIENT_REQUIREMENTS.md` (ver Header) para identificar precisamente o que mudou, em vez de comparar o documento inteiro do zero.

## Estrutura do CLIENT_REQUIREMENTS.md

1. **Header** — título, data da última sincronização, objetivo de negócio em 1-3 frases (sem sistemas internos, siglas técnicas ou nomes de tabelas).
2. **Scope** — o que está incluído, em linguagem de negócio.
3. **Actors and Permissions** — mantido como no `REQUIREMENTS.md`.
4. **Business Rules** — reescritas sem identificadores técnicos e sem os IDs internos (`RN-XXX`) visíveis no corpo do texto — ver regras de filtragem abaixo.
5. **Use Cases** — fluxos do ponto de vista de quem usa, sem falar em módulos, camadas, ou arquitetura interna.
6. **Outputs** — documentos, comunicações ou resultados visíveis ao cliente.
7. **Data Guarantees** — "Persistence and Audit" reescrito em garantia de negócio, sem tabelas, chaves ou estrutura de banco.
8. **Decisions and Out of Scope** — mantido como no `REQUIREMENTS.md`.
9. **Open Questions for the Client** — apenas pendências (`PEND-XXX`) que dependem de decisão ou resposta do cliente. Pendências técnicas internas não entram — ver regra de triagem.
10. **Summary of Changes** — resumo em linguagem de negócio do que mudou desde a última sincronização, derivado do histórico de Git sobre `REQUIREMENTS.md`, não de um changelog manual.

Omita uma seção se não houver conteúdo correspondente relevante ao cliente.

## Regras de filtragem e reescrita

- **Nunca inclua identificadores técnicos.** Campo, tabela, enum, classe, endpoint, ou qualquer coisa em `code formatting` no `REQUIREMENTS.md` vira linguagem natural de negócio aqui.
- **Nunca exponha os IDs internos (`RN-XXX`, `PEND-XXX`) no corpo do texto do cliente** — eles são instrumentação interna de rastreabilidade, não algo que o cliente precisa ver. Internamente (nos seus próprios registros de trabalho, se precisar rastrear a correspondência), pode manter a referência, mas não no arquivo entregue ao cliente.
- **Nunca inclua arquitetura interna** — módulos, camadas, serviços, integrações técnicas.
- **Preserve o significado da regra, não a forma.** Remover jargão técnico não pode enfraquecer nem simplificar demais a regra em si.
- **Triagem de pendências:** para cada `PEND-XXX`, pergunte "isso depende de decisão do cliente, ou é escolha técnica que o time resolve sozinho?". Só o primeiro tipo entra em "Open Questions for the Client". Na dúvida, não inclua.

## Regras de sincronização

- **Não regenere o documento inteiro a cada sincronização.** Use o histórico do Git sobre `REQUIREMENTS.md` desde a última sincronização para identificar exatamente quais regras/seções mudaram, e atualize só essas.
- **Mudança técnica sem efeito percebido pelo cliente** não gera alteração no `CLIENT_REQUIREMENTS.md` nem entra em "Summary of Changes".
- **Pendência resolvida em `REQUIREMENTS.md`:** se estava em "Open Questions for the Client" e agora tem decisão registrada como Business Rule, mova para a seção definitiva e remova de pendências.
- **Nunca deixe o `CLIENT_REQUIREMENTS.md` divergir silenciosamente do `REQUIREMENTS.md`.** Se uma regra mudou na fonte, a versão do cliente reflete a nova regra, e isso aparece no Summary of Changes.
- Se a mudança em `REQUIREMENTS.md` for ambígua quanto a impactar ou não a experiência do cliente, pergunte antes de decidir incluir ou omitir.

## Saída esperada

Produza **o arquivo `delivery/CLIENT_REQUIREMENTS.md` completo**, pronto para salvar ou substituir o anterior — não um diff. Não inclua meta-comentário sobre o processo de triagem no corpo do documento (o "Summary of Changes" é a única exceção, por ser parte do arquivo). Ao final da resposta, sugira uma mensagem de commit objetiva (ex. `docs: sync CLIENT_REQUIREMENTS.md with vaccination age rule update`). Se `REQUIREMENTS.md` não puder ser localizado, informe isso e não prossiga.

## Lê (upstream)

- `REQUIREMENTS.md` (raiz do módulo) — fonte única da verdade técnica
- Histórico Git sobre `REQUIREMENTS.md` (`git log` / `git diff`) — delta desde a última sincronização
- `delivery/CLIENT_REQUIREMENTS.md` (ou raiz, pré-IMP-011) — versão anterior para sync

## Gera (downstream)

- `<modulo>/<projeto>/delivery/CLIENT_REQUIREMENTS.md` — cria do zero ou sincroniza apenas o que mudou

## Nunca edita

- `REQUIREMENTS.md` — fonte, somente leitura
- Artefatos técnicos de spec (DATA_MODEL.md, API_CONTRACTS.md, TASKS.md, etc.)
- Config do OpenCode (AGENTS.md, opencode.jsonc, skills, agents)

## Tools

- `read`/`glob`/`grep` — localizar e ler REQUIREMENTS.md e artefatos do módulo
- `bash` — git log/diff sobre REQUIREMENTS.md para identificar o delta
- `write`/`edit` — gravar `delivery/CLIENT_REQUIREMENTS.md`

## Modo de erro

`strict` — sem `REQUIREMENTS.md` localizável, informe e não prossiga; mudança ambígua quanto a impacto no cliente → `warn` (pergunte antes de incluir ou omitir).

## Algoritmo

1. Localize e leia `REQUIREMENTS.md` do módulo — sem ele, informe e encerre (Modo de erro)
2. Identifique o delta: com Git, use `git log`/`git diff` sobre `REQUIREMENTS.md` desde a data registrada no Header do `CLIENT_REQUIREMENTS.md`; sem Git, compare o documento inteiro
3. Reescreva o conteúdo em linguagem de negócio aplicando as regras de filtragem (sem identificadores técnicos, IDs internos ou arquitetura interna)
4. Faça a triagem das pendências (`PEND-XXX`) — só as que dependem de decisão do cliente entram em "Open Questions for the Client"
5. Aplique as regras de sincronização: atualize apenas o que mudou; Summary of Changes coerente com o delta
6. Escreva `delivery/CLIENT_REQUIREMENTS.md` completo

## Formato de commit

```
docs: sync CLIENT_REQUIREMENTS.md (<modulo>)
```

## Casos de Borda

- **CLIENT_REQUIREMENTS.md inexistente** — gere do zero a partir do REQUIREMENTS.md atual.
- **CLIENT_REQUIREMENTS.md na raiz (pré-IMP-011)** — sincronize e reloqueie para `delivery/`.
- **Mudança técnica sem efeito percebido pelo cliente** — não altera o documento nem o Summary of Changes.
- **PEND técnica interna** — não entra em "Open Questions for the Client" (regra de triagem).
- **PEND resolvida** — mova para a seção definitiva e remova das pendências.
