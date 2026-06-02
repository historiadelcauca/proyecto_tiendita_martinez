import pathlib

contenido = """import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ventas_formulario.dart';

class VentasListado extends StatefulWidget {
  const VentasListado({super.key});

  @override
  State<VentasListado> createState() => _VentasListadoState();
}

class _VentasListadoState extends State<VentasListado> {
  final String baseUrl = 'http://10.0.2.2:3000/app/ventas';
  final Color azulMarino = const Color(0xFF1B2D5E);
  final Color amarillo = const Color(0xFFF5C300);

  List<Map<String, dynamic>> ventas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  Future<void> _cargarVentas() async {
    setState(() => cargando = true);
    try {
      final respuesta = await http.get(Uri.parse(baseUrl + '/listar'));
      final body = jsonDecode(respuesta.body);
      if (body['ok'] == true) {
        setState(() {
          ventas = List<Map<String, dynamic>>.from(body['data']);
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'FINALIZADA':
        return Colors.green;
      case 'ANULADA':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ventas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarVentas,
          ),
        ],
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator(color: azulMarino))
          : ventas.isEmpty
              ? Center(
                  child: Text(
                    'No hay ventas registradas.',
                    style: TextStyle(color: azulMarino, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ventas.length,
                  itemBuilder: (context, index) {
                    final v = ventas[index];
                    final total = (v['totalPagar'] ?? 0).toDouble();
                    final estado = v['estado'] ?? '';
                    final metodo = v['metodoPago'] ?? '';
                    final empleado = v['empleado'] ?? 'Sin empleado';
                    final cliente = v['cliente'] ?? 'Cliente general';
                    final fecha = v['fechaHora'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Venta #' + v['idVenta'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: azulMarino,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _colorEstado(estado).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _colorEstado(estado)),
                                  ),
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      color: _colorEstado(estado),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: azulMarino),
                                const SizedBox(width: 4),
                                Text(
                                  'Total: \$' + total.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.payment, size: 16, color: azulMarino),
                                const SizedBox(width: 4),
                                Text(metodo, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 16, color: azulMarino),
                                const SizedBox(width: 4),
                                Text(empleado, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 16),
                                Icon(Icons.people_outline, size: 16, color: azulMarino),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    cliente,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  fecha.toString().length > 16
                                      ? fecha.toString().substring(0, 16)
                                      : fecha.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: amarillo,
        foregroundColor: azulMarino,
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VentasFormulario()),
          );
          if (resultado == true) _cargarVentas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
"""

pathlib.Path(r'C:\proyectos\proyecto_tiendita_martinez\lib\ventas_listado.dart').write_text(contenido, encoding='utf-8')
print('OK ventas_listado')
