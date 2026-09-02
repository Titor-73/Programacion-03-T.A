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
    public Promocion getPromocion() { return new Promocion(promocion); }
    public Producto getProducto() { return new Producto(producto); }

	public BigDecimal calcularPrecioPromocional() {
		BigDecimal precioRegular = producto.getPrecioRegular();
		BigDecimal precioPromocional;

		switch (tipoDescuento) {
			case PORCENTAJE:
				precioPromocional = precioRegular.subtract(
					precioRegular.multiply(valorDescuento).divide(BigDecimal.valueOf(100))
				);
				break;

			case MONTO_FIJO:
				precioPromocional = precioRegular.subtract(valorDescuento);
				break;

			case PRECIO_ESPECIAL:
				precioPromocional = valorDescuento;
				break;

			default:
				precioPromocional = precioRegular;
		}

		return precioPromocional.max(BigDecimal.ZERO);
	}
}
