---
name: rdd-mcp-figma-setup
description: >-
  Wizard de configuração do MCP Figma (figma-developer-mcp / Framelink) para o
  OpenCode — verifica o server no opencode.jsonc global ou cria entrada no
  escopo do projeto (.opencode/opencode.json), orienta o cadastro da env var
  FIGMA_API_KEY (nunca imprime, loga ou comita o token), habilita enabled: true
  e valida a conexão com a API Figma. Idempotente e executado por demanda.
  Use quando o usuário pedir "configurar MCP Figma", "setup figma mcp",
  "conectar figma ao opencode", "token do figma" ou "configurar figma
  developer mcp".
license: MIT
compatibility: opencode
metadata:
  audience: analistas-e-devs
  workflow: setup-infra
---
# rdd-mcp-figma-setup - Wizard de configuração do MCP Figma (figma-developer-mcp)

Configura o acesso ao Figma via MCP (`figma-developer-mcp`, pacote Framelink) para que
skills como `rdd-figma-tasks` consigam ler designs reais (frames, componentes, tokens)
como entrada do pipeline RDD. Idempotente: pode ser reexecutado a qualquer momento —
passos já satisfeitos são apenas confirmados.

## Lê (upstream)

- `~/.config/opencode/opencode.jsonc` — config global (server `figma` já definido, `enabled: false` por padrão)
- `.opencode/opencode.json` do projeto — config local (escopo por projeto, opcional)
- Env var `FIGMA_API_KEY` — apenas EXISTÊNCIA (`[Environment]::GetEnvironmentVariable('FIGMA_API_KEY','User') -ne $null`); NUNCA imprimir o valor
- `AGENTS.md` do projeto — para documentar as tools disponíveis (opcional)

## Gera (downstream)

- Ajuste no bloco `mcp.figma` (`enabled: true`) — global ou no projeto
- Env var de usuário `FIGMA_API_KEY` (via Variáveis de Ambiente do Windows ou PowerShell — o valor vem do operador, nunca é ecoado)
- Seção `<!-- figma-mcp -->` no `AGENTS.md` do projeto (opcional)

## Nunca edita

- Código de aplicações
- Entradas `mcp` de outros servers (azure-devops, playwright) — adiciona/ajusta SOMENTE o bloco `figma`
- **NENHUM arquivo com o valor do token** — proibido escrever `FIGMA_API_KEY` em opencode.json(c), .env, docs, scripts, git. O token vive EXCLUSIVAMENTE na env var do usuário

## 1. Pré-requisitos

- **Node.js** >= 18 (para `npx figma-developer-mcp`)
- **Token pessoal do Figma** — o operador gera em Figma → Settings → Account → Personal access tokens (escopo `file_content:read` é suficiente para leitura de designs)
- **Reinício do OpenCode** após mudanças — config e env var não são hot-reloaded

## 2. Verificar o server no config

O server `figma` já está definido no config global (`~/.config/opencode/opencode.jsonc`):

```json
"figma": {
  "type": "local",
  "command": ["npx", "-y", "figma-developer-mcp", "--stdio"],
  "enabled": false
}
```

Verifique:
1. O bloco existe? Se não existir (máquina nova), adicione-o exatamente como acima.
2. O `figma-developer-mcp` está no NPM registry? Teste: `npx -y figma-developer-mcp --help`.

### Escopo global vs projeto

| Escopo | Quando usar |
|--------|-------------|
| Global (opencode.jsonc) — padrão deste repo | O workflow RDD usa Figma como insumo em qualquer projeto; server fica definido mas habilitado |
| Projeto (.opencode/opencode.json) | Quando só um projeto específico consome Figma |

Se optar por projeto, adicione no `.opencode/opencode.json`:

```json
{
  "mcp": {
    "figma": {
      "type": "local",
      "command": ["npx", "-y", "figma-developer-mcp", "--stdio"],
      "enabled": true
    }
  }
}
```

