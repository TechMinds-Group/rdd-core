---
name: rdd-mcp-playwright-setup
description: >-
  Guia completo para configurar o MCP Playwright (@playwright/mcp) em projetos
  OpenCode, sempre no escopo do projeto (.opencode/opencode.json).
  Use quando o usuário pedir "configurar MCP Playwright", "setup playwright mcp",
  "adicionar MCP de browser", "conectar playwright ao opencode", "criar profile
  de conexão playwright".
---

# rdd-mcp-playwright-setup

Guia passo a passo para integrar o Playwright (automação de navegador) ao OpenCode via MCP.

## Lê (upstream)

- `.opencode/opencode.json` do projeto — config local do projeto
- `AGENTS.md` do projeto — instruções existentes para o agente
- `package.json` do projeto — para detectar Playwright já instalado

## Gera (downstream)

- Entrada `mcp` no `opencode.json` do projeto
- Seção `<!-- playwright-mcp -->` no `AGENTS.md` do projeto

## Nunca edita

- Código de aplicações
- Entradas `mcp` já existentes — adiciona, nunca sobrescreve
- Config global (`~/.config/opencode/opencode.jsonc`) — MCP de browser é sempre por projeto (ver Passo 3)

## 1. Pré-requisitos

- **Node.js** >= 18 instalado (para `npx` e `@playwright/mcp`)
- **Playwright browsers** instalados (Chromium, Firefox ou WebKit):
  ```bash
  npx playwright install chromium
  # ou todos os browsers:
  npx playwright install
  ```
- **Docker** (opcional) — se preferir rodar o MCP em container

### Verificar instalação do Node.js

```bash
node --version   # deve ser >= 18
```

### Verificar browsers instalados

```bash
npx playwright install --dry-run
# ou listar browsers já instalados:
npx playwright install --list  # (Playwright >= 1.50)
```

## 2. Escolher modo de execução

O MCP Playwright pode ser executado de três formas:

| Modo | Comando | Quando usar |
|------|---------|-------------|
| **npx** (recomendado) | `npx -y @playwright/mcp` | Setup rápido, sem instalação global |
| **Docker** | `docker run ...` | Ambientes isolados, CI/CD |
| **Local install** | `node node_modules/@playwright/mcp` | Projetos que já usam Playwright |

### Modo npx (recomendado)

Mais simples — o `npx` baixa e executa o pacote automaticamente:

```json
{
  "command": ["npx", "-y", "@playwright/mcp"]
}
```

### Modo Docker

```json
{
  "command": ["docker", "run", "--rm", "-i", "--init", "-e", "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1", "mcr.microsoft.com/playwright:v1.52.0", "npx", "@playwright/mcp"]
}
```

### Modo local (instalação no projeto)

```bash
npm install --save-dev @playwright/mcp
```

```json
{
  "command": ["npx", "@playwright/mcp"]
}
```

## 3. Configurar MCP no projeto

> **Sempre no escopo do projeto.** Não configurar MCP de browser globalmente
> (`~/.config/opencode/opencode.jsonc`): MCP global fica ativo em todas as
> sessões do OpenCode — inclusive em projetos que não usam browser — consumindo
> tokens de contexto desnecessariamente. Um MCP por projeto mantém as tools
> disponíveis apenas onde fazem sentido.

Adicione o bloco `mcp` no arquivo `.opencode/opencode.json` do projeto:

```json
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp"],
      "enabled": true
    }
  }
}
```

- O nome do servidor (`playwright`) compõe o identificador das tools no cliente; use nomes distintos se houver múltiplos servidores MCP Playwright.
- `npx -y` instala e executa o pacote automaticamente.
- `enabled: true` ativa o MCP ao iniciar a sessão — requer **reinício do OpenCode** para valer (config não é hot-reloaded).

### Múltiplos profiles (Chromium + Firefox)

Se precisar de dois navegadores simultaneamente:

