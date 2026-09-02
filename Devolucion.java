import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

public class Devolucion {
    private int idDevolucion;
    private LocalDateTime fechaHora;
    private TipoDevolucion tipo;
    private String motivo;
    private BigDecimal montoDevuelto;
    private EstadoDevolucion estado;
    private Venta venta;
    private Cajero cajero;
    private List<DetalleDevolucion> detalles;
	
	public Devolucion(int idDevolucion, TipoDevolucion tipo, String motivo, Venta venta, Cajero cajero) {
        this.idDevolucion = idDevolucion;
        this.fechaHora = LocalDateTime.now();
        this.tipo = tipo;
        this.motivo = motivo;
        this.montoDevuelto = BigDecimal.ZERO;
        this.estado = EstadoDevolucion.REGISTRADA;
        this.venta = venta;
        this.cajero = cajero;
        this.detalles = new ArrayList<>();
    }
	public Devolucion(Devolucion devolucion) {
        this.idDevolucion = devolucion.idDevolucion;
        this.fechaHora = devolucion.fechaHora;
        this.tipo = devolucion.tipo;
        this.motivo = devolucion.motivo;
        this.montoDevuelto = devolucion.montoDevuelto;
        this.estado = devolucion.estado;
        this.venta = devolucion.getVenta();
        this.cajero = devolucion.getCajero();
        this.detalles = new ArrayList<>();
    }
	
	public int getIdDevolucion() { return idDevolucion; }
    public LocalDateTime getFechaHora() { return fechaHora; }
    public TipoDevolucion getTipo() { return tipo; }
    public String getMotivo() { return motivo; }
    public BigDecimal getMontoDevuelto() { return montoDevuelto; }
    public EstadoDevolucion getEstado() { return estado; }
    public void setEstado(EstadoDevolucion estado) { this.estado = estado; }
    public Venta getVenta() { return new Venta(venta); }
    public Cajero getCajero() { return new Cajero(cajero); }
    public List<DetalleDevolucion> getDetalles() { return new ArrayList<>(this.detalles); }
	
	public void agregarDetalle(DetalleDevolucion detalle) {
        if (detalle != null) {
            this.detalles.add(detalle);
            this.montoDevuelto = this.montoDevuelto.add(detalle.getMontoDevuelto());
        }
    }
}