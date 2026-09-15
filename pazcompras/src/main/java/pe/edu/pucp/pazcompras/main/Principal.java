package pe.edu.pucp.pazcompras.main;

import java.math.BigDecimal;
import pe.edu.pucp.pazcompras.catalogo.Categoria;
import pe.edu.pucp.pazcompras.catalogo.Producto;

public class Principal {
    public static void main(String[] args) {
        Categoria categoria = new Categoria(1, "Bebidas", "Catálogo global");
        Producto producto = new Producto(1, "AGUA-001", "Agua",
                "Botella de agua", new BigDecimal("2.50"), false, categoria, null);

        System.out.println("PazCompras - Modelo de dominio");
        System.out.println(producto.getNombre() + ": S/ " + producto.getPrecioRegular());

        //PRUEBA 1(edson)(Si quieren borran todo este codigo pero a mi si me corrio )
                System.out.println("=== INICIO DE PRUEBAS DE LA CAPA DE DOMINIO ===");

        // 1. USUARIOS Y SEDE
        System.out.println("\n--- 1. Creación de Usuarios y Sede ---");
        Sede sedeSanMiguel = new Sede(1, "Sede San Miguel", "Av. La Marina 2000", "01-4567890",
                LocalTime.of(8, 0), LocalTime.of(22, 0));

        Administrador admin = new Administrador(1, "Carlos", "Pérez", "admin@pazcompras.pe", "hash123", "999111222");
        Cajero cajero = new Cajero(2, "Ana", "Gómez", "agomez@pazcompras.pe", "hash456", "999222333", "CAJ-001", sedeSanMiguel);
        Cliente cliente = new Cliente(3, "Juan", "López", "jlopez@gmail.com", "hash789", "999333444");

        sedeSanMiguel.agregarCajero(cajero);
        System.out.println("Sede creada: " + sedeSanMiguel.getNombre() + " con " + sedeSanMiguel.getCajeros().size() + " cajero(s).");
        System.out.println("Cliente registrado: " + cliente.getNombres() + " " + cliente.getApellidos());

        // 2. CATÁLOGO DE PRODUCTOS Y CATEGORÍAS
        System.out.println("\n--- 2. Catálogo y Productos ---");
        Categoria catLacteos = new Categoria(10, "Lácteos", "Productos derivados de la leche");
        Producto leche = new Producto(101, "PROD-001", "Leche Entera 1L", "Leche entera UHT",
                new BigDecimal("5.50"), true, catLacteos, "http://img.com/leche.png");
        Producto queso = new Producto(102, "PROD-002", "Queso Edam 250g", "Queso madurado",
                new BigDecimal("12.00"), true, catLacteos, "http://img.com/queso.png");

        catLacteos.agregarProducto(leche);
        catLacteos.agregarProducto(queso);
        System.out.println("Categoría '" + catLacteos.getNombre() + "' contiene " + catLacteos.getProductos().size() + " productos.");

        // 3. INVENTARIO Y LOTES
        System.out.println("\n--- 3. Inventario, Lotes y Movimientos ---");
        InventarioProducto invLeche = new InventarioProducto(1, 10, sedeSanMiguel, leche);
        LoteInventario loteLeche = new LoteInventario(50, "LOT-2026-A", 50, LocalDate.now().plusDays(5), invLeche);

        invLeche.agregarLote(loteLeche);
        sedeSanMiguel.agregarInventario(invLeche);

        System.out.println("Stock Físico Leche: " + invLeche.getStockFisico());
        System.out.println("Stock Disponible: " + invLeche.getStockDisponible());
        System.out.println("¿Tiene bajo stock? " + invLeche.tieneBajoStock());

        // Evaluación del lote próximo a vencer (vence en 5 días)
        EstadoVencimiento estadoLote = loteLeche.getEstadoVencimiento(LocalDate.now(), 7);
        System.out.println("Estado de vencimiento del lote: " + estadoLote); // Debería ser PROXIMO_A_VENCER

        MovimientoInventario movIngreso = new MovimientoInventario(1, TipoMovimientoInventario.INGRESO, 50,
                "Ingreso inicial de mercadería", OrigenMovimiento.MANUAL, invLeche, loteLeche, admin);
        System.out.println("Movimiento registrado por: " + movIngreso.getTipo() + " de " + movIngreso.getCantidad() + " unidades.");

        // 4. PROMOCIONES
        System.out.println("\n--- 4. Promociones ---");
        Promocion promoCyber = new Promocion(1, "Cyber Paz", "Descuento por Cyber",
                LocalDateTime.now().minusDays(1), LocalDateTime.now().plusDays(2));
        promoCyber.setEstado(EstadoPromocion.ACTIVA);

        DetallePromocion detPromo = new DetallePromocion(1, TipoDescuento.MONTO_FIJO, new BigDecimal("0.50"), promoCyber, leche);
        promoCyber.agregarDetalle(detPromo);
        System.out.println("Promoción '" + promoCyber.getNombre() + "' activa con " + promoCyber.getDetalles().size() + " detalle(s).");

        // 5. PEDIDOS
        System.out.println("\n--- 5. Flujo de Pedidos ---");
        Pedido pedido = new Pedido(1001, cliente, sedeSanMiguel, cajero);

        DetallePedido detPed1 = new DetallePedido(1, 2, leche.getPrecioRegular(), new BigDecimal("0.50"), pedido, leche);
        DetallePedido detPed2 = new DetallePedido(2, 1, queso.getPrecioRegular(), BigDecimal.ZERO, pedido, queso);

        pedido.agregarDetalle(detPed1);
        pedido.agregarDetalle(detPed2);
        cliente.agregarPedido(pedido);

        System.out.println("Subtotal Detalle 1 Leche (2x 5.00): " + detPed1.getSubtotalReferencial()); // 10.00
        System.out.println("Total Referencial Pedido: " + pedido.getTotalReferencial()); // 22.00
        System.out.println("Estado de Pedido actual: " + pedido.getEstado());

        // Test de evaluación de vencimiento del pedido
        boolean vencio = pedido.evaluarVencimiento(LocalDateTime.now().plusHours(3));
        System.out.println("¿Evaluó vencimiento tras 3 horas? " + vencio + " | Nuevo Estado: " + pedido.getEstado());

        // 6. VENTAS Y DETALLE DE VENTA
        System.out.println("\n--- 6. Flujo de Ventas ---");
        DetalleVenta detVenta1 = new DetalleVenta(1, 3, new BigDecimal("5.50"), new BigDecimal("0.50"), null, leche);
        System.out.println("Detalle Venta Subtotal (3 x (5.50 - 0.50)): " + detVenta1.getSubtotal()); // 15.00

        // 7. COMPROBACIÓN DE ENUMS Y COPIAS DEFENSIVAS
        System.out.println("\n--- 7. Verificación de Inmutabilidad / Copias Defensivas ---");
        Producto copiaLeche = new Producto(leche);
        copiaLeche.setPrecioRegular(new BigDecimal("99.99"));
        System.out.println("Precio Original Leche: " + leche.getPrecioRegular()); // Debe seguir siendo 5.50
        System.out.println("Precio Copia Modificada: " + copiaLeche.getPrecioRegular()); // 99.99

        System.out.println("\n=== TODAS LAS PRUEBAS FINALIZARON CON ÉXITO ===");
    }
}
