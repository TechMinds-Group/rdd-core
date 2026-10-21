---
project: PORTAL-NOTICIAS
module: requisitos
status: confirmado
---

# REQUIREMENTS — Portal de Notícias

> Módulo sem análise reversa — RNs de reuniões de negócio, sem tags de confiança.

## 5. Regras de Negócio

### RN-001 [confirmado]
Quando o editor publicar uma notícia, então o sistema deve registrar data, hora e autor da publicação.

### RN-002 [confirmado]
Se a notícia tiver data de expiração no passado, então o sistema deve removê-la da home automaticamente.

## 6. Dados e Campos

### RN-001 — Publicação de notícia

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| titulo | Texto (200) | Sim | Título da notícia |
| autor | Referência | Sim | Autor da publicação |

### RN-002 — Expiração de notícia

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| dataExpiracao | Data | Não | Data limite de exibição na home |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **NOTICIA** — notícias do portal (INSERT, SELECT, UPDATE)

### Rastreabilidade

- RN-001 → NOTICIA (INSERT)
- RN-002 → NOTICIA (UPDATE status)
