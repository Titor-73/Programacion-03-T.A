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
        this.sede = sede;
        this.cajero = cajero;
        this.pedido = pedido;
        this.detalles = new ArrayList<>();
        this.devoluciones = new ArrayList<>();
    }
	
	public Venta(Venta venta){
		this.idVenta = venta.idVenta;
        this.fechaHora = venta.fechaHora;
        this.subtotal = venta.subtotal;
        this.descuentoTotal = venta.descuentoTotal;
        this.total = venta.total;
        this.estado = venta.estado;
        this.sede = venta.getSede();
        this.cajero = venta.getCajero();
        this.pedido = venta.getPedido();
        this.detalles = new ArrayList<>();
        this.devoluciones = new ArrayList<>();
	}
	
	public int getIdVenta() { return idVenta; }
    public LocalDateTime getFechaHora() { return fechaHora; }
    public BigDecimal getSubtotal() { return subtotal; }
    public BigDecimal getDescuentoTotal() { return descuentoTotal; }
    public BigDecimal getTotal() { return total; }
    public EstadoVenta getEstado() { return estado; }
    public void setEstado(EstadoVenta estado) { this.estado = estado; }
    public Sede getSede() { return new Sede(sede); }
    public Cajero getCajero() { return new Cajero(cajero); }
    public Pedido getPedido() { return new Pedido(pedido); }
    public List<DetalleVenta> getDetalles() { return new ArrayList<>(this.detalles); }
    public List<Devolucion> getDevoluciones() { return new ArrayList<>(this.devoluciones); }
	
	public void agregarDetalle(DetalleVenta detalle) {
        if (detalle != null) {
            this.detalles.add(detalle);
            this.subtotal = this.subtotal.add(detalle.getSubtotal());
            this.descuentoTotal = this.descuentoTotal.add(
                detalle.getDescuentoUnitario().multiply(BigDecimal.valueOf(detalle.getCantidad()))
            );
            this.total = this.subtotal.subtract(this.descuentoTotal);
        }
    }

    public void agregarDevolucion(Devolucion devolucion) {
        if (devolucion != null) {
            this.devoluciones.add(devolucion);
        }
    }
}