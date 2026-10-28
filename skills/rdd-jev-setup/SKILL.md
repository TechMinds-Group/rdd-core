---
name: rdd-jev-setup
description: >-
  Wizard de verificação do runtime Jev (TypeSafe System One) para o workflow
  RDD — confirma a presença da tool `jev_classify` no catálogo da sessão,
  executa smoke test com input trivial (resposta JSON tipada com
  probabilidades = runtime funcional) e, se ausente, diagnostica a causa
  (plugin jev-tool.js ausente no runtime OU TYPESAFE_API_KEY não definida)
  e registra pendência NÃO bloqueante (padrão IMP-080) com a remediação
  correta — copiar `plugins/jev-tool.js` (versionado no core desde
  28/10/2026) e/ou criar a key em console.typesafe.ai/keys — listando os
  consumidores que degradam para fallback (rdd-decision-audit,
  rdd-quality-gates, rdd-prompt-gate). Idempotente e executado por demanda;
  delegado pelo rdd-setup (Passo 5d). Use quando o usuário pedir
  "configurar o jev", "setup jev", "verificar o jev" ou reportar
  "jev_classify ausente".
---
# rdd-jev-setup — Wizard de Verificação do Runtime Jev (TypeSafe System One)

Setup do runtime Jev para o workflow RDD: confirma que a tool `jev_classify`
está disponível na sessão, valida com smoke test e, se ausente, diagnostica
a causa e registra pendência NÃO bloqueante com a remediação correta. O Jev
é a segunda camada semântica das skills (julgamentos tipados
probability-aware — contradições no rdd-decision-audit, severidade no
rdd-quality-gates, qualificação de prompt no rdd-prompt-gate). Idempotente —
pode ser reexecutado; nada é instalado nem gravado.

## Ground truth (investigação de 28/10/2026 — revisada no mesmo dia; NÃO reabrir sem evidência nova)

A tool `jev_classify` é registrada por um **plugin OpenCode local**. Primeira
investigação (incompleta — não varreu `plugins/`) concluiu "session-provided
sem rota local"; a revisão com o operador encontrou a peça faltante:

| Camada | Evidência |
|--------|-----------|
| **Plugin OpenCode** | `plugins/jev-tool.js` — API de plugins V2 (`Plugin.define` + `ctx.tool.transform`); auto-carregado do diretório `plugins/` (por isso NÃO aparece no bloco `mcp` do `opencode.jsonc` — causa do falso negativo da 1ª busca) |
| **Transporte** | **Não é MCP** — chamada HTTPS direta: `POST https://api.typesafe.ai/v1/systemone`, body `{ state, model: "jev-latest", questions }` (`jev-latest` → `jev-1.14.0` server-side) |
| **Credencial** | env var `TYPESAFE_API_KEY` (Bearer; key em `console.typesafe.ai/keys`) — NUNCA logada nem versionada |
| **Distribuição** | `plugins/` versionado no core e publicado no subset público desde 28/10/2026 (decisão do operador) — adotadores recebem o plugin; a key é individual |

**Consequência de design:** a remediação de runtime ausente é **real e
local** — os dois diagnósticos possíveis são (a) plugin ausente no runtime →
copiar `plugins/jev-tool.js` (vem com o core) e reiniciar o OpenCode;
(b) `TYPESAFE_API_KEY` não definida → criar a key e gravar a env var
(User-scope). NUNCA logar nem versionar a key. Não existe MCP server Jev —
NUNCA inventar entry no `opencode.jsonc`.

## Diferenciação

| Componente | Escopo |
|------------|--------|
| `rdd-jev-setup` (esta) | Valida o **runtime** (presença da tool + smoke test); thin wizard — NÃO embute conhecimento de uso do Jev |
| `@rdd-jev-classifier` (subagent) | **Consumidor** — classificação calibrada para skills do domínio Requisitos/Dev (segunda camada de validação) |
| `rdd-typesafe-ai` (skill) | Conhecimento de domínio TypeSafe — construir software com unidades de IA (System One, Jev); cita docs vivas |
| `rdd-setup` | Delegador — chama esta skill no Passo 5d (só quando a tool está ausente na sessão) |

