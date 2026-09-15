package pe.edu.pucp.pazcompras.main;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

import pe.edu.pucp.pazcompras.catalogo.Categoria;
import pe.edu.pucp.pazcompras.catalogo.Producto;
import pe.edu.pucp.pazcompras.inventario.EstadoVencimiento;
import pe.edu.pucp.pazcompras.inventario.InventarioProducto;
import pe.edu.pucp.pazcompras.inventario.LoteInventario;
import pe.edu.pucp.pazcompras.inventario.MovimientoInventario;
import pe.edu.pucp.pazcompras.inventario.OrigenMovimiento;
import pe.edu.pucp.pazcompras.inventario.TipoMovimientoInventario;
import pe.edu.pucp.pazcompras.pedidos.DetallePedido;
import pe.edu.pucp.pazcompras.pedidos.Pedido;
import pe.edu.pucp.pazcompras.promociones.DetallePromocion;
import pe.edu.pucp.pazcompras.promociones.EstadoPromocion;
import pe.edu.pucp.pazcompras.promociones.Promocion;
import pe.edu.pucp.pazcompras.promociones.TipoDescuento;
import pe.edu.pucp.pazcompras.sedes.Sede;
import pe.edu.pucp.pazcompras.usuarios.Administrador;
import pe.edu.pucp.pazcompras.usuarios.Cajero;
import pe.edu.pucp.pazcompras.usuarios.Cliente;
import pe.edu.pucp.pazcompras.ventas.DetalleVenta;
import pe.edu.pucp.pazcompras.ventas.Venta;

public class Principal {
    public static void main(String[] args) {
        System.out.println("=== PRUEBAS DE LA CAPA DE DOMINIO ===");

        // Usuarios y sede
        Sede sedeSanMiguel = new Sede(1, "Sede San Miguel", "Av. La Marina 2000", "01-4567890",
                LocalTime.of(8, 0), LocalTime.of(22, 0));
        Administrador admin = new Administrador(1, "Carlos", "Pérez", "admin@pazcompras.pe", "hash123", "999111222");
        Cajero cajero = new Cajero(2, "Ana", "Gómez", "agomez@pazcompras.pe", "hash456", "999222333",
                "CAJ-001", sedeSanMiguel);
        Cliente cliente = new Cliente(3, "Juan", "López", "jlopez@gmail.com", "hash789", "999333444");
        sedeSanMiguel.agregarCajero(cajero);

        System.out.println("Sede: " + sedeSanMiguel.getNombre());
        System.out.println("Cajeros: " + sedeSanMiguel.getCajeros().size());
        System.out.println("Cliente: " + cliente.getNombres() + " " + cliente.getApellidos());

        // Catálogo
        Categoria lacteos = new Categoria(10, "Lácteos", "Productos derivados de la leche");
        Producto leche = new Producto(101, "PROD-001", "Leche Entera 1L", "Leche entera UHT",
                new BigDecimal("5.50"), true, lacteos, "http://img.com/leche.png");
        Producto queso = new Producto(102, "PROD-002", "Queso Edam 250g", "Queso madurado",
                new BigDecimal("12.00"), true, lacteos, "http://img.com/queso.png");
        lacteos.agregarProducto(leche);
        lacteos.agregarProducto(queso);

        System.out.println("Productos en " + lacteos.getNombre() + ": " + lacteos.getProductos().size());

        // Inventario y lotes
        InventarioProducto inventarioLeche = new InventarioProducto(1, 10, sedeSanMiguel, leche);
        LoteInventario loteLeche = new LoteInventario(50, "LOT-2026-A", 50,
                LocalDate.now().plusDays(5), inventarioLeche);
        inventarioLeche.agregarLote(loteLeche);
        sedeSanMiguel.agregarInventario(inventarioLeche);

        EstadoVencimiento estadoLote = loteLeche.getEstadoVencimiento(LocalDate.now(), 7);
        MovimientoInventario movimiento = new MovimientoInventario(1, TipoMovimientoInventario.INGRESO, 50,
                "Ingreso inicial", OrigenMovimiento.MANUAL, inventarioLeche, loteLeche, admin);

        System.out.println("Stock físico: " + inventarioLeche.getStockFisico());
        System.out.println("Stock disponible: " + inventarioLeche.getStockDisponible());
        System.out.println("Bajo stock: " + inventarioLeche.tieneBajoStock());
        System.out.println("Vencimiento del lote: " + estadoLote);
        System.out.println("Movimiento: " + movimiento.getTipo());

        // Promociones
        Promocion promocion = new Promocion(1, "Cyber Paz", "Descuento por campaña",
                LocalDateTime.now().minusDays(1), LocalDateTime.now().plusDays(2));
        promocion.setEstado(EstadoPromocion.ACTIVA);
        DetallePromocion detallePromocion = new DetallePromocion(1, TipoDescuento.MONTO_FIJO,
                new BigDecimal("0.50"), promocion, leche);
        promocion.agregarDetalle(detallePromocion);

        System.out.println("Promoción: " + promocion.getNombre() + " - " + promocion.getEstado());

        // Pedidos y reserva
        Pedido pedido = new Pedido(1001, cliente, sedeSanMiguel, cajero);
        DetallePedido detallePedido1 = new DetallePedido(1, 2, leche.getPrecioRegular(),
                new BigDecimal("0.50"), pedido, leche);
        DetallePedido detallePedido2 = new DetallePedido(2, 1, queso.getPrecioRegular(),
                BigDecimal.ZERO, pedido, queso);
        pedido.agregarDetalle(detallePedido1);
        pedido.agregarDetalle(detallePedido2);
        cliente.agregarPedido(pedido);

        System.out.println("Total referencial: S/ " + pedido.getTotalReferencial());
        System.out.println("Estado inicial: " + pedido.getEstado());
        boolean vencio = pedido.evaluarVencimiento(LocalDateTime.now().plusHours(3));
        System.out.println("Reserva vencida: " + vencio + " - " + pedido.getEstado());

        // Venta
        Venta venta = new Venta(2001, sedeSanMiguel, cajero, null);
        DetalleVenta detalleVenta = new DetalleVenta(1, 3, new BigDecimal("5.50"),
                new BigDecimal("0.50"), venta, leche);
        venta.agregarDetalle(detalleVenta);

        System.out.println("Subtotal venta: S/ " + venta.getSubtotal());
        System.out.println("Descuento venta: S/ " + venta.getDescuentoTotal());
        System.out.println("Total venta: S/ " + venta.getTotal());

        // Copia defensiva
        Producto copiaLeche = new Producto(leche);
        copiaLeche.setPrecioRegular(new BigDecimal("99.99"));
        System.out.println("Precio original: S/ " + leche.getPrecioRegular());
        System.out.println("Precio copia: S/ " + copiaLeche.getPrecioRegular());

        System.out.println("=== PRUEBAS FINALIZADAS ===");
    }
}
