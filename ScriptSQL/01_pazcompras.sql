-- PazCompras | MySQL 8.0.16+ | InnoDB | UTF-8
-- Crear en una instancia de desarrollo. No borra ni reemplaza una base existente.
-- Ejecutar una sola vez y detenerse ante cualquier error.
-- Fuente: dominio Java del commit d4439345 y alcance corregido.
-- Las fechas DATETIME se interpretan como hora local de Lima.
SET NAMES utf8mb4;
SET SESSION time_zone = '-05:00';
CREATE DATABASE pazcompras CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE pazcompras;

-- Herencia: una cuenta base y una tabla por subtipo, como persona/empleado
-- en el ejemplo del profesor. rol es el discriminador de la clase Java.
CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(254) NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso DATETIME NULL,
    rol ENUM('CLIENTE','CAJERO','ADMINISTRADOR') NOT NULL,
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT uq_usuario_rol UNIQUE (id_usuario, rol),
    CONSTRAINT ck_usuario_activo CHECK (activo IN (0,1)),
    CONSTRAINT ck_usuario_hash CHECK (CHAR_LENGTH(contrasena_hash) >= 60)
) ENGINE=InnoDB;

CREATE TABLE cliente (
    id_usuario INT PRIMARY KEY,
    rol ENUM('CLIENTE','CAJERO','ADMINISTRADOR') NOT NULL DEFAULT 'CLIENTE',
    CONSTRAINT ck_cliente_rol CHECK (rol = 'CLIENTE'),
    CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario, rol)
        REFERENCES usuario (id_usuario, rol)
) ENGINE=InnoDB;

CREATE TABLE administrador (
    id_usuario INT PRIMARY KEY,
    rol ENUM('CLIENTE','CAJERO','ADMINISTRADOR') NOT NULL DEFAULT 'ADMINISTRADOR',
    CONSTRAINT ck_administrador_rol CHECK (rol = 'ADMINISTRADOR'),
    CONSTRAINT fk_administrador_usuario FOREIGN KEY (id_usuario, rol)
        REFERENCES usuario (id_usuario, rol)
) ENGINE=InnoDB;

CREATE TABLE sede (
    id_sede INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL COMMENT 'Direccion de la tienda, no de entrega',
    telefono VARCHAR(20),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    horario_apertura TIME NOT NULL,
    horario_cierre TIME NOT NULL,
    CONSTRAINT ck_sede_activa CHECK (activa IN (0,1))
) ENGINE=InnoDB;

CREATE TABLE cajero (
    id_usuario INT PRIMARY KEY,
    codigo_empleado VARCHAR(30) NOT NULL,
    id_sede INT NOT NULL,
    rol ENUM('CLIENTE','CAJERO','ADMINISTRADOR') NOT NULL DEFAULT 'CAJERO',
    CONSTRAINT uq_cajero_codigo UNIQUE (codigo_empleado),
    CONSTRAINT uq_cajero_sede UNIQUE (id_usuario, id_sede),
    CONSTRAINT ck_cajero_rol CHECK (rol = 'CAJERO'),
    CONSTRAINT fk_cajero_usuario FOREIGN KEY (id_usuario, rol)
        REFERENCES usuario (id_usuario, rol),
    CONSTRAINT fk_cajero_sede FOREIGN KEY (id_sede) REFERENCES sede (id_sede)
) ENGINE=InnoDB;

CREATE TABLE categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre),
    CONSTRAINT ck_categoria_activa CHECK (activa IN (0,1))
) ENGINE=InnoDB;

CREATE TABLE producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(40) NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500),
    precio_regular DECIMAL(12,2) NOT NULL,
    imagen_url VARCHAR(2048),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    controla_vencimiento BOOLEAN NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_categoria INT NOT NULL,
    CONSTRAINT uq_producto_codigo UNIQUE (codigo),
    CONSTRAINT ck_producto_precio CHECK (precio_regular >= 0),
    CONSTRAINT ck_producto_flags CHECK (activo IN (0,1) AND controla_vencimiento IN (0,1)),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
    INDEX ix_producto_nombre (nombre),
    INDEX ix_producto_precio (precio_regular)
) ENGINE=InnoDB;

