# REQUIREMENTS — Módulo Bloqueios (fixture de eval)

> **Propósito:** Testar derivação de modelo de dados com 2 entidades relacionadas

## 6. Dados e Campos

### RN-001 — Cadastro de Produtor

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| nome | Texto (100) | Sim | Nome completo do produtor |
| cpfCnpj | Texto (14) | Sim | CPF ou CNPJ do produtor |
| email | Texto (100) | Não | E-mail para contato |
| dataCadastro | Data | Sim | Data de cadastro |

### RN-002 — Cadastro de Propriedade

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| nomePropriedade | Texto (200) | Sim | Nome da propriedade |
| endereco | Texto (300) | Sim | Endereço completo |
| areaHectares | Número (10,2) | Sim | Área em hectares |
| idProdutor | Número | Sim | ID do produtor responsável |

## 9. Persistência e Auditoria

### Tabelas envolvidas

- **PRODUTOR** — cadastro de produtores (CRUD)
- **PROPRIEDADE** — cadastro de propriedades vinculadas a produtor (CRUD)

### Finalidade

Armazenar dados cadastrais de produtores e suas propriedades para
controle de bloqueios sanitários.

### Rastreabilidade

- RN-001 → PRODUTOR (INSERT, SELECT, UPDATE)
- RN-002 → PROPRIEDADE (INSERT, SELECT, UPDATE) com FK para PRODUTOR
- Relacionamento: 1:N (PRODUTOR → PROPRIEDADE)