Espelho do `rdd-aws-setup` (que valida acesso AWS): mesmo padrão thin wizard
— valida, não instala.

## Lê (upstream)

- `plugins/jev-tool.js` — referência do mecanismo (plugin que registra a
  tool; fonte da remediação — versão do core, 28/10/2026)
- Ambiente: presença da env var `TYPESAFE_API_KEY` (o executor confirma;
  NUNCA imprime o valor)
- Catálogo de tools da sessão — presença da tool `jev_classify` (o executor
  confirma no catálogo disponível à sessão)
- Resposta do smoke test — JSON tipado (`model`, `answers` com
  type/choice/confidence/probabilities) = runtime funcional

## Gera (downstream)

- Relatório textual compacto (não persiste arquivo): status do runtime,
  resultado do smoke test, consumidores ok/degradados
- Nada é instalado, gravado ou editado — ausência vira pendência no relatório
  do chamador (rdd-setup, Passo 6), nunca artefato

## Nunca edita

- `opencode.jsonc` — NUNCA adiciona MCP server jev/typesafe (o Jev não é
  MCP — é plugin; inventar entry quebraria o startup do OpenCode)
- `plugins/jev-tool.js` — lê como referência; NUNCA edita o plugin
- `TYPESAFE_API_KEY` — NUNCA imprime, loga, comita ou grava o valor; só
  orienta o operador a defini-la
- Artefatos de módulo RDD e código de aplicações
- Remote — nunca commita nem push

## Tools

- Catálogo de tools da sessão (detecção: `jev_classify` presente?)
- Tool `jev_classify` (smoke test com input trivial — Passo 2)
- `question` (perguntas AGRUPADAS — IMP-043; só se o operador pedir algo fora
  do escopo, ex.: "instalar" → explicar o ground truth)
- `read` (opcional: re-verificar o ground truth se o operador duvidar —
  opencode.jsonc e busca em arquivo; NUNCA editar)

## Modo de erro

`strict` nos passos próprios: a detecção deve ser confirmada no catálogo de
tools (não presumida) e o smoke test deve retornar JSON tipado para declarar
o runtime funcional. **Exceção obrigatória:** ausência do runtime é
PENDÊNCIA, não erro — registra no relatório com a remediação correta e
segue (padrão IMP-080); o setup do RDD nunca bloqueia por Jev ausente.

## Formato de commit

Nenhum — este wizard não edita artefatos versionados e nunca commita.

## Algoritmo

### Fluxo síncrono (obrigatório)

```
Passo 1 (detecção) → Passo 2 (smoke test) → Passo 3 (pendência, se ausente) → Passo 4 (relatório)
                          ↓ presente                ↓ ausente
                     [valida JSON tipado]    [registra e segue]
```

### Passo 1 — Detecção

Confirme no catálogo de tools da sessão se a tool `jev_classify` está
disponível. O executor confirma diretamente no catálogo — não há como
instalar por arquivo (ground truth acima).

| Estado | Ação |
|--------|------|
| Presente | siga ao Passo 2 (smoke test) |
| Ausente | pule ao Passo 3 (pendência) |

### Passo 2 — Smoke test (runtime presente)

Invoque `jev_classify` com input trivial:

- **text:** `O sistema rejeitou o cadastro por CPF inválido`
- **questions:** `{"gravidade":{"type":"choice","criteria":{"alta":"Alta","baixa":"Baixa"}}}`

**Interpretação da resposta:**

| Resposta | Veredito |
|----------|----------|
| JSON tipado (`model` + `answers.gravidade` com `type: choice`, `choice` e `probabilities`) | ✓ runtime funcional |
| Erro, vazio ou resposta sem estrutura tipada | ⚠️ runtime presente mas degradado — registre o erro cru no relatório e trate como pendência (Passo 3) |

