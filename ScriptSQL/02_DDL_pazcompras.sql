-- ======================================================================================
-- PazCompras | MySQL 8.0.16+ | InnoDB | UTF-8
-- Crear en una instancia de desarrollo. No borra ni reemplaza una base existente.
-- Ejecutar una sola vez y detenerse ante cualquier error.
-- Fuente: dominio Java del commit d4439345 y alcance corregido.
-- Las fechas DATETIME se interpretan como hora local de Lima.
-- ======================================================================================
SET NAMES utf8mb4;
SET SESSION time_zone = '-05:00';
CREATE DATABASE IF NOT EXISTS pazcompras CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
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
