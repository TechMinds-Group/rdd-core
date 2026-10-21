# Architecture Decision Records — Bloqueios Sanitários

## ADR-001: Histórico unificado de eventos de bloqueio

**Status:** Aceito
**Data:** 20/09/2026
**Decisor:** Victor Souza
**Contexto:** Era preciso definir onde registrar os eventos de bloqueio
(criação e encerramento). Alternativa rejeitada: tabelas separadas por tipo
de evento (fragmenta a consulta histórica).
**Decisão:** Eventos de bloqueio (criação e encerramento) serão registrados
em uma única tabela HIST_BLOQUEIO, diferenciados por tipo de evento.
**Consequências:** Consulta histórica unificada; modelo de dados com 1
tabela de histórico; API de consulta de histórico unificada.