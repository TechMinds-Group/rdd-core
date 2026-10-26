---
name: rdd-aws-setup
description: >-
  Wizard de configuração do acesso AWS para o workflow RDD — verifica a AWS
  CLI v2 instalada (winget id `Amazon.AWSCLI`; path padrão
  `C:\Program Files\Amazon\AWSCLIV2\aws.exe` quando o PATH não atualizou),
  valida a PRESENÇA do MCP server oficial `aws-mcp` no opencode.jsonc (só
  valida — não instala nem edita a config), orienta a criação do par de
  access keys no console IAM (passo executado pelo OPERADOR no console
  web), configura credenciais SEMPRE via `aws configure --profile <nome>`
  interativo no terminal do operador (nunca recebe, imprime, loga ou grava
  senha de console nem access keys), valida com `aws sts
  get-caller-identity --profile <nome>` e fecha com higiene obrigatória
  (MFA no usuário IAM, rotação de senha exposta, `~/.aws` nunca dentro de
  repo). Idempotente e executado por demanda; delegado pelo rdd-setup.
  Use quando o usuário pedir "configurar aws", "setup aws", "aws cli",
  "credenciais aws", "perfil aws" ou "onboarding aws".
---
# rdd-aws-setup — Wizard de Configuração do Acesso AWS

Setup do acesso AWS numa máquina: garante AWS CLI instalada, MCP server
`aws-mcp` presente, credenciais configuradas por perfil e validadas via
STS. Pré-condição de qualquer uso AWS pelo workflow (infra de deploy,
auditoria, skills AWS do MCP oficial). Idempotente — pode ser reexecutado;
passos já completos são pulados e perfil existente não é sobrescrito sem
confirmação.

## Diferenciação

| Componente | Escopo |
|------------|--------|
| `rdd-aws-setup` (esta) | Configura o **acesso** (CLI + credenciais por perfil + MCP presente); thin wizard — NÃO embute conhecimento de domínio AWS |
| `signing-in-to-aws` (skill embutida do MCP `aws-mcp`) | **Referência viva de autenticação AWS** — como obter/renovar credenciais em runtime; cite-a em dúvidas de autenticação, não duplique aqui |
| Skills AWS do `aws-mcp` (ex.: `aws-security`, `aws-storage`, `aws-deployment`) | Conhecimento de domínio AWS por serviço — consomem o acesso configurado por esta skill |
| `rdd-setup` | Delegador — chama esta skill no Passo 5c |

Espelho do `rdd-gh-setup` (que configura a gh CLI para o domínio GitHub).

## Lê (upstream)

- Saída de `aws --version` — CLI presente? Se o PATH não tiver atualizado
  após instalação recente, fallback: `Test-Path 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'`
- `~/.config/opencode/opencode.jsonc` — bloco `mcp."aws-mcp"` presente?
  `enabled: true`? (**SÓ leitura** — nunca edita o jsonc)
- Saída de `aws configure list-profiles` — perfis existentes (NOMES apenas;
  NUNCA o conteúdo de `~/.aws/credentials`)
- Saída de `aws sts get-caller-identity --profile <nome>` — ARN/conta da
  identidade (validação)
- `rules/client-profile.md` — perfil do cliente (IMP-103), opcional, para
  registrar o provider AWS (conta/região/profile — NUNCA segredo)

## Gera (downstream)

- Relatório textual de validação (não persiste arquivo)
- Estado autenticado da AWS CLI (efeito colateral: `aws configure
  --profile` executado INTERATIVAMENTE pelo operador no terminal — grava
  em `~/.aws`, fora de qualquer repo)
- Opcional, sob confirmação: bloco `<!-- provider-aws -->` em
  `rules/client-profile.md` (conta, região e profile — gitignored,
  IMP-103; NUNCA access key)

## Nunca edita

- `opencode.jsonc` — esta skill SÓ valida a presença do server `aws-mcp`;
  instalação/habilitação do server é decisão do operador (fora do escopo
  desta execução)
- **NENHUM arquivo com credencial** — proibido escrever senha de console
  IAM, Access Key ID ou Secret Access Key em arquivo algum (versionado OU
  gitignored: client-profile, .env, docs, scripts, commit). Credenciais
  vivem EXCLUSIVAMENTE em `~/.aws`, escritas pelo `aws configure`
  interativo do operador
- Código de aplicações e artefatos de módulo RDD
- Remote — nunca commita nem push

## Tools

- `bash` (validações read-only: `aws --version`,
  `aws configure list-profiles`, `aws sts get-caller-identity`; Test-Path
  da CLI e de `~/.aws`)
- `question` (perguntas AGRUPADAS — IMP-043: instalar CLI? configurar
  perfil agora? registrar provider no client-profile?)
- `read` (opencode.jsonc para o bloco `mcp."aws-mcp"`;
  rules/client-profile.md quando for registrar provider)
