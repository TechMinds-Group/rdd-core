---
name: rdd-mcp-postgres-setup
description: >-
  Guia completo para configurar o MCP PostgreSQL (@microsoft/postgres-mcp)
  em projetos OpenCode, sempre no escopo do projeto (.opencode/opencode.json).
  Use quando o usuário pedir "configurar MCP postgres", "setup postgres mcp",
  "adicionar MCP de banco", "conectar postgres ao opencode", "criar profile
  de conexão postgres".
---

# rdd-mcp-postgres-setup

Guia passo a passo para integrar um banco PostgreSQL ao OpenCode via MCP.

## Lê (upstream)

- `~/.postgres-mcp/connections.yaml` — profiles de conexão existentes
- `.opencode/opencode.json` do projeto — config local do projeto
- `AGENTS.md` do projeto — instruções existentes para o agente

## Gera (downstream)

- Entrada `mcp` no `opencode.json` do projeto
- Profile em `~/.postgres-mcp/connections.yaml`
- Seção `<!-- postgres-mcp -->` no `AGENTS.md` do projeto

## Nunca edita

- Código de aplicações
- Senhas em texto plano — sempre via keyring (`set-password`)
- Entradas `mcp` já existentes — adiciona, nunca sobrescreve
- Config global (`~/.config/opencode/opencode.jsonc`) — MCP de banco é sempre por projeto (ver Passo 4)

## 1. Pré-requisitos

- **PostgreSQL** acessível (local ou remoto)
- **Node.js** instalado (para `npx`)
- **Docker** (opcional) — se o banco roda em container com port mapping

## 2. Criar profile de conexão

Crie ou edite o arquivo `~/.postgres-mcp/connections.yaml`:

```yaml
connections:
- name: meu-projeto-local
  host: localhost
  port: 5432
  database: meu_banco
  user: postgres
  is_azure: false
  access_mode: ro
```

### Campos

| Campo | Obrigatório | Descrição |
|-------|-------------|-----------|
| `name` | sim | Identificador único do profile (usado depois para conectar) |
| `host` | sim | Hostname ou IP do servidor |
| `port` | sim | Porta do PostgreSQL (padrão: 5432) |
| `database` | sim | Nome do banco de dados |
| `user` | sim | Usuário do banco |
| `is_azure` | não | `true` se for Azure Database for PostgreSQL; `false` para padrão |
| `access_mode` | não | `ro` (read-only) ou `rw` (read-write). Padrão: `rw` |

### Modo de acesso

- **`ro` (read-only)** — bloqueia ferramentas de escrita (`postgres_mcp_modify`). Ideal para consultas e diagnósticos.
- **`rw` (read-write)** — permite DDL/DML. Use com cautela; escritas ainda pedem confirmação do usuário.

## 3. Segurança — configurar senha

> ⚠️ **NUNCA** inclua a senha no `connections.yaml`. O arquivo contém apenas metadados de conexão.

A senha é armazenada no **keyring do sistema operacional**:

```bash
npx @microsoft/postgres-mcp connection set-password <nome-do-profile>
```

Exemplo:

```bash
npx @microsoft/postgres-mcp connection set-password meu-projeto-local
```

O sistema abrirá um prompt para digitar a senha. Ela fica salva em:

- **Windows**: Windows Credential Manager
- **macOS**: Keychain
- **Linux**: Secret Service (GNOME Keyring, KDE Wallet)

### Ambientes sem keyring (Docker, CI)

Use a variável de ambiente `POSTGRES_MCP_CONNECTION_STRING`:

```bash
export POSTGRES_MCP_CONNECTION_STRING="postgresql://user:password@host:5432/database?sslmode=require"
```

## 4. Configurar MCP no projeto

> **Sempre no escopo do projeto.** Não configurar MCP de banco globalmente
> (`~/.config/opencode/opencode.jsonc`): MCP global fica ativo em todas as
> sessões do OpenCode — inclusive em projetos que não usam banco — consumindo
> tokens de contexto desnecessariamente. Um MCP por projeto mantém as tools
> disponíveis apenas onde fazem sentido.

Adicione o bloco `mcp` no arquivo `.opencode/opencode.json` do projeto:

```json
{
  "mcp": {
    "postgres": {
      "type": "local",
      "command": ["npx", "-y", "@microsoft/postgres-mcp", "run"],
      "enabled": true
    }
  }
}
```

- O nome do servidor (`postgres`) compõe o identificador das tools no cliente; use nomes distintos se houver múltiplos servidores MCP postgres.
- `npx -y` instala e executa o pacote automaticamente.
- `enabled: true` ativa o MCP ao iniciar a sessão — requer **reinício do OpenCode** para valer (config não é hot-reloaded).
- O escopo por projeto não limita **qual banco** conectar — isso é papel do profile (Passo 2) ou de `POSTGRES_MCP_CONNECTION_STRING`. Um único servidor MCP atende N bancos via profiles.