## 3. Cadastrar a env var FIGMA_API_KEY (sem expor o token)

O `figma-developer-mcp` lê a env var `FIGMA_API_KEY` do processo. Como o OpenCode herda
o ambiente do usuário, cadastre a variável no nível de USUÁRIO do Windows.

**Opção A — Interface gráfica (recomendada, nada vai para histórico):**
1. `Win+R` → `sysdm.cpl` → aba Avançado → Variáveis de Ambiente
2. Variáveis do usuário → Novo → Nome: `FIGMA_API_KEY`, Valor: cole o token
3. OK e REABRA o terminal/OpenCode

**Opção B — PowerShell (valor não vai para o histórico como literal):**

```powershell
$v = Read-Host -Prompt 'Cole o token FIGMA (entrada oculta nao existe no Read-Host; cole com cuidado)'
[Environment]::SetEnvironmentVariable('FIGMA_API_KEY', $v, 'User')
$v = $null  # descarta da memoria da sessao
```

**Proibições absolutas:**
- NUNCA `echo`, `Write-Host`, log ou screenshot do token
- NUNCA `setx FIGMA_API_KEY <valor>` com o valor inline (vai para histórico do shell e para a linha de comando do processo)
- NUNCA escrever o token em `opencode.json(c)`, `.env`, docs ou commits

## 4. Habilitar o server

No escopo escolhido (Passo 2), mude `"enabled": false` → `"enabled": true` no bloco `figma`.
Edite APENAS esse bloco — não toque em `azure-devops` ou `playwright`.

## 5. Validação

Após **reiniciar o OpenCode** (reabrindo o terminal, para a env var valer):

1. **Tools disponíveis** — as tools do server aparecem com prefixo `figma_`:
   `figma_get_metadata`, `figma_get_code`, `figma_get_screenshot`, `figma_get_variable_defs`.
2. **Conexão real** — chame `figma_get_metadata` com um link de arquivo Figma do operador
   (ou de teste público). URL esperada: `https://www.figma.com/design/<fileKey>/<Nome>?node-id=<x-y>`.
3. Se retornar metadados do arquivo (nome, frames) → conexão OK.

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `{"error": "..."}` 403/404 na chamada | Token inválido/expirado ou sem acesso ao arquivo | Regenerar token no Figma; conferir escopo `file_content:read` e permissão no arquivo |
| `FIGMA_API_KEY` ausente / Invalid API key | Env var não cadastrada ou sessão antiga | Refazer Passo 3 e REABRIR o terminal/OpenCode (setx/env não valem para processos já abertos) |
| `npx: command not found` | Node.js ausente | Instalar Node.js >= 18 |
| MCP server not responding | Server não iniciou | Conferir o bloco `figma` no config e reiniciar o OpenCode |
| Tools `figma_*` não aparecem | Server `enabled: false` ou config inválida | Passo 4; validar JSON do config (vírgulas/aspas) |

## Modo de erro

- Falha de conexão na validação: seguir a tabela de Troubleshooting; se persistir, pedir ao operador para regenerar o token (nunca pedir para COLAR o token no chat).
- Bloco `figma` já existente: idempotente — apenas confirmar/mudar `enabled`; nunca duplicar a entrada.
- Operador tenta colar o token no chat/arquivo: recusar e orientar o Passo 3 (env var).

## Casos de Borda

- **CI/CD ou sessão de serviço:** cadastrar `FIGMA_API_KEY` como secret do ambiente do runner (nunca no repo).
- **Proxy corporativo:** `figma-developer-mcp` respeita `HTTPS_PROXY`; configurar env var de usuário se a API Figma exigir proxy.
- **Múltiplos tokens/contas:** um token por env var; para trocar de conta, substituir o valor da mesma variável (não criar segunda entrada MCP).
- **Operador pede server global habilitado por padrão:** ok — o server só consome contexto quando o OpenCode inicia; se pesando, manter `enabled: false` e habilitar apenas no projeto que usa Figma.