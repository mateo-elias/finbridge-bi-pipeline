-- =============================================
-- CAPA STAGING — Limpieza y transformación
-- Proyecto: FinBridge | Business Intelligence Pipeline
-- =============================================

-- staging.ubicaciones
CREATE TABLE staging.ubicaciones AS
SELECT
    id_ubicacion,
    TRIM(pais) AS pais,
    TRIM(provincia) AS provincia,
    TRIM(ciudad) AS ciudad,
    TRIM(codigo_postal) AS codigo_postal,
    TRIM(region) AS region
FROM raw.ubicaciones;

-- staging.tipos_transaccion
CREATE TABLE staging.tipos_transaccion AS
SELECT
    id_tipo_transaccion,
    TRIM(nombre_tipo) AS nombre_tipo,
    TRIM(descripcion) AS descripcion,
    TRIM(categoria) AS categoria,
    CASE 
        WHEN TRIM(aplica_comision) = 'si' THEN TRUE
        ELSE FALSE
    END AS aplica_comision,
    CASE
        WHEN limite_monto IS NULL THEN 0
        ELSE CAST(limite_monto AS DECIMAL)
    END AS limite_monto
FROM raw.tipos_transaccion;

-- staging.clientes
-- Correcciones: email NULL → valor por defecto / fecha formato DD-MM-YYYY → DATE
CREATE TABLE staging.clientes AS
SELECT
    id_cliente,
    TRIM(nombre) AS nombre,
    TRIM(apellido) AS apellido,
    edad,
    TRIM(ocupacion) AS ocupacion,
    TRIM(tipo_cliente) AS tipo_cliente,
    COALESCE(TRIM(email), 'sin_email@finbridge.com') AS email,
    TRIM(telefono) AS telefono,
    CASE
        WHEN fecha_registro ~ '^\d{2}-\d{2}-\d{4}$'
        THEN TO_DATE(fecha_registro, 'DD-MM-YYYY')
        ELSE TO_DATE(fecha_registro, 'YYYY-MM-DD')
    END AS fecha_registro,
    TRIM(estado) AS estado,
    id_ubicacion
FROM raw.clientes;

-- staging.transacciones
-- Exclusiones: monto NULL / monto negativo / fecha inválida
CREATE TABLE staging.transacciones AS
SELECT
    id_transaccion,
    id_cliente,
    id_tipo_transaccion,
    id_ubicacion,
    fecha_hora,
    CAST(monto AS DECIMAL) AS monto,
    TRIM(moneda) AS moneda,
    TRIM(estado_transaccion) AS estado_transaccion,
    TRIM(canal) AS canal,
    TRIM(descripcion) AS descripcion,
    TRIM(ip_origen) AS ip_origen,
    CAST(comision AS DECIMAL) AS comision
FROM raw.transacciones
WHERE monto IS NOT NULL
AND CAST(monto AS DECIMAL) > 0
AND fecha_hora NOT LIKE '%32-%'
AND fecha_hora NOT LIKE '%-13-%';
