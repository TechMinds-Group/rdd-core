---
name: rdd-stack-angular
description: >-
  Playbook de stack Angular para os executors de dev do RDD
  (rdd-dev-frontend). Comandos de build/verify (ng test, ng lint),
  estrutura de MFE Angular com Webpack Module Federation, padrões
  (módulos federados, componentes compartilhados, services HTTP, guards),
  validações reativas de formulário e convenções de spec Karma/Jasmine.
  Carregada via skill tool quando o repo alvo detecta angular.json/package.json
  com Angular. Use junto com "angular", "mfe", "module federation", "karma",
  "jasmine", "ng test", "frontend". Use quando o repo alvo for Angular/MFE
  detectado (angular.json/package.json), ao rodar "ng test"/"ng lint" ou ao
  implementar features de frontend.
---
# rdd-stack-angular — Playbook de Stack

Playbook de conhecimento para executors de dev do RDD que implementam
código em repos Angular MFE e derivados. Contém o **como** da stack — comandos, estrutura e padrões.
O **o quê** (tela, fluxo, validações, RNs) vem de TASKS.md/UI_SPEC.md/
ACCEPTANCE_CRITERIA.md/REQUIREMENTS.md; as convenções específicas do
repo vêm do `AGENTS.md` do repo (precedência sobre este playbook); as
convenções de **teste** do projeto vêm de skill específica (camada acima deste playbook).

## Escopo

- **Aplica-se a:** repos frontend Angular e MFEs do ecossistema
  (Micro Frontends com Webpack Module Federation)
- **Fonte de verdade de versões:** `package.json` do repo (Angular,
  devDependencies) — não este playbook.

## Lê (upstream)

- `AGENTS.md` do repo alvo — convenções específicas do repo (precedência sobre este playbook)
- Código-fonte do repo (read-only) — `angular.json`, `package.json`, `webpack.config.js`, componentes/services/guards existentes
- Artefatos de spec do módulo referenciados pela task: TASKS.md, UI_SPEC.md, API_CONTRACTS.md, ACCEPTANCE_CRITERIA.md, REQUIREMENTS.md
- Skill `<projeto>-test-generator` — convenções de spec Karma/Jasmine (camada acima deste playbook). **Project-local:** só existe em projetos que a fornecem — se ausente no projeto, siga as convenções de spec do próprio repo (specs existentes + AGENTS.md)

## Gera (downstream)

- Nenhum artefato de módulo — este playbook só orienta a implementação aplicada pelos executors de dev (`rdd-dev-frontend`): código Angular, specs Karma/Jasmine e relatório da task

## Nunca edita

- Artefatos de spec RDD (REQUIREMENTS.md, DATA_MODEL.md, API_CONTRACTS.md, UI_SPEC.md, ACCEPTANCE_CRITERIA.md, TASKS.md) — read-only
- `AGENTS.md` do repo alvo
- Config de Module Federation (`webpack.config.js`) sem sinalizar em `decisões:` (ver Pitfalls)

## Tools

- `read`/`glob`/`grep` — inspecionar código-fonte e configs do repo (read-only)
- `bash` — executar `ng test`, `ng lint` e `npm install` (com ask)
- Skill tool — carregar `<projeto>-test-generator` quando o passo envolver specs (se existir no projeto; ausente → convenções do repo)

## Modo de erro

`warn` — repo sem `angular.json`/`package.json` com Angular (ex: repo React): sinalizar `needs-stack-playbook.` (stack desconhecida para este playbook), seguir as convenções do `AGENTS.md` do repo e encerrar com orientação — não aplicar padrões Angular por inferência.

## Comandos de build e verificação

**Testes — builder-aware (IMP-084):** antes de rodar testes, confira o
builder de teste do project em `angular.json`
(`projects.<projeto>.architect.test.builder`):

| Builder em `angular.json` | Comando de teste |
|---------------------------|------------------|
| `@angular-devkit/build-angular:karma` (Karma/Jasmine) | `ng test --watch=false --browsers=ChromeHeadless` — single-run, exita |
| `@angular/build:unit-test` (Vitest) | `ng test` — single-run e exita **por padrão**; flags do Karma (`--watch=false`, `--browsers=ChromeHeadless`) **não se aplicam** |

Rodar flags inaplicáveis ao builder faz o comando falhar ou ficar preso
em watch — ver regra anti-hang no Passo 7 do `rdd-dev-frontend`.

| Ação | Comando |
|------|---------|
| Teste único | `ng test --include='**/<arquivo>.spec.ts'` |
| Lint | `ng lint` (quando o repo tiver config ESLint) |
| Build de produção | `ng build` (via CI — raro localmente) |
| Dev server | `ng serve` (porta por projeto — ver `package.json`/`angular.json`) |

**Pré-verificação de ambiente:** Node instalado e `npm install` executado
(`node_modules` presente). Sem ambiente, reportar `not-verified.` com
motivo — não pular testes silenciosamente.

## Verificação visual (browser-in-the-loop)

O "como" Angular do Passo 7.5 do `rdd-dev-frontend`:

| Ação | Como |
|------|------|
| Dev server | Preferir server já rodando; para subir, `ng serve` em background via `Start-Process` (bash, ask) e aguardar a porta responder — **teto de ~60s**: não subiu no teto, mate o processo (`Stop-Process`) e reporte `visual: not-verified (dev-server timeout)` (IMP-084) |
| Porta | De `angular.json`/`package.json` (serve options) — portas por MFE são fixas; não reutilizar a de outro MFE |
| Shell vs remote | Em MFE, subir o **shell** que compõe o remote alterado — remote sozinho não renderiza a tela composta |
| Navegar/intervir | `playwright_browser_navigate`, `_click`, `_type`, `_fill_form`, `_select_option` |
| Aguardar render | `playwright_browser_wait_for` (texto-chave da tela) antes do screenshot |
| Capturar | `playwright_browser_take_screenshot` por estado relevante; `playwright_browser_console_messages` para erros de runtime |

