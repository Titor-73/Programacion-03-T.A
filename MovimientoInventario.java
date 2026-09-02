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
	
	public MovimientoInventario(int idMovimiento, TipoMovimientoInventario tipo, int cantidad, String motivo, OrigenMovimiento origen, InventarioProducto inventarioProducto, LoteInventario lote, Usuario usuario) {
        this.idMovimiento = idMovimiento;
        this.tipo = tipo;
        this.cantidad = cantidad;
        this.fechaHora = LocalDateTime.now();
        this.motivo = motivo;
        this.origen = origen;
        this.inventarioProducto = new InventarioProducto(inventarioProducto);

        if (usuario instanceof Cliente) {
            this.usuario = new Cliente((Cliente) usuario);
        } else if (usuario instanceof Cajero) {
            this.usuario = new Cajero((Cajero) usuario);
        } else if (usuario instanceof Administrador) {
            this.usuario = new Administrador((Administrador) usuario);
        } else {
            this.usuario = null;
        }

		this.lote = (lote != null) ? new LoteInventario(lote) : null;
        this.stockFisicoResultante = inventarioProducto.getStockFisico();
        this.stockReservadoResultante = inventarioProducto.getStockReservado();
    }
	
	public int getIdMovimiento() { return idMovimiento; }
    public TipoMovimientoInventario getTipo() { return tipo; }
    public int getCantidad() { return cantidad; }
    public LocalDateTime getFechaHora() { return fechaHora; }
    public InventarioProducto getInventarioProducto() { return inventarioProducto; }
}
