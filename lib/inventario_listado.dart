import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InventarioListado extends StatefulWidget {
  const InventarioListado({super.key});
  @override
  State<InventarioListado> createState() => _InventarioListadoState();
}

class _InventarioListadoState extends State<InventarioListado> {
  final String baseUrl = 'http://10.0.2.2:3000/app/inventario';
  final Color azulMarino = const Color(0xFF1B2D5E);
  final Color amarillo = const Color(0xFFF5C300);
  List<Map<String, dynamic>> inventario = [];
  bool cargando = true;

  @override
  void initState() { super.initState(); _cargar(); }

  double _toDouble(dynamic v) => double.parse(v.toString());
  int _toInt(dynamic v) => int.parse(v.toString());

  Future<void> _cargar() async {
    setState(() => cargando = true);
    try {
      final res = await http.get(Uri.parse(baseUrl));
      final body = jsonDecode(res.body);
      if (body['ok'] == true) {
        setState(() {
          inventario = List<Map<String, dynamic>>.from(body['data'] ?? body['inventario'] ?? []);
          cargando = false;
        });
      } else { setState(() => cargando = false); }
    } catch (e) { setState(() => cargando = false); }
  }

  Color _colorStock(int actual, int minimo) {
    if (actual <= 0) return Colors.red;
    if (actual <= minimo) return Colors.orange;
    return Colors.green;
  }

  void _editarStock(Map<String, dynamic> item) {
    final ctrl = TextEditingController(text: _toInt(item['stockActual']).toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Actualizar stock', style: TextStyle(color: azulMarino, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(item['nombreProducto'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Stock actual',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: azulMarino, width: 2)),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: amarillo, foregroundColor: azulMarino),
            onPressed: () async {
              final nuevoStock = int.tryParse(ctrl.text.trim());
              if (nuevoStock == null || nuevoStock < 0) return;
              Navigator.pop(context);
              await _actualizarStock(item['idInventario'], nuevoStock);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _actualizarStock(dynamic idInventario, int nuevoStock) async {
    try {
      final res = await http.put(
        Uri.parse(baseUrl + '/' + idInventario.toString()),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'stockActual': nuevoStock}),
      );
      final body = jsonDecode(res.body);
      if (body['ok'] == true) {
        _cargar();
      } else {
        _mostrarError(body['mensaje'] ?? 'Error al actualizar.');
      }
    } catch (e) { _mostrarError('Error: ' + e.toString()); }
  }

  void _mostrarError(String m) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Error'), content: Text(m),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargar)],
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator(color: azulMarino))
          : inventario.isEmpty
              ? Center(child: Text('Sin registros de inventario.', style: TextStyle(color: azulMarino)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: inventario.length,
                  itemBuilder: (context, index) {
                    final item = inventario[index];
                    final stockActual = _toInt(item['stockActual']);
                    final stockMinimo = _toInt(item['stockMinimo']);
                    final color = _colorStock(stockActual, stockMinimo);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item['nombreProducto'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: azulMarino)),
                            const SizedBox(height: 4),
                            Text('Categoria: ' + item['categoria'].toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Ubicacion: ' + item['ubicacion'].toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 6),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color)),
                                child: Text('Stock: ' + stockActual.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              const SizedBox(width: 8),
                              Text('Min: ' + stockMinimo.toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ]),
                          ])),
                          IconButton(
                            icon: Icon(Icons.edit, color: azulMarino),
                            onPressed: () => _editarStock(item),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}