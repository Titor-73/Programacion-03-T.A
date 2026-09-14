-- Consultas de apoyo; no crean reportes adicionales ni modifican datos.
USE pazcompras;
SET SESSION time_zone = '-05:00';
SET @fecha_consulta = NOW();
SET @id_sede = NULL; -- NULL: cadena completa (administrador). 1 o 2: una sede.
SET @desde = DATE(@fecha_consulta) - INTERVAL 7 DAY;
SET @hasta = DATE(@fecha_consulta) + INTERVAL 1 DAY; -- extremo superior EXCLUSIVO
SET @dias_proximo = 7; -- ejemplo configurable; el documento no fija este umbral

-- 1. Cuentas y perfiles. No se muestran hashes.
SELECT u.id_usuario, u.nombres, u.apellidos, u.correo, u.rol, c.id_sede, u.activo
FROM usuario u LEFT JOIN cajero c ON c.id_usuario = u.id_usuario
ORDER BY u.id_usuario;

-- 2. Catalogo y stock por sede.
-- Las reservas vencidas se descuentan del saldo retenido PARA ESTA CONSULTA.
-- La futura capa transaccional debera persistir VENCIDO y la liberacion una sola vez.
-- Es una vista efectiva, no una actualizacion del stock almacenado.
WITH reservas_vencidas AS (
    SELECT p.id_sede, dp.id_producto, SUM(dp.cantidad) AS unidades
    FROM pedido p JOIN detalle_pedido dp ON dp.id_pedido = p.id_pedido
    WHERE p.estado IN ('RESERVADO','EN_PREPARACION','LISTO_PARA_RECOJO')
      AND p.fecha_expiracion_reserva <= @fecha_consulta
    GROUP BY p.id_sede, dp.id_producto
)
SELECT s.nombre AS sede, pr.codigo, pr.nombre AS producto, pr.precio_regular,
       i.stock_fisico, i.stock_reservado AS reservado_almacenado,
       COALESCE(rv.unidades,0) AS reservas_por_liberar,
       i.stock_reservado - COALESCE(rv.unidades,0) AS reservado_vigente,
       i.stock_fisico - i.stock_reservado + COALESCE(rv.unidades,0) AS stock_disponible,
       i.stock_minimo,
       (i.stock_fisico - i.stock_reservado + COALESCE(rv.unidades,0) <= i.stock_minimo) AS bajo_stock
FROM inventario_producto i
JOIN sede s ON s.id_sede = i.id_sede
JOIN producto pr ON pr.id_producto = i.id_producto
LEFT JOIN reservas_vencidas rv ON rv.id_sede = i.id_sede AND rv.id_producto = i.id_producto
WHERE (@id_sede IS NULL OR i.id_sede = @id_sede) AND i.activo = 1 AND pr.activo = 1
ORDER BY i.id_sede, pr.id_producto;

-- 3. Los estados de los lotes se calculan al consultar; no se almacenan.
-- Un lote que vence hoy es PROXIMO_A_VENCER, igual que el metodo Java.
SELECT s.nombre AS sede, pr.nombre AS producto, l.codigo_lote, l.cantidad_actual,
       l.fecha_vencimiento,
       CASE
           WHEN l.fecha_vencimiento IS NULL THEN 'VIGENTE'
           WHEN l.fecha_vencimiento < DATE(@fecha_consulta) THEN 'VENCIDO'
           WHEN l.fecha_vencimiento <= DATE(@fecha_consulta) + INTERVAL @dias_proximo DAY
               THEN 'PROXIMO_A_VENCER'
           ELSE 'VIGENTE'
       END AS estado_vencimiento
FROM lote_inventario l
JOIN inventario_producto i ON i.id_inventario_producto = l.id_inventario_producto
JOIN producto pr ON pr.id_producto = i.id_producto
JOIN sede s ON s.id_sede = i.id_sede
WHERE (@id_sede IS NULL OR i.id_sede = @id_sede)
ORDER BY i.id_sede, l.id_lote;

-- 4. Estado efectivo de los pedidos, sin temporizadores ni eventos programados.
SELECT p.id_pedido, p.id_sede, p.id_cliente, p.id_cajero, p.fecha_creacion,
       p.fecha_expiracion_reserva, p.estado AS estado_almacenado,
       CASE WHEN p.estado IN ('RESERVADO','EN_PREPARACION','LISTO_PARA_RECOJO')
                  AND p.fecha_expiracion_reserva <= @fecha_consulta
            THEN 'VENCIDO' ELSE p.estado END AS estado_efectivo,
       p.total_referencial
