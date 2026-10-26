-- ============================================================
-- RetailPro - Extrayendo métricas clave con SQL
-- Pre-entrega: Consultas SQL de negocio (Módulo 4)
-- Autor: Diego Villaverde
-- Fecha: 2026-10-26
-- Motor: SQL Server (SSMS)
-- Requisito: Ventas_Tech_DB creada y cargada con el script de M3.
-- ============================================================
-- Se consulta únicamente la tabla ventas, sin modificar sus datos.
-- Se cuenta cada fila de ventas como un pedido en este ejercicio.
-- Los importes se calculan siempre como cantidad * precio_unitario.

USE [Ventas_Tech_DB];
GO

-- ============================================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- ============================================================
-- SUM obtiene la facturación y COUNT(*) cuenta los pedidos.
-- AVG calcula el importe promedio de los pedidos de cada mes.
-- Se agrupa por año y mes para no mezclar meses de distintos años.
-- DECIMAL muestra el ticket promedio con dos decimales.

SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    CAST(AVG(cantidad * precio_unitario) AS DECIMAL(18, 2)) AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;

-- ============================================================
-- CONSULTA 2: RANKING DE LOS CINCO PRODUCTOS CON MAYOR FACTURACIÓN
-- ============================================================
-- Se suman las unidades y la facturación por id_producto.
-- TOP 5 limita el resultado después de ordenar de mayor a menor.
-- Si dos productos facturan lo mismo, se ordenan por id_producto.

SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC, id_producto ASC;

-- ============================================================
-- CONSULTA 3: CLIENTES RECURRENTES
-- ============================================================
-- HAVING filtra los grupos: se conservan clientes con más de un pedido.

SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC, id_cliente ASC;

-- ============================================================
-- CONSULTA 4: COMPARACIÓN CON EL PROMEDIO MENSUAL GENERAL
-- ============================================================
-- WITH define resultados temporales para organizar el cálculo.
-- Primero se calcula la facturación de cada año y mes.
-- Después se promedian esos totales mensuales, no los pedidos.
-- El promedio incluye únicamente meses con ventas registradas.
-- Se compara sin redondear; solo se formatea el promedio mostrado.
-- Si el total coincide con el promedio, se informa "En el promedio".

;WITH facturacion_mensual AS (
    SELECT
        YEAR(fecha_venta) AS anio,
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
), comparacion_mensual AS (
    SELECT
        anio,
        mes,
        total_facturado,
        (SELECT AVG(total_facturado) FROM facturacion_mensual) AS promedio_mensual_general
    FROM facturacion_mensual
)
SELECT
    anio,
    mes,
    total_facturado,
    CAST(promedio_mensual_general AS DECIMAL(18, 2)) AS promedio_mensual_general,
    CASE
        WHEN total_facturado > promedio_mensual_general THEN 'Por encima'
        WHEN total_facturado < promedio_mensual_general THEN 'Por debajo'
        ELSE 'En el promedio'
    END AS comparacion_con_promedio
FROM comparacion_mensual
ORDER BY anio, mes;

-- ============================================================
-- BLOQUE DE CIERRE: TRES HALLAZGOS DE NEGOCIO
-- ============================================================
-- Alcance: los 10 registros de ventas del archivo ventas_tech_db.sql de M3.
-- Si se modifican esos datos, corresponde revisar estos hallazgos.
--
-- 1. Marzo de 2024 factura 6.444,00 en 10 pedidos, con un ticket
--    promedio de 644,40. Es el único mes cargado: por eso la consulta 4
--    lo clasifica "En el promedio"; no hay otros meses para comparar.
--
-- 2. El producto 1 lidera la facturación con 3 unidades y 3.600,00,
--    equivalentes al 55,87 % del total (3.600 / 6.444 * 100).
--
-- 3. Los cinco clientes registran dos pedidos cada uno y todos son
--    recurrentes. El cliente 1 es quien más gasta: 2.640,00.
