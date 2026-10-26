---
name: rdd-mcp-sqlite-setup
description: >-
  Guia completo para configurar o MCP SQLite (rusq/mcp-sqlite — binário nativo
  Go) no OpenCode — baixa o release oficial com verificação SHA256 do
  checksums.txt (nunca instala binário sem hash conferido), instala em
  %LOCALAPPDATA%\Programs\mcp-sqlite\, grava o bloco mcp.sqlite no
  opencode.jsonc global (sem banco fixo — o .db é escolhido por sessão via
  open_database) e valida com smoke test (handshake MCP + banco descartável no
  Temp). Idempotente, executado por demanda; delegado pelo rdd-setup. Use
  quando o usuário pedir "configurar MCP SQLite", "setup sqlite mcp",
  "conectar sqlite ao opencode" ou "mcp de banco sqlite".
---

# rdd-mcp-sqlite-setup — Wizard de configuração do MCP SQLite (rusq/mcp-sqlite)

Guia passo a passo para integrar bancos SQLite ao OpenCode via MCP. Idempotente:
pode ser reexecutado a qualquer momento — passos já satisfeitos são apenas
confirmados. O binário inicia SEM banco aberto; o arquivo `.db` é escolhido por
sessão com a tool `open_database` (um único server MCP atende N bancos).

## Por que rusq/mcp-sqlite (e não os alternativos)

| Server | Veredito | Motivo |
|--------|----------|--------|
| `rusq/mcp-sqlite` (Go, binário nativo) | ✅ **escolhido** | Inicia sem banco e expõe `open_database` — o `.db` é escolhido por sessão |
| `@executeautomation/database-server` | ❌ não usar | Exige path fixo de banco no startup (`process.exit(1)` sem argumento — verificado no código-fonte) |
| `mcp-server-sqlite` (uvx/Python) | ❌ não usar | Idem — path fixo obrigatório no startup |

Versão validada: **v0.0.3** (release 2026-08, mais recente na data de validação).

## Lê (upstream)

- `~/.config/opencode/opencode.jsonc` — config global (bloco `mcp.sqlite` já existente?)
- `%LOCALAPPDATA%\Programs\mcp-sqlite\mcp-sqlite.exe` — binário já instalado?
- `.opencode/opencode.json` do projeto — apenas se o operador pedir escopo projeto

## Gera (downstream)

- Bloco `mcp.sqlite` no `~/.config/opencode/opencode.jsonc` (global — padrão)
- Binário `mcp-sqlite.exe` instalado em `%LOCALAPPDATA%\Programs\mcp-sqlite\`
- Seção `<!-- sqlite-mcp -->` no `AGENTS.md` do projeto (opcional, quando escopo projeto)

## Nunca edita

- Código de aplicações
- Entradas `mcp` de outros servers (azure-devops, playwright, figma, postgres) — edita SOMENTE o bloco `sqlite`
- Conteúdo de bancos reais do operador — smoke test SEMPRE com `.db` descartável no Temp
- Nunca imprime/loga tokens, connection strings ou dados sensíveis de bancos
- Nunca força kill de processos nem remove `.db` travado por handle ativo do server
- Nunca instala o binário sem conferir o SHA256 contra o `checksums.txt` do release

## 1. Pré-requisitos

- **Windows amd64** (arm64 → ver Casos de borda)
- **Rede** para acessar `github.com` (release + `checksums.txt`)
- **Reinício do OpenCode** após editar config — não é hot-reloaded

## 2. Verificar estado atual (idempotência)

**Passo 1 — config:** o bloco `mcp.sqlite` já existe no `~/.config/opencode/opencode.jsonc`?
Se existe com `"enabled": true` → pular para o Passo 5 (validação) e confirmar o binário.

> ⚠️ **Armadilha PowerShell:** o `ConvertFrom-Json` do PS 5.1 não parseia JSONC
> (comentários). Valide a config pelo hot-reload do OpenCode (tools `sqlite_*`
> aparecem no catálogo da sessão) ou com parser que suporte comentários — nunca
> com `ConvertFrom-Json` direto no `.jsonc`.

**Passo 2 — binário:** verificar a instalação:

```powershell
Test-Path "$env:LOCALAPPDATA\Programs\mcp-sqlite\mcp-sqlite.exe"
```

> ℹ️ `mcp-sqlite.exe --help` imprime o usage no **stderr** e sai com **code 1** —
> NÃO é falha. Não trate como erro.

## 3. Baixar e instalar o binário (SHA256 obrigatório)

Modo guiado — o operador executa na máquina; a skill sugere os comandos.

```powershell
# 1. Baixar release e checksums (sempre da release oficial v0.0.3)
$dst = "$env:TEMP\mcp-sqlite"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
$base = 'https://github.com/rusq/mcp-sqlite/releases/download/v0.0.3'
Invoke-WebRequest "$base/mcp-sqlite_0.0.3_windows_amd64.zip" -OutFile "$dst\mcp-sqlite.zip"
Invoke-WebRequest "$base/checksums.txt" -OutFile "$dst\checksums.txt"

