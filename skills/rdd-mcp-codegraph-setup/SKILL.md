---
name: rdd-mcp-codegraph-setup
description: >-
  Wizard de configuração do MCP codebase-memory-mcp (DeusData — grafo de
  conhecimento de código via tree-sitter + Hybrid LSP) no OpenCode — detecta
  instalação existente (idempotente), baixa a release oficial com verificação
  OBRIGATÓRIA de supply-chain (SHA-256 do checksums.txt + gh attestation
  verify SLSA L3 + scan Windows Defender), configura MANUALMENTE no
  opencode.jsonc global (escopo corrente desta máquina — servidor agnóstico a
  repo, decisão do operador 2026-10-23; escopo de projeto só se pedido;
  install.ps1 NUNCA executado) e valida com smoke test. Use quando o usuário
  pedir "configurar MCP codegraph",
  "setup codebase-memory", "codegraph mcp", "grafo de código via MCP",
  "indexar repo no grafo" ou "codebase-memory-mcp".
---

# rdd-mcp-codegraph-setup — Wizard de configuração do MCP codebase-memory-mcp

Grafo de conhecimento de código via MCP (tree-sitter + Hybrid LSP, binário C
único, MIT) para engenharia reversa assistida. **Postura adotada no RDD: o grafo
é complemento determinístico do grep (P-01 da base reverse-engineering) — nunca
substitui a matriz de padrões por stack.**

Fundação knowledge-first:
`~/.config/opencode/knowledge/reverse-engineering/KNOWLEDGE.md` §"Ferramenta
validada — codebase-memory-mcp (piloto 2026-10-23)" — leia essa seção antes de
operar; ela contém os ganhos medidos e as limitações canônicas.

- Repo canônico: **DeusData/codebase-memory-mcp** — NUNCA `elarsaks/` (espelho
  com 0 stars; desconfiar de forks não oficiais).
- Versão validada no piloto: **v0.12.1** (produto .NET do cliente: 5.832 nodes /
  25.322 edges em 8,5s).
- **`install.ps1` NUNCA é executado** — o installer escreve em configs de
  agentes automaticamente (decisão de segurança do piloto). Config MCP manual
  apenas.
- Idempotente: segunda execução revalida e reporta "já configurado".

## Lê (upstream)

- `~/.config/opencode/knowledge/reverse-engineering/KNOWLEDGE.md` — base do
  domínio (versão >= 1.1.0; seção da ferramenta validada)
- `%LOCALAPPDATA%\Programs\cbm\codebase-memory-mcp.exe` (Windows) ou
  `~/.local/bin/codebase-memory-mcp` (Linux/Mac) — binário já instalado?
- `~/.config/opencode/opencode.jsonc` (escopo corrente) ou
  `.opencode/opencode.json` do projeto (se escopo projeto) — entrada
  `mcp.codebase-memory-mcp` já existe?
- Release latest do GitHub DeusData via `gh release view` (tag + assets)

## Gera (downstream)

- Bloco `mcp.codebase-memory-mcp` no `opencode.jsonc` global (escopo corrente)
  ou no `.opencode/opencode.json` do projeto (se escopo projeto)
