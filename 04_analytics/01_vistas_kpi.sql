-- =============================================
-- CAPA ANALYTICS — Vistas KPI
-- Proyecto: FinBridge | Business Intelligence Pipeline
-- =============================================

-- KPI: Volumen mensual y ticket promedio
CREATE VIEW dwh.kpi_volumen_mensual AS
SELECT
    d.anio,
    d.mes,
    d.nombre_mes,
    COUNT(f.id_transaccion) AS cantidad_transacciones,
    ROUND(SUM(f.monto), 2) AS volumen_total,
    ROUND(AVG(f.monto), 2) AS ticket_promedio
FROM dwh.fact_transacciones f
JOIN dwh.dim_tiempo d ON f.id_tiempo = d.id_tiempo
WHERE f.estado_transaccion = 'exitosa'
GROUP BY d.anio, d.mes, d.nombre_mes
ORDER BY d.anio, d.mes;

-- KPI: Tipos de transacción más usados
CREATE VIEW dwh.kpi_tipos_transaccion AS
SELECT
    tt.nombre_tipo,
    tt.categoria,
    COUNT(f.id_transaccion) AS cantidad,
    ROUND(SUM(f.monto), 2) AS volumen_total
FROM dwh.fact_transacciones f
JOIN dwh.dim_tipo_transaccion tt ON f.id_tipo_transaccion = tt.id_tipo_transaccion
WHERE f.estado_transaccion = 'exitosa'
GROUP BY tt.nombre_tipo, tt.categoria
ORDER BY cantidad DESC;

-- KPI: Clientes nuevos por mes
CREATE VIEW dwh.kpi_clientes_nuevos AS
SELECT
    d.anio,
    d.mes,
    d.nombre_mes,
    COUNT(c.id_cliente) AS clientes_nuevos
FROM dwh.dim_cliente c
JOIN dwh.dim_tiempo d ON c.fecha_registro = d.fecha
GROUP BY d.anio, d.mes, d.nombre_mes
ORDER BY d.anio, d.mes;

-- KPI: Clientes activos vs inactivos
CREATE VIEW dwh.kpi_clientes_activos AS
SELECT
    estado,
    COUNT(id_cliente) AS cantidad,
    ROUND(COUNT(id_cliente) * 100.0 / SUM(COUNT(id_cliente)) OVER(), 2) AS porcentaje
FROM dwh.dim_cliente
GROUP BY estado
ORDER BY cantidad DESC;

-- KPI: Segmento de cliente
CREATE VIEW dwh.kpi_segmento_cliente AS
SELECT
    c.tipo_cliente,
    COUNT(DISTINCT f.id_cliente) AS cantidad_clientes,
    COUNT(f.id_transaccion) AS cantidad_transacciones,
    ROUND(SUM(f.monto), 2) AS volumen_total,
    ROUND(AVG(f.monto), 2) AS ticket_promedio
FROM dwh.fact_transacciones f
JOIN dwh.dim_cliente c ON f.id_cliente = c.id_cliente
WHERE f.estado_transaccion = 'exitosa'
GROUP BY c.tipo_cliente
ORDER BY volumen_total DESC;

-- KPI: Ubicación geográfica
CREATE VIEW dwh.kpi_ubicacion AS
SELECT
    u.pais,
    u.provincia,
    COUNT(DISTINCT f.id_cliente) AS cantidad_clientes,
    COUNT(f.id_transaccion) AS cantidad_transacciones,
    ROUND(SUM(f.monto), 2) AS volumen_total
FROM dwh.fact_transacciones f
JOIN dwh.dim_cliente c ON f.id_cliente = c.id_cliente
JOIN dwh.dim_ubicacion u ON c.id_ubicacion = u.id_ubicacion
WHERE f.estado_transaccion = 'exitosa'
GROUP BY u.pais, u.provincia
ORDER BY volumen_total DESC;

-- KPI: Calidad — montos
CREATE VIEW dwh.kpi_calidad_montos AS
SELECT
    COUNT(*) AS total_transacciones_raw,
    SUM(CASE WHEN monto IS NULL THEN 1 ELSE 0 END) AS montos_nulos,
    SUM(CASE WHEN CAST(monto AS DECIMAL) < 0 THEN 1 ELSE 0 END) AS montos_negativos
FROM raw.transacciones
WHERE monto IS NOT NULL;

-- KPI: Calidad — fechas
CREATE VIEW dwh.kpi_calidad_fechas AS
SELECT
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN fecha_registro ~ '^\d{2}-\d{2}-\d{4}$' THEN 1 ELSE 0 END) AS fechas_formato_incorrecto
FROM raw.clientes;

-- KPI: Calidad — emails
CREATE VIEW dwh.kpi_calidad_emails AS
SELECT
    COUNT(*) AS total_clientes,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS emails_nulos
FROM raw.clientes;