CREATE TABLE promocion (
    id_promocion INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion VARCHAR(500),
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    estado ENUM('PROGRAMADA','ACTIVA','FINALIZADA','CANCELADA') NOT NULL DEFAULT 'PROGRAMADA',
    CONSTRAINT ck_promocion_fechas CHECK (fecha_fin > fecha_inicio),
    INDEX ix_promocion_vigencia (estado, fecha_inicio, fecha_fin)
) ENGINE=InnoDB;

CREATE TABLE detalle_promocion (
    id_detalle_promocion INT PRIMARY KEY AUTO_INCREMENT,
    tipo_descuento ENUM('PORCENTAJE','MONTO_FIJO','PRECIO_ESPECIAL') NOT NULL,
    valor_descuento DECIMAL(12,2) NOT NULL,
    id_promocion INT NOT NULL,
    id_producto INT NOT NULL,
    CONSTRAINT uq_detalle_promocion_producto UNIQUE (id_promocion, id_producto),
    CONSTRAINT ck_detalle_promocion_valor CHECK (
        valor_descuento >= 0 AND (tipo_descuento <> 'PORCENTAJE' OR valor_descuento <= 100)),
    CONSTRAINT fk_detalle_promocion_cabecera FOREIGN KEY (id_promocion) REFERENCES promocion (id_promocion),
    CONSTRAINT fk_detalle_promocion_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
) ENGINE=InnoDB;

CREATE TABLE inventario_producto (
    id_inventario_producto INT PRIMARY KEY AUTO_INCREMENT,
    stock_fisico INT NOT NULL DEFAULT 0,
    stock_reservado INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 0,
    ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    id_sede INT NOT NULL,
    id_producto INT NOT NULL,
    CONSTRAINT uq_inventario_sede_producto UNIQUE (id_sede, id_producto),
    CONSTRAINT ck_inventario_stock CHECK (
        stock_fisico >= 0 AND stock_reservado >= 0
        AND stock_reservado <= stock_fisico AND stock_minimo >= 0),
    CONSTRAINT ck_inventario_activo CHECK (activo IN (0,1)),
    CONSTRAINT fk_inventario_sede FOREIGN KEY (id_sede) REFERENCES sede (id_sede),
    CONSTRAINT fk_inventario_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
) ENGINE=InnoDB;

CREATE TABLE lote_inventario (
    id_lote INT PRIMARY KEY AUTO_INCREMENT,
    codigo_lote VARCHAR(60) NOT NULL,
    cantidad_actual INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_vencimiento DATE NULL COMMENT 'NULL para productos sin control de vencimiento',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    id_inventario_producto INT NOT NULL,
    CONSTRAINT uq_lote_codigo UNIQUE (id_inventario_producto, codigo_lote),
    CONSTRAINT uq_lote_inventario UNIQUE (id_lote, id_inventario_producto),
    CONSTRAINT ck_lote_cantidad CHECK (cantidad_actual >= 0),
    CONSTRAINT ck_lote_activo CHECK (activo IN (0,1)),
    CONSTRAINT fk_lote_inventario FOREIGN KEY (id_inventario_producto)
        REFERENCES inventario_producto (id_inventario_producto),
    INDEX ix_lote_vencimiento (fecha_vencimiento)
) ENGINE=InnoDB;

CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion_reserva DATETIME NOT NULL,
    fecha_preparacion DATETIME NULL,
    fecha_listo_recojo DATETIME NULL,
    fecha_entrega DATETIME NULL,
    fecha_cancelacion DATETIME NULL,
    motivo_cancelacion VARCHAR(500),
    estado ENUM('RESERVADO','EN_PREPARACION','LISTO_PARA_RECOJO','ENTREGADO','CANCELADO','VENCIDO')
        NOT NULL DEFAULT 'RESERVADO',
    total_referencial DECIMAL(14,2) NOT NULL DEFAULT 0,
    id_cliente INT NOT NULL,
    id_sede INT NOT NULL,
    id_cajero INT NULL COMMENT 'Puede asignarse cuando el cajero comienza la atencion',
    CONSTRAINT uq_pedido_sede UNIQUE (id_pedido, id_sede),
    CONSTRAINT ck_pedido_duracion CHECK (
        fecha_expiracion_reserva = DATE_ADD(fecha_creacion, INTERVAL 2 HOUR)),
    CONSTRAINT ck_pedido_total CHECK (total_referencial >= 0),
    CONSTRAINT ck_pedido_entrega CHECK (
        (estado = 'ENTREGADO' AND fecha_entrega IS NOT NULL
         AND fecha_entrega >= fecha_creacion AND fecha_entrega < fecha_expiracion_reserva)
        OR (estado <> 'ENTREGADO' AND fecha_entrega IS NULL)),
    CONSTRAINT ck_pedido_cancelacion CHECK (
        (estado = 'CANCELADO' AND fecha_cancelacion IS NOT NULL
         AND fecha_cancelacion >= fecha_creacion)
        OR (estado <> 'CANCELADO' AND fecha_cancelacion IS NULL)),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_usuario),
    CONSTRAINT fk_pedido_sede FOREIGN KEY (id_sede) REFERENCES sede (id_sede),
    CONSTRAINT fk_pedido_cajero_sede FOREIGN KEY (id_cajero, id_sede)
        REFERENCES cajero (id_usuario, id_sede),
    INDEX ix_pedido_expiracion (estado, fecha_expiracion_reserva),
    INDEX ix_pedido_cliente_fecha (id_cliente, fecha_creacion)
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
    id_detalle_pedido INT PRIMARY KEY AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio_referencial DECIMAL(12,2) NOT NULL,
    descuento_referencial DECIMAL(12,2) NOT NULL DEFAULT 0,
    subtotal_referencial DECIMAL(14,2) NOT NULL,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    CONSTRAINT uq_detalle_pedido_producto UNIQUE (id_pedido, id_producto),
    CONSTRAINT ck_detalle_pedido_importes CHECK (
        cantidad > 0 AND precio_referencial >= 0 AND descuento_referencial >= 0
        AND descuento_referencial <= precio_referencial
        AND subtotal_referencial = cantidad * (precio_referencial - descuento_referencial)),
    CONSTRAINT fk_detalle_pedido_cabecera FOREIGN KEY (id_pedido) REFERENCES pedido (id_pedido),
    CONSTRAINT fk_detalle_pedido_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
) ENGINE=InnoDB;

CREATE TABLE venta (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(14,2) NOT NULL,
    descuento_total DECIMAL(14,2) NOT NULL DEFAULT 0,
    total DECIMAL(14,2) NOT NULL,
    estado ENUM('REGISTRADA') NOT NULL DEFAULT 'REGISTRADA',
    id_sede INT NOT NULL,
    id_cajero INT NOT NULL,
    id_pedido INT NULL COMMENT 'NULL para venta directa; cobro siempre presencial',
    CONSTRAINT uq_venta_pedido UNIQUE (id_pedido),
    CONSTRAINT ck_venta_importes CHECK (
        subtotal >= 0 AND descuento_total >= 0 AND descuento_total <= subtotal
        AND total = subtotal - descuento_total),
    CONSTRAINT fk_venta_sede FOREIGN KEY (id_sede) REFERENCES sede (id_sede),
    CONSTRAINT fk_venta_cajero_sede FOREIGN KEY (id_cajero, id_sede)
        REFERENCES cajero (id_usuario, id_sede),
    CONSTRAINT fk_venta_pedido_sede FOREIGN KEY (id_pedido, id_sede)
        REFERENCES pedido (id_pedido, id_sede),
    INDEX ix_venta_sede_fecha (id_sede, fecha_hora),
    INDEX ix_venta_fecha (fecha_hora)
) ENGINE=InnoDB;

