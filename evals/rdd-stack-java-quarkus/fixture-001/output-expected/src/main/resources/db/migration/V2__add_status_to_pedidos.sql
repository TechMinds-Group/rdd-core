-- V2: adiciona status aos pedidos (migrada da DDL manual fix-pedidos.sql)
ALTER TABLE PEDIDOS ADD (
    STATUS VARCHAR2(20) DEFAULT 'ABERTO' NOT NULL
);
