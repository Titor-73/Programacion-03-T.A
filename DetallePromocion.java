import java.math.BigDecimal;

public class DetallePromocion {
    private int idDetallePromocion;
    private TipoDescuento tipoDescuento;
    private BigDecimal valorDescuento;
    private Promocion promocion;
    private Producto producto;
	
	public DetallePromocion(int idDetallePromocion, TipoDescuento tipoDescuento, BigDecimal valorDescuento, Promocion promocion, Producto producto) {
        this.idDetallePromocion = idDetallePromocion;
        this.tipoDescuento = tipoDescuento;
        this.valorDescuento = valorDescuento;
        this.promocion = promocion;
        this.producto = producto;
    }
	
	public int getIdDetallePromocion() { return idDetallePromocion; }
    public TipoDescuento getTipoDescuento() { return tipoDescuento; }
    public BigDecimal getValorDescuento() { return valorDescuento; }
    public Promocion getPromocion() { return (promocion != null) ? new Promocion(promocion) : null; }
    public Producto getProducto() { return (producto != null) ? new Producto(producto) : null; }
}
