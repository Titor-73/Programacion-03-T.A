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
	
	public Producto(int idProducto, String codigo, String nombre, String descripcion, 
					BigDecimal precioRegular, boolean controlaVencimiento, 
					Categoria categoria, String imagenUrl) {
        this.idProducto = idProducto;
        this.codigo = codigo;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precioRegular = precioRegular;
        this.activo = true;
        this.controlaVencimiento = controlaVencimiento;
        this.fechaRegistro = LocalDateTime.now();
        this.categoria = categoria;
		this.imagenUrl = imagenUrl;
    }
	public Producto(Producto producto) {
        this.idProducto = producto.idProducto;
        this.codigo = producto.codigo;
        this.nombre = producto.nombre;
        this.descripcion = producto.descripcion;
        this.precioRegular = producto.precioRegular;
        this.activo = producto.activo;
        this.controlaVencimiento = producto.controlaVencimiento;
        this.fechaRegistro = producto.fechaRegistro;
        this.categoria = producto.categoria;
		this.imagenUrl = producto.imagenUrl;
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
