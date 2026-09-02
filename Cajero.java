public class Cajero extends Usuario {
    private String codigoEmpleado;
    private Sede sede;
	
	public Cajero(int idUsuario, String nombres, String apellidos, String correo, String contrasenaHash, String telefono, String codigoEmpleado, Sede sede) {
        super(idUsuario, nombres, apellidos, correo, contrasenaHash, telefono);
        this.codigoEmpleado = codigoEmpleado;
		this.sede = sede;
    }

	public Cajero(Cajero cajero) {
		super(cajero);
		this.codigoEmpleado = cajero.codigoEmpleado;
		this.sede = (cajero.sede != null) ? new Sede(cajero.sede) : null;
	}
	
	public String getCodigoEmpleado() {
		return codigoEmpleado;
	}

    public void setCodigoEmpleado(String codigoEmpleado) {
		this.codigoEmpleado = codigoEmpleado;
	}

	public Sede getSede() {
		return (sede != null) ? new Sede(sede) : null;
	}

	public void setSede(Sede sede) {
		this.sede = (sede != null) ? new Sede(sede) : null;
	}
}
