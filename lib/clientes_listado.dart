import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'clientes_formulario.dart';

const Color azul = Color(0xFF1B2D5E);
const Color amarillo = Color(0xFFF5C300);
const String baseUrl = 'http://10.0.2.2:3000/app/clientes';

class Cliente {
  final int idCliente;
  final String nombre;
  final String telefono;
  final int puntosAcumulados;

  Cliente({
    required this.idCliente,
    required this.nombre,
    required this.telefono,
    required this.puntosAcumulados,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['idCliente'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      puntosAcumulados: json['puntosAcumulados'] ?? 0,
    );
  }
}

class ClientesListado extends StatefulWidget {
  const ClientesListado({super.key});

  @override
  State<ClientesListado> createState() => _ClientesListadoState();
}

class _ClientesListadoState extends State<ClientesListado> {
  List<Cliente> _clientes = [];
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['ok'] == true) {
          final List lista = body['data'] ?? [];
          setState(() {
            _clientes = lista.map((e) => Cliente.fromJson(e)).toList();
            _cargando = false;
          });
        } else {
          setState(() {
            _error = body['mensaje'] ?? 'Error';
            _cargando = false;
          });
        }
      } else {
        setState(() {
          _error = 'Error ${response.statusCode}';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No se pudo conectar al servidor.';
        _cargando = false;
      });
    }
  }

  Future<void> _eliminarCliente(int id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar eliminación',
          style: TextStyle(color: azul, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Eliminar a "$nombre"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/$id'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _mostrarSnackbar('✅ Cliente eliminado', Colors.green);
        _cargarClientes();
      } else {
        _mostrarSnackbar('❌ Error al eliminar', Colors.red);
      }
    } catch (e) {
      _mostrarSnackbar('❌ Error de conexión', Colors.red);
    }
  }

  void _mostrarSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _irAlFormulario({Cliente? cliente}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ClientesFormulario(cliente: cliente)),
    );
    if (resultado == true) _cargarClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: azul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'La Tiendita Martínez',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarClientes,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: amarillo,
        foregroundColor: azul,
        icon: const Icon(Icons.person_add),
        label: const Text(
          'Nuevo Cliente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => _irAlFormulario(),
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: azul),
            SizedBox(height: 16),
            Text('Cargando clientes...', style: TextStyle(color: azul)),
          ],
        ),
      );
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: _cargarClientes,
              ),
            ],
          ),
        ),
      );
    }
    if (_clientes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay clientes registrados.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: azul,
      onRefresh: _cargarClientes,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _clientes.length,
        itemBuilder: (ctx, i) => _buildCard(_clientes[i]),
      ),
    );
  }

  Widget _buildCard(Cliente c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: azul.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: azul,
          radius: 24,
          child: Text(
            c.nombre.isNotEmpty ? c.nombre[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          c.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: azul,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(c.telefono, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: amarillo),
                const SizedBox(width: 4),
                Text(
                  '${c.puntosAcumulados} puntos',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: azul),
              onPressed: () => _irAlFormulario(cliente: c),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _eliminarCliente(c.idCliente, c.nombre),
            ),
          ],
        ),
      ),
    );
  }
}