Sem dev server ou MCP Playwright no projeto → `visual: not-verified (motivo)`
no relatório da task — degradação explícita, não silenciosa.

## Estrutura de projeto típica (MFE Angular)

```
<repo>/
├── projects/ (ou src/)               # um workspace por MFE ou multi
│   ├── <mfe-shell>/                  # host (shell de composição)
│   ├── <mfe-feature>/                # MFE de domínio (rastreabilidade, pnib...)
│   └── <shared-lib>/                 # biblioteca compartilhada
├── webpack.config.js / webpack.*.js  # config de Module Federation
└── angular.json                      # projetos, builders, budgets
```

Dentro de um MFE:
```
<mfe-feature>/src/app/
├── modules/<modulo>/                # feature module
│   ├── components/                  # componentes da tela
│   ├── services/                    # serviços HTTP (um por recurso)
│   ├── guards/                      # guards de rota quando aplicável
│   ├── models/                      # interfaces/DTOs (espelham contrato da API)
│   └── <modulo>.routing.module.ts
└── shared/ (ou shared-lib)          # componentes/pipes reutilizáveis
```

## Padrões dominantes Angular (ex.: skill project-local `<projeto>-test-generator` quando presente)

### Composição de MFE (Module Federation)
- Webpack Module Federation: shell carrega remote por config; alterações
  de **config federation** (exposes/shared) são excepcionais — sinalizar
  em `decisões:` quando a task exigir
- Portas por MFE fixadas nos configs — não reutilizar porta de outro MFE

### Integração HTTP
- Services com `HttpClient`, um por recurso do API_CONTRACTS.md
- Models TypeScript espelham os DTOs do contrato (nomes de campos
  idênticos — não "traduzir" payload)
- Interceptors existentes (auth, erro) — usar os do repo, não criar novo

### Formulários e validações
- Reactive Forms; validações **exatamente como em UI_SPEC.md** (campos
  obrigatórios, máscaras, limites)
- Regras de exibição condicional da UI_SPEC → bindings no template,
  nunca lógica hardcoded no component

### Estilo
- SCSS por componente + estilos compartilhados / design tokens do repo
- Reuse componente de `shared/` antes de criar novo (verificar usages
  com grep antes de alterar componente compartilhado)

## Testes

- **Convenções de spec:** seguir a skill `<projeto>-test-generator`
  (TestBed, `jasmine.createSpyObj`, `HttpClientTestingController`,
  `ComponentFixture`) quando existir no projeto — este playbook não substitui; é camada genérica. Sem a skill project-local, espelhe as convenções dos specs existentes do repo
- Cobrir: render inicial, interações da UI_SPEC, validações de formulário,
  cenários de erro do contrato
- `ng test` com a suíte inteira verde — não apenas os specs novos

## Pitfalls

1. **Alterar componente compartilhado** — impacta outros MFEs federados;
   grep de usages antes e registrar impacto no relatório
2. **Node/dependências desatualizadas** — `ng test` falhando por
   `node_modules` stale; `npm install` (via bash, ask) antes de concluir
   que é bug
3. **Module Federation shared deps** — versões duplicadas de libs no
   `shared` config quebram em runtime, não em build; sinalizar mudanças
4. **Validação inventada** — máscara/validação fora da UI_SPEC é
   `needs-spec.`, não iniciativa própria
5. **Porta em conflito** — cada MFE tem porta própria; conferir antes de
   `ng serve`
6. **`ng test` preso em watch** — flags do Karma não valem para o builder
   Vitest (`@angular/build:unit-test`); checar o builder em `angular.json`
   antes (IMP-084); comando que não termina → `not-verified (hang)`

## Algoritmo

1. **Detectar stack:** confirme `angular.json` + `package.json` com Angular no repo alvo. Sem eles → `warn` (ver Modo de erro).
2. **Carregar convenções:** leia o `AGENTS.md` do repo (precedência sobre este playbook) e, para specs, carregue `<projeto>-test-generator` (se existir no projeto; ausente → convenções de spec do próprio repo).
3. **Contextualizar a task:** leia os artefatos de spec referenciados (TASKS.md, UI_SPEC.md, API_CONTRACTS.md) para saber o **o quê**.
4. **Aplicar na implementação:** use os comandos, estrutura e padrões deste playbook (MFE, services HTTP, Reactive Forms, SCSS) ao codar.
5. **Verificar:** rode `ng test` builder-aware (tabela em "Comandos de build e verificação") com a suíte inteira verde e `ng lint`; comando que não termina → abortar e reportar `not-verified (hang)` (IMP-084); reporte `not-verified.`/`regressed.` conforme o caso.

## Casos de Borda

- **Repo React (package.json com react, sem angular.json):** este
  playbook NÃO se aplica — sinalizar `needs-stack-playbook.` e seguir
  convenções do AGENTS.md do repo
- **MFE sem shell local (integração só em ambiente):** validar componente
  isoladamente via testes; integração visual fica para homologação
- **AngularJS legado no workspace:** não misturar; sinalizar no relatório
- **Teste falhando por causa pré-existente:** reportar `regressed.` com o
  spec quebrado; corrigir apenas se for do escopo da task

## Formato de commit

```
feat(<mfe>): <descricao-curta>
```

(Convenção final pertence ao AGENTS.md do repo — este playbook só
sugere o estilo dominante.)
