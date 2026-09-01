import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Producto {
    private int idProducto;
    private String codigo;
    private String nombre;
    private String descripcion;
    private BigDecimal precioRegular;
    private String imagenUrl;
    private boolean activo;
    private boolean controlaVencimiento;
    private LocalDateTime fechaRegistro;
    private Categoria categoria;
	
	public Producto(int idProducto, String codigo, String nombre, String descripcion, BigDecimal precioRegular, boolean controlaVencimiento, Categoria categoria) {
        this.idProducto = idProducto;
        this.codigo = codigo;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precioRegular = precioRegular;
        this.activo = true;
        this.controlaVencimiento = controlaVencimiento;
        this.fechaRegistro = LocalDateTime.now();
        this.categoria = categoria;
    }
	
	public int getIdProducto() { return idProducto; }
    public String getCodigo() { return codigo; }
    public String getNombre() { return nombre; }
    public BigDecimal getPrecioRegular() { return precioRegular; }
    public void setPrecioRegular(BigDecimal precio) { this.precioRegular = precio; }
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
    public boolean isControlaVencimiento() { return controlaVencimiento; }
    public Categoria getCategoria() { return categoria; }
}