FROM pedido p WHERE (@id_sede IS NULL OR p.id_sede = @id_sede)
ORDER BY p.id_pedido;

-- 5. Promociones globales vigentes: una fila por promocion y producto.
-- No define acumulacion ni prioridad entre promociones superpuestas.
SELECT pm.nombre AS promocion, pr.nombre AS producto, pr.precio_regular,
       dp.tipo_descuento, dp.valor_descuento,
       ROUND(CASE dp.tipo_descuento
           WHEN 'PORCENTAJE' THEN pr.precio_regular * (1-dp.valor_descuento/100)
           WHEN 'MONTO_FIJO' THEN GREATEST(0, pr.precio_regular-dp.valor_descuento)
           WHEN 'PRECIO_ESPECIAL' THEN dp.valor_descuento
       END,2) AS precio_promocional,
       pm.fecha_inicio, pm.fecha_fin
FROM promocion pm
JOIN detalle_promocion dp ON dp.id_promocion = pm.id_promocion
JOIN producto pr ON pr.id_producto = dp.id_producto
WHERE pm.estado = 'ACTIVA' AND pm.fecha_inicio <= @fecha_consulta
      AND @fecha_consulta < pm.fecha_fin AND pr.activo = 1
ORDER BY pm.id_promocion, pr.id_producto;

-- 6. Historial de ventas; el importe historico proviene de la venta,
-- no del precio actual del producto.
SET @id_producto = NULL;
SELECT v.id_venta, v.fecha_hora, v.id_sede, v.id_cajero, v.id_pedido,
       v.subtotal, v.descuento_total, v.total
FROM venta v
WHERE v.fecha_hora >= @desde AND v.fecha_hora < @hasta
  AND (@id_sede IS NULL OR v.id_sede = @id_sede)
  AND (@id_producto IS NULL OR EXISTS (
      SELECT 1 FROM detalle_venta dv
      WHERE dv.id_venta = v.id_venta AND dv.id_producto = @id_producto))
ORDER BY v.fecha_hora, v.id_venta;

-- 7. RF-16: metricas en pantalla. No es un tercer reporte.
SELECT COUNT(*) AS cantidad_ventas, COALESCE(SUM(v.total),0) AS ingresos,
       COALESCE(SUM(d.unidades),0) AS unidades_vendidas
FROM venta v
JOIN (SELECT id_venta, SUM(cantidad) AS unidades FROM detalle_venta GROUP BY id_venta) d
    ON d.id_venta = v.id_venta
WHERE v.fecha_hora >= @desde AND v.fecha_hora < @hasta
  AND (@id_sede IS NULL OR v.id_sede = @id_sede);

-- 8. RF-17: REPORTE 1, ventas por sede y periodo.
-- Se agrupan primero los detalles para no multiplicar los totales de cabecera.
SELECT s.id_sede, s.nombre AS sede, COUNT(v.id_venta) AS cantidad_ventas,
       COALESCE(SUM(d.unidades),0) AS unidades_vendidas, COALESCE(SUM(v.total),0) AS monto_total
FROM sede s
LEFT JOIN venta v ON v.id_sede = s.id_sede AND v.fecha_hora >= @desde AND v.fecha_hora < @hasta
LEFT JOIN (SELECT id_venta, SUM(cantidad) AS unidades FROM detalle_venta GROUP BY id_venta) d
    ON d.id_venta = v.id_venta
WHERE (@id_sede IS NULL OR s.id_sede = @id_sede)
GROUP BY s.id_sede, s.nombre ORDER BY s.id_sede;

-- 9. RF-18: REPORTE 2, diez productos mas vendidos.
-- Si se vendieron menos de diez productos, devuelve los que existan.
SELECT pr.id_producto, pr.codigo, pr.nombre, SUM(dv.cantidad) AS unidades_vendidas,
       SUM(dv.subtotal) AS monto_vendido
FROM detalle_venta dv JOIN venta v ON v.id_venta = dv.id_venta
JOIN producto pr ON pr.id_producto = dv.id_producto
WHERE v.fecha_hora >= @desde AND v.fecha_hora < @hasta
  AND (@id_sede IS NULL OR v.id_sede = @id_sede)
GROUP BY pr.id_producto, pr.codigo, pr.nombre
ORDER BY unidades_vendidas DESC, pr.id_producto ASC LIMIT 10;
