import java.math.BigDecimal;

public class DetalleDevolucion {
    private int idDetalleDevolucion;
    private int cantidadDevuelta;
    private BigDecimal montoDevuelto;
    private boolean reintegraStock;
    private String motivoNoReintegro;
    private Devolucion devolucion;
    private DetalleVenta detalleVenta;
	
	public DetalleDevolucion(int idDetalleDevolucion, int cantidadDevuelta, BigDecimal montoDevuelto, boolean reintegraStock, String motivoNoReintegro, Devolucion devolucion, DetalleVenta detalleVenta) {
        this.idDetalleDevolucion = idDetalleDevolucion;
        this.cantidadDevuelta = cantidadDevuelta;
        this.montoDevuelto = montoDevuelto;
        this.reintegraStock = reintegraStock;
        this.motivoNoReintegro = motivoNoReintegro;
        this.devolucion = devolucion;
        this.detalleVenta = detalleVenta;
    }
	
	public int getIdDetalleDevolucion() { return idDetalleDevolucion; }
    public int getCantidadDevuelta() { return cantidadDevuelta; }
    public BigDecimal getMontoDevuelto() { return montoDevuelto; }
    public boolean isReintegraStock() { return reintegraStock; }
    public String getMotivoNoReintegro() { return motivoNoReintegro; }
    public Devolucion getDevolucion() { return new Devolucion(devolucion); }
    public DetalleVenta getDetalleVenta() { return detalleVenta; }
}