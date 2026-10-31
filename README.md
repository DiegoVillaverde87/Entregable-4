# RetailPro

Proyecto formativo de análisis de ventas, clientes y productos de Diego Villaverde. El objetivo es documentar consultas SQL reproducibles y preparar información para el análisis comercial en Power BI.

Este repositorio reúne las pre-entregas de SQL de los módulos 4 y 5. El caso de negocio se llama RetailPro; la base de ejemplo utilizada conserva el nombre `Ventas_Tech_DB` y la referencia a TechStore del script de M3.

## Herramientas

- **SQL Server 2016 o posterior**: motor de la base de datos.
- **SQL Server Management Studio (SSMS)**: ejecución y revisión de los scripts.
- **Power BI, Power Query y DAX**: preparación, modelado y visualización del proyecto.
- **GitHub**: publicación y control de versiones.
- **ChatGPT**, disponible con versión gratuita: apoyo para revisar SQL, proponer hallazgos y documentar. Sus sugerencias requieren evaluación técnica.

Los archivos de Power BI se mantienen en repositorios de otras etapas; no forman parte de este repositorio.

## Archivos disponibles

| Archivo | Contenido |
| --- | --- |
| [m4_consultas_negocio.sql](m4_consultas_negocio.sql) | Resumen ejecutivo mensual, ranking de cinco productos por facturación, clientes recurrentes y comparación con el promedio mensual. |
| [m5_consultas_joins.sql](m5_consultas_joins.sql) | Detalle de ventas con INNER JOIN, clientes y productos sin ventas con LEFT JOIN y comparación de dos tramos de marzo mediante UNION ALL. |

## Requisito previo y orden de ejecución

La base debe crearse y cargarse con el [script ventas_tech_db.sql de M3](https://github.com/DiegoVillaverde87/data-analytics-practicas/blob/main/ventas_tech_db.sql), publicado en otro repositorio del mismo autor.

1. Abrí SSMS y conectate a una instancia de SQL Server 2016 o posterior con permisos para crear la base y las tablas.
2. Descargá y abrí `ventas_tech_db.sql` de M3. Revisalo y ejecutalo con **F5** o **Ejecutar**. El script crea `Ventas_Tech_DB` si no existe y selecciona esa base.
3. Abrí y ejecutá `m4_consultas_negocio.sql`. El propio archivo selecciona `Ventas_Tech_DB` mediante `USE`.
4. Abrí y ejecutá `m5_consultas_joins.sql`.
5. Revisá las grillas de resultados antes de utilizarlas en Power BI.

**El script de M3 contiene DROP TABLE y recrea las cuatro tablas. Al volver a ejecutarlo, elimina sus datos actuales y repone la muestra.** Usalo en la base de práctica. Los scripts de M4 y M5 consultan los datos sin modificarlos.

Los archivos utilizan T-SQL y separadores `GO`, por lo que estas instrucciones corresponden a SSMS conectado a SQL Server.

## Comprobación de la carga original

La muestra contiene 4 categorías, 5 clientes, 6 productos y 10 ventas, todas de marzo de 2024.

Con esa carga, la consulta 1 de M4 debe devolver:

| Año | Mes | Facturación | Pedidos | Ticket promedio |
| --- | --- | --- | --- | --- |
| 2024 | 3 | 6.444,00 | 10 | 644,40 |

La consulta 2 de M4 debe mostrar los productos en este orden:

| id_producto | Unidades vendidas | Facturación |
| --- | --- | --- |
| 1 | 3 | 3.600,00 |
| 3 | 3 | 1.350,00 |
| 5 | 3 | 390,00 |
| 6 | 4 | 380,00 |
| 2 | 13 | 364,00 |

El detalle de la consulta 1 de M5 debe conservar 10 filas, con 10 valores distintos de `id_venta`, y sumar 6.444,00 en `total_venta`.

Si se modifica la carga, estos valores de referencia deben actualizarse.

## Definiciones y límites del análisis

- **Facturación**: suma de `cantidad * precio_unitario`, usando el precio registrado en cada venta. El script no declara una moneda.
- **Pedido**: para este ejercicio, cada fila de `ventas` se cuenta como un pedido. La base no tiene un identificador de pedido separado que agrupe varias líneas.
- **Ticket promedio**: facturación dividida por la cantidad de filas de venta del período.
- **Ciudad**: `ciudad_cliente` corresponde a la residencia del comprador. No identifica una sucursal ni el lugar donde ocurrió la venta.
- **Canal de la consulta 4 de M5**: es una etiqueta creada para dos períodos de marzo. No representa un canal comercial Online o Presencial observado.
- **Ranking**: devuelve solo cinco de los seis productos. Los cinco suman 6.084,00; los 360,00 restantes corresponden al producto 4 y no significan ausencia de ventas.
- **INNER JOIN**: la carga original tiene todas las relaciones completas. Las claves foráneas del esquema admiten nulos, por lo que una carga futura podría perder filas en este cruce si faltan cliente, producto o categoría.

La muestra permite practicar agregaciones y cruces, pero un solo mes no permite inferir tendencias ni estacionalidad. Sin costos ni márgenes, la facturación tampoco permite concluir rentabilidad. Antes de continuar el proyecto con nuevos datos, validá relaciones, cantidades de filas y totales, y revisá los hallazgos documentados.
