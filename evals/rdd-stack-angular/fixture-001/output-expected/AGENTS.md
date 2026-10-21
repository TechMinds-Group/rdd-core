# AGENTS — Portal.FE

Instruções do agente para o repo Portal.FE (Angular 21 standalone, MFE, Bootstrap).

## Comandos

- Testes: `ng test`
- Lint: `ng lint`

## Formulários (Angular)

- **Reactive Forms** obrigatório — `FormBuilder` + `Validators` com as
  validações exatamente como em UI_SPEC.md (obrigatórios, máscaras, limites).
- Regras de exibição condicional da UI_SPEC → **bindings no template**
  (`[disabled]`, `*ngIf` sobre o form) — nunca lógica hardcoded no component.
- Persistência via service com `HttpClient` (um por recurso do API_CONTRACTS.md).
- Suíte `ng test` inteira verde antes de concluir — não apenas os specs novos.
