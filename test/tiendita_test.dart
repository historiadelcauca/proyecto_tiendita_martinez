// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

// ─────────────────────────────────────────────
// FUNCIÓN AUXILIAR — igual a la usada en todos los módulos
// ─────────────────────────────────────────────
double toDouble(dynamic v) => double.parse(v.toString());

// ─────────────────────────────────────────────
// VALIDACIONES — lógica de los formularios
// ─────────────────────────────────────────────
bool validarCliente(String nombre, String telefono) {
  return nombre.isNotEmpty && telefono.isNotEmpty;
}

bool validarProducto(
  String nombre,
  String codigo,
  dynamic precioVenta,
  dynamic precioCompra,
) {
  if (nombre.isEmpty || codigo.isEmpty) return false;
  final pv = toDouble(precioVenta);
  final pc = toDouble(precioCompra);
  return pv > 0 && pc > 0 && pv >= pc;
}

bool validarEmpleado(
  String nombre,
  String usuario,
  String rol,
  String password,
) {
  return nombre.isNotEmpty &&
      usuario.isNotEmpty &&
      rol.isNotEmpty &&
      password.isNotEmpty;
}

bool validarStock(dynamic stockActual, dynamic stockMinimo) {
  final actual = toDouble(stockActual);
  final minimo = toDouble(stockMinimo);
  return actual >= 0 && minimo >= 0;
}

// ─────────────────────────────────────────────
// LÓGICA DE COLORES DE INVENTARIO
// ─────────────────────────────────────────────
String colorStock(dynamic stockActual, dynamic stockMinimo) {
  final actual = toDouble(stockActual);
  final minimo = toDouble(stockMinimo);
  if (actual <= minimo) return 'rojo';
  if (actual <= minimo * 2) return 'naranja';
  return 'verde';
}

// ─────────────────────────────────────────────
// CONSTRUCCIÓN DE MAPAS — igual a como los usan los formularios
// ─────────────────────────────────────────────
Map<String, dynamic> construirMapaCliente(
  String nombre,
  String telefono,
  int puntos,
) {
  return {'nombre': nombre, 'telefono': telefono, 'puntos': puntos};
}

Map<String, dynamic> construirMapaProducto(
  String nombre,
  String codigo,
  double precioVenta,
  double precioCompra,
  String categoria,
) {
  return {
    'nombreProducto': nombre,
    'codigoProducto': codigo,
    'precioVenta': precioVenta,
    'precioCompra': precioCompra,
    'categoria': categoria,
  };
}

Map<String, dynamic> construirDetalleVenta(
  int idProducto,
  int cantidad,
  double precioUnitario,
) {
  return {
    'idProducto': idProducto,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'subtotal': cantidad * precioUnitario,
  };
}

// ─────────────────────────────────────────────
// LÓGICA DE CARRITO DE VENTAS
// ─────────────────────────────────────────────
double calcularTotalCarrito(List<Map<String, dynamic>> carrito) {
  double total = 0;
  for (final item in carrito) {
    total += toDouble(item['cantidad']) * toDouble(item['precioUnitario']);
  }
  return total;
}

