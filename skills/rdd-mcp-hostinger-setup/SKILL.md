---
name: rdd-mcp-hostinger-setup
description: >-
  Wizard de configuração do MCP oficial da Hostinger no OpenCode — servidor
  REMOTE (Streamable HTTP em https://mcp.hostinger.com) com OAuth (tokens fora
  da config, refresh via PKCE — NUNCA pedir API token no chat), instalação via
  CLI `opencode mcp add --global` (formato V2, preserva config existente),
  sign-in pelo TUI /mcps e smoke test com billing_subscriptions_list. Dá ao
  workflow a API Hostinger completa (~410 operações em 13 grupos: VPS,
  hosting, domains, dns, billing, mail, wordpress e outros) via 3 ferramentas
  (search/execute/multi-execute). Idempotente, executado por demanda;
  consumidor natural: rdd-devops. Use quando o usuário pedir "configurar MCP
  Hostinger", "mcp hostinger", "hostinger api no opencode" ou "conectar
  hostinger".
---

# rdd-mcp-hostinger-setup — Wizard de configuração do MCP oficial da Hostinger

Integra a API Hostinger ao OpenCode via MCP **remoto oficial**
(`https://mcp.hostinger.com`, Streamable HTTP) com **OAuth** — zero segredo
gerenciado pelo usuário. Consumidores: infra de VPS da organização
(`rdd-vps-setup`, `rdd-vps-troubleshoot`), gestão de domínios/DNS e
billing, via 3 ferramentas (`search`, `execute`, `multi-execute`).

Fundação knowledge-first:
`~/.config/opencode/knowledge/mcp-hostinger/KNOWLEDGE.md` (v1.0.0) — leia
antes de operar; contém as armadilhas validadas em produção (2026-10-24).

- Idempotente: pode ser reexecutado a qualquer momento — passos já satisfeitos
  são apenas confirmados.
- Escopo padrão: **GLOBAL** (`~/.config/opencode`), convenção das skills
  irmãs de MCP setup. Escopo projeto só sob pedido explícito.

## Por que remote OAuth (e não stdio local)

| Opção | Veredito | Motivo |
|-------|----------|--------|
| Remote `https://mcp.hostinger.com` + OAuth | ✅ **padrão** | Sem binário local, sem Node ≥ 24, tokens fora da config (PKCE, refresh automático), API completa em 1 server |
| stdio `@hostinger/mcp` (npm) | ❌ não padrão | Exige Node ≥ 24; credenciais locais (`%APPDATA%\\hostinger-mcp\\credentials.json`) ou `HOSTINGER_API_TOKEN` (segredo em disco). Ver Casos de borda |

## Lê (upstream)

- `~/.config/opencode/knowledge/mcp-hostinger/KNOWLEDGE.md` — base do domínio
  (versão >= 1.0.0)
- Saída de `opencode mcp list` — server `hostinger` já existe? Autenticado?
- `~/.config/opencode/opencode.jsonc` — entrada `mcp.servers.hostinger`
  (V2) e eventuais entradas legadas V1 flat (`mcp.<nome>`) para checar
  duplicidade

## Gera (downstream)

- Entrada `mcp.servers.hostinger` no opencode.jsonc global (via CLI
  `opencode mcp add` — preserva config existente)
- Credenciais OAuth gerenciadas pelo OpenCode (fora da config, sem arquivo
  escrito por esta skill)
- Seção `<!-- hostinger-mcp -->` no `AGENTS.md` do projeto (opcional —
  quando o projeto consome operações Hostinger e quer documentar as tools)

## Nunca edita

- Código de aplicações
- Entradas `mcp` de outros servers (azure-devops, playwright, figma,
  postgres, sqlite, codebase-memory-mcp) — adiciona/ajusta SOMENTE o bloco
  `hostinger`
- **NENHUM arquivo com token/credencial** — proibido escrever
  `HOSTINGER_API_TOKEN` ou credenciais OAuth em opencode.json(c), .env,
  docs, scripts, git. No modo remoto não há token em disco; no stdio, as
  credenciais do pacote (`credentials.json`) são segredo — nunca imprimir,
  logar ou comitar
- Config do OpenCode escrita à mão quando o CLI resolve — usar
  `opencode mcp add`, não editar `mcp.servers` manualmente

