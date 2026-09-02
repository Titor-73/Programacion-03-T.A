public class Cajero extends Usuario {
    private String codigoEmpleado;
    private Sede sede;
	
	public Cajero(int idUsuario, String nombres, String apellidos, String correo, String contrasenaHash, String telefono, String codigoEmpleado, Sede sede) {
        super(idUsuario, nombres, apellidos, correo, contrasenaHash, telefono);
        this.codigoEmpleado = codigoEmpleado;
		this.sede = newSede(sede);
    }
	public Cajero(Cajero cajero){
		super(cajero);
		this.codigoEmpleado = cajero.codigoEmpleado;
		this.sede = cajero.getSede();
	}
	
	public String getCodigoEmpleado() { 
		return codigoEmpleado;
	}
    public void setCodigoEmpleado(String codigoEmpleado) {
		this.codigoEmpleado = codigoEmpleado;
	}
	public Sede getSede(){
		return new Sede(this.sede);
	}
	public void setSede(Sede sede){
		this.sede = new Sede(sede);
	}
}