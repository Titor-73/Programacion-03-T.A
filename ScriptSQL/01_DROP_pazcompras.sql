-- Desactivar temporalmente la revisión de llaves foráneas para evitar bloqueos
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS movimiento_inventario;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS venta;
DROP TABLE IF EXISTS detalle_pedido;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS lote_inventario;
DROP TABLE IF EXISTS inventario_producto;
DROP TABLE IF EXISTS detalle_promocion;
DROP TABLE IF EXISTS promocion;
DROP TABLE IF EXISTS producto;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS cajero;
DROP TABLE IF EXISTS sede;
DROP TABLE IF EXISTS administrador;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS usuario;

-- DROP DATABASE IF EXISTS pazcompras; -- Opcional: borrar la base de datos completa

SET FOREIGN_KEY_CHECKS = 1;