## 1. Pré-requisitos

- **OpenCode V2** (CLI `opencode mcp` disponível)
- **Conta Hostinger** com acesso à API (o login OAuth é feito no browser)
- **Rede** para `https://mcp.hostinger.com` e para o fluxo OAuth
- **Reinício do OpenCode** após instalar o server — config não é
  hot-reloaded

## 2. Verificar estado atual (idempotência)

```powershell
opencode mcp list
```

Interprete o estado:

| Estado | Ação |
|--------|------|
| `hostinger` não aparece | Instalar (Passo 3) |
| `⚠ hostinger  needs authentication` | Server instalado — pular para o Passo 4 (sign-in) |
| `✓ hostinger  connected` | Tudo pronto — rodar só o smoke test (Passo 5) para confirmar |

Checagem de duplicidade (V2 vs legado V1 no mesmo arquivo): se existir
`mcp.servers.hostinger` **E** `mcp.hostinger` no
`~/.config/opencode/opencode.jsonc`, manter UMA só (preferir a V2 do CLI) —
server duplicado deixa o estado ambíguo no `/mcps`.

## 3. Instalar o server (global — padrão)

```powershell
opencode mcp add hostinger --global --url https://mcp.hostinger.com
```

- Grava `mcp.servers.hostinger` no opencode.jsonc global (formato V2) e
  coexiste com entradas legadas V1 flat sem conflito.
- Timeout no add → verificar conectividade com `https://mcp.hostinger.com`
  antes de insistir.
- Escopo project-local (mesmo comando sem `--global`, na raiz do projeto)
  só se o operador pedir explicitamente.

## 4. Autenticação OAuth (sem token — nunca no chat)

1. **Confirme o estado esperado pós-add**: `opencode mcp list` mostra
   `⚠ hostinger  needs authentication` — normal, não é erro.
2. **Sign-in pelo TUI (interativo, na sessão do operador):**
   `/mcps` → selecionar `hostinger` → autorizar no browser (login
   Hostinger).
3. **Estado final esperado**: `✓ hostinger  connected` no `/mcps` e no
   `opencode mcp list`.

> ⚠️ **NUNCA rodar `opencode mcp auth hostinger` via shell tool** — o link
> de autorização pode ficar oculto em output de background process e o fluxo
> OAuth não completa. Sempre instruir o `/mcps` interativo do TUI.

- Tokens ficam fora da config: o OpenCode armazena as credenciais e faz
  refresh automático via PKCE. Zero segredo em disco gerenciado pelo usuário.
- Refazer login/trocar de conta: `opencode mcp logout hostinger` e repetir o
  sign-in pelo `/mcps`.

## 5. Smoke test (validação final)

Após **reiniciar o OpenCode** (tools `hostinger_*` no catálogo da sessão),
duas etapas — só reportar sucesso com as DUAS OK:

1. `search` encontra a operação canônica (retorna o `inputSchema`
   autoritativo):

   ```json
   { "query": "list subscriptions billing" }
   ```

   Esperado: retorna `billing_subscriptions_list` com `readOnly: true`.

2. `execute` roda a operação read-only:

   ```json
   { "operation": "billing_subscriptions_list" }
   ```

   Esperado: JSON com a lista de assinaturas da conta Hostinger.

Nunca usar operação de escrita (create/delete) no smoke test.

## 6. Relatar estado final

Checklist de fechamento do wizard:

- [ ] `mcp.servers.hostinger` no opencode.jsonc global — demais servers intactos
- [ ] Sem duplicidade V1/V2 do server `hostinger`
- [ ] `✓ hostinger  connected` (OAuth via /mcps)
- [ ] Smoke test OK (search → execute em `billing_subscriptions_list`)
- [ ] **Reinício do OpenCode pendente?** — config não é hot-reloaded
- [ ] (Opcional) seção `<!-- hostinger-mcp -->` no AGENTS.md do projeto que
      consome operações Hostinger, listando as 3 tools

## Ferramentas disponíveis

| Ferramenta | Uso | Exemplo |
|------------|-----|---------|
| `search` | Encontra operação por keyword; o `inputSchema` retornado é AUTORITATIVO — as shapes vêm daqui, nunca de memória | `{ query: "list vps" }` |
| `execute` | Roda 1 operação (params flat: path, query, body) | `{ operation: "billing_subscriptions_list" }` |
| `multi-execute` | Até 20 operações em cadeia, para na 1ª falha; `$steps.<i>.<path>` encadeia saída → entrada | criar VPS → referenciar o id no passo seguinte |

