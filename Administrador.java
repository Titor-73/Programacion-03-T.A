public class Administrador extends Usuario {
	
	public Administrador(int idUsuario, String nombres, String apellidos, String correo, String contrasenaHash, String telefono) {
        super(idUsuario, nombres, apellidos, correo, contrasenaHash, telefono);
    }
}