// ─────────────────────────────────────────────
// TESTS
// ─────────────────────────────────────────────
void main() {
  group('_toDouble — conversión de tipos del backend', () {
    test('convierte int a double', () {
      expect(toDouble(100), equals(100.0));
    });
    test('convierte String numérico a double', () {
      expect(toDouble('2000.50'), equals(2000.50));
    });
    test('convierte double a double', () {
      expect(toDouble(1500.0), equals(1500.0));
    });
    test('convierte String entero a double', () {
      expect(toDouble('9000'), equals(9000.0));
    });
  });

  group('validarCliente — formulario de clientes', () {
    test('válido con nombre y teléfono', () {
      expect(validarCliente('José Isidro Sánchez', '3127809393'), isTrue);
    });
    test('inválido con nombre vacío', () {
      expect(validarCliente('', '3127809393'), isFalse);
    });
    test('inválido con teléfono vacío', () {
      expect(validarCliente('José Isidro Sánchez', ''), isFalse);
    });
    test('inválido con ambos vacíos', () {
      expect(validarCliente('', ''), isFalse);
    });
  });

  group('validarProducto — formulario de productos', () {
    test('válido con todos los campos correctos', () {
      expect(
        validarProducto('Agua Mineral 500ml', 'AGU002', '2000', '1200'),
        isTrue,
      );
    });
    test('inválido con nombre vacío', () {
      expect(validarProducto('', 'AGU002', '2000', '1200'), isFalse);
    });
    test('inválido con precioVenta menor que precioCompra', () {
      expect(validarProducto('Producto', 'COD01', '800', '1200'), isFalse);
    });
    test('inválido con precioVenta cero', () {
      expect(validarProducto('Producto', 'COD01', '0', '1200'), isFalse);
    });
    test('válido cuando precioVenta como String decimal', () {
      expect(
        validarProducto('Jamón 250g', 'JAM001', '9000.0', '7200.0'),
        isTrue,
      );
    });
  });

  group('validarEmpleado — formulario de empleados', () {
    test('válido con todos los campos', () {
      expect(
        validarEmpleado('Clara Martínez', 'cmartinezg', 'Gerente', 'clave123'),
        isTrue,
      );
    });
    test('inválido con usuario vacío', () {
      expect(
        validarEmpleado('Clara Martínez', '', 'Gerente', 'clave123'),
        isFalse,
      );
    });
    test('inválido con password vacío', () {
      expect(
        validarEmpleado('Clara Martínez', 'cmartinezg', 'Gerente', ''),
        isFalse,
      );
    });
  });

  group('colorStock — indicadores de inventario', () {
    test('verde cuando stock es más del doble del mínimo', () {
      expect(colorStock(98, 15), equals('verde'));
    });
    test('verde para Papas fritas (75 > 40)', () {
      expect(colorStock(75, 20), equals('verde'));
    });
    test('naranja cuando stock está entre mínimo y doble del mínimo', () {
      expect(colorStock(18, 15), equals('naranja'));
    });
    test('rojo cuando stock es igual al mínimo', () {
      expect(colorStock(15, 15), equals('rojo'));
    });
    test('rojo cuando stock es menor al mínimo', () {
      expect(colorStock(8, 15), equals('rojo'));
    });
  });

  group('construirMapaCliente — estructura de datos', () {
    test('mapa contiene las claves correctas', () {
      final mapa = construirMapaCliente(
        'Natalia Fernanda Rojas',
        '3182345678',
        600,
      );
      expect(mapa.containsKey('nombre'), isTrue);
      expect(mapa.containsKey('telefono'), isTrue);
      expect(mapa.containsKey('puntos'), isTrue);
      expect(mapa['puntos'], equals(600));
    });
  });

  group('construirDetalleVenta — líneas del carrito', () {
    test('subtotal se calcula correctamente', () {
      final detalle = construirDetalleVenta(1, 3, 2000.0);
      expect(detalle['subtotal'], equals(6000.0));
    });
    test('el mapa contiene idProducto, cantidad y precioUnitario', () {
      final detalle = construirDetalleVenta(5, 2, 9000.0);
      expect(detalle['idProducto'], equals(5));
      expect(detalle['cantidad'], equals(2));
      expect(detalle['precioUnitario'], equals(9000.0));
    });
  });

  group('calcularTotalCarrito — módulo de ventas', () {
    test('total correcto con un producto', () {
      final carrito = [
        {'idProducto': 1, 'cantidad': 2, 'precioUnitario': 2000.0},
      ];
      expect(calcularTotalCarrito(carrito), equals(4000.0));
    });
    test('total correcto con múltiples productos', () {
      final carrito = [
        {'idProducto': 1, 'cantidad': 2, 'precioUnitario': 2000.0},
        {'idProducto': 2, 'cantidad': 1, 'precioUnitario': 9000.0},
        {'idProducto': 3, 'cantidad': 3, 'precioUnitario': 1500.0},
      ];
      expect(calcularTotalCarrito(carrito), equals(17500.0));
    });
    test('carrito vacío retorna cero', () {
      expect(calcularTotalCarrito([]), equals(0.0));
    });
    test('funciona con precios como String del backend', () {
      final carrito = [
        {'idProducto': 4, 'cantidad': '2', 'precioUnitario': '13500.0'},
      ];
      expect(calcularTotalCarrito(carrito), equals(27000.0));
    });
  });

  group('validarStock — módulo de inventario', () {
    test('válido con stock y mínimo positivos', () {
      expect(validarStock(98, 15), isTrue);
    });
    test('válido con stock cero', () {
      expect(validarStock(0, 10), isTrue);
    });
    test('inválido con stock negativo', () {
      expect(validarStock(-1, 10), isFalse);
    });
  });
}
