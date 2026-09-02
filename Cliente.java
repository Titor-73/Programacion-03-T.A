import java.util.List;
import java.util.ArrayList;

public class Cliente extends Usuario {
    private List<Pedido> pedidos;

	public Cliente(int idUsuario, String nombres, String apellidos, String correo, String contrasenaHash, String telefono) {
        super(idUsuario, nombres, apellidos, correo, contrasenaHash, telefono);
		this.pedidos = new ArrayList<>();
    }

	public Cliente(Cliente cliente) {
		super(cliente);
		this.pedidos = (cliente.pedidos != null) ? new ArrayList<>(cliente.pedidos) : new ArrayList<>();
	}
	
	public List<Pedido> getPedidos() {
		return new ArrayList<>(this.pedidos);
	}

	public void agregarPedido(Pedido pedido) {
        if (pedido != null) {
            this.pedidos.add(pedido);
        }
    }
}