# 2. Conferir SHA256 — OBRIGATÓRIO antes de extrair/instalar
$expected = (Get-Content "$dst\checksums.txt" |
  Select-String 'mcp-sqlite_0.0.3_windows_amd64.zip').Line.Split(' ')[0]
$actual = (Get-FileHash "$dst\mcp-sqlite.zip" -Algorithm SHA256).Hash.ToLower()
if ($expected.ToLower() -ne $actual) { throw 'SHA256 mismatch — NÃO instalar.' }

# 3. Extrair para o path de instalação (zip contém: mcp-sqlite.exe, LICENSE, README.md)
$ins = "$env:LOCALAPPDATA\Programs\mcp-sqlite"
New-Item -ItemType Directory -Force -Path $ins | Out-Null
Expand-Archive "$dst\mcp-sqlite.zip" -DestinationPath $ins -Force

# 4. Binário no lugar
Test-Path "$ins\mcp-sqlite.exe"
```

- **Hash mismatch ou falha de rede → ABORTAR** (ver Modo de erro) — nunca instalar binário sem hash conferido.
- Convenção de instalação: `%LOCALAPPDATA%\Programs\mcp-sqlite\` (padrão validado nesta máquina).

## 4. Configurar MCP no opencode.jsonc (global — padrão)

Adicione o bloco `sqlite` dentro de `"mcp"` no `~/.config/opencode/opencode.jsonc`:

```jsonc
"sqlite": {
  "type": "local",
  "command": ["C:\\Users\\<user>\\AppData\\Local\\Programs\\mcp-sqlite\\mcp-sqlite.exe"],
  "enabled": true,
  "timeout": 10000
}
```

- **Escopo global é o padrão** (decisão já tomada pelo operador): bancos SQLite locais
  servem diagnóstico em qualquer projeto, e sem banco fixo o server não adiciona
  custo além do startup.
- Edite APENAS o bloco `sqlite` — não toque em `azure-devops`, `playwright`, `figma` ou `postgres`.
- No JSON, backslashes do caminho são escapados (`\\`) — colar o path real do usuário.
- `"timeout": 10000` cobre o cold start do binário nativo.

### Escopo projeto (opcional)

Se o operador pedir escopo por projeto, adicione o mesmo bloco no
`.opencode/opencode.json` do projeto e documente as tools no `AGENTS.md`
do projeto (seção `<!-- sqlite-mcp -->`).

## 5. Smoke test (banco descartável no Temp)

> ⚠️ Sempre com `.db` de TESTE no Temp — nunca abrir banco real do operador.

**a) Handshake MCP** (valida o binário sem OpenCode reiniciado) — ecoar no stdin do exe:

```
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"1.0"}}}
```

Resposta esperada contém: `"serverInfo":{"name":"sqlite-mcp-server","version":"0.0.3"}`.

**b) Ciclo de banco** — após reiniciar o OpenCode (tools `sqlite_*` no catálogo):

1. **Criar o `.db` de teste ANTES de abrir** — `open_database` falha com
   `database file not found` se o arquivo não existe:

   ```powershell
   New-Item -ItemType File -Force -Path "$env:TEMP\mcp-sqlite-smoke.db"
   ```

2. `open_database(path: "<TEMP>\mcp-sqlite-smoke.db")` — abre o banco da sessão
3. `execute` com DDL + DML (bind params `?`):

   ```sql
   CREATE TABLE smoke_test (id INTEGER PRIMARY KEY, nome TEXT)
   ```

   ```sql
   INSERT INTO smoke_test (nome) VALUES (?)
   ```

4. `query` de leitura: `SELECT * FROM smoke_test`
5. `get_schema` — valida que o schema é visível
6. **Cleanup:** o `.db` de teste fica travado pelo handle do server até a sessão
   encerrar — agendar a remoção para uma sessão futura (`Remove-Item` após fechar).
   **NUNCA forçar kill de processo** para destravar.

## 6. Relatar estado final

Checklist de fechamento do wizard:

- [ ] Binário instalado em `%LOCALAPPDATA%\Programs\mcp-sqlite\` — SHA256 conferido
- [ ] Bloco `mcp.sqlite` no opencode.jsonc (global) — demais servers intactos
- [ ] Handshake MCP OK (`serverInfo: sqlite-mcp-server`)
- [ ] Smoke test OK (open_database → execute → query → get_schema)
- [ ] `.db` de teste agendado para remoção em sessão futura (handle ativo)
- [ ] **Reinício do OpenCode pendente?** — config não é hot-reloaded

## Ferramentas disponíveis

| Ferramenta | Uso | Exemplo |
|------------|-----|---------|
| `open_database` | Abre um `.db` para a sessão (arquivo deve existir) | `{ path: "C:\\...\\banco.db" }` |
| `get_schema` | Schema: tabelas, colunas, índices, FKs | `{ mask: "USER_%" }` |
| `query` | SELECT/WITH/EXPLAIN — **read-only** | `SELECT * FROM users LIMIT 10` |
| `execute` | INSERT/UPDATE/DELETE/DDL — escrita | `CREATE TABLE`, `INSERT INTO ... VALUES (?)` |

Todas as tools aceitam **bind params** `?` (array `params`) — usar sempre que a
query levar input do usuário.

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `database file not found` no `open_database` | Arquivo `.db` não existe | Criar com `New-Item` ANTES de abrir (a tool não cria arquivo) |
| Tools `sqlite_*` não aparecem | Server `enabled: false`, config inválida ou sem reinício | Conferir bloco `sqlite` e reiniciar o OpenCode |
| `ConvertFrom-Json` falha no `.jsonc` | PS 5.1 não parseia JSONC (comentários) | Validar pelo catálogo de tools do OpenCode ou parser que suporte comentários |
| `mcp-sqlite --help` sai com code 1 | Usage vai no stderr — comportamento normal | NÃO é falha; validar pelo handshake MCP (Passo 5a) |
| `SHA256 mismatch` | Download corrompido ou asset errado | Baixar novamente; conferir arquitetura (amd64 vs arm64) |
| `.db` de teste não apaga | Handle aberto pelo server | Remover em sessão futura — nunca forçar kill |
| `MCP server not responding` | Timeout curto ou path errado no `command` | Conferir path real do exe e manter `"timeout": 10000` |

## Modo de erro

- **Falha de rede no download ou hash mismatch: ABORTAR com instrução manual** — nunca instalar binário sem hash conferido; sugerir download manual do release no browser + conferência do SHA256, e retomar o wizard.
- **opencode.jsonc corrompido (JSON inválido): abortar e reportar** — nunca reescrever o config por conta própria; pedir correção ao operador.
- **Bloco `sqlite` já existente:** idempotente — apenas confirmar/ajustar `enabled` ou o path; nunca duplicar a entrada.
- Falha no smoke test: seguir a tabela de Troubleshooting; se persistir, reportar o erro exato (resposta do handshake ou mensagem da tool).

## Casos de borda

- **Binário já instalado em outra versão:** sugerir upgrade opcional para v0.0.3; nunca sobrescrever sem confirmação explícita do operador.
- **Windows ARM64:** usar o asset `mcp-sqlite_0.0.3_windows_arm64.zip` (mesma release, conferir hash correspondente no `checksums.txt`).
- **Escopo projeto:** mesmo bloco no `.opencode/opencode.json` — manter as escolhas padrão (global, sem banco fixo) a menos que o operador peça.
- **Múltiplos bancos:** um único server atende N `.db` — trocar com `open_database` por sessão; não criar segunda entrada MCP.
- **`.db` travado por handle ativo:** remover em sessão futura — nunca `Stop-Process`.

## Formato de commit sugerido

`feat(skills): add rdd-mcp-sqlite-setup (IMP-105 MCP setup parity)`