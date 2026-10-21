---
project: EVAL
module: mudancas
status: draft
---
# Registro de Mudancas

## CR-001: Prazo de bloqueio configuravel

**Status:** pending
**Data:** 17/10/2026
**Solicitante:** PO
**RN afetada:** RN-001
**Origem:** requisito-mal-capturado
**Descricao:** O prazo de bloqueio deve ser configuravel por cultivo.
**Justificativa:** A RN-001 nao especificou o prazo; a lacuna so foi
descoberta apos a implementacao (requisito mal capturado no clarify).
**Downstreams afetados:** DATA_MODEL

## CR-002: Registro sem origem (exemplo de registro incompleto)

**Status:** pending
**Data:** 17/10/2026
**Solicitante:** PO
**RN afetada:** RN-001
**Descricao:** CR de exemplo sem campo Origem.

> Invariante IMP-099: CR sem campo Origem = registro incompleto.
> A agregacao de metricas trata como N/A (sem dados) - nunca inventa origem.
