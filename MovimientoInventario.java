import java.time.LocalDateTime;

public class MovimientoInventario {
    private int idMovimiento;
    private TipoMovimientoInventario tipo;
    private int cantidad;
    private LocalDateTime fechaHora;
    private String motivo;
    private OrigenMovimiento origen;
    private int stockFisicoResultante;
    private int stockReservadoResultante;
    private InventarioProducto inventarioProducto;
    private LoteInventario lote;
    private Usuario usuario;
	
	public MovimientoInventario(int idMovimiento, TipoMovimientoInventario tipo, int cantidad, String motivo, OrigenMovimiento origen, InventarioProducto inventarioProducto,LoteInventario inventarioProducto, Usuario usuario) {
        this.idMovimiento = idMovimiento;
        this.tipo = tipo;
        this.cantidad = cantidad;
        this.fechaHora = LocalDateTime.now();
        this.motivo = motivo;
        this.origen = origen;
        this.inventarioProducto = new InventarioProducto(inventarioProducto);
        this.usuario = new Usuario(usuario);
		this.lote = new LoteInventario(inventarioProducto);
        this.stockFisicoResultante = inventarioProducto.getStockFisico();
        this.stockReservadoResultante = inventarioProducto.getStockReservado();
    }
	
	public int getIdMovimiento() { return idMovimiento; }
    public TipoMovimientoInventario getTipo() { return tipo; }
    public int getCantidad() { return cantidad; }
    public LocalDateTime getFechaHora() { return fechaHora; }
    public InventarioProducto getInventarioProducto() { return inventarioProducto; }
}
