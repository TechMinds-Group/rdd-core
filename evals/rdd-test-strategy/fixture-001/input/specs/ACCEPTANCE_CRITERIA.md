---
project: BLOQUEIOS-SANITARIO
module: aceitacao
audience: [tecnica]
status: draft
---

# Critérios de Aceitação — Bloqueios Sanitários

> **Derivado de:** REQUIREMENTS.md §5 (RN-001, RN-002, RN-003, RN-004)
> **Formato:** Gherkin (Dado-Quando-Então), derivado de EARS

---

## RN-001

**Tipo EARS:** Evento — "Quando um bloqueio for aplicado..., então o sistema deve registrar..."

### Cenário: Aplicar bloqueio com auditoria completa

**Dado** que o Operador está autenticado
**Quando** o Operador aplica um bloqueio a um produtor sem bloqueio ativo, informando o motivo
**Então** o sistema registra o bloqueio com data, hora e o usuário responsável (Operador autenticado)

---

## RN-002

**Tipo EARS:** Indesejado — "Se o produtor já possuir bloqueio ativo..., então o sistema deve rejeitar..."

### Cenário: Bloqueio duplicado é rejeitado

**Dado** que o produtor possui um bloqueio com status ativo
**Quando** o Operador tenta aplicar um novo bloqueio ao mesmo produtor
**Então** o sistema rejeita a operação com o erro BLOQ_DUPLICADO
**E** nenhum novo registro de bloqueio é criado

### Cenário: Bloqueio após encerramento anterior é permitido

**Dado** que o produtor possui apenas bloqueios com status encerrado
**Quando** o Operador aplica um novo bloqueio informando o motivo
**Então** o sistema registra o bloqueio normalmente

---

## RN-003

**Tipo EARS:** Estado — "Enquanto o produtor possuir bloqueio ativo, o sistema deve impedir..."

**Background:**

**Dado** que o produtor possui um bloqueio com status ativo

### Cenário: Emissão de GTA impedida durante bloqueio

**Dado** que o produtor possui bloqueio ativo
**Quando** o emissor de GTA consulta o status do produtor
**Então** o sistema indica bloqueio ativo e a emissão de GTA é impedida

### Cenário: Emissão de GTA liberada após encerramento

**Dado** que o bloqueio do produtor foi encerrado
**Quando** o emissor de GTA consulta o status do produtor
**Então** o sistema indica ausência de bloqueio ativo e a emissão de GTA é permitida

---

## RN-004

**Tipo EARS:** Evento — "Quando um bloqueio for encerrado..., então o sistema deve registrar..."

### Cenário: Encerramento registra motivo no histórico

**Dado** que o produtor possui um bloqueio com status ativo
**Quando** o Operador encerra o bloqueio informando o motivo do encerramento
**Então** o sistema muda o status do bloqueio para encerrado
**E** o sistema registra no histórico de bloqueios um evento de encerramento com o motivo informado, data, hora e usuário responsável

### Cenário: Encerramento exige motivo

**Dado** que o produtor possui um bloqueio com status ativo
**Quando** o Operador tenta encerrar o bloqueio sem informar o motivo
**Então** o sistema rejeita a operação com erro de validação de campo obrigatório
