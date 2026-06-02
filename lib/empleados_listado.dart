import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'empleados_formulario.dart';

class EmpleadosListado extends StatefulWidget {
  const EmpleadosListado({super.key});

  @override
  State<EmpleadosListado> createState() => _EmpleadosListadoState();
}

class _EmpleadosListadoState extends State<EmpleadosListado> {
  List<Map<String, dynamic>> _empleados = [];
  bool _cargando = true;
  String _error = '';

  final String baseUrl = 'http://10.0.2.2:3000/app/empleados';

  static const Color azulMarino = Color(0xFF1B2D5E);
  static const Color amarillo = Color(0xFFF5C300);

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
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
          final List lista = body['data'] ?? [];
          setState(() {
            _empleados = lista
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            _cargando = false;
          });
        } else {
          setState(() {
            _error = body['mensaje'] ?? 'Error al cargar empleados';
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

  Future<void> _eliminarEmpleado(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este empleado?',
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
            content: Text('Empleado eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarEmpleados();
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

  Future<void> _navegarFormulario({Map<String, dynamic>? empleado}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmpleadosFormulario(empleado: empleado),
      ),
    );
    if (resultado == true) _cargarEmpleados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Empleados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarEmpleados,
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
                    onPressed: _cargarEmpleados,
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
          : _empleados.isEmpty
          ? const Center(
              child: Text(
                'No hay empleados registrados',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarEmpleados,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _empleados.length,
                itemBuilder: (context, index) {
                  final e = _empleados[index];
                  final id = e['idEmpleado'];
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
                          Icons.badge,
                          color: azulMarino,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        e['nombre'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: azulMarino,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuario: ${e['usuario'] ?? '-'}'),
                          Text('Rol: ${e['rol'] ?? '-'}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: azulMarino),
                            onPressed: () => _navegarFormulario(empleado: e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarEmpleado(id),
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
