-- Todas las filas deben indicar inconsistencias = 0 inmediatamente tras cargar.
-- No corrige ni borra datos. Para comparar reservas se usa el estado almacenado,
-- incluso si la hora de consulta ya supero las dos horas.
USE pazcompras;
SELECT 'stock_y_lotes' AS comprobacion, COUNT(*) AS inconsistencias
FROM inventario_producto i
LEFT JOIN (SELECT id_inventario_producto, SUM(cantidad_actual) cantidad FROM lote_inventario
        GROUP BY id_inventario_producto) l USING(id_inventario_producto)
WHERE i.stock_fisico <> COALESCE(l.cantidad,0)
UNION ALL
SELECT 'reservas_y_pedidos', COUNT(*)
FROM inventario_producto i
LEFT JOIN (
    SELECT p.id_sede, d.id_producto, SUM(d.cantidad) cantidad
    FROM pedido p JOIN detalle_pedido d USING(id_pedido)
    WHERE p.estado IN ('RESERVADO','EN_PREPARACION','LISTO_PARA_RECOJO')
    GROUP BY p.id_sede, d.id_producto
) r ON r.id_sede=i.id_sede AND r.id_producto=i.id_producto
WHERE i.stock_reservado <> COALESCE(r.cantidad,0)
UNION ALL
SELECT 'totales_pedidos', COUNT(*) FROM pedido p
LEFT JOIN (SELECT id_pedido, SUM(subtotal_referencial) total FROM detalle_pedido
            GROUP BY id_pedido) d USING(id_pedido)
WHERE d.total IS NULL OR p.total_referencial <> d.total
UNION ALL
SELECT 'totales_ventas', COUNT(*) FROM venta v
LEFT JOIN (SELECT id_venta, SUM(cantidad*precio_unitario) bruto,
                SUM(cantidad*descuento_unitario) descuento, SUM(subtotal) total
        FROM detalle_venta GROUP BY id_venta) d USING(id_venta)
WHERE d.total IS NULL OR v.subtotal<>d.bruto OR v.descuento_total<>d.descuento OR v.total<>d.total
UNION ALL
SELECT 'entregas_y_ventas', COUNT(*) FROM pedido p LEFT JOIN venta v USING(id_pedido)
WHERE (p.estado='ENTREGADO' AND (v.id_venta IS NULL OR v.fecha_hora<>p.fecha_entrega))
    OR (p.estado<>'ENTREGADO' AND v.id_venta IS NOT NULL)
UNION ALL
SELECT 'subtipo_usuario', COUNT(*) FROM usuario u
LEFT JOIN cliente c ON c.id_usuario=u.id_usuario
LEFT JOIN cajero j ON j.id_usuario=u.id_usuario
LEFT JOIN administrador a ON a.id_usuario=u.id_usuario
WHERE (c.id_usuario IS NOT NULL)+(j.id_usuario IS NOT NULL)+(a.id_usuario IS NOT NULL) <> 1
UNION ALL
SELECT 'productos_con_inventario', COUNT(*) FROM detalle_pedido d
JOIN pedido p USING(id_pedido)
LEFT JOIN inventario_producto i ON i.id_sede=p.id_sede AND i.id_producto=d.id_producto
WHERE i.id_inventario_producto IS NULL
UNION ALL
SELECT 'lotes_control_vencimiento', COUNT(*) FROM lote_inventario l
JOIN inventario_producto i USING(id_inventario_producto) JOIN producto p USING(id_producto)
WHERE (p.controla_vencimiento=1 AND l.fecha_vencimiento IS NULL)
    OR (p.controla_vencimiento=0 AND l.fecha_vencimiento IS NOT NULL)
UNION ALL
SELECT 'saldos_y_movimientos', COUNT(*) FROM inventario_producto i
LEFT JOIN (
    SELECT id_inventario_producto,
        SUM(CASE WHEN tipo IN ('INGRESO','AJUSTE_POSITIVO') THEN cantidad
                    WHEN tipo IN ('VENTA','AJUSTE_NEGATIVO','MERMA','VENCIMIENTO') THEN -cantidad ELSE 0 END) fisico,
        SUM(CASE WHEN tipo='RESERVA' THEN cantidad
                    WHEN tipo='LIBERACION_RESERVA' THEN -cantidad ELSE 0 END) reservado
    FROM movimiento_inventario GROUP BY id_inventario_producto
) m USING(id_inventario_producto)
WHERE i.stock_fisico<>COALESCE(m.fisico,0) OR i.stock_reservado<>COALESCE(m.reservado,0);

-- Cada saldo historico debe coincidir con la acumulacion de movimientos.
WITH historial AS (
    SELECT m.*,
        SUM(CASE WHEN tipo IN ('INGRESO','AJUSTE_POSITIVO') THEN cantidad
                    WHEN tipo IN ('VENTA','AJUSTE_NEGATIVO','MERMA','VENCIMIENTO') THEN -cantidad ELSE 0 END)
            OVER (PARTITION BY id_inventario_producto ORDER BY fecha_hora,id_movimiento) fisico_calculado,
        SUM(CASE WHEN tipo='RESERVA' THEN cantidad
                    WHEN tipo='LIBERACION_RESERVA' THEN -cantidad ELSE 0 END)
            OVER (PARTITION BY id_inventario_producto ORDER BY fecha_hora,id_movimiento) reservado_calculado
    FROM movimiento_inventario m
)
SELECT 'historial_movimientos' AS comprobacion, COUNT(*) AS inconsistencias FROM historial
WHERE stock_fisico_resultante<>fisico_calculado OR stock_reservado_resultante<>reservado_calculado;
