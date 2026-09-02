import java.math.BigDecimal;

public class DetalleVenta {
    private int idDetalleVenta;
    private int cantidad;
    private BigDecimal precioUnitario;
    private BigDecimal descuentoUnitario;
    private BigDecimal subtotal;
    private Venta venta;
    private Producto producto;
	
	public DetalleVenta(int idDetalleVenta, int cantidad, BigDecimal precioUnitario, BigDecimal descuentoUnitario, Venta venta, Producto producto) {
        this.idDetalleVenta = idDetalleVenta;
        this.cantidad = cantidad;
        this.precioUnitario = precioUnitario;
        this.descuentoUnitario = (descuentoUnitario != null) ? descuentoUnitario : BigDecimal.ZERO;
        this.venta = venta;
        this.producto = producto;
        this.calcularSubtotal();
    }

	public DetalleVenta(DetalleVenta detalleVenta) {
        this.idDetalleVenta = detalleVenta.idDetalleVenta;
        this.cantidad = detalleVenta.cantidad;
        this.precioUnitario = detalleVenta.precioUnitario;
        this.descuentoUnitario = detalleVenta.descuentoUnitario;
        this.subtotal = detalleVenta.subtotal;
        this.venta = detalleVenta.venta;
        this.producto = detalleVenta.producto;
    }
	
	public int getIdDetalleVenta() { return idDetalleVenta; }
    public int getCantidad() { return cantidad; }
    public BigDecimal getPrecioUnitario() { return precioUnitario; }
    public BigDecimal getDescuentoUnitario() { return descuentoUnitario; }
    public BigDecimal getSubtotal() { return subtotal; }
    public Venta getVenta() { return (venta != null) ? new Venta(venta) : null; }
    public Producto getProducto() { return (producto != null) ? new Producto(producto) : null; }
	
	public void calcularSubtotal() {
        BigDecimal precioEfectivo = this.precioUnitario.subtract(this.descuentoUnitario);
        this.subtotal = precioEfectivo.multiply(BigDecimal.valueOf(this.cantidad));
	}
}