NUNCA envie dado de cliente/real no smoke test — input trivial de teste,
sempre.

### Passo 3 — Runtime ausente (ou degradado): diagnóstico + pendência NÃO bloqueante

Diagnostique a causa na ordem — as duas falhas são independentes:

| Check | Diagnóstico | Remediação |
|-------|-------------|------------|
| `plugins/jev-tool.js` existe no runtime? | Plugin ausente → a tool não é registrada | Copiar `plugins/jev-tool.js` do core para o `plugins/` do runtime e **reiniciar o OpenCode** |
| `TYPESAFE_API_KEY` definida (User-scope)? (o executor confirma presença; NUNCA imprime o valor) | Key ausente → a tool falha ao executar | Operador cria a key em `console.typesafe.ai/keys` e grava a env var User-scope; NUNCA logar/comitar o valor |

Registre pendência no relatório (padrão IMP-080) com o diagnóstico encontrado
e a remediação correspondente + a nota de fallback:

> skills consumidoras degradam para fallback sem Jev (opinião do modelo)

Liste os consumidores afetados:

| Consumidor | Uso do Jev | Sem Jev |
|------------|-----------|---------|
| `rdd-decision-audit` | valida contradições semânticas em DECISIONS.md | pula a segunda camada; auditoria estrutural segue |
| `rdd-quality-gates` | triagem de severidade de findings | severidade por opinião do modelo |
| `rdd-prompt-gate` | julgamento tipado do prompt do operador | faixas por heurística |

Depois SIGA — a pendência não bloqueia o chamador (rdd-setup segue ao Passo 6).

### Passo 4 — Relatório compacto

```text
═══ rdd-jev-setup — <RESULTADO> ═══

Runtime Jev: ✓ presente (jev_classify na sessão) | ✗ ausente — pendência NÃO bloqueante
Smoke test: ✓ JSON tipado (model <versão>, choice + probabilities) | ⚠️ <erro> | — não executável (tool ausente)
Consumidores: ok/degradados — rdd-decision-audit, rdd-quality-gates, rdd-prompt-gate

Diagnóstico (se ausente): <plugin jev-tool.js ausente — copiar do core e reiniciar
| TYPESAFE_API_KEY não definida — criar em console.typesafe.ai/keys e gravar a env var
User-scope> (NUNCA logar/comitar o valor). Skills consumidoras degradam para
fallback sem Jev.

Próximo passo sugerido: continuar o rdd-setup (Passo 6 — validação de
ambiente), ou seguir a sessão (Jev ausente não bloqueia).
```

## Casos de Borda

- **Re-execução (idempotente):** runtime presente revalida o smoke test e
  devolve o mesmo relatório — nada muda no ambiente.
- **Operador pede "instalar o Jev":** oriente a rota real — o plugin
  `plugins/jev-tool.js` já vem com o core (versionado desde 28/10/2026);
  se a tool não aparece na sessão, verifique o arquivo no runtime e a env
  var `TYPESAFE_API_KEY` (key em `console.typesafe.ai/keys`), depois
  reinicie o OpenCode. NUNCA invente MCP server no `opencode.jsonc` (o Jev
  não é MCP — é plugin).
- **Smoke test falha com tool presente:** runtime degradado — pendência com
  o erro cru reportado; consumidores afetados idem Passo 3.
- **Delegado pelo rdd-setup (Passo 5d):** ao concluir, retorne o relatório
  para o wizard pai seguir ao Passo 6 — a pendência (se houver) entra no
  relatório final do setup.
- **Jev ausente em sessão de consumo:** skills consumidoras
  (rdd-decision-audit, rdd-quality-gates, rdd-prompt-gate) já possuem
  fallback — esta skill apenas diagnostica; não reconfigure nada.