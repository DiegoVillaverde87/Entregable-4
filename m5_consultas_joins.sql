-- ============================================================
-- RetailPro - Cruzando tablas para enriquecer el análisis
-- Pre-entrega: Consultas con JOINs para el proyecto (Módulo 5)
-- Autor: Diego Villaverde
-- Fecha: 2026-10-26
-- Motor: SQL Server (SSMS)
-- Requisito: ejecutar primero ventas_tech_db.sql del Módulo 3.
-- ============================================================
-- Dimensiones disponibles: clientes, productos y categorias.
-- ciudad_cliente permite agrupar por residencia del comprador;
-- categoria_producto permite comparar familias de productos.
-- Los hallazgos corresponden a los datos de ejemplo de M3:
-- 5 clientes, 6 productos y 10 ventas, todas de marzo de 2024.
-- Si se modifica esa carga, corresponde revisar los hallazgos.

USE [Ventas_Tech_DB];
GO

-- ============================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: reunir cada venta con el cliente, producto y categoría
-- para disponer del detalle que se utilizará en Power BI.
-- La ciudad corresponde al cliente, no al lugar donde ocurrió la venta.
-- El total usa el precio unitario registrado en la operación.
-- ============================================================

SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email AS email_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto,
    cat.id_categoria,
    cat.nombre_categoria AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;

-- Hallazgo: las 10 ventas suman 6.444,00; Computación aporta
-- 4.950,00, equivalentes al 76,82 % de la facturación de la muestra.

-- ============================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes registrados sin primera compra
-- para que CRM pueda planificar acciones de activación.
-- Se filtra la PK de ventas: NULL indica ausencia de coincidencias.
-- ============================================================

SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro, c.id_cliente;

-- Hallazgo: aparecen 0 de los 5 clientes registrados; todos compraron.
-- CRM no tiene clientes pendientes de primera compra en esta muestra.

-- ============================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento
-- para que el área de producto revise su oferta y promoción.
-- El LEFT JOIN a categorias conserva incluso un producto sin categoría.
-- Se usa el precio actual del catálogo, porque no existe una venta.
-- ============================================================

SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria_producto,
    p.precio
FROM productos AS p
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.id_producto;

-- Hallazgo: aparecen 0 de los 6 productos; todos registran ventas.
-- El área de producto no detecta artículos sin movimiento en esta carga.

-- ============================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: comparar la facturación de dos tramos de marzo de 2024.
-- canal se crea como literal en cada SELECT y etiqueta el período;
-- no representa un canal Online o Presencial observado en el origen.
-- Ambos SELECT devuelven fecha_venta, total y canal, en ese orden.
-- Los rangos no se superponen: cada venta de marzo entra una sola vez.
-- UNION ALL conserva ventas aunque coincidan fecha, importe y etiqueta.
-- ============================================================

SELECT
    canal,
    SUM(total) AS total_canal
FROM (
    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Marzo 01 al 10' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-01'
      AND fecha_venta < '2024-03-11'

    UNION ALL

    SELECT
        fecha_venta,
        cantidad * precio_unitario AS total,
        'Marzo 11 al 31' AS canal
    FROM ventas
    WHERE fecha_venta >= '2024-03-11'
      AND fecha_venta < '2024-04-01'
) AS consolidado
GROUP BY canal
ORDER BY canal;

-- Hallazgo: del 1 al 10 de marzo se facturan 3.620,00 y del 11 al 31,
-- 2.824,00; el primer tramo supera al segundo en 796,00.
