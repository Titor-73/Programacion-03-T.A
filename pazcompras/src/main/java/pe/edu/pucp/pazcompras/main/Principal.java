package pe.edu.pucp.pazcompras.main;

import java.math.BigDecimal;
import pe.edu.pucp.pazcompras.catalogo.Categoria;
import pe.edu.pucp.pazcompras.catalogo.Producto;

public class Principal {
    public static void main(String[] args) {
        Categoria categoria = new Categoria(1, "Bebidas", "Catálogo global");
        Producto producto = new Producto(1, "AGUA-001", "Agua",
                "Botella de agua", new BigDecimal("2.50"), false, categoria, null);

        System.out.println("PazCompras - Modelo de dominio");
        System.out.println(producto.getNombre() + ": S/ " + producto.getPrecioRegular());
    }
}