```json
{
  "mcp": {
    "playwright-chromium": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp", "--browser", "chromium"],
      "enabled": true
    },
    "playwright-firefox": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp", "--browser", "firefox"],
      "enabled": true
    }
  }
}
```

### Opções de linha de comando do @playwright/mcp

| Flag | Descrição | Padrão |
|------|-----------|--------|
| `--browser` | Navegador a usar: `chromium`, `firefox`, `webkit` | `chromium` |
| `--headless` | Rodar sem interface gráfica | `true` |
| `--port` | Porta para depuração remota | `9222` |
| `--user-data-dir` | Diretório de perfil do usuário | temporário |
| `--proxy-server` | Servidor proxy (ex: `http://proxy:8080`) | — |

Exemplo com flags personalizadas:

```json
{
  "command": ["npx", "-y", "@playwright/mcp", "--browser", "firefox", "--headless", "false"]
}
```

## 4. Instruções para o agente (AGENTS.md)

Adicione uma seção no `AGENTS.md` do projeto:

```markdown
<!-- playwright-mcp -->
Playwright via MCP (@playwright/mcp):
- Browser: Chromium (padrão)
- Mode: headless
- Use `playwright_browser_navigate` para navegar para URLs.
- Use `playwright_browser_snapshot` para capturar o estado acessível da página.
- Use `playwright_browser_click` para clicar em elementos.
- Use `playwright_browser_type` para preencher campos de texto.
- Use `playwright_browser_evaluate` para executar JavaScript na página.
- Use `playwright_browser_find` para buscar texto na árvore de acessibilidade.
- Use `playwright_browser_take_screenshot` para capturar screenshot.
- Use `playwright_browser_network_requests` para inspecionar tráfego de rede.
<!-- playwright-mcp -->
```

### Ferramentas disponíveis

| Ferramenta | Uso | Exemplo |
|------------|-----|---------|
| `playwright_browser_navigate` | Navegar para URL | `{ url: "https://example.com" }` |
| `playwright_browser_snapshot` | Capturar árvore de acessibilidade | `{ depth: 5 }` |
| `playwright_browser_click` | Clicar em elemento | `{ target: "ref-123" }` |
| `playwright_browser_type` | Preencher campo de texto | `{ target: "ref-456", text: "valor" }` |
| `playwright_browser_evaluate` | Executar JS na página | `{ function: "() => document.title" }` |
| `playwright_browser_find` | Buscar texto na árvore | `{ text: "Login" }` |
| `playwright_browser_take_screenshot` | Screenshot da página | `{ scale: "css" }` |
| `playwright_browser_network_requests` | Listar requisições de rede | `{ static: false }` |
| `playwright_browser_network_request` | Detalhes de uma requisição | `{ index: 1 }` |
| `playwright_browser_resize` | Redimensionar viewport | `{ width: 1280, height: 720 }` |
| `playwright_browser_press_key` | Pressionar tecla | `{ key: "Enter" }` |
| `playwright_browser_hover` | Passar mouse sobre elemento | `{ target: "ref-789" }` |
| `playwright_browser_select_option` | Selecionar em dropdown | `{ target: "ref-012", values: ["opcao"] }` |
| `playwright_browser_fill_form` | Preencher múltiplos campos | `{ fields: [...] }` |
| `playwright_browser_drag` | Arrastar elemento | `{ startTarget: "...", endTarget: "..." }` |
| `playwright_browser_drop` | Soltar arquivo/dados | `{ target: "...", paths: [...] }` |
| `playwright_browser_handle_dialog` | Aceitar/rejeitar dialog | `{ accept: true }` |
| `playwright_browser_emulate_media` | Emular mídia CSS | `{ colorScheme: "dark" }` |
| `playwright_browser_console_messages` | Obter console messages | `{ level: "info" }` |
| `playwright_browser_tabs` | Gerenciar abas | `{ action: "list" }` |
| `playwright_browser_wait_for` | Aguardar condição | `{ text: "carregado" }` |
| `playwright_browser_navigate_back` | Voltar no histórico | `{}` |
| `playwright_browser_close` | Fechar página | `{}` |