- `edit` (APENAS sob confirmação explícita: `rules/client-profile.md` —
  bloco provider AWS sem segredo)

## Modo de erro

`warn` — validações que falharem não bloqueiam a conclusão do wizard:
entram no relatório como ⚠️ com orientação de correção. Só é `strict` na
validação final mínima: sem AWS CLI instalada, o relatório termina com
falha clara e orienta `winget install --id Amazon.AWSCLI -e`. **Exceção de
segurança sempre strict:** credencial (senha de console ou access key)
colada no chat ou em arquivo → recusa imediata, orienta DESATIVAR a key
exposta no console IAM e criar outra, refazendo os Passos 4-5.

## Formato de commit

Nenhum — este wizard não edita artefatos versionados e nunca commita.

## Algoritmo

### Fluxo síncrono (obrigatório)

```
Passo 1 → Passo 2 → Passo 3 → Passo 4 → Passo 5 → Passo 6 → Passo 7 → Passo 8
            ↓                     ↓           ↓           ↓
         [pular]             [operador]   [operador]  [checklist]
```

### Passo 1 — Detectar estado atual

```powershell
aws --version 2>&1
# fallback se o PATH ainda não tiver a CLI após instalação recente:
Test-Path 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'
aws configure list-profiles 2>&1   # nomes de perfis apenas
Test-Path "$HOME\.aws"
```

Monte o diagnóstico:

| Item | Fonte | Estado esperado |
|------|-------|----------------|
| AWS CLI instalada | `aws --version` | `aws-cli/2.x` exibido |
| Perfis configurados | `aws configure list-profiles` | >= 1 perfil listado (nomes apenas) |
| MCP server `aws-mcp` | opencode.jsonc, bloco `mcp."aws-mcp"` | presente + `enabled: true` |
| Identidade válida | `aws sts get-caller-identity --profile <nome>` | ARN do usuário IAM |

Exiba o diagnóstico antes de orientar qualquer mudança.

### Passo 2 — Instalação da CLI (se ausente)

Se `aws --version` falhar (e o fallback de path também):

```powershell
winget install --id Amazon.AWSCLI -e
```

Após instalar, peça confirmação para revalidar (`aws --version`). Se ainda
ausente (PATH não atualizado), oriente REABRIR o terminal/sessão e use o
fallback `Test-Path 'C:\Program Files\Amazon\AWSCLIV2\aws.exe'`;
persistindo a ausência, registre ⚠️ e encerre com falha clara (strict).

### Passo 3 — Validar o MCP server `aws-mcp` (só presença)

Leia `~/.config/opencode/opencode.jsonc` e verifique o bloco
`mcp."aws-mcp"`:

| Estado | Ação |
|--------|------|
| Ausente | ⚠️ pendência — a skill NÃO edita o jsonc; instalação/habilitação do server é decisão do operador; reexecutar depois |
| Presente, `enabled: false` | ⚠️ pendência — habilitar é decisão do operador (não edita nesta skill); as skills AWS embutidas só valem após habilitar + REINICIAR o OpenCode |
| Presente + `enabled: true` | ✓ confirmado |

**Fronteira KISS:** esta skill não instala, não baixa e não edita config
de MCP — o conhecimento de domínio AWS já vem embutido no server oficial
(skills como `signing-in-to-aws`); duplicar aqui violaria o escopo thin
wizard.

### Passo 4 — Par de access keys no console IAM (operador executa)

Caso de uso: acesso programático via CLI. Oriente o OPERADOR (passo no
console web, fora da máquina):

1. Console IAM → Users → `<usuário-iam-do-operador>` → Security
   credentials
2. Create access key → caso de uso **Command Line Interface (CLI)**
3. (Recomendado) descrição/tag da key para rastreio
4. O console exibe Access Key ID + Secret Access Key **uma única vez** —
   o operador usa na hora no Passo 5, no terminal

**Proibições absolutas:**
- NUNCA criar access key na conta **root** — só usuário IAM, com escopo
  mínimo
- NUNCA colar Access Key ID ou Secret no chat desta skill (o wizard não
  recebe segredo)
- NUNCA escrever em arquivo, env var global, log ou commit
- Em dúvida de método/renovação de credencial → cite a skill
  `signing-in-to-aws` do MCP `aws-mcp` (referência viva), não improvise

### Passo 5 — Configurar credenciais (`aws configure --profile`, terminal do operador)

A configuração é SEMPRE interativa, executada pelo OPERADOR no terminal:

```powershell
aws configure --profile <nome-do-perfil>
# AWS Access Key ID:     <colado pelo operador direto no terminal>
# AWS Secret Access Key: <idem>
# Default region name:   <região, ex.: us-east-1 / sa-east-1>
# Default output format: json
```

