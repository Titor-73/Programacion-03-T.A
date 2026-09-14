"""Pruebas SQL de laboratorio. Ejecutar solo contra una instancia desechable.
Usa el cliente mysql; el esquema pazcompras debe estar ausente al comenzar.
No conecta a la base de datos de la aplicacion ni elimina bases existentes.
"""
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
CMD = [
    "mysql", "--protocol=TCP",
    "--host=" + os.environ.get("MYSQL_HOST", "127.0.0.1"),
    "--port=" + os.environ.get("MYSQL_PORT", "3306"),
    "--user=" + os.environ.get("MYSQL_USER", "root"),
    "--default-character-set=utf8mb4", "--batch", "--skip-column-names",
]

def run(sql, expected_error=None):
    result = subprocess.run(CMD, input=sql, text=True, encoding="utf-8",
                            capture_output=True, check=False)
    if expected_error is not None:
        assert result.returncode != 0, "Se acepto una operacion invalida: " + sql
        assert ("ERROR " + str(expected_error) + " ") in result.stderr, result.stderr
    else:
        assert result.returncode == 0, result.stderr
    return result.stdout.strip()

def scalar(sql):
    return run("USE pazcompras; " + sql)

assert run("SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name='pazcompras';") == "0", (
    "La base pazcompras ya existe. Esta prueba requiere una instancia de desarrollo nueva."
)
run((ROOT / "ScriptSQL/01_pazcompras.sql").read_text(encoding="utf-8"))
assert scalar("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='pazcompras' AND table_type='BASE TABLE';") == "16"
assert scalar("SELECT COUNT(DISTINCT estado) FROM pedido;") == "6"
assert scalar("SELECT SUM(total) FROM venta;") == "26.80"
assert scalar("SELECT SUM(cantidad) FROM detalle_venta;") == "9"
assert scalar("SELECT GROUP_CONCAT(stock_fisico ORDER BY id_inventario_producto) FROM inventario_producto;") == "24,10,19,8,20,9,15,4"
assert scalar("SELECT SUM(stock_reservado) FROM inventario_producto;") == "8"

checks = run((ROOT / "ScriptSQL/05_validaciones.sql").read_text(encoding="utf-8"))
for row in checks.splitlines():
    name, count = row.split("\t")
    assert count == "0", name + ": " + count
assert len(checks.splitlines()) == 10
run((ROOT / "ScriptSQL/02_consultas.sql").read_text(encoding="utf-8"))

# Cada operacion negativa corre en su propia transaccion; al salir se revierte.
negative = [
    ("UPDATE inventario_producto SET stock_fisico=-1 WHERE id_inventario_producto=1",3819),
    ("UPDATE inventario_producto SET stock_reservado=999 WHERE id_inventario_producto=1",3819),
    ("UPDATE pedido SET fecha_expiracion_reserva=fecha_creacion+INTERVAL 3 HOUR WHERE id_pedido=1",3819),
    ("UPDATE pedido SET id_cajero=3 WHERE id_pedido=1",1452),
    ("UPDATE venta SET id_cajero=3 WHERE id_venta=1",1452),
    ("UPDATE venta SET id_sede=2,id_cajero=3 WHERE id_venta=1",1452),
    ("INSERT INTO venta(fecha_hora,subtotal,descuento_total,total,id_sede,id_cajero,id_pedido) VALUES(NOW(),13,1.5,11.5,1,2,4)",1062),
    ("UPDATE movimiento_inventario SET id_lote=5 WHERE id_movimiento=1",1452),
    ("UPDATE detalle_venta SET subtotal=999 WHERE id_detalle_venta=1",3819),
    ("UPDATE detalle_pedido SET cantidad=0 WHERE id_detalle_pedido=1",3819),
    ("INSERT INTO cliente(id_usuario) VALUES(2)",1452),
    ("INSERT INTO cliente(id_usuario,rol) VALUES(2,'CAJERO')",3819),
    ("UPDATE detalle_promocion SET valor_descuento=101 WHERE id_detalle_promocion=1",3819),
    ("UPDATE producto SET id_categoria=999 WHERE id_producto=1",1452),
    ("UPDATE usuario SET correo='admin@example.test' WHERE id_usuario=2",1062),
    ("INSERT INTO inventario_producto(id_sede,id_producto) VALUES(1,1)",1062),
]
for sql, code in negative:
    run("USE pazcompras; START TRANSACTION; " + sql + "; ROLLBACK;",code)

# La consulta efectiva deja de retener las ocho unidades dos horas despues,
# aun cuando los datos persistidos esperan la transaccion de liberacion.
assert scalar("""SELECT SUM(d.cantidad) FROM detalle_pedido d JOIN pedido p USING(id_pedido)
WHERE p.estado IN ('RESERVADO','EN_PREPARACION','LISTO_PARA_RECOJO')
AND p.fecha_expiracion_reserva <= NOW()+INTERVAL 2 HOUR;""") == "8"
assert scalar("SELECT COUNT(*) FROM information_schema.events WHERE event_schema='pazcompras';") == "0"
# Un segundo intento de crear el esquema debe fallar sin destruir los datos.
run("CREATE DATABASE pazcompras;",1007)
assert scalar("SELECT SUM(total) FROM venta;") == "26.80"
print("OK: 16 tablas, 10 conciliaciones, 16 rechazos de datos invalidos y consultas MySQL.")
