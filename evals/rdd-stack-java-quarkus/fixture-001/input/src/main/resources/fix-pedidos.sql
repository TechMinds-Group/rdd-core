-- DDL MANUAL — aplicar direto no banco (VIOLA a convenção Flyway)
ALTER TABLE PEDIDOS ADD (
    STATUS VARCHAR2(20) DEFAULT 'ABERTO' NOT NULL
);
