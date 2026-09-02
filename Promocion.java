import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;

public class Promocion {
    private int idPromocion;
    private String nombre;
    private String descripcion;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;
    private EstadoPromocion estado;
    private List<DetallePromocion> detalles;
	
	public Promocion(int idPromocion, String nombre, String descripcion, LocalDateTime fechaInicio, LocalDateTime fechaFin) {
        this.idPromocion = idPromocion;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.fechaInicio = fechaInicio;
        this.fechaFin = fechaFin;
        this.estado = EstadoPromocion.PROGRAMADA;
        this.detalles = new ArrayList<>();
    }
	public Promocion(Promocion promocion) {
        this.idPromocion = promocion.idPromocion;
        this.nombre = promocion.nombre;
        this.descripcion = promocion.descripcion;
        this.fechaInicio = promocion.fechaInicio;
        this.fechaFin = promocion.fechaFin;
        this.estado = promocion.estado;
        this.detalles = new ArrayList<>(promocion.detalles);
    }
	
	public void agregarDetalle(DetallePromocion detalle) {
        if (detalle != null) {
            this.detalles.add(detalle);
        }
    }
	
	public int getIdPromocion() { return idPromocion; }
    public String getNombre() { return nombre; }
    public String getDescripcion() { return descripcion; }
    public LocalDateTime getFechaInicio() { return fechaInicio; }
    public LocalDateTime getFechaFin() { return fechaFin; }
    public EstadoPromocion getEstado() { return estado; }
    public void setEstado(EstadoPromocion estado) { this.estado = estado; }
    public List<DetallePromocion> getDetalles() { return new ArrayList<>(this.detalles); }
	public void setIdPromocion (int idPromocion){
		this.idPromocion = idPromocion;
	}
}
