---
name: rdd-azure-setup
description: >-
  Wizard de configuração do MCP Azure DevOps para o workflow RDD — verifica o
  server `azure-devops` no opencode.jsonc global, orienta o cadastro do PAT na
  env var de usuário ADO_PAT_B64 (nunca imprime, loga ou comita o token),
  habilita enabled: true, valida conexão com a org/projeto definidos no perfil do cliente (rules/client-profile.md)
  e confirma as tools do MCP. Idempotente e executado por demanda; delegado
  pelo rdd-setup. Use quando o usuário pedir "configurar MCP Azure DevOps",
  "setup azure devops mcp", "configurar PAT do azure", "token do azure
  devops", "conectar azure boards ao opencode" ou "onboarding azure".
---
# rdd-azure-setup — Wizard de Configuração do MCP Azure DevOps

Configura o acesso ao Azure DevOps via MCP (`azure-devops/mcp`) para que a
skill `rdd-azure-workitem-creator` (e o `@rdd-azure-orchestrator`) consigam
criar/consultar work items no Azure Boards. Idempotente: pode ser
reexecutado a qualquer momento — passos já satisfeitos são apenas
confirmados.

## Diferenciação

| Skill | Escopo |
|-------|--------|
| `rdd-azure-setup` (esta) | Configura o **acesso** (server MCP + credencial); não cria work items |
| `rdd-azure-workitem-creator` | **Usa** o acesso para criar work items a partir das tasks do delivery |

Espelho do `rdd-gh-setup` (que configura a gh CLI para o domínio GitHub).

## Lê (upstream)

- `~/.config/opencode/opencode.jsonc` — bloco `mcp."azure-devops"` (server já definido, `enabled: false` por padrão)
- Env var `ADO_PAT_B64` — apenas EXISTÊNCIA (`[Environment]::GetEnvironmentVariable('ADO_PAT_B64','User') -ne $null`); NUNCA imprimir o valor
- `rules/client-profile.md` — perfil do cliente (IMP-103): org, projeto, usuário, repos e defaults do tracker. Fonte única de defaults — NUNCA hardcode de cliente nesta skill (AGENTS.md global mantém os blocos locais, gitignored).

## Gera (downstream)

- Ajuste no bloco `mcp."azure-devops"` (`enabled: true`) do opencode.jsonc
- Env var de usuário `ADO_PAT_B64` (PAT em base64 — o valor vem do operador, nunca é ecoado)
- Relatório textual de validação (não persiste arquivo)

## Nunca edita

- Código de aplicações
- Entradas `mcp` de outros servers (figma, playwright) — ajusta SOMENTE o bloco `azure-devops`
- **NENHUM arquivo com o valor do PAT** — proibido escrever em opencode.json(c), .env, docs, scripts, git. O token vive EXCLUSIVAMENTE na env var de usuário
- Artefatos de módulo RDD (REQUIREMENTS, delivery, etc.)
- Remote — nunca commita nem push

## Tools

- `bash` (validações; decodificação do PAT **sem ecoar** o valor)
- `question` (perguntar ao operador o que precisa ser feito quando algo estiver ausente)
- `read` (ler opencode.jsonc e AGENTS.md para contexto)
- `edit` (mudar apenas `"enabled": false` → `true` no bloco `azure-devops`)

## Modo de erro

`warn` — validações que falharem não bloqueiam a conclusão do wizard: entram
no relatório como ⚠️ com orientação de correção. Só é `strict` na validação
final mínima: sem PAT cadastrado ou com server desabilitado, o relatório
termina com falha clara e orienta o passo que falta.

## Formato de commit

Nenhum — este wizard não edita artefatos versionados e nunca commita.

## Algoritmo

### Fluxo síncrono (obrigatório)

```
Passo 1 → Passo 2 → Passo 3 → Passo 4 → Passo 5 → Passo 6
             ↘          ↘          ↘
           [pular]    [pular]    [pular]
```

### Passo 1 — Detectar estado atual

1. Verificar o bloco `azure-devops` no `~/.config/opencode/opencode.jsonc`:
   existe? `enabled` está `true` ou `false`?
2. Verificar existência (nunca valor) da env var:

```powershell
[bool][Environment]::GetEnvironmentVariable('ADO_PAT_B64','User')
```

Monte o diagnóstico:

| Item | Fonte | Estado esperado |
|------|-------|----------------|
| Server `azure-devops` definido | opencode.jsonc | bloco `mcp."azure-devops"` presente |
| Habilitado | opencode.jsonc | `"enabled": true` |
| PAT cadastrado | env var `ADO_PAT_B64` (User) | `True` (existência apenas) |

Exiba o diagnóstico antes de alterar qualquer coisa.

### Passo 2 — Gerar o PAT (se ausente), sem expor

