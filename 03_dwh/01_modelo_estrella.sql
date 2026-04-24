-- =============================================
-- CAPA DWH — Modelo estrella
-- Proyecto: FinBridge | Business Intelligence Pipeline
-- =============================================

-- dim_ubicacion
CREATE TABLE dwh.dim_ubicacion (
    id_ubicacion INT PRIMARY KEY,
    pais VARCHAR(100),
    provincia VARCHAR(100),
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(20),
    region VARCHAR(50)
);

INSERT INTO dwh.dim_ubicacion
SELECT * FROM staging.ubicaciones;

-- dim_tipo_transaccion
CREATE TABLE dwh.dim_tipo_transaccion (
    id_tipo_transaccion INT PRIMARY KEY,
    nombre_tipo VARCHAR(100),
    descripcion VARCHAR(255),
    categoria VARCHAR(50),
    aplica_comision BOOLEAN,
    limite_monto DECIMAL
);

INSERT INTO dwh.dim_tipo_transaccion
SELECT * FROM staging.tipos_transaccion;

-- dim_cliente
CREATE TABLE dwh.dim_cliente (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    edad INT,
    ocupacion VARCHAR(100),
    tipo_cliente VARCHAR(50),
    email VARCHAR(150),
    telefono VARCHAR(20),
    fecha_registro DATE,
    estado VARCHAR(50),
    id_ubicacion INT REFERENCES dwh.dim_ubicacion(id_ubicacion)
);

INSERT INTO dwh.dim_cliente
SELECT * FROM staging.clientes;

-- dim_tiempo
CREATE TABLE dwh.dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    fecha DATE,
    dia INT,
    mes INT,
    nombre_mes VARCHAR(20),
    trimestre INT,
    anio INT,
    dia_semana VARCHAR(20),
    es_fin_de_semana BOOLEAN
);

INSERT INTO dwh.dim_tiempo
SELECT
    ROW_NUMBER() OVER (ORDER BY fecha) AS id_tiempo,
    fecha,
    EXTRACT(DAY FROM fecha) AS dia,
    EXTRACT(MONTH FROM fecha) AS mes,
    TO_CHAR(fecha, 'TMMonth') AS nombre_mes,
    EXTRACT(QUARTER FROM fecha) AS trimestre,
    EXTRACT(YEAR FROM fecha) AS anio,
    TO_CHAR(fecha, 'TMDay') AS dia_semana,
    EXTRACT(ISODOW FROM fecha) IN (6, 7) AS es_fin_de_semana
FROM (
    SELECT DISTINCT CAST(fecha_hora AS DATE) AS fecha
    FROM staging.transacciones
) fechas;

-- fact_transacciones
CREATE TABLE dwh.fact_transacciones (
    id_transaccion INT PRIMARY KEY,
    id_cliente INT REFERENCES dwh.dim_cliente(id_cliente),
    id_tiempo INT REFERENCES dwh.dim_tiempo(id_tiempo),
    id_tipo_transaccion INT REFERENCES dwh.dim_tipo_transaccion(id_tipo_transaccion),
    id_ubicacion INT REFERENCES dwh.dim_ubicacion(id_ubicacion),
    monto DECIMAL,
    moneda VARCHAR(10),
    estado_transaccion VARCHAR(50),
    canal VARCHAR(50),
    descripcion VARCHAR(255),
    ip_origen VARCHAR(50),
    comision DECIMAL
);

INSERT INTO dwh.fact_transacciones
SELECT
    t.id_transaccion,
    t.id_cliente,
    d.id_tiempo,
    t.id_tipo_transaccion,
    t.id_ubicacion,
    t.monto,
    t.moneda,
    t.estado_transaccion,
    t.canal,
    t.descripcion,
    t.ip_origen,
    t.comision
FROM staging.transacciones t
JOIN dwh.dim_tiempo d ON CAST(t.fecha_hora AS DATE) = d.fecha;