Grupos da API (~410 operações em 13): `vps`, `hosting`, `domains`, `dns`,
`billing`, `mail`, `wordpress`, `agency-hosting`, `ecommerce`,
`horizons`, `reach`, `agent-readiness`, `oss`.

Padrão de uso: `search` → ler `inputSchema` → `execute`/`multi-execute`.
Operação assíncrona (ex.: criar VPS) retorna "queued" — pollar a operação de
leitura correspondente com backoff; NUNCA reenviar a escrita.

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `needs authentication` persistente | Fluxo OAuth não completado | Refazer sign-in via `/mcps`; se falhar, `opencode mcp logout hostinger` e logar de novo |
| Server duplicado/ambíguo no /mcps | Entrada V2 (`mcp.servers.hostinger`) E V1 flat (`mcp.hostinger`) no mesmo arquivo | Manter UMA só (preferir a V2) |
| Timeout no `mcp add` | Sem rota para o server | Verificar conectividade com `https://mcp.hostinger.com` (proxy corporativo → `HTTPS_PROXY`) |
| Tools `hostinger_*` não aparecem | Sem reinício do OpenCode ou server desabilitado | Reiniciar o OpenCode; conferir `mcp.servers.hostinger` |
| 401/403 no `execute` | Sessão OAuth expirada ou conta sem permissão à operação | `opencode mcp logout hostinger` + sign-in; conferir plano/permissões na conta |
| `multi-execute` para no meio | Falha do passo N (cadeia para na 1ª falha) | Ler o erro do passo N; corrigir params e recomeçar a cadeia — passos já concluídos NÃO são reenviados |

## Modo de erro

- **OAuth não completa (browser falha): ABORTAR e reportar** — nunca pedir
  para o operador COLAR token no chat com workaround; orientar logout +
  novo sign-in.
- **Operador tenta colar token no chat/arquivo: recusar e orientar** — no
  modo remoto não existe token a colar; o modo `HOSTINGER_API_TOKEN` só
  existe no stdio (caso de borda) e memmo là o valor nunca passa pelo chat.
- **Server `hostinger` já existente:** idempotente — apenas validar estado
  (autenticação + smoke test); nunca duplicar a entrada.
- **opencode.jsonc corrompido (JSON inválido): abortar e reportar** — nunca
  reescrever o config por conta própria; pedir correiçao ao operador.
- Falha no smoke test: seguir a tabela de Troubleshooting; se persistir,
  reportar o erro exato (mensagem da tool).

## Casos de borda

- **stdio local `@hostinger/mcp` (não padrão):** pacote npm oficial com
  binários por categoria (`hostinger-vps-mcp`, `hostinger-dns-mcp`,
  `hostinger-domains-mcp`, ... ou unificado `hostinger-api-mcp`). Exige
  **Node.js ≥ 24**. Auth: OAuth PKCE do próprio pacote no 1ª tool call
  (credenciais em `%APPDATA%\\hostinger-mcp\\credentials.json` no Windows)
  ou env var `HOSTINGER_API_TOKEN` (bypassa OAuth). Só recomendar se o
  operador precisar de ferramentas por categoria isoladas ou ambiente sem
  OAuth no browser.
- **Escopo projeto:** mesmo comando sem `--global` na raiz do projeto;
  documentar as tools no AGENTS.md do projeto (segção
  `<!-- hostinger-mcp -->`).
- **Troca de conta Hostinger:** `opencode mcp logout hostinger` + novo
  sign-in — não criar segunda entrada MCP.
- **Proxy corporativo:** o transporte remoto respeita `HTTPS_PROXY`;
  configurar env var de usuário se a rede exigir.
- **CI/automação sem browser:** fora de escopo deste wizard (OAuth precisa
  de browser) — avaliar o modo stdio com `HOSTINGER_API_TOKEN` como secret
  do runner, nunca em arquivo versionado.

## Formato de commit sugerido

`feat(skills): add rdd-mcp-hostinger-setup (MCP Hostinger remote OAuth)`