- Binário em `%LOCALAPPDATA%\Programs\cbm\` (Windows) ou `~/.local/bin/`
  (Linux/Mac)
- Cache derivado `~/.cache/codebase-memory-mcp/` — **contém o grafo do código
  indexado (dado derivado do código do cliente — tratar sob LGPD; ver
  Uninstall)**

## Nunca edita

- Qualquer outra coisa do config global `~/.config/opencode/opencode.jsonc`
  (permission, plugins, demais servers) — edita SOMENTE o bloco
  `mcp.codebase-memory-mcp`; escopo global só com decisão explícita do
  operador (corrente nesta máquina desde 2026-10-23)
- Entradas `mcp` de outros servers (azure-devops, playwright, figma, sqlite,
  postgres) — edita SOMENTE o bloco `codebase-memory-mcp`
- **Executa `install.ps1` do projeto — NUNCA** (escreve em configs de agentes
  automaticamente)
- Código de aplicações e artefatos de módulo RDD
- `agents/*.md` — esta skill NÃO habilita permissão `mcp.*` em
  `@rdd-reverse-orchestrator` (tarefa separada do improver/builder)
- `evals/golden-human/`

## 1. Pré-requisitos

- **gh CLI autenticado** (release view + attestation verify)
- **Windows amd64** ou Linux/Mac (arm64 → Casos de borda)
- **Rede** para `github.com` (release, checksums, attestation)
- **Reinício do OpenCode** após editar config — não é hot-reloaded

## 2. Estado atual (idempotência)

**Passo 1 — binário:**

```powershell
Test-Path "$env:LOCALAPPDATA\Programs\cbm\codebase-memory-mcp.exe"
# Linux/Mac: test -x ~/.local/bin/codebase-memory-mcp
```

Binário presente → pular para o Passo 3 (revalidação de versão) e checar o
Passo 4.

**Passo 2 — config:** o bloco `mcp.codebase-memory-mcp` já existe no
`opencode.jsonc` global (escopo corrente) ou no `.opencode/opencode.json` do
projeto (se escopo projeto) com `"enabled": true`?

- Binário + config OK → pular para o Passo 5 (smoke test) e reportar
  "já configurado".
- Ambos OK inclusive smoke test → encerrar com checklist preenchido.

## 3. Baixar e verificar supply-chain (OBRIGATÓRIO — modo erro strict)

Se o binário não existir. Modo guiado — o operador executa; a skill sugere os
comandos. **NUNCA extrair/instalar antes das 3 verificações verdes.**

```powershell
# 1. Descobrir a release latest oficial (DeusData — NUNCA elarsaks)
gh release view --repo DeusData/codebase-memory-mcp --json tagName,assets |
  ConvertFrom-Json

# 2. Baixar asset + checksums para o Temp
$dst = "$env:TEMP\cbm"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
$tag = '<tag-da-release>'            # ex.: v0.12.1
$asset = '<codebase-memory-mcp_windows_amd64.zip>'   # nome exato do asset
$base = "https://github.com/DeusData/codebase-memory-mcp/releases/download/$tag"
Invoke-WebRequest "$base/$asset" -OutFile "$dst\$asset"
Invoke-WebRequest "$base/checksums.txt" -OutFile "$dst\checksums.txt"

# 3a. SHA-256 vs checksums.txt — mismatch = ABORTAR
$expected = (Get-Content "$dst\checksums.txt" |
  Select-String [regex]::Escape($asset)).Line.Split(' ')[0]
$actual = (Get-FileHash "$dst\$asset" -Algorithm SHA256).Hash.ToLower()
if ($expected.ToLower() -ne $actual) { throw 'SHA256 mismatch — NÃO instalar.' }

# 3b. Attestation SLSA — falha = ABORTAR
gh attestation verify "$dst\$asset" `
  --repo DeusData/codebase-memory-mcp `
  --signer-workflow "DeusData/codebase-memory-mcp/.github/workflows/_build.yml"

# 3c. Windows Defender — detecção = ABORTAR
& "$env:ProgramData\Microsoft\Windows Defender\Platforms\*\MpCmdRun.exe" `
  -Scan -ScanType 3 -File "$dst\$asset"

# 4. Só agora extrair e instalar
$ins = "$env:LOCALAPPDATA\Programs\cbm"
New-Item -ItemType Directory -Force -Path $ins | Out-Null
Expand-Archive "$dst\$asset" -DestinationPath $ins -Force
Test-Path "$ins\codebase-memory-mcp.exe"
# Linux/Mac: extrair tar.gz para ~/.local/bin/ e chmod +x
```

**Qualquer falha nas 3 verificações (hash, attestation, Defender) = ABORTAR**
com instrução explícita de NÃO prosseguir (ver Modo de erro).

> ⚠️ `install.ps1` do zip: NÃO executar — extrair apenas o binário.

## 4. Config MCP (escopo global — corrente)

Adicione o bloco `codebase-memory-mcp` dentro de `"mcp"` no
`~/.config/opencode/opencode.jsonc` global:

```json
{
  "mcp": {
    "codebase-memory-mcp": {
      "type": "local",
      "command": ["C:\\Users\\<user>\\AppData\\Local\\Programs\\cbm\\codebase-memory-mcp.exe"],
      "enabled": true
    }
  }
}
```

- **Escopo global é o corrente nesta máquina** (decisão explícita do operador
  em 2026-10-23): o servidor é agnóstico a repo (indexa qualquer `repo_path`
  via tools) e o `@rdd-reverse-orchestrator` opera sobre N repos de produto;
  custo aceito: tools MCP em toda sessão.
- **Em máquinas/escopos novos:** perguntar — global = recomendado p/ RDD-doc;
  projeto (`.opencode/opencode.json` do alvo, mesmo bloco JSON acima) = uso
  restrito. Nunca tocar em outros blocos do config.
- Backslashes escapados (`\\`) no JSON; colar o path real do binário.
- Editar APENAS o bloco `codebase-memory-mcp` — demais servers intactos.
- **Reinício do OpenCode** para as tools `codebase-memory-mcp_*` aparecerem.

## 5. Smoke test

Após reiniciar o OpenCode, com as tools MCP no catálogo:

1. `list_projects` — handshake vivo do server.
2. `index_repository` com `repo_path` **absoluto** de um repo pequeno (ou o
   repo do operador, com aviso de que o grafo do código indexado fica em
   `~/.cache/codebase-memory-mcp/` — LGPD).
3. `search_graph` com `name_pattern` regex simples (ex.: `.*Configuration.*`)
   e `limit` pequeno — confirmar que devolve nodes com arquivo + linhas.

Resposta com nodes e metadados = smoke test OK. Falha → tabela de
Troubleshooting (CLI como fallback de diagnóstico — §6).

## 6. Comandos de operação — fallback CLI (pré-restart/troubleshooting)

Uso primário = tools MCP (§5). A CLI abaixo serve para diagnóstico quando o
MCP falha e para smoke test pré-restart. Regras — economizam troubleshooting:

| Regra | Detalhe |
|-------|---------|
| **Sempre `--args-file <path.json>`** | JSON inline é frágil no PowerShell — gravar args num `.json` no Temp e passar o path |
| **Exit code 1 mesmo em sucesso** | Comportamento cosmético da CLI — NÃO é falha; validar pelo stdout/JSON |
| **Filtrar stderr** | `2>$null` — suprime warning de allocator no stderr |

```powershell
# Padrão de invocação via CLI
@{ repo_path = 'C:\Users\<user>\...\repo-alvo' } | ConvertTo-Json |
  Set-Content "$env:TEMP\cbm-args.json" -Encoding ASCII
& "$env:LOCALAPPDATA\Programs\cbm\codebase-memory-mcp.exe" `
  --tool index_repository --args-file "$env:TEMP\cbm-args.json" 2>$null
```

Flags relevantes:

| Tool | Args | Notas |
|------|------|-------|
| `index_repository` | `repo_path` (absoluto) | Indexa o repo no grafo |
| `search_graph` | `name_pattern` (regex), `label`, `limit` | Busca nodes — ex.: `*Configuration*` listou 19 configs EF com arquivo+linhas em 1 query |
| `trace_path` | `function_name`, `direction` (callers/callees), `depth` (1–5) | Call chains multi-arquivo — 47 callers rastreados com hop-distance no piloto; grep não resolve isso |
| `get_architecture` | `aspects`: `clusters`, `boundaries`, `layers`, `routes` | Clusters Louvain + boundaries por fan-in/fan-out real (confirma arquitetura por call graph, não por pastas — P-07) |
| `list_projects` | — | Projetos indexados |
| `delete_project` | project | Remove o grafo de um repo |

Labels úteis: `Class`, `Method`, `Function`, `Route`, `File`, `Folder`,
`Module`.

## 7. Relatar estado final

Checklist de fechamento do wizard:

- [ ] Binário em `%LOCALAPPDATA%\Programs\cbm\` — supply-chain verificado
      (SHA-256 ✓ · attestation SLSA ✓ · Defender ✓)
- [ ] Bloco `mcp.codebase-memory-mcp` no escopo decidido (global:
      `opencode.jsonc` · projeto: `.opencode/opencode.json`) — demais servers
      e blocos intactos
- [ ] `install.ps1` NÃO executado
- [ ] Smoke test OK (`list_projects` → `index_repository` → `search_graph`)
- [ ] Operador ciente: cache `~/.cache/codebase-memory-mcp/` contém grafo do
      código indexado (LGPD)
- [ ] **Reinício do OpenCode pendente?** — config não é hot-reloaded

## Limitação declarada (consultar antes de operar)

- Nodes `Route` **não capturam atributos ASP.NET** (`[HttpGet]`, `[Route]`) —
  para **inventário de endpoints**, continuar com matriz de grep por stack
  (Fatia 3 do rdd-reverse-orchestrator); o grafo entra como complemento nas
  **call chains** dos handlers (`trace_path`).
- Grafo é complemento do grep (P-01) — nunca fonte primária de evidência;
  citações continuam ancoradas em arquivo+linha (P-02).

## Ferramentas disponíveis

| Tool | Uso | Exemplo |
|------|-----|---------|
| `index_repository` | Indexa repo no grafo | `{ repo_path: "C:\\...\\repo" }` |
| `search_graph` | Busca nodes (regex/label) | `{ name_pattern: ".*Config.*", limit: 20 }` |
| `trace_path` | Call chains (callers/callees) | `{ function_name: "X", depth: 3 }` |
| `get_architecture` | Clusters/boundaries/layers/routes | `{ aspects: ["clusters","boundaries"] }` |
| `list_projects` | Projetos indexados | `{}` |
| `delete_project` | Remove grafo de um projeto | `{ project: "<nome>" }` |

## Uninstall

1. Remover o bloco `mcp.codebase-memory-mcp` do config onde foi gravado
   (global: `~/.config/opencode/opencode.jsonc` · projeto:
   `.opencode/opencode.json`).
2. Remover o binário (`%LOCALAPPDATA%\Programs\cbm\` ou `~/.local/bin/`).
3. Remover `~/.cache/codebase-memory-mcp/` — **LGPD: o cache contém o grafo do
   código indexado (dado derivado do código do cliente)**; remover em
   desinstalação, troca de máquina ou encerramento de contrato.
4. Reiniciar o OpenCode.

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| CLI sai com **exit code 1** em operação bem-sucedida | Comportamento cosmético conhecido | NÃO é falha — validar pelo JSON no stdout |
| Erro de parsing de JSON no PowerShell | JSON inline no comando | Sempre `--args-file <path.json>` (Passo 6) |
| Warning ruidoso no stderr | Allocator do binário | Filtrar com `2>$null` |
| Tools MCP não aparecem | Config não carregada / sem reinício | Conferir bloco no `opencode.jsonc` global (ou `.opencode/opencode.json`) e reiniciar |
| `gh attestation verify` falha | Asset de mirror/fork ou release não oficial | ABORTAR — usar somente repo DeusData; nunca `elarsaks/` |
| `SHA256 mismatch` | Download corrompido ou asset errado | Baixar novamente; conferir asset e arquitetura |
| `search_graph` vazio | Repo não indexado ou pattern não casa | Rodar `index_repository` antes; testar regex mais ampla |
| Inventário de endpoints incompleto via grafo | Limitação `Route`/atributos ASP.NET | Usar grep para endpoints; grafo só para call chains |
| Indexação lenta em repo grande | Tamanho do repo | Esperar (piloto: 5,8k nodes/25,3k edges em 8,5s em .NET médio); evitar re-indexar a cada sessão |

## Modo de erro

- **Qualquer falha na verificação de supply-chain (SHA-256, attestation,
  Defender): ABORTAR com instrução explícita de NÃO instalar/prosseguir** —
  sugerir download manual + conferência e retomar o wizard só com as 3
  verificações verdes.
- **`install.ps1` presente no zip: NÃO executar** — extrair apenas o binário.
- **Config com JSON inválido (global ou projeto): abortar e reportar** — nunca
  reescrever o config por conta própria.
- **Bloco `codebase-memory-mcp` já existente:** idempotente — confirmar path e
  `enabled`; nunca duplicar a entrada.
- **Repositório alvo não é do cliente/no escopo: pedir confirmação** antes de
  indexar (o cache passa a conter o grafo daquele código).

## Casos de borda

- **Binário já instalado (piloto):** detectar e reportar "já configurado" —
  revalidar versão vs latest; nunca sobrescrever sem confirmação explícita.
- **Linux/Mac:** binário em `~/.local/bin/codebase-memory-mcp` (`chmod +x`);
  mesmo supply-chain (checksums + attestation; Defender não se aplica).
- **Windows ARM64:** conferir se a release publica asset arm64; se não,
  informar indisponibilidade — não usar asset amd64.
- **Escopo não decidido / máquina nova:** perguntar (IMP-043) — avisar do custo
  de contexto em todas as sessões e do cache de código do cliente; só
  configurar global após confirmação explícita (nesta máquina: corrente desde
  2026-10-23).
- **Múltiplos projetos no escopo projeto:** uma entrada MCP por projeto
  apontando para o MESMO binário — não duplicar binário (no escopo global, uma
  entrada única serve todos).
- **Repo indexado ficou stale:** re-executar `index_repository` após mudanças
  grandes de código; `delete_project` antes se o index antigo não for mais
  necessário.
- **Ambiente sem `gh`:** attestation verify é obrigatório — sem gh, instruir
  instalação/autenticação (rdd-gh-setup) ou download manual com conferência
  manual de hash; nunca pular a verificação.

## Formato de commit sugerido

`feat(skills): add rdd-mcp-codegraph-setup (codegraph MCP — piloto v0.12.1)`
