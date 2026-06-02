import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'productos_formulario.dart';

class ProductosListado extends StatefulWidget {
  const ProductosListado({super.key});

  @override
  State<ProductosListado> createState() => _ProductosListadoState();
}

class _ProductosListadoState extends State<ProductosListado> {
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = true;
  String _error = '';

  final String baseUrl = 'http://10.0.2.2:3000/app/productos';

  static const Color azulMarino = Color(0xFF1B2D5E);
  static const Color amarillo = Color(0xFFF5C300);

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['ok'] == true) {
          final List lista = body['productos'] ?? [];
          setState(() {
            _productos = lista
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            _cargando = false;
          });
        } else {
          setState(() {
            _error = body['mensaje'] ?? 'Error al cargar productos';
            _cargando = false;
          });
        }
      } else {
        setState(() {
          _error = 'Error del servidor: ${response.statusCode}';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarProducto(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este producto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      final body = jsonDecode(response.body);
      if (!mounted) return;
      if (body['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarProductos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['mensaje'] ?? 'Error al eliminar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navegarFormulario({Map<String, dynamic>? producto}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductosFormulario(producto: producto),
      ),
    );
    if (resultado == true) _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarProductos,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarFormulario(),
        backgroundColor: amarillo,
        child: const Icon(Icons.add, color: azulMarino),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(_error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarProductos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azulMarino,
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : _productos.isEmpty
          ? const Center(
              child: Text(
                'No hay productos registrados',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarProductos,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final p = _productos[index];
                  final id = p['idProducto'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: amarillo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: azulMarino,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        p['nombre'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: azulMarino,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Código: ${p['codigoBarra'] ?? '-'}'),
                          Text(
                            'Venta: \$${p['precioVenta'] ?? '-'}  |  Compra: \$${p['precioCompra'] ?? '-'}',
                          ),
                          Text('Categoría: ${p['categoria'] ?? '-'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: azulMarino),
                            onPressed: () => _navegarFormulario(producto: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarProducto(id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
