# Base de datos de PazCompras

## Entrega y motor

Script para **MySQL 8.0.16 o superior**, InnoDB y UTF-8. Se recomienda MySQL 8.0
para trabajar con MySQL Workbench 8.0. No es un script para Microsoft SQL Server.
Se tomó como referencia el SQL MySQL del profesor y el modelo Java de PazCompras
del commit `d4439345`. La consigna pide creación de tablas, relaciones y registros
de prueba; no pide DAO esta semana.

- `01_pazcompras.sql`: crea la base, sus **16 tablas**, restricciones e índices,
  y carga los registros de prueba. Es el archivo principal de entrega.
- `02_consultas.sql`: ejemplos de catálogo, stock, pedidos, vencimientos,
  promociones, historial, métricas y exactamente los dos reportes del alcance.
- `03_validaciones.sql`: diez comprobaciones de coherencia de los datos.
- `../scripts/validar_sql.py`: pruebas automáticas para una instancia MySQL
  desechable. La compilación Java permanece en su flujo Maven separado.

## Ejecutar e importar por ingeniería inversa

1. Conectarse desde Workbench a un **servidor MySQL de desarrollo**.
   Workbench es el cliente: instalar Workbench por sí solo no instala el servidor.
2. Abrir `01_pazcompras.sql` y ejecutar el archivo completo con un usuario que
   pueda crear esquemas. Mantener activada la opción de detener la ejecución
   ante errores. El esquema `pazcompras` debe estar ausente.
3. Actualizar el panel **Schemas**. Debe aparecer `pazcompras` con 16 tablas.
4. Ejecutar `03_validaciones.sql`: las diez comprobaciones deben devolver cero.
   Ejecutar `02_consultas.sql` para explorar los ejemplos.
5. Seleccionar **Database > Reverse Engineer**, elegir la misma conexión y
   el esquema `pazcompras`, seleccionar sus tablas y completar el asistente.
   Las relaciones se reconstruyen a partir de las claves foráneas.
6. Revisar el diagrama obtenido y guardarlo como archivo `.mwb` para la entrega.

También es posible importar solo la estructura mediante **File > Import >
Reverse Engineer MySQL Create Script**. Esa alternativa crea un modelo a partir
del archivo; no ejecuta los INSERT ni valida los datos en un servidor.

