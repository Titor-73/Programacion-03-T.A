import java.time.LocalDateTime;

public abstract class Usuario {
    private int idUsuario;
    private String nombres;
    private String apellidos;
    private String correo;
    private String contrasenaHash;
    private String telefono;
    private boolean activo;
    private LocalDateTime fechaRegistro;
    private LocalDateTime ultimoAcceso;
	
	public Usuario(int idUsuario, String nombres, String apellidos, String correo, String contrasenaHash, String telefono) {
        this.idUsuario = idUsuario;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.correo = correo;
        this.contrasenaHash = contrasenaHash;
        this.telefono = telefono;
        this.activo = true; // Por defecto nace activo
        this.fechaRegistro = LocalDateTime.now(); // Asigna la fecha y hora actual
    }
	public int getIdUsuario() { 
		return idUsuario; 
	}
    public void setIdUsuario(int idUsuario) { 
		this.idUsuario = idUsuario; 
	}

    public String getNombres() { 
		return nombres; 
	}
    public void setNombres(String nombres) { 
		this.nombres = nombres; 
	}

    public String getApellidos() { 
		return apellidos; 
	}
    public void setApellidos(String apellidos) { 
		this.apellidos = apellidos; 
	}

    public String getCorreo() { 
		return correo; 
	}
    public void setCorreo(String correo) { 
		this.correo = correo; 
	}

    public String getContrasenaHash() { 
		return contrasenaHash; 
	}
    public void setContrasenaHash(String contrasenaHash) { 
		this.contrasenaHash = contrasenaHash; 
	}

    public String getTelefono() { 
		return telefono; 
	}
    public void setTelefono(String telefono) { 
		this.telefono = telefono; 
	}

    public boolean isActivo() { 
		return activo; 
	}
    public void setActivo(boolean activo) { 
		this.activo = activo;
	}

    public LocalDateTime getFechaRegistro() { 
		return fechaRegistro;
	}

    public LocalDateTime getUltimoAcceso() { 
		return ultimoAcceso;
	}
    public void setUltimoAcceso(LocalDateTime ultimoAcceso) {
		this.ultimoAcceso = ultimoAcceso;
	}
}