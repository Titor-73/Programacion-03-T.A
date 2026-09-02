import java.time.LocalDate;

public class LoteInventario {
    private int idLote;
    private String codigoLote;
    private int cantidadActual;
    private LocalDate fechaIngreso;
    private LocalDate fechaVencimiento;
    private boolean activo;
    private InventarioProducto inventarioProducto;
	
	public LoteInventario(int idLote, String codigoLote, int cantidadActual, LocalDate fechaVencimiento, InventarioProducto inventarioProducto) {
        this.idLote = idLote;
        this.codigoLote = codigoLote;
        this.cantidadActual = cantidadActual;
        this.fechaIngreso = LocalDate.now();
        this.fechaVencimiento = fechaVencimiento;
        this.activo = true;
        this.inventarioProducto = inventarioProducto;
    }
	public LoteInventario(LoteInventario lote){
		this.idLote = lote.idLote;
		this.codigoLote = lote.codigoLote;
		this.cantidadActual = lote.cantidadActual;
		this.activo = lote.activo;
		this.fechaIngreso = lote.fechaIngreso;
		this.fechaVencimiento = lote.fechaVencimiento;
		this.inventarioProducto = new InventarioProducto(lote.inventarioProducto);
	}
	public int getIdLote() { return idLote; }
    public String getCodigoLote() { return codigoLote; }
    public int getCantidadActual() { return cantidadActual; }
    public void setCantidadActual(int cantidad) { this.cantidadActual = cantidad; }
    public LocalDate getFechaVencimiento() { return fechaVencimiento; }
    public InventarioProducto getInventarioProducto() { return inventarioProducto; }
}