- O wizard NUNCA executa esse comando com valores inline, NUNCA recebe as
  respostas e NUNCA grava `~/.aws/credentials` por conta própria
- Perfil existente com mesmo nome → perguntar antes de orientar
  sobrescrever (idempotência: sem confirmação, pular e registrar
  ✓ "perfil já existe")
- Alternativa avançada (sob demanda do operador): `aws configure sso` —
  orientar e validar igual (Passo 6)

### Passo 6 — Validar credenciais

```powershell
aws sts get-caller-identity --profile <nome-do-perfil>
```

- Sucesso → JSON com `Arn`, `Account`, `UserId` — exiba ARN e conta
  (dados não-sensíveis) como confirmação
- `Unable to locate credentials` → Passo 5 não concluído para esse perfil
- `InvalidClientTokenId` / `SignatureDoesNotMatch` → key inválida ou
  colada errada; refazer Passos 4-5 (e desativar a key antiga no IAM)
- `AccessDenied` no STS → política do usuário IAM sem
  `sts:GetCallerIdentity` (permissão mínima)

### Passo 7 — Higiene de segurança (obrigatória no relatório)

Checklist exibido no fim, com orientação de correção para cada item
faltante:

| Item | Orientação |
|------|-----------|
| MFA no usuário IAM | Console IAM → Security credentials → Assign MFA device; CLI usa sessão temporária (`sts get-session-token` + `--serial-number`/`token-code`) |
| Senha de console exposta/sem rotação | Trocar a senha no console; se a senha passou por chat/e-mail/log, trocar IMEDIATAMENTE |
| `~/.aws` nunca dentro de repo | `~/.aws` fica no `$HOME`, fora de qualquer repo; validar que o diretório de projetos não contém `credentials`/`config` soltos |

### Passo 8 — (opcional, sob confirmação) Registrar provider AWS + relatório final

**Opcional, só com confirmação explícita:** gravar em
`rules/client-profile.md` (gitignored — IMP-103) um bloco do provider AWS:

```markdown
<!-- provider-aws -->
Conta AWS: <12 dígitos — campo Account do STS>
Região default: <região>
Profile CLI: <nome-do-perfil>
<!-- /provider-aws -->
```

NUNCA gravar Access Key ID, Secret ou senha — só dados não-sensíveis
(conta/região/profile). Sem confirmação, pule e registre ℹ️.

Relatório final:

```text
═══ rdd-aws-setup — <RESULTADO> ═══

✅ AWS CLI: aws-cli/2.x | ⚠️ Ausente — winget install --id Amazon.AWSCLI -e
✅ MCP server aws-mcp: presente e habilitado | ⚠️ <pendência — skill não edita jsonc>
✅ Perfil <nome>: ARN <arn-do-usuário> | ⚠️ <erro do Passo 6>
🔒 Higiene: MFA ✓/⚠️ | rotação ✓/⚠️ | ~/.aws fora de repo ✓/⚠️
ℹ️ Provider no client-profile: registrado | não registrado (opcional)

🔍 Validação:
| Verificação | Estado | Observação |

Próximo passo sugerido: continuar o rdd-setup (Passo 6 — validação de
ambiente), ou usar as skills AWS do MCP oficial com o acesso configurado.
```

## Casos de Borda

- **Re-execução (idempotente):** passos já OK são pulados; perfil
  existente não é sobrescrito sem confirmação — troca de credencial =
  refazer o Passo 5 com o MESMO nome de perfil (nunca criar segunda
  entrada).
- **Múltiplos perfis:** `aws configure list-profiles` lista todos; valide
  o perfil alvo informado (ou pergunte com `question` agrupada) — nunca
  exiba conteúdo de credenciais, só nomes.
- **Credencial colada no chat/arquivo:** recusa imediata (strict);
  oriente DESATIVAR a key exposta no console IAM, criar outra e refazer
  os Passos 4-5.
- **Conta root:** recusar criar/orientar access key de root — só usuário
  IAM.
- **aws-mcp ausente/desabilitado:** pendência ⚠️ sem bloquear
  CLI/credenciais (a CLI funciona independente do MCP); skills AWS
  embutidas só valem após habilitar + reiniciar o OpenCode.
- **SSO (IAM Identity Center):** caso avançado — orientar
  `aws configure sso` (terminal do operador); validação idem Passo 6; o
  nome do perfil vem do SSO.
- **PATH sem a CLI após instalação:** use o fallback de path padrão
  (`C:\Program Files\Amazon\AWSCLIV2\aws.exe`); persistindo, oriente
  reabrir o terminal.
- **Proxy corporativo:** a CLI respeita env vars de proxy; configure se a
  rede exigir.
- **Delegado pelo rdd-setup:** ao concluir, retorne o relatório para o
  wizard pai seguir ao Passo 6 (validação de ambiente).