## 5. Instruções para o agente (AGENTS.md)

Adicione uma seção no `AGENTS.md` do projeto:

```markdown
<!-- postgres-mcp -->
PostgreSQL via MCP (@microsoft/postgres-mcp):
- Connection profile: `meu-projeto-local`
- Database: `meu_banco` on `localhost:5432`
- User: `postgres` | Mode: read-only
- Key tables: users, orders, products
- Use postgres_mcp_query for SELECT, EXPLAIN and other read-only queries.
- Use postgres_mcp_db_context to fetch schema (tables, indexes, functions).
- Use postgres_mcp_modify for DDL/DML (CREATE, ALTER, INSERT, UPDATE, DELETE) — requires user confirmation.
<!-- postgres-mcp -->
```

### Ferramentas disponíveis

| Ferramenta | Uso | Exemplo |
|------------|-----|---------|
| `postgres_mcp_query` | Consultas SELECT, EXPLAIN | `SELECT * FROM users LIMIT 10` |
| `postgres_mcp_db_context` | Schema: tabelas, índices, funções | `objectType: 'all'` |
| `postgres_mcp_modify` | DDL/DML (escrita) | `CREATE TABLE`, `INSERT INTO` — **requer confirmação** |

### Listar profiles disponíveis

```
postgres_mcp_list_connection_profiles
```

### Conectar a um profile

```
postgres_mcp_connect(profileId: '<profile-id>')
```

## Exemplo de referência validado (projeto legado)

Configuração em produção, usada como gabarito:

- **Profile:** `legacy-db-local` → `legacy_db` em `localhost:5434` (Docker com port mapping), user `admin`, `access_mode: ro`
- **Servidor MCP:** `npx -y @microsoft/postgres-mcp run`
- **Ferramentas em uso:** `postgres_mcp_query` (SELECT/EXPLAIN), `postgres_mcp_db_context` (schema: tabelas, índices, funções), `postgres_mcp_modify` (DDL/DML — sempre com confirmação do usuário)
- **Instrução do agente:** bloco `<!-- rpg-postgres -->` no AGENTS.md do projeto, listando profile, database, host:porta, mode e tabelas-chave (Nodes, Campaigns, knowledge_chunks, ingestion_jobs)

Lições validadas:
- Default `access_mode: ro` — só usar `rw` quando o projeto exigir DDL/DML no dia a dia.
- Nunca senha no YAML; sempre keyring (`set-password`) ou connection string em variável de ambiente.
- Documentar as tabelas-chave no AGENTS.md acelera o uso correto pelo agente.

## 6. Validação

Após configurar, valide com estes passos:

1. **Listar profiles** — confirma que o YAML foi lido:
   ```
   postgres_mcp_list_connection_profiles
   ```

2. **Conectar** — obtém um `connectionId`:
   ```
   postgres_mcp_connect(profileId: '<id-retornado>')
   ```

3. **Consultar schema** — verifica que o banco responde:
   ```
   postgres_mcp_db_context(connectionId: '<connection-id>', objectType: 'tables')
   ```

4. **Query simples** — valida permissões:
   ```
   postgres_mcp_query(connectionId: '<connection-id>', query: 'SELECT 1 AS test')
   ```

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `Password not found` | Senha não configurada | Rodar `npx @microsoft/postgres-mcp connection set-password <profile>` |
| `Connection refused` | Porta errada ou banco offline | Verificar `host`/`port` no YAML e se o PostgreSQL está rodando |
| `FATAL: password authentication failed` | Senha incorreta | Reconfigurar senha com `set-password` |
| `Read-only violation` | Access mode `ro` bloqueia escrita | Mudar `access_mode` para `rw` no YAML |
| `Port already in use` | Porta mapeada por outro processo | Usar outra porta no YAML ou parar o conflito |
| `npx: command not found` | Node.js não instalado | Instalar Node.js (>= 18) |

## Modo de erro

- Falha ao conectar: seguir a tabela de Troubleshooting; se persistir, reportar o erro exato ao usuário — nunca tentar workaround com senha em texto plano.
- Entrada `mcp` já existente no projeto com o mesmo nome: nunca sobrescrever — propor outro nome de servidor.

## Casos de borda

- **Múltiplos bancos:** criar um profile por banco no `connections.yaml`; todos aparecem em `postgres_mcp_list_connection_profiles` no mesmo servidor MCP.
- **Azure PostgreSQL:** `is_azure: true` no profile.
- **CI/Docker sem keyring:** usar `POSTGRES_MCP_CONNECTION_STRING` (Passo 3).
- **Usuário pede MCP global:** explicar o trade-off (MCP ativo em todas as sessões consome tokens mesmo sem uso) e configurar por projeto; só aceitar global se o usuário insistir explicitamente após o aviso.