CREATE TABLE detalle_venta (
    id_detalle_venta INT PRIMARY KEY AUTO_INCREMENT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    descuento_unitario DECIMAL(12,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(14,2) NOT NULL,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    CONSTRAINT uq_detalle_venta_producto UNIQUE (id_venta, id_producto),
    CONSTRAINT ck_detalle_venta_importes CHECK (
        cantidad > 0 AND precio_unitario >= 0 AND descuento_unitario >= 0
        AND descuento_unitario <= precio_unitario
        AND subtotal = cantidad * (precio_unitario - descuento_unitario)),
    CONSTRAINT fk_detalle_venta_cabecera FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
    CONSTRAINT fk_detalle_venta_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
) ENGINE=InnoDB;

CREATE TABLE movimiento_inventario (
    id_movimiento INT PRIMARY KEY AUTO_INCREMENT,
    tipo ENUM('INGRESO','VENTA','AJUSTE_POSITIVO','AJUSTE_NEGATIVO',
              'RESERVA','LIBERACION_RESERVA','MERMA','VENCIMIENTO') NOT NULL,
    cantidad INT NOT NULL COMMENT 'Magnitud positiva; el tipo determina el efecto',
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(500) NOT NULL,
    origen ENUM('MANUAL','PEDIDO','VENTA','SISTEMA') NOT NULL,
    stock_fisico_resultante INT NOT NULL,
    stock_reservado_resultante INT NOT NULL,
    id_inventario_producto INT NOT NULL,
    id_lote INT NULL COMMENT 'Opcional en reservas; siempre pertenece al mismo inventario',
    id_usuario INT NOT NULL COMMENT 'Actor de la operacion; SISTEMA identifica evaluacion bajo demanda',
    CONSTRAINT ck_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_movimiento_stock CHECK (
        stock_fisico_resultante >= 0 AND stock_reservado_resultante >= 0
        AND stock_reservado_resultante <= stock_fisico_resultante),
    CONSTRAINT fk_movimiento_inventario FOREIGN KEY (id_inventario_producto)
        REFERENCES inventario_producto (id_inventario_producto),
    CONSTRAINT fk_movimiento_lote_inventario FOREIGN KEY (id_lote, id_inventario_producto)
        REFERENCES lote_inventario (id_lote, id_inventario_producto),
    CONSTRAINT fk_movimiento_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    INDEX ix_movimiento_inventario_fecha (id_inventario_producto, fecha_hora)
) ENGINE=InnoDB;

-- ============================================================
-- DATOS DE PRUEBA: toda la carga es una sola transaccion.
-- Las tablas se crean fuera de ella porque DDL hace commit implicito.
-- Los usuarios y direcciones siguientes son ficticios.
-- ============================================================
START TRANSACTION;
SET @ahora = NOW();
SET @hoy = DATE(@ahora);
-- Clave exclusiva para demostracion: PazComprasDemo2026!
-- Hash scrypt individual con sal aleatoria; formato documentado en README.
INSERT INTO usuario (id_usuario,nombres,apellidos,correo,contrasena_hash,telefono,rol) VALUES
(1,'Ana','Prueba','admin@example.test','scrypt$131072$8$1$wgar5MFgTV0uyDCSccow4w==$r92DlQlfbBthvA5YLhmcZ5mVAwEiNcrZGyUCuQQPQYw=',NULL,'ADMINISTRADOR'),
(2,'Luis','Prueba','cajero.centro@example.test','scrypt$131072$8$1$UkEqTqpQP8jFQwK7w0p2QQ==$hU+KQZ9Lk5OKB8m05aQPQ/20TYdScUyolVYsHoRY2QU=',NULL,'CAJERO'),
(3,'Rosa','Prueba','cajero.norte@example.test','scrypt$131072$8$1$AfDWoVPvKSdJDkfeSFkhBw==$d9TLEpqgtLjepba5CEb12Ja1t34LGNeRmaFakPHQuHo=',NULL,'CAJERO'),
(4,'Carla','Ejemplo','cliente.uno@example.test','scrypt$131072$8$1$X4qtedFawNrXZiUReVNAeg==$j+5OLjl7xJzYmwsYOvJSO8PjIs+CwkK2OL/AQXcvyuA=',NULL,'CLIENTE'),
(5,'Pedro','Ejemplo','cliente.dos@example.test','scrypt$131072$8$1$jMA4b+/9xKoS+uCY8HYSBA==$NJjn6A3nHHrhilf/y45xYUbDJGZiFaZawSqm8kbxUfI=',NULL,'CLIENTE'),
(6,'Elena','Ejemplo','cliente.tres@example.test','scrypt$131072$8$1$1aFz2izcKRmWYfD0ctUUOQ==$9kXI1k1edxCzh7nEZjjnXr5MSbR0X0WBAnDI1mJZkuU=',NULL,'CLIENTE');
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
