import java.time.LocalTime;
import java.util.List;
import java.util.ArrayList;

public class Sede {
    private int idSede;
    private String nombre;
    private String direccion;
    private String telefono;
    private boolean activa;
    private LocalTime horarioApertura;
    private LocalTime horarioCierre;
    private List<Cajero> cajeros;
    private List<InventarioProducto> inventarios;
	
	public Sede(int idSede, String nombre, String direccion, String telefono, LocalTime horarioApertura, LocalTime horarioCierre) {
        this.idSede = idSede;
        this.nombre = nombre;
        this.direccion = direccion;
        this.telefono = telefono;
        this.activa = true;
        this.horarioApertura = horarioApertura;
        this.horarioCierre = horarioCierre;
        this.cajeros = new ArrayList<>();
        this.inventarios = new ArrayList<>();
    }
	
	public int getIdSede() { return idSede; }
    public void setIdSede(int idSede) { this.idSede = idSede; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public boolean isActiva() { return activa; }
    public void setActiva(boolean activa) { this.activa = activa; }

    public LocalTime getHorarioApertura() { return horarioApertura; }
    public void setHorarioApertura(LocalTime horarioApertura) { this.horarioApertura = horarioApertura; }

    public LocalTime getHorarioCierre() { return horarioCierre; }
    public void setHorarioCierre(LocalTime horarioCierre) { this.horarioCierre = horarioCierre; }

    public List<Cajero> getCajeros() {
        return new ArrayList<>(this.cajeros);
    }

    public List<InventarioProducto> getInventarios() {
        return new ArrayList<>(this.inventarios);
    }
	public void agregarCajero(Cajero cajero) {
        if (cajero != null && !this.cajeros.contains(cajero)) {
            this.cajeros.add(cajero);
        }
    }
	
	public void agregarInventario(InventarioProducto inventario) {
		if (inventario != null && !this.inventarios.contains(inventario)) {
			this.inventarios.add(inventario);
		}
	}
}