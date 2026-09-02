import java.util.List;
import java.util.ArrayList;

public class Categoria {
    private int idCategoria;
    private String nombre;
    private String descripcion;
    private boolean activa;
	private List<Producto> productos;
	
	public Categoria(int idCategoria, String nombre, String descripcion) {
        this.idCategoria = idCategoria;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.activa = true;
        this.productos = new ArrayList<>();
    }
	
	public int getIdCategoria() { return idCategoria; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public boolean isActiva() { return activa; }
    public void setActiva(boolean activa) { this.activa = activa; }
    public List<Producto> getProductos() { return new ArrayList<>(this.productos); }
	
	public void agregarProducto(Producto producto) {
        if (producto != null && !this.productos.contains(producto)) {
            this.productos.add(producto);
        }
    }
}