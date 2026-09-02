import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

public class InventarioProducto {
    private int idInventarioProducto;
    private int stockFisico;
    private int stockReservado;
    private int stockMinimo;
    private LocalDateTime ultimaActualizacion;
    private boolean activo;
    private Sede sede;
    private Producto producto;
    private List<LoteInventario> lotes;
    private List<MovimientoInventario> movimientos;
	
	public InventarioProducto(int idInventarioProducto, int stockMinimo, Sede sede, Producto producto) {
        this.idInventarioProducto = idInventarioProducto;
        this.stockFisico = 0;
        this.stockReservado = 0;
        this.stockMinimo = stockMinimo;
        this.ultimaActualizacion = LocalDateTime.now();
        this.activo = true;
        this.sede = sede;
        this.producto = producto;
        this.lotes = new ArrayList<>();
        this.movimientos = new ArrayList<>();
    }
	public InventarioProducto (InventarioProducto inventario){
		this.lotes = new ArrayList<>(inventario.lotes);
		this.movimientos = new ArrayList<>(inventario.movimientos);
		this.idInventarioProducto = inventario.idInventarioProducto;
		this.stockFisico = inventario.stockFisico;
		this.stockReservado = inventario.stockReservado;
		this.stockMinimo = inventario.stockMinimo;
		this.ultimaActualizacion = inventario.ultimaActualizacion;
		this.activo = inventario.activo;
		this.sede = inventario.sede;
        this.producto = inventario.producto;
	}
	public int getIdInventarioProducto() { return idInventarioProducto; }
    public int getStockFisico() { return stockFisico; }
    public int getStockReservado() { return stockReservado; }
    public Sede getSede() { return sede; }
    public Producto getProducto() { return producto; }
    public List<LoteInventario> getLotes() { return new ArrayList<>(this.lotes); }
    public List<MovimientoInventario> getMovimientos() { return new ArrayList<>(this.movimientos); }
	
	public void agregarLote(LoteInventario lote) {
        if (lote != null) {
            this.lotes.add(lote);
            this.stockFisico += lote.getCantidadActual();
            this.ultimaActualizacion = LocalDateTime.now();
        }
    }

    public int getStockDisponible() {
        return this.stockFisico - this.stockReservado;
    }

	public boolean tieneBajoStock() {
    	return getStockDisponible() <= stockMinimo;
	}
}
