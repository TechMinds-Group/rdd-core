---
name: rdd-stack-boilerplate
description: >-
  Template engine para bootstrapping de projetos RDD a partir de boilerplates
  pré-definidos por stack. Lê o registry `rules/stack-templates.yaml`,
  clona o boilerplate correspondente, executa o setup pós-clone
  (rename, env, restore) e prepara o projeto para receber implementação.
  Invocada por rdd-dev-backend e rdd-dev-frontend ao detectar repo vazio
  (sem código-fonte, só README) ou no início de um novo projeto via
  rdd-intake-orchestrator. Evita scaffold genérico (`dotnet new webapi`)
  — usa um repo curado da organização (`boilerplate_org` do perfil — IMP-105).
  Use junto com "boilerplate", "template", "bootstrap", "novo projeto",
  "scaffold", "stack template", "clone boilerplate".
---

# rdd-stack-boilerplate — Bootstrap de projetos a partir de boilerplates

## Escopo

- **Entrada:** um repositório vazio (só README) + stack detectada (ex.: `.NET`)
- **Saída:** repositório populado com o boilerplate da stack + renomeado para o projeto
- **Quando carregar:** no passo 0 do `rdd-dev-backend`/`rdd-dev-frontend`, ANTES de implementar qualquer task — se o repo for vazio, carregar este stack-boilerplate primeiro
- **Fallback:** sem boilerplate no registry → executor gera scaffold genérico (`dotnet new webapi`)

## Lê (upstream)

- `rules/stack-templates.yaml` — registry de boilerplates por stack (lazy-loaded via AGENTS.md)
- `AGENTS.md` do repo alvo — convenções específicas do projeto

## Gera (downstream)

- O repositório alvo populado com o boilerplate + renomeado + configurado
- Relatório resumido: boilerplate usado, steps executados, pendências pós-setup

## Nunca edita

- `rules/stack-templates.yaml` (adicionar stacks manualmente ou via CR)
- Boilerplate repos (são lidos como template, nunca modificados)
- Código existente no repo alvo (só escrive em repo vazio)

## Tools

- `read` — ler o registry YAML e o AGENTS.md do repo
- `bash` — `git clone`, `powershell rename-project.ps1`, `dotnet restore`
- `glob` — detectar stack no repo alvo
- `question` — confirmar stack quando ambígua ou sem boilerplate

## Modo de erro

`warn` — repo já tem código-fonte → pular boilerplate (repo existente, não é bootstrap).
Boilerplate não encontrado ou repo privado sem acesso → orientar fallback a scaffold genérico.

## Algoritmo

1. **Detectar stack no repo alvo:** use `glob` para os padrões em `templates.<stack>.detect`.
   Se mais de uma stack combinar, pergunte (`question`). Se nenhuma, reporte que a stack não tem
   boilerplate no registry e encerre (deixando o executor cair no scaffold genérico).

2. **Carregar o registry:** leia `rules/stack-templates.yaml` e busque o template da stack detectada.

3. **Verificar boilerplate disponível:** se `templates.<stack>.boilerplate` for `null`,
   reporte que não há boilerplate para esta stack e encerre (executor usará scaffold genérico).

4. **Verificar se o repo já tem código:** se o repo alvo tiver mais que README.md e arquivos
   de config mínima (`.gitignore`, `.env.example`, `LICENSE`), pule — repo não é vazio.

5. **Clonar boilerplate na pasta correta:**

   ```bash
   git clone --depth 1 https://github.com/<Org>/<Boilerplate> /tmp/<boilerplate>-tmp
   ```

6. **Renomear para o nome do projeto:** execute o script de rename do boilerplate (se existir).

   ```bash
   cd /tmp/<boilerplate>-tmp
   powershell -File rename-project.ps1 <ProjectName>
   ```

   O nome do projeto (`<ProjectName>`) é derivado do nome do repo alvo:
   - Se o repo termina com `-API`, `-API` é extraído (ex.: `Lumen-API` → `Lumen`)
   - Caso contrário, usa o nome completo do repo.
   - Pergunte via `question` se a derivação não for clara.

7. **Copiar conteúdo para o repo alvo:**

   ```bash
   # Remove .git do boilerplate
   Remove-Item -Recurse -Force /tmp/<boilerplate>-tmp/.git
   # Copia para o repo alvo
   Copy-Item -Recurse -Force /tmp/<boilerplate>-tmp\* <repo-target>\ 
   ```

8. **Configurar pós-clone:**
   - Copiar `.env.example` para `.env`
   - Rodar `dotnet restore` (se .NET)
   - Ajustar connection string do banco para `<ProjectName>` (em `appsettings*.json` ou `.env`)

9. **Registrar no relatório:** boilerplate usado, rename aplicado, steps executados, quebra de compatibilidade com
   o playbook (ex.: versão de dependências diferente da documentada), pendências pós-setup
   (ex.: configurar secrets, subir migrations, ajustar docker-compose ports).

## Relatório de saída

```
═══ rdd-stack-boilerplate — .NET ═══
Boilerplate: <boilerplate_org do perfil>/Boilerplate.NET-API (ex.: Acme-Group/Boilerplate.NET-API)
Rename: <ProjectName> (Lumen)
Steps executados:
  - git clone --depth 1
  - rename-project.ps1 Lumen
  - Copiado para repo alvo
  - .env criado a partir de .env.example
  - dotnet restore (OK)
Quebras de compatibilidade:
  - (nenhuma — boilerplate atualizado)
Pendências pós-setup:
  - Configurar secrets do GitHub
  - Ajustar docker-compose ports se necessário
```

## Formato de commit

```
(Não commita diretamente — o executor (rdd-dev-backend) commita o bootstrap)
```

## Casos de Borda

- **Repo já tem código:** pular silenciosamente (repo existente, em desenvolvimento). Reporte "pulado — repo não vazio".
- **Boilerplate não encontrado:** oriente fallback ao scaffold genérico (`dotnet new webapi`). Registry não precisa ter entry para toda stack.
- **rename-project.ps1 falha:** reporte erro e pare; o conteúdo bruto do boilerplate fica no diretório, e o operador pode renomear manualmente.
- **Multi-stack detectada (ex.: `*.csproj` + `angular.json` no mesmo repo):** pergunte via `question` qual stack usar.
- **Stack sem boilerplate no registry:** reporte e encerre; não falhe (o executor faz scaffold genérico).
- **Projeto sem nome claro (ex.: repo `Lumen` sem sufixo):** pergunte o nome do projeto para o rename. O nome do projeto .NET (solution name) pode ser diferente do nome do repo.