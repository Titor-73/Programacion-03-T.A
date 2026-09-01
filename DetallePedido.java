import java.math.BigDecimal;

public class DetallePedido {
    private int idDetallePedido;
    private int cantidad;
    private BigDecimal precioReferencial;
    private BigDecimal descuentoReferencial;
    private BigDecimal subtotalReferencial;
    private Pedido pedido;
    private Producto producto;
	
	public DetallePedido(int idDetallePedido, int cantidad, BigDecimal precioReferencial, BigDecimal descuentoReferencial, Pedido pedido, Producto producto) {
        this.idDetallePedido = idDetallePedido;
        this.cantidad = cantidad;
        this.precioReferencial = precioReferencial;
        this.descuentoReferencial = (descuentoReferencial != null) ? descuentoReferencial : BigDecimal.ZERO;
        this.pedido = pedido;
        this.producto = producto;
        this.calcularSubtotalReferencial();
    }
	
	public int getIdDetallePedido() { return idDetallePedido; }
    public int getCantidad() { return cantidad; }
    public BigDecimal getPrecioReferencial() { return precioReferencial; }
    public BigDecimal getDescuentoReferencial() { return descuentoReferencial; }
    public BigDecimal getSubtotalReferencial() { return subtotalReferencial; }
    public Pedido getPedido() { return pedido; }
    public Producto getProducto() { return producto; }
	
	public void calcularSubtotalReferencial() {
        BigDecimal precioEfectivo = this.precioReferencial.subtract(this.descuentoReferencial);
        this.subtotalReferencial = precioEfectivo.multiply(BigDecimal.valueOf(this.cantidad));
    }
}