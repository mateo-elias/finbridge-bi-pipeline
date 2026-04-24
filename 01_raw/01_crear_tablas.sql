-- =============================================
-- CAPA RAW — Creación de tablas
-- Proyecto: FinBridge | Business Intelligence Pipeline
-- =============================================

-- Schemas
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA dwh;

-- Tabla: raw.ubicaciones
CREATE TABLE raw.ubicaciones (
    id_ubicacion INT,
    pais VARCHAR(100),
    provincia VARCHAR(100),
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(20),
    region VARCHAR(50)
);

-- Tabla: raw.clientes
CREATE TABLE raw.clientes (
    id_cliente INT,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    edad INT,
    ocupacion VARCHAR(100),
    tipo_cliente VARCHAR(50),
    email VARCHAR(150),
    telefono VARCHAR(20),
    fecha_registro VARCHAR(50),
    estado VARCHAR(50),
    id_ubicacion INT
);

-- Tabla: raw.tipos_transaccion
CREATE TABLE raw.tipos_transaccion (
    id_tipo_transaccion INT,
    nombre_tipo VARCHAR(100),
    descripcion VARCHAR(255),
    categoria VARCHAR(50),
    aplica_comision VARCHAR(10),
    limite_monto VARCHAR(50)
);

-- Tabla: raw.transacciones
CREATE TABLE raw.transacciones (
    id_transaccion INT,
    id_cliente INT,
    id_tipo_transaccion INT,
    id_ubicacion INT,
    fecha_hora VARCHAR(50),
    monto VARCHAR(50),
    moneda VARCHAR(10),
    estado_transaccion VARCHAR(50),
    canal VARCHAR(50),
    descripcion VARCHAR(255),
    ip_origen VARCHAR(50),
    comision VARCHAR(50)
);