Oriente o operador a gerar o Personal Access Token no Azure DevOps:
`https://dev.azure.com/<org-do-perfil>` → User settings → Personal Access Tokens →
New Token. Escopo mínimo: **Work Items (Read & Write)**. Validade
recomendada: 90 dias (renovação via re-execução deste wizard).

**Proibições absolutas:**
- NUNCA `echo`, `Write-Host`, log ou screenshot do token
- NUNCA `setx ADO_PAT_B64 <valor>` com o valor inline (vai para histórico do shell)
- NUNCA escrever o PAT em opencode.json(c), .env, docs ou commits

### Passo 3 — Cadastrar ADO_PAT_B64 (sem expor)

O server do opencode.jsonc lê `$env:ADO_PAT_B64` e o PAT é informado em
**base64**. Oriente o cadastro no nível de USUÁRIO do Windows:

**Opção A — Interface gráfica (recomendada, nada vai para histórico):**
1. `Win+R` → `sysdm.cpl` → aba Avançado → Variáveis de Ambiente
2. Variáveis do usuário → Novo → Nome: `ADO_PAT_B64`
3. Valor: primeiro converta o PAT em base64 **numa janela à parte**
   (`[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes('SEU_PAT'))`)
   e cole o resultado. Feche a janela sem salvar o script.
4. OK e REABRA o terminal/OpenCode

**Opção B — PowerShell (sem literal no histórico):**

```powershell
$pat = Read-Host -AsSecureString -Prompt 'Cole o PAT do Azure DevOps'
$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(
  [System.Net.NetworkCredential]::new('', $pat).Password))
[Environment]::SetEnvironmentVariable('ADO_PAT_B64', $b64, 'User')
$b64 = $null; $pat = $null  # descarta da memória da sessão
```

### Passo 4 — Habilitar o server

No `~/.config/opencode/opencode.jsonc`, mude `"enabled": false` →
`"enabled": true` no bloco `azure-devops`. Edite APENAS esse bloco — não
toque em `figma` ou `playwright`. O comando do server já fixa a org
**<org-do-perfil>** (`azure-devops/mcp <org-do-perfil> --authentication pat`) — não
altere o comando, apenas habilite.

### Passo 5 — Validação

Após **reiniciar o OpenCode** (reabrindo o terminal, para a env var valer):

1. **Tools disponíveis** — as tools do server aparecem com prefixo
   `azure-devops` (ex.: criação/listagem de work items, queries de Boards).
2. **Conexão real** — liste projetos ou consulte um work item existente na
   org do perfil (rules/client-profile.md); o resultado deve mencionar o projeto do perfil.
3. Se retornar dados da org → conexão OK.

### Passo 6 — Relatório final

```text
═══ rdd-azure-setup — <RESULTADO> ═══

✓. Server azure-devops: definido | habilitado
✓. PAT (ADO_PAT_B64): cadastrado | ⚠️ Ausente — refaça o Passo 3
✓. Org/projeto do perfil (client-profile.md): acesso confirmado | ⚠️ <erro>

🔍 Validação:
| Verificação | Estado | Observação |

Próximo passo sugerido: @rdd-azure-orchestrator para criar work items,
ou continue o rdd-setup (Passo 6 — validação de ambiente).
```

## Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `TF401027` / 401 na validação | PAT inválido, expirado ou escopo insuficiente | Regenerar o PAT com escopo Work Items (Read & Write); refazer Passo 3 |
| `ADO_PAT_B64` ausente / token nulo | Env var não cadastrada ou sessão antiga | Refazer Passo 3 e REABRIR o terminal/OpenCode |
| Base64 inválido no decode do server | Valor colado não está em base64 (PAT cru) | Refazer a conversão do Passo 3 (Opção B faz automaticamente) |
| Tools `azure-devops` não aparecem | Server `enabled: false` ou config inválida | Passo 4; validar JSON do config (vírgulas/aspas) |
| Org errada nas queries | Comando do server alterado | Restaurar comando original (`azure-devops/mcp <org-do-perfil> --authentication pat`) |

## Casos de Borda

- **Re-execução (idempotente):** itens já OK são pulados; nada é refeito. PAT expirado → só refazer Passos 2-3.
- **Troca de PAT:** substituir o valor da MESMA env var `ADO_PAT_B64` (nunca criar segunda entrada MCP nem segunda env var).
- **Outra org/projeto eventual:** A fonte de defaults é o perfil do cliente (rules/client-profile.md — IMP-103); para operação em outra org/projeto, informe explicitamente na chamada da tool — o wizard não altera o perfil.
- **CI/CD ou sessão de serviço:** cadastrar `ADO_PAT_B64` como secret do ambiente do runner (nunca no repo).
- **Proxy corporativo:** o MCP local respeita as env vars de proxy; configure se a rede exigir.
- **Operador tenta colar o PAT no chat/arquivo:** recusar e orientar o Passo 3 (env var).
- **Delegado pelo rdd-setup:** ao concluir, retorne o relatório para o wizard pai seguir ao Passo 6 (validação de ambiente).