## 5. Instalar browsers Playwright

Se os browsers ainda não estiverem instalados:

```bash
# Apenas Chromium (mais comum, suficiente para maioria dos casos)
npx playwright install chromium

# Todos os browsers
npx playwright install

# Com dependências de sistema (Linux)
npx playwright install-deps chromium
```

### Verificar instalação

```bash
# Testar se o Playwright consegue iniciar o browser
npx playwright open --browser=chromium https://example.com
```

## 6. Validação

Após configurar, valide com estes passos:

1. **Reinicie o OpenCode** — a config não é hot-reloaded.

2. **Navegar para uma URL** — testa que o servidor MCP responde:
   ```
   playwright_browser_navigate(url: "https://example.com")
   ```

3. **Capturar snapshot** — verifica que o browser renderizou:
   ```
   playwright_browser_snapshot(depth: 3)
   ```

4. **Executar JavaScript** — valida que a página está interativa:
   ```
   playwright_browser_evaluate(function: "() => document.title")
   ```

5. **Screenshot** — confirma renderização visual:
   ```
   playwright_browser_take_screenshot(scale: "css")
   ```

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `browserType.launch: Executable doesn't exist` | Browser não instalado | Rodar `npx playwright install chromium` |
| `npx: command not found` | Node.js não instalado | Instalar Node.js (>= 18) |
| `Port already in use` | Porta 9222 ocupada | Usar `--port` com valor diferente |
| `MCP server not responding` | Servidor não iniciou | Verificar `opencode.json` e reiniciar OpenCode |
| `Error: Connection refused` | Browser crashou | Rodar `npx playwright install --force chromium` |
| `Host system dependencies missing` | Faltam libs no Linux | Rodar `npx playwright install-deps chromium` |
| `Timeout waiting for browser` | Browser lento para iniciar | Aumentar timeout ou verificar recursos do sistema |
| `Permission denied` | Sandbox do Chromium | Usar `--no-sandbox` (apenas em container/CI) |
| `MCP server already exists` | Nome duplicado no opencode.json | Usar nome diferente (ex: `playwright-2`) |

## Modo de erro

- Falha ao iniciar o servidor MCP: seguir a tabela de Troubleshooting; se persistir, verificar se os browsers foram instalados corretamente com `npx playwright install --list`.
- Entrada `mcp` já existente no projeto com o mesmo nome: nunca sobrescrever — propor outro nome de servidor (ex: `playwright-2`, `playwright-firefox`).

## Casos de borda

- **Múltiplos navegadores:** criar uma entrada MCP por navegador no `opencode.json` com nomes distintos (`playwright-chromium`, `playwright-firefox`, `playwright-webkit`) e flag `--browser` correspondente.
- **Modo headless false:** útil para depuração visual; requer ambiente com display (não funciona em CI/SSH sem Xvfb).
- **CI/Docker sem display:** usar `--headless` (padrão) ou configurar `xvfb-run`.
- **Proxy corporativo:** configurar `--proxy-server` ou variáveis de ambiente `HTTP_PROXY`/`HTTPS_PROXY`.
- **Usuário pede MCP global:** explicar o trade-off (MCP ativo em todas as sessões consome tokens mesmo sem uso) e configurar por projeto; só aceitar global se o usuário insistir explicitamente após o aviso.
- **Playwright já instalado no projeto:** detectar `@playwright/mcp` no `package.json` e sugerir modo local em vez de npx.
- **Windows vs Linux paths:** usar barras invertidas no Windows para caminhos de `--user-data-dir`.
- **Firewall bloqueando saída:** configurar proxy ou usar `--proxy-server` para tráfego do browser.