import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

public class Pedido {
    private int idPedido;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaExpiracionReserva;
	private LocalDateTime fechaPreparacion;
	private LocalDateTime fechaListoRecojo;
	private LocalDateTime fechaEntrega;
	private LocalDateTime fechaCancelacion;
	private String motivoCancelacion;
    private EstadoPedido estado;
    private BigDecimal totalReferencial;
    private Cliente cliente;
    private Sede sede;
    private Cajero cajero;
    private List<DetallePedido> detalles;
	
	public Pedido(int idPedido, Cliente cliente, Sede sede, Cajero cajero) {
        this.idPedido = idPedido;
        this.fechaCreacion = LocalDateTime.now();
        this.fechaExpiracionReserva = this.fechaCreacion.plusHours(2);
        this.estado = EstadoPedido.RESERVADO;
        this.totalReferencial = BigDecimal.ZERO;
        this.cliente = cliente;
        this.sede = sede;
        this.cajero = cajero;
        this.detalles = new ArrayList<>();
    }

	public Pedido(Pedido pedido) {
        this.idPedido = pedido.idPedido;
        this.fechaCreacion = pedido.fechaCreacion;
        this.fechaExpiracionReserva = pedido.fechaExpiracionReserva;
        this.fechaPreparacion = pedido.fechaPreparacion;
        this.fechaListoRecojo = pedido.fechaListoRecojo;
        this.fechaEntrega = pedido.fechaEntrega;
        this.fechaCancelacion = pedido.fechaCancelacion;
        this.motivoCancelacion = pedido.motivoCancelacion;
        this.estado = pedido.estado;
        this.totalReferencial = pedido.totalReferencial;
        this.cliente = pedido.cliente;
        this.sede = pedido.sede;
        this.cajero = pedido.cajero;
        this.detalles = new ArrayList<>(pedido.detalles);
    }
	
	public int getIdPedido() { return idPedido; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public EstadoPedido getEstado() { return estado; }
    public void setEstado(EstadoPedido estado) { this.estado = estado; }
    public BigDecimal getTotalReferencial() { return totalReferencial; }
    public Cliente getCliente() { return new Cliente(cliente); }
    public Sede getSede() { return new Sede(sede); }
    public Cajero getCajero() { return (cajero != null) ? new Cajero(cajero) : null; }
    public List<DetallePedido> getDetalles() { return new ArrayList<>(this.detalles); }
	
	public void agregarDetalle(DetallePedido detalle) {
        if (detalle != null) {
            this.detalles.add(detalle);
            this.totalReferencial = this.totalReferencial.add(detalle.getSubtotalReferencial());
        }
    }
}
