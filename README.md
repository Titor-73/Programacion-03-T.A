# PazCompras

La base de datos MySQL, sus registros de prueba y las instrucciones de ingeniería
inversa están en [ScriptSQL/README.md](ScriptSQL/README.md).

Trabajo Académico del curso [1INF30] Programación 3 de la PUCP, ciclo 2026-2.

## Estructura Maven

Adaptación de `ProyectosJAVA/softprog_solution` del archivo del profesor
`1INF30-2026-2-main.zip`. El `pom.xml` de la raíz es el proyecto padre y
agregador; cada módulo usa el directorio estándar `src/main/java`.

```text
Programacion-03-T.A/
├── pom.xml                       # pazcompras_solution
├── pazcompras_domain/            # Clases y enums del dominio
│   ├── pom.xml
│   └── src/main/java/pe/edu/pucp/pazcompras/
│       ├── usuarios/model/
│       ├── sedes/model/
│       ├── catalogo/model/
│       ├── promociones/model/
│       ├── inventario/model/
│       ├── pedidos/model/
│       └── ventas/model/
├── pazcompras_dbmanager/         # Estructura para conexión futura
│   ├── pom.xml
│   └── src/main/
│       ├── java/pe/edu/pucp/pazcompras/config/
│       └── resources/
├── pazcompras_dao/               # Estructura para persistencia futura
│   ├── pom.xml
│   └── src/main/
│       ├── java/pe/edu/pucp/pazcompras/dao/
│       └── resources/
└── pazcompras/                   # Aplicación de comprobación
    ├── pom.xml
    └── src/main/java/pe/edu/pucp/pazcompras/main/Principal.java
```

Coordenadas: `pe.edu.pucp.pazcompras:pazcompras_solution:1.0-SNAPSHOT`.
Los módulos de dominio y conexión son independientes. El módulo DAO depende de
dominio y conexión; la aplicación depende de los tres, siguiendo el ejemplo del
profesor. Todos heredan Java 25 y UTF-8 del padre.

## Ubicación de las clases

Todos los paquetes parten de `pe.edu.pucp.pazcompras`.

| Paquete | Clases y enums |
| --- | --- |
| `usuarios.model` | Usuario, Cliente, Cajero, Administrador |
| `sedes.model` | Sede |
| `catalogo.model` | Categoria, Producto |
| `promociones.model` | Promocion, DetallePromocion, EstadoPromocion, TipoDescuento |
| `inventario.model` | InventarioProducto, LoteInventario, MovimientoInventario, TipoMovimientoInventario, OrigenMovimiento, EstadoVencimiento |
| `pedidos.model` | Pedido, DetallePedido, EstadoPedido |
| `ventas.model` | Venta, DetalleVenta, EstadoVenta |

Las clases existentes conservan sus atributos, constructores y métodos. La
migración modifica su ubicación, declaración de paquete e imports.

## Compilación y ejecución

Requisitos: JDK 25 y Maven 3.9 o posterior. `JAVA_HOME` debe señalar al JDK 25.
Ejecutar desde la raíz del repositorio:

```shell
mvn clean verify
```

Esto compila los módulos y genera sus JAR en cada directorio `target/`.
No hay una suite de pruebas automatizadas en esta entrega; un build correcto
valida la compilación y el empaquetado, no los flujos completos del sistema.

Ejecutar la comprobación de consola en Windows:

```shell
java -cp "pazcompras/target/classes;pazcompras_domain/target/classes" pe.edu.pucp.pazcompras.main.Principal
```

En Linux o macOS, sustituir el separador `;` del classpath por `:`.
La salida esperada incluye `Agua: S/ 2.50`. Esta aplicación solo comprueba que
los paquetes de la aplicación pueden utilizar el dominio; no es la interfaz web.

En IntelliJ IDEA, abrir el `pom.xml` de la raíz como proyecto y seleccionar JDK
25 para el proyecto y Maven. En NetBeans, abrir la carpeta raíz como proyecto
Maven y usar la plataforma JDK 25. Maven reconoce los cuatro módulos. Para
ejecutar desde el IDE, abrir `Principal.java` y ejecutar su método `main`.

## Alcance de esta entrega

La estructura sigue el proyecto del profesor; los módulos `pazcompras_dao` y
`pazcompras_dbmanager` contienen únicamente documentación de sus futuros
paquetes y recursos. No implementan DAO, SQL ni conexiones, y no incluyen
credenciales ni dependencias de MySQL. La persistencia requiere su consigna
vigente y el esquema de datos validado.

El dominio conserva el alcance corregido: catálogo, precios y promociones
globales; inventario, pedidos, ventas y cajeros por sede; administrador global;
reservas de dos horas para recojo y pago presencial; evaluaciones bajo demanda.
Quedan fuera devoluciones, anulaciones posteriores a la venta, delivery, pagos
online, proveedores, abastecimiento y centros de distribución.

La reorganización no implementa transacciones de stock, autorización de acceso
ni los 18 RF completos. Esos flujos pertenecen a etapas posteriores. Los
archivos compilados, `target/` y la configuración personal del IDE se excluyen
del repositorio.
