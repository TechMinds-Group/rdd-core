---
project: Contatos App
module: design-brief
audience: [design]
status: draft
---
# DESIGN_BRIEF — Contatos App

> Contexto de produto para geração de design no Figma Make.
> Fonte: PROJECT_CHARTER.md, REQUIREMENTS.md, UI_SPEC.md — 29/09/2026

## 1. Identidade do produto

- **Nome:** Contatos App
- **Posicionamento:** aplicativo leve de gestão de contatos pessoais — simplicidade radical, menos cliques que a concorrência.
- **Tom de voz:** direto e amigável (público consumidor final, perfil não técnico)
- **Diferencial:** cadastro rápido — um contato em menos de 20 segundos

## 2. Propósito e públicos

- **Propósito:** cadastro rápido, busca instantânea e organização por etiquetas de contatos pessoais.
- **Públicos/atores:** Usuário — dono dos contatos; acesso total às próprias informações.

## 3. Identidade visual

- **Paleta:** a definir — sugestão: paleta clara e neutra com um acento vibrante para o FAB, coerente com a simplicidade radical do posicionamento
- **Tipografia:** a definir — sugestão: sans-serif de sistema, legibilidade em listas
- **Densidade/estilo geral:** listas espaçadas, cantos suaves, foco em toque
- **Iconografia:** a definir — sugestão: ícones outline de traço simples

## 4. Design system / padrões visuais

- **Padrões de layout:** AppBar + campo de busca + lista de itens (avatar, nome, etiqueta) + FAB — UI_SPEC §2.3
- **Regras de UI globais:** telefone no formato (XX) XXXXX-XXXX; diálogo nativo de confirmação antes de excluir; toasts de sucesso no topo com auto-dismiss em 3s — UI_SPEC §5

## 5. Estado atual da UI

- **Status do produto:** greenfield — nada implementado
- **Telas já especificadas/existentes:** Lista de Contatos (UI_SPEC §2.1 — especificada, não implementada)
- **Padrões já adotados:** nenhum (greenfield)

## 6. Constraints de design

- Interface orientada a toque (FAB, listas) — alvos de toque generosos
- Confirmação obrigatória antes de excluir (diálogo nativo)
- **Out of scope (não prototipar):** importação de agendas externas, compartilhamento social

## 7. Telas prioritárias

1. Lista de Contatos — tela inicial e fluxo crítico (cadastro em menos de 20 segundos)

## 8. Instruções para o Figma Make

**Faça:**
- Siga as regras de UI globais da seção 4 (formato de telefone, toasts, confirmações)
- Prototipe o fluxo de cadastro completo partindo da Lista de Contatos

**Não faça:**
- Não invente funcionalidades de out-of-scope (importação de agendas, compartilhamento)
- Não adicione telas além da especificada sem confirmação
- Não apresente sugestões como decisões confirmadas (paleta e tipografia estão "a definir")