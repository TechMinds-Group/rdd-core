---
project: BLOQUEIOS-SANITARIO
module: requisitos
status: confirmado
---

# REQUIREMENTS — Bloqueios Sanitários

## 2. Atores e Permissões

| Ator | Permissões |
|---|---|
| Operador | Criar, listar e encerrar bloqueios |
| Consultor | Apenas visualizar bloqueios |

## 5. Regras de Negócio

### RN-001 [confirmado]
Quando um bloqueio for aplicado a um produtor, então o sistema deve registrar data, hora e usuário responsável do bloqueio.

### RN-002 [confirmado]
Se o produtor já possuir bloqueio ativo, então o sistema deve rejeitar o novo bloqueio com o erro BLOQ_DUPLICADO.

### RN-003 [confirmado]
Enquanto o produtor possuir bloqueio ativo, o sistema deve impedir a emissão de GTA para o produtor.

### RN-004 [confirmado]
Quando um bloqueio for encerrado, então o sistema deve registrar o motivo do encerramento no histórico de bloqueios.

## 6. Dados e Campos

### RN-001 — Aplicação de bloqueio

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| idProdutor | Número | Sim | ID do produtor bloqueado |
| motivo | Texto (500) | Sim | Motivo do bloqueio |

### RN-004 — Encerramento de bloqueio

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| idBloqueio | Número | Sim | ID do bloqueio a encerrar |
| motivoFim | Texto (500) | Sim | Motivo do encerramento |

## 7. Casos de Uso

### UC-01 — Aplicar bloqueio (RN-001, RN-002)
Operador informa produtor e motivo; sistema valida duplicidade e registra o bloqueio com auditoria.

### UC-02 — Consultar bloqueios (RN-003)
Consultor lista bloqueios ativos por produtor e vê o status de GTA.

### UC-03 — Encerrar bloqueio (RN-004)
Operador encerra um bloqueio ativo informando o motivo do encerramento.

## 8. Saídas e Integrações

- Relatório de bloqueios ativos por produtor (tela UC-02)
- Status de bloqueio exposto ao emissor de GTA (RN-003)

## 9. Persistência e Auditoria

TODO: definir volume de dados e politica de retencão do histórico.

### Tabelas envolvidas

- **BLOQUEIO** — bloqueios de produtores (INSERT, SELECT, UPDATE)
- **HIST_BLOQUEIO** — histórico de eventos de bloqueio (INSERT)

### Rastreabilidade

- RN-001 → BLOQUEIO (INSERT)
- RN-002 → BLOQUEIO (SELECT)
- RN-003 → BLOQUEIO (SELECT) — consumido pelo emissor de GTA
- RN-004 → BLOQUEIO (UPDATE), HIST_BLOQUEIO (INSERT)

