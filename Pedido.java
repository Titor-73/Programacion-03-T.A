import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class Pedido {
    private int idPedido;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaExpiracionReserva;
    private EstadoPedido estado;
    private BigDecimal totalReferencial;
    private Cliente cliente;
    private Sede sede;
    private Cajero cajero;
    private List<DetallePedido> detalles;
	
	public Pedido(int idPedido, Cliente cliente, Sede sede, Cajero cajero) {
        this.idPedido = idPedido;
        this.fechaCreacion = LocalDateTime.now();
        this.estado = EstadoPedido.PENDIENTE; // Enum correspondiente
        this.totalReferencial = BigDecimal.ZERO;
        this.cliente = cliente;
        this.sede = sede;
        this.cajero = cajero;
        this.detalles = new ArrayList<>();
    }
	
	public int getIdPedido() { return idPedido; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public EstadoPedido getEstado() { return estado; }
    public void setEstado(EstadoPedido estado) { this.estado = estado; }
    public BigDecimal getTotalReferencial() { return totalReferencial; }
    public Cliente getCliente() { return cliente; }
    public Sede getSede() { return sede; }
    public Cajero getCajero() { return cajero; }
    public List<DetallePedido> getDetalles() { return new ArrayList<>(this.detalles); }
	
	public void agregarDetalle(DetallePedido detalle) {
        if (detalle != null) {
            this.detalles.add(detalle);
            this.totalReferencial = this.totalReferencial.add(detalle.getSubtotalReferencial());
        }
    }
}