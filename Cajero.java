public class Cajero extends Usuario {
    private String codigoEmpleado;
    private Sede sede;
	
	public Cajero(int idUsuario, String nombres, String apellidos, String correo, String contrasenaHash, String telefono, String codigoEmpleado, Sede sede) {
        super(idUsuario, nombres, apellidos, correo, contrasenaHash, telefono);
        this.codigoEmpleado = codigoEmpleado;
		this.sede = sede;
    }
	
	public String getCodigoEmpleado() { 
		return codigoEmpleado;
	}
    public void setCodigoEmpleado(String codigoEmpleado) {
		this.codigoEmpleado = codigoEmpleado;
	}
	public Sede getSede(){
		return this.sede;
	}
	public void setSede(Sede sede){
		this.sede = sede;
	}
}