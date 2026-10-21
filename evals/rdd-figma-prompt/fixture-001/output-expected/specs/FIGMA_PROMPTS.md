---
project: CONTATOS
module: especificacao-visual
audience: [tecnica]
status: active
---

# FIGMA Prompts — Contatos

> Arquivo append-only de prompts gerados para o Figma Make.

## Prompt — 03/09/2026 10:00 (modo: completo)

> **Versão dos documentos:** fixture-001
> **Documentos fonte:** REQUIREMENTS.md, UI_SPEC.md

Crie um protótipo de aplicativo web de agenda de contatos corporativa.

**Contexto:** agenda de contatos corporativa com exportação para agendas telefônicas.

**Atores:** Usuário — visualiza, cadastra e exporta contatos.

**Lista de telas:**

1. **Lista de Contatos** (`/contatos`) — tabela de contatos para consulta e exportação.
   - Layout: cabeçalho com título e botão de ação principal; tabela central com nome e telefone por linha.
   - Campos: nome do contato (texto), telefone (texto formatado).
   - Estados visuais: linha ao passar o mouse; estado vazio com orientação para cadastrar o primeiro contato.
   - RNs que originam a tela: 001, 002.

**Fluxo de navegação:** única tela; exportação abre confirmação e finaliza com toast de sucesso.

**Regras de UI globais:** confirmação explícita antes de exportações; toast de sucesso após exportação.

**Não incluir:** cadastro e edição de contatos, controle de permissões, integrações além da exportação.

**Instrução de estilo:** aplicativo web moderno, tema escuro, componentes de tabela e botões consistentes, tipografia limpa e contraste alto.

---