Documentación oficial:
[ingeniería inversa](https://dev.mysql.com/doc/workbench/en/wb-reverse-engineering.html)
e [importación de un script](https://dev.mysql.com/doc/workbench/en/wb-reverse-engineer-create-script.html).

Desde la consola del cliente MySQL:

```sql
SOURCE /ruta/ScriptSQL/01_pazcompras.sql;
SOURCE /ruta/ScriptSQL/03_validaciones.sql;
SOURCE /ruta/ScriptSQL/02_consultas.sql;
```

El script no tiene DROP, TRUNCATE, DELETE ni desactivación de claves foráneas.
No es una migración sobre una base existente ni una carga repetible: si ya existe
`pazcompras`, se detiene al intentar crearla. Para repetir las pruebas, utilizar
otra instancia vacía o adaptar el nombre del esquema en los tres archivos.
No continuar ejecutando sentencias después de un error.

## Correspondencia con Java

| Tabla | Clase / relación |
| --- | --- |
| usuario | Usuario: datos comunes de cuenta y discriminador de rol |
| cliente | Cliente: mismo identificador que Usuario |
| cajero | Cajero: mismo identificador que Usuario y una sede obligatoria |
| administrador | Administrador: mismo identificador que Usuario, alcance global |
| sede | Sede |
| categoria | Categoria |
| producto | Producto y su categoría global |
| promocion | Promocion global |
| detalle_promocion | DetallePromocion: producto asociado y descuento |
| inventario_producto | InventarioProducto: una fila por sede y producto |
| lote_inventario | LoteInventario |
| movimiento_inventario | MovimientoInventario: inventario, lote opcional y usuario |
| pedido | Pedido: cliente, sede y cajero opcional |
| detalle_pedido | DetallePedido |
| venta | Venta: sede, cajero y pedido opcional |
| detalle_venta | DetalleVenta |

La tabla adicional respecto de las 15 tablas orientativas del PDF es
`administrador`: representa la clase que ya existe en Java y sigue el patrón de
herencia mediante clave primaria compartida del profesor. No agrega funciones
de gestión de administradores.

Las listas de las clases se representan mediante claves foráneas en sus
elementos, no mediante columnas con listas. Los enums se conservan con los
mismos valores de Java. `EstadoVencimiento` es calculado y no necesita una tabla
ni una columna persistida. Los reportes y métricas se calculan desde las ventas.

El discriminador `rol` de las tablas de cuentas es información del mapeo
relacional, no una nueva clase. Sus restricciones impiden que un mismo usuario
se registre simultáneamente como cajero y cliente. La creación de la cuenta y
su fila de subtipo deberá ser atómica en la futura capa de persistencia.

## Integridad representada por el esquema

- Un solo inventario por combinación sede-producto.
- Cajeros de pedidos y ventas pertenecen a la sede de la operación.
- Una venta asociada a pedido pertenece a la sede de ese pedido.
- Un pedido puede tener como máximo una venta. Las ventas directas usan NULL.
- Un movimiento con lote utiliza un lote del mismo inventario.
- Stock físico, reservado y mínimo no negativos; reservado no supera físico.
- Cantidades de detalle positivas; importes y descuentos coherentes por fila.
- Vencimiento de la reserva exactamente dos horas después de su creación.
- Venta únicamente en estado REGISTRADA; sin estados posteriores de anulación.
- Identificadores, códigos, correo y relaciones con restricciones explícitas.

Los CHECK requieren MySQL 8.0.16+ para su aplicación efectiva:
[documentación oficial](https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html).
No se usan borrados en cascada; el dominio usa activación/desactivación y conserva
el historial.

## Qué deberá coordinar la aplicación

Este entregable es el esquema y sus datos de prueba, **no la implementación de
los flujos transaccionales completos**. Las claves y CHECK no pueden garantizar,
por sí solos, sumas entre tablas, permisos de sesión o decisiones de negocio.
`03_validaciones.sql` detecta las inconsistencias que requieren esa coordinación.

Al implementar persistencia, cada operación deberá usar transacciones y bloqueo
de las filas de inventario implicadas:

- Reserva: validar productos e inventario de la sede, disponibilidad, insertar
  cabecera/detalles, aumentar reservado y registrar movimientos.
- Cancelación o vencimiento: bloquear pedido y sus inventarios, confirmar que
  sigue pendiente, liberar sus unidades **una sola vez**, registrar movimientos
  y actualizar el estado. Evaluarlo al consultar o antes de nuevas reservas.
- Venta directa: comprobar disponibilidad, registrar venta/detalles, reducir
  físico y lotes, y registrar movimientos en una transacción.
- Venta de reserva: comprobar vigencia, registrar venta/detalles, reducir físico
  y reservado, actualizar lotes, registrar movimientos y marcar ENTREGADO con
  la misma fecha de la venta.
- Inventario: conciliar cantidades de lotes, totales de inventario y movimientos.
  Retirar unidades vencidas antes de ofrecerlas para reserva o venta.
- Acceso: el cajero utiliza la sede de su cuenta y el cliente sus propios pedidos.
  La selección global de las consultas de ejemplo está destinada al administrador;
  un parámetro SQL por sí solo no es un control de autorización.

No hay triggers, procedimientos, jobs ni eventos programados. En
`02_consultas.sql`, el estado efectivo y la disponibilidad consideran reservas
que ya vencieron **sin persistir esa liberación**. La transacción de liberación
descrita arriba será necesaria en la aplicación. Los totales de cabecera y
detalle conservan los atributos del modelo Java y deben actualizarse juntos.

## Datos de prueba y resultados esperados

La carga usa una fecha base capturada con NOW en hora de Lima, de modo que
puedan probarse estados y fechas relativos al momento de ejecución.

- 6 usuarios: 1 administrador, 2 cajeros (uno por sede), 3 clientes.
- 2 sedes, 3 categorías y 4 productos globales.
- 4 promociones en distintos estados, con 6 detalles; cubren los tres tipos
  de descuento existentes.
- 8 inventarios, 9 lotes y 29 movimientos.
- 6 pedidos: uno por cada estado definido, con 8 detalles.
- 3 ventas y 5 detalles: una venta de reserva y dos ventas directas.
- Un lote vencido con cantidad cero, retirado mediante un movimiento; lotes
  próximos a vencer y vigentes; productos sin control de vencimiento.

Inmediatamente después de la carga: **8 unidades reservadas**, **9 unidades
vendidas** y **S/ 26.80 vendidos**. En el reporte por sede: Centro registra
2 ventas, 7 unidades y S/ 16.50; Norte registra 1 venta, 2 unidades y S/ 10.30.
El producto más vendido es Agua, con 6 unidades. A medida que transcurre el
tiempo cambiarán los estados efectivos de las reservas, como corresponde.

Todos los correos terminan en `example.test` y los datos personales son ficticios.
La contraseña de demostración es `PazComprasDemo2026!`. En la tabla solo se guarda
un hash scrypt con sal distinta por usuario:
`scrypt$N$r$p$sal_base64$hash_base64`, con N=131072, r=8, p=1 y salida de 32 bytes.
El algoritmo de autenticación Java aún no está implementado; debe interpretar
ese formato o generar nuevos hashes al implementar la autenticación.

## Decisiones que el alcance no fija

- Umbral de “próximo a vencer”: la consulta usa 7 días como parámetro de ejemplo,
  no como regla definitiva; el método Java también lo recibe como parámetro.
- Un lote que vence hoy se considera próximo a vencer, conforme al método Java.
- No se decide acumulación o prioridad entre promociones solapadas; la consulta
  presenta cada oferta por separado. El precio y descuento realmente cobrados
  se conservan en cada detalle de venta.
- Los precios en pedidos son referenciales, conforme al modelo. La política
  ante cambios de precio/promoción entre reserva y cobro queda por confirmar.
- No se añaden impuestos, comprobantes fiscales, métodos de pago, proveedores,
  delivery, centro de distribución ni devoluciones.
- Se utiliza DATETIME con hora local de Lima para corresponder a LocalDateTime;
  una política de horarios nocturnos o múltiples zonas horarias queda fuera
  de esta entrega.
