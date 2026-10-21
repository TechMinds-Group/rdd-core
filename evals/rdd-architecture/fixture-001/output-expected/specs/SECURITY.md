---
project: BLOQUEIOS-SANITARIO
module: seguranca
audience: [tecnica]
status: draft
---

# Segurança — Bloqueios Sanitários

> **Derivado de:** REQUIREMENTS.md §2 (atores e permissões), specs/DATA_MODEL.md

---

## 1. Autenticação

| Aspecto | Definição |
|---|---|
| Quem acessa | Operadores e Consultores internos (REQUIREMENTS §2) |
| Emissor de GTA | Integração servidor-a-servidor (GET gta-status) |
| Sessão | Autenticação obrigatória para todos os endpoints de escrita |

## 2. Autorização

| Ator | Permissões | Endpoints |
|---|---|---|
| Operador | Criar e encerrar bloqueios | POST /bloqueios, POST /bloqueios/{id}/encerramento |
| Consultor | Somente leitura | GET /bloqueios |
| Emissor GTA | Somente leitura de status | GET /bloqueios/gta-status/{idProdutor} |

**Regra:** o perfil do usuário autenticado é verificado em cada endpoint;
tentativa de escrita por Consultor → 403.

## 3. Dados Sensíveis

| Dado | Classificação | Tratamento |
|---|---|---|
| Motivo do bloqueio | Operacional | Sem PII — texto livre auditado |
| Vínculo com produtor | Referência externa | Somente COD_PRODUTOR; dados cadastrais do produtor ficam no sistema de origem |
| Histórico (HIST_BLOQUEIO) | Trilha de auditoria | Append-only — sem UPDATE/DELETE |

## 4. Auditoria

- Toda escrita em BLOQUEIO preenche CTR_DTH_INC, CTR_USU_INC (e equivalentes
  de atualização) — exigência de REQUIREMENTS.md §9 / RN-001
- Eventos de ciclo de vida registrados em HIST_BLOQUEIO (DEC-001):
  CRIADO e ENCERRADO, com usuário e data/hora

## 5. Ameaças e Mitigações

| Ameaça | Mitigação |
|---|---|
| Bloqueio duplicado por corrida | Validação de bloqueio ativo na escrita + constraint no banco (RN-002) |
| Encerramento sem rastreio | Motivo obrigatório + evento em HIST_BLOQUEIO (RN-004) |
| Alteração silenciosa de status | Histórico append-only impossibilita reescrever eventos |
