-- ============================================================
-- pazcompras | MySQL 8.0+
-- DATOS DE PRUEBA: toda la carga es una sola transaccion.
-- Script de Carga de Datos y Prueba (DML)
-- ============================================================
USE pazcompras;
SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;
SET @ahora = NOW();
SET @hoy = DATE(@ahora);
-- Clave exclusiva para demostracion: PazComprasDemo2026!
-- Hash scrypt individual con sal aleatoria; formato documentado en README.
INSERT INTO usuario (id_usuario,nombres,apellidos,correo,contrasena_hash,telefono,rol) VALUES
(1,'Freddy','Paz','fpaz@example.test','scrypt$131072$8$1$wgar5MFgTV0uyDCSccow4w==$r92DlQlfbBthvA5YLhmcZ5mVAwEiNcrZGyUCuQQPQYw=',NULL,'ADMINISTRADOR'),
(2,'Jose Luis','Corcuera','jlcorcuera@example.test','scrypt$131072$8$1$UkEqTqpQP8jFQwK7w0p2QQ==$hU+KQZ9Lk5OKB8m05aQPQ/20TYdScUyolVYsHoRY2QU=',NULL,'CAJERO'),
(3,'Rony','Cueva','cajero.norte@example.test','scrypt$131072$8$1$AfDWoVPvKSdJDkfeSFkhBw==$d9TLEpqgtLjepba5CEb12Ja1t34LGNeRmaFakPHQuHo=',NULL,'CAJERO'),
(4,'Ana','Roncal','cliente.uno@example.test','scrypt$131072$8$1$X4qtedFawNrXZiUReVNAeg==$j+5OLjl7xJzYmwsYOvJSO8PjIs+CwkK2OL/AQXcvyuA=',NULL,'CLIENTE'),
(5,'Erasmo','Gomez','cliente.dos@example.test','scrypt$131072$8$1$jMA4b+/9xKoS+uCY8HYSBA==$NJjn6A3nHHrhilf/y45xYUbDJGZiFaZawSqm8kbxUfI=',NULL,'CLIENTE'),
(6,'Viktor','KHLEBNIKOV','vkhlebn@example.test','scrypt$131072$8$1$1aFz2izcKRmWYfD0ctUUOQ==$9kXI1k1edxCzh7nEZjjnXr5MSbR0X0WBAnDI1mJZkuU=',NULL,'CLIENTE');
INSERT INTO cliente (id_usuario) VALUES (4),(5),(6);
UPDATE usuario SET fecha_registro = @ahora - INTERVAL 30 DAY;
INSERT INTO administrador (id_usuario) VALUES (1);
INSERT INTO sede (id_sede,nombre,direccion,telefono,horario_apertura,horario_cierre) VALUES
(1,'Sede Centro','Direccion ficticia Centro 100',NULL,'07:00:00','23:00:00'),
(2,'Sede Norte','Direccion ficticia Norte 200',NULL,'08:00:00','22:00:00');
INSERT INTO cajero (id_usuario,codigo_empleado,id_sede) VALUES (2,'CAJ-001',1),(3,'CAJ-002',2);
INSERT INTO categoria (id_categoria,nombre,descripcion) VALUES
(1,'Bebidas','Bebidas y lacteos'),(2,'Alimentos','Snacks y alimentos'),(3,'Limpieza','Limpieza e higiene');
INSERT INTO producto (id_producto,codigo,nombre,descripcion,precio_regular,controla_vencimiento,id_categoria) VALUES
(1,'AGUA-001','Agua 625 ml','Producto de demostracion sin control de vencimiento',2.50,FALSE,1),
(2,'LECHE-001','Leche 1 L','Control de vencimiento por lote',5.00,TRUE,1),
(3,'GALLETA-001','Galletas','Control de vencimiento por lote',3.00,TRUE,2),
(4,'JABON-001','Jabon','Producto sin control de vencimiento',5.50,FALSE,3);
INSERT INTO promocion (id_promocion,nombre,descripcion,fecha_inicio,fecha_fin,estado) VALUES
(1,'Promocion global vigente','Descuentos de demostracion',@ahora-INTERVAL 2 DAY,@ahora+INTERVAL 5 DAY,'ACTIVA'),
(2,'Proxima campana','Todavia no vigente',@ahora+INTERVAL 7 DAY,@ahora+INTERVAL 14 DAY,'PROGRAMADA'),
(3,'Campana anterior','Historico',@ahora-INTERVAL 20 DAY,@ahora-INTERVAL 10 DAY,'FINALIZADA'),
(4,'Campana cancelada','No aplicable',@ahora-INTERVAL 1 DAY,@ahora+INTERVAL 3 DAY,'CANCELADA');
INSERT INTO detalle_promocion (id_detalle_promocion,tipo_descuento,valor_descuento,id_promocion,id_producto) VALUES
(1,'PORCENTAJE',10.00,1,1),(2,'MONTO_FIJO',0.50,1,3),(3,'PRECIO_ESPECIAL',4.80,1,2),
(4,'PORCENTAJE',15.00,2,4),(5,'MONTO_FIJO',0.25,3,3),(6,'PORCENTAJE',5.00,4,4);
-- Saldos resultantes del historial que se inserta al final.
INSERT INTO inventario_producto
(id_inventario_producto,stock_fisico,stock_reservado,stock_minimo,ultima_actualizacion,id_sede,id_producto) VALUES
(1,24,3,5,@ahora,1,1),
(2,10,2,3,@ahora,1,2),
(3,19,0,4,@ahora,1,3),
(4,8,0,8,@ahora,1,4),
(5,20,1,5,@ahora,2,1),
(6,9,0,2,@ahora,2,2),
(7,15,2,3,@ahora,2,3),
(8,4,0,4,@ahora,2,4);
INSERT INTO lote_inventario
(id_lote,codigo_lote,cantidad_actual,fecha_ingreso,fecha_vencimiento,id_inventario_producto) VALUES
(1,'LOTE-1',24,@hoy-INTERVAL 7 DAY,NULL,1),
(2,'LOTE-2',10,@hoy-INTERVAL 7 DAY,@hoy+INTERVAL 2 DAY,2),
(3,'LOTE-3',19,@hoy-INTERVAL 7 DAY,@hoy+INTERVAL 60 DAY,3),
(4,'LOTE-4',8,@hoy-INTERVAL 7 DAY,NULL,4),
(5,'LOTE-5',20,@hoy-INTERVAL 7 DAY,NULL,5),
(6,'LOTE-6',9,@hoy-INTERVAL 7 DAY,@hoy+INTERVAL 2 DAY,6),
(7,'LOTE-7',15,@hoy-INTERVAL 7 DAY,@hoy+INTERVAL 60 DAY,7),
(8,'LOTE-8',4,@hoy-INTERVAL 7 DAY,NULL,8),
(9,'LECHE-RETIRADA',0,@hoy-INTERVAL 7 DAY,@hoy-INTERVAL 1 DAY,2);
INSERT INTO pedido
(id_pedido,fecha_creacion,fecha_expiracion_reserva,fecha_preparacion,fecha_listo_recojo,fecha_entrega,fecha_cancelacion,motivo_cancelacion,estado,total_referencial,id_cliente,id_sede,id_cajero) VALUES
(1,@ahora-INTERVAL 30 MINUTE,@ahora+INTERVAL 90 MINUTE,NULL,NULL,NULL,NULL,NULL,'RESERVADO',6.75,4,1,NULL),
(2,@ahora-INTERVAL 45 MINUTE,@ahora+INTERVAL 75 MINUTE,@ahora-INTERVAL 35 MINUTE,NULL,NULL,NULL,NULL,'EN_PREPARACION',9.60,5,1,2),
(3,@ahora-INTERVAL 20 MINUTE,@ahora+INTERVAL 100 MINUTE,@ahora-INTERVAL 15 MINUTE,@ahora-INTERVAL 10 MINUTE,NULL,NULL,NULL,'LISTO_PARA_RECOJO',7.25,6,2,3),
(4,@ahora-INTERVAL 1440 MINUTE,@ahora-INTERVAL 1320 MINUTE,@ahora-INTERVAL 1435 MINUTE,@ahora-INTERVAL 1420 MINUTE,@ahora-INTERVAL 1410 MINUTE,NULL,NULL,'ENTREGADO',11.50,4,1,2),
(5,@ahora-INTERVAL 180 MINUTE,@ahora-INTERVAL 60 MINUTE,NULL,NULL,NULL,@ahora-INTERVAL 170 MINUTE,'Cancelado por el cliente','CANCELADO',4.80,5,1,NULL),
(6,@ahora-INTERVAL 240 MINUTE,@ahora-INTERVAL 120 MINUTE,NULL,NULL,NULL,NULL,NULL,'VENCIDO',7.50,6,2,NULL);
INSERT INTO detalle_pedido
(id_detalle_pedido,cantidad,precio_referencial,descuento_referencial,subtotal_referencial,id_pedido,id_producto) VALUES
(1,3,2.50,0.25,6.75,1,1),(2,2,5.00,0.20,9.60,2,2),
(3,1,2.50,0.25,2.25,3,1),(4,2,3.00,0.50,5.00,3,3),
(5,4,2.50,0.25,9.00,4,1),(6,1,3.00,0.50,2.50,4,3),
(7,1,5.00,0.20,4.80,5,2),(8,3,3.00,0.50,7.50,6,3);
INSERT INTO venta
(id_venta,fecha_hora,subtotal,descuento_total,total,id_sede,id_cajero,id_pedido) VALUES
(1,@ahora-INTERVAL 1410 MINUTE,13.00,1.50,11.50,1,2,4),
(2,@ahora-INTERVAL 3000 MINUTE,5.00,0.00,5.00,1,2,NULL),
(3,@ahora-INTERVAL 25 MINUTE,10.50,0.20,10.30,2,3,NULL);
INSERT INTO detalle_venta
(id_detalle_venta,cantidad,precio_unitario,descuento_unitario,subtotal,id_venta,id_producto) VALUES
(1,4,2.50,0.25,9.00,1,1),(2,1,3.00,0.50,2.50,1,3),
(3,2,2.50,0.00,5.00,2,1),(4,1,5.00,0.20,4.80,3,2),(5,1,5.50,0.00,5.50,3,4);
INSERT INTO movimiento_inventario
(id_movimiento,tipo,cantidad,fecha_hora,motivo,origen,stock_fisico_resultante,stock_reservado_resultante,id_inventario_producto,id_lote,id_usuario) VALUES
(1,'INGRESO',30,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',30,0,1,1,1),
(2,'INGRESO',12,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',12,0,2,NULL,1),
(3,'INGRESO',20,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',20,0,3,3,1),
(4,'INGRESO',8,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',8,0,4,4,1),
(5,'INGRESO',20,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',20,0,5,5,1),
(6,'INGRESO',10,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',10,0,6,6,1),
(7,'INGRESO',15,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',15,0,7,7,1),
(8,'INGRESO',5,@ahora-INTERVAL 10080 MINUTE,'Ingreso inicial de prueba','MANUAL',5,0,8,8,1),
(9,'VENTA',2,@ahora-INTERVAL 3000 MINUTE,'Venta directa 2','VENTA',28,0,1,1,2),
(10,'RESERVA',4,@ahora-INTERVAL 1440 MINUTE,'Pedido 4','PEDIDO',28,4,1,NULL,4),
(11,'RESERVA',1,@ahora-INTERVAL 1440 MINUTE,'Pedido 4','PEDIDO',20,1,3,NULL,4),
(12,'VENTA',4,@ahora-INTERVAL 1410 MINUTE,'Venta 1 de pedido 4','VENTA',24,4,1,1,2),
(13,'LIBERACION_RESERVA',4,@ahora-INTERVAL 1410 MINUTE,'Entrega de pedido 4','VENTA',24,0,1,NULL,2),
(14,'VENTA',1,@ahora-INTERVAL 1410 MINUTE,'Venta 1 de pedido 4','VENTA',19,1,3,3,2),
(15,'LIBERACION_RESERVA',1,@ahora-INTERVAL 1410 MINUTE,'Entrega de pedido 4','VENTA',19,0,3,NULL,2),
(16,'VENCIMIENTO',2,@ahora-INTERVAL 360 MINUTE,'Retiro de lote vencido','MANUAL',10,0,2,9,2),
(17,'MERMA',1,@ahora-INTERVAL 350 MINUTE,'Envase deteriorado','MANUAL',18,0,3,3,2),
(18,'AJUSTE_POSITIVO',2,@ahora-INTERVAL 340 MINUTE,'Ajuste por conteo','MANUAL',20,0,3,3,1),
(19,'AJUSTE_NEGATIVO',1,@ahora-INTERVAL 330 MINUTE,'Correccion de conteo','MANUAL',19,0,3,3,1),
(20,'RESERVA',3,@ahora-INTERVAL 240 MINUTE,'Pedido 6','PEDIDO',15,3,7,NULL,6),
(21,'RESERVA',1,@ahora-INTERVAL 180 MINUTE,'Pedido 5','PEDIDO',10,1,2,NULL,5),
(22,'LIBERACION_RESERVA',1,@ahora-INTERVAL 170 MINUTE,'Cancelacion de pedido 5','PEDIDO',10,0,2,NULL,5),
(23,'LIBERACION_RESERVA',3,@ahora-INTERVAL 120 MINUTE,'Pedido 6 vencido al consultar','SISTEMA',15,0,7,NULL,3),
(24,'RESERVA',2,@ahora-INTERVAL 45 MINUTE,'Pedido 2','PEDIDO',10,2,2,NULL,5),
(25,'RESERVA',3,@ahora-INTERVAL 30 MINUTE,'Pedido 1','PEDIDO',24,3,1,NULL,4),
(26,'VENTA',1,@ahora-INTERVAL 25 MINUTE,'Venta directa 3','VENTA',9,0,6,6,3),
(27,'VENTA',1,@ahora-INTERVAL 25 MINUTE,'Venta directa 3','VENTA',4,0,8,8,3),
(28,'RESERVA',1,@ahora-INTERVAL 20 MINUTE,'Pedido 3','PEDIDO',20,1,5,NULL,6),
(29,'RESERVA',2,@ahora-INTERVAL 20 MINUTE,'Pedido 3','PEDIDO',15,2,7,NULL,6);
COMMIT;

-- Verificacion inmediata de la carga.
SELECT 'Carga completa' AS resultado, (SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema='pazcompras' AND table_type='BASE TABLE') AS tablas,
(SELECT COUNT(*) FROM pedido) AS pedidos, (SELECT COUNT(*) FROM venta) AS ventas;
