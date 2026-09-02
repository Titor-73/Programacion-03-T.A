import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

public class Venta {
    private int idVenta;
    private LocalDateTime fechaHora;
    private BigDecimal subtotal;
    private BigDecimal descuentoTotal;
    private BigDecimal total;
    private EstadoVenta estado;
    private Sede sede;
    private Cajero cajero;
    private Pedido pedido;
    private List<DetalleVenta> detalles;
    private List<Devolucion> devoluciones;

    public Venta(int idVenta, Sede sede, Cajero cajero, Pedido pedido) {
        this.idVenta = idVenta;
        this.fechaHora = LocalDateTime.now();

        this.subtotal = BigDecimal.ZERO;
        this.descuentoTotal = BigDecimal.ZERO;
        this.total = BigDecimal.ZERO;

        this.estado = EstadoVenta.REGISTRADA;

        this.sede = (sede != null)
                ? new Sede(sede)
                : null;

        this.cajero = (cajero != null)
                ? new Cajero(cajero)
                : null;

        // Una venta directa puede no venir de un pedido
        this.pedido = (pedido != null)
                ? new Pedido(pedido)
                : null;

        this.detalles = new ArrayList<>();
        this.devoluciones = new ArrayList<>();
    }

    // Constructor copia
    public Venta(Venta venta) {
        this.idVenta = venta.idVenta;
        this.fechaHora = venta.fechaHora;
        this.subtotal = venta.subtotal;
        this.descuentoTotal = venta.descuentoTotal;
        this.total = venta.total;
        this.estado = venta.estado;

        this.sede = (venta.sede != null)
                ? new Sede(venta.sede)
                : null;

        this.cajero = (venta.cajero != null)
                ? new Cajero(venta.cajero)
                : null;

        this.pedido = (venta.pedido != null)
                ? new Pedido(venta.pedido)
                : null;

        this.detalles = (venta.detalles != null)
                ? new ArrayList<>(venta.detalles)
                : new ArrayList<>();

        this.devoluciones = (venta.devoluciones != null)
                ? new ArrayList<>(venta.devoluciones)
                : new ArrayList<>();
    }

    public void setIdVenta(int idVenta) {
        this.idVenta = idVenta;
    }

    public int getIdVenta() {
        return idVenta;
    }

    public LocalDateTime getFechaHora() {
        return fechaHora;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public BigDecimal getDescuentoTotal() {
        return descuentoTotal;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public EstadoVenta getEstado() {
        return estado;
    }

    public void setEstado(EstadoVenta estado) {
        this.estado = estado;
    }

    public Sede getSede() {
        return (sede != null)
                ? new Sede(sede)
                : null;
    }

    public Cajero getCajero() {
        return (cajero != null)
                ? new Cajero(cajero)
                : null;
    }

    public Pedido getPedido() {
        return (pedido != null)
                ? new Pedido(pedido)
                : null;
    }

    public List<DetalleVenta> getDetalles() {
        return new ArrayList<>(this.detalles);
    }

    public List<Devolucion> getDevoluciones() {
        return new ArrayList<>(this.devoluciones);
    }

    public void agregarDetalle(DetalleVenta detalle) {
        if (detalle != null) {
            this.detalles.add(detalle);
           

            BigDecimal cantidad = BigDecimal.valueOf(detalle.getCantidad());
            
            // Subtotal ANTES del descuento
            BigDecimal brutoLinea =
                    detalle.getPrecioUnitario()
                            .multiply(cantidad);

            // Descuento total de esta línea
            BigDecimal descuentoLinea =
                    detalle.getDescuentoUnitario()
                            .multiply(cantidad);

            
            this.subtotal =
                    this.subtotal.add(brutoLinea);

            this.descuentoTotal =
                    this.descuentoTotal.add(descuentoLinea);

            this.total =
                    this.subtotal.subtract(this.descuentoTotal);
        }
    }

    public void agregarDevolucion(Devolucion devolucion) {
        if (devolucion != null) {
            this.devoluciones.add(devolucion);
        }
    }
}
