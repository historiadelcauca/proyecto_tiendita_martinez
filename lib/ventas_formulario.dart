import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VentasFormulario extends StatefulWidget {
  const VentasFormulario({super.key});
  @override
  State<VentasFormulario> createState() => _VentasFormularioState();
}

class _VentasFormularioState extends State<VentasFormulario> {
  final Color azulMarino = const Color(0xFF1B2D5E);
  final Color amarillo = const Color(0xFFF5C300);
  final String urlEmpleados = 'http://10.0.2.2:3000/app/empleados';
  final String urlClientes = 'http://10.0.2.2:3000/app/clientes';
  final String urlProductos = 'http://10.0.2.2:3000/app/productos';
  final String urlVentas = 'http://10.0.2.2:3000/app/ventas';
  List<Map<String, dynamic>> empleados = [];
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> productos = [];
  Map<String, dynamic>? empleadoSeleccionado;
  Map<String, dynamic>? clienteSeleccionado;
  String metodoPago = 'Efectivo';
  final List<String> metodos = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
    'Nequi',
    'Daviplata',
  ];
  List<Map<String, dynamic>> carrito = [];
  bool cargando = false;
  bool cargandoDatos = true;

  double _toDouble(dynamic v) => double.parse(v.toString());

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final resEmp = await http.get(Uri.parse(urlEmpleados));
      final resCli = await http.get(Uri.parse(urlClientes));
      final resPro = await http.get(Uri.parse(urlProductos));
      final bodyEmp = jsonDecode(resEmp.body);
      final bodyCli = jsonDecode(resCli.body);
      final bodyPro = jsonDecode(resPro.body);
      setState(() {
        if (bodyEmp['ok'] == true)
          empleados = List<Map<String, dynamic>>.from(bodyEmp['data']);
        if (bodyCli['ok'] == true)
          clientes = List<Map<String, dynamic>>.from(bodyCli['data']);
        if (bodyPro['ok'] == true)
          productos = List<Map<String, dynamic>>.from(
            bodyPro['productos'] ?? bodyPro['data'] ?? [],
          );
        cargandoDatos = false;
      });
    } catch (e) {
      setState(() => cargandoDatos = false);
    }
  }

  double get totalCarrito {
    double t = 0;
    for (final i in carrito) {
      t += _toDouble(i['precioVenta']) * (i['cantidad'] as int);
    }
    return t;
  }

  void _agregarProducto(Map<String, dynamic> p) {
    final id = p['idProducto'];
    final idx = carrito.indexWhere((i) => i['idProducto'] == id);
    if (idx >= 0) {
      setState(
        () => carrito[idx]['cantidad'] = (carrito[idx]['cantidad'] as int) + 1,
      );
    } else {
      setState(() {
        carrito.add({
          'idProducto': id,
          'nombre': p['nombre'],
          'precioVenta': _toDouble(p['precioVenta']),
          'cantidad': 1,
        });
      });
    }
  }

  void _cambiarCantidad(int i, int d) {
    setState(() {
      final nv = (carrito[i]['cantidad'] as int) + d;
      if (nv <= 0)
        carrito.removeAt(i);
      else
        carrito[i]['cantidad'] = nv;
    });
  }

  Future<void> _guardarVenta() async {
    if (empleadoSeleccionado == null) {
      _err('Selecciona un empleado.');
      return;
    }
    if (carrito.isEmpty) {
      _err('Agrega al menos un producto.');
      return;
    }
    setState(() => cargando = true);
    final datos = {
      'idEmpleado': empleadoSeleccionado!['idEmpleado'],
      'idCliente': clienteSeleccionado?['idCliente'],
      'metodoPago': metodoPago,
      'productos': carrito
          .map(
            (i) => {'idProducto': i['idProducto'], 'cantidad': i['cantidad']},
          )
          .toList(),
    };
    try {
      final res = await http.post(
        Uri.parse(urlVentas),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datos),
      );
      final body = jsonDecode(res.body);
      if (!mounted) return;
      if (body['ok'] == true) {
        final total = _toDouble(body['totalPagar'] ?? 0);
        final id = body['idVenta'];
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(
              'Venta registrada',
              style: TextStyle(color: azulMarino, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Venta ' +
                  id.toString() +
                  ' completada. Total: ' +
                  total.toStringAsFixed(2),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: amarillo,
                  foregroundColor: azulMarino,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        _err(body['mensaje'] ?? 'Error.');
      }
    } catch (e) {
      _err('Error: ' + e.toString());
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _err(String m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(m),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _mostrarSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar producto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: azulMarino,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                itemCount: productos.length,
                itemBuilder: (_, i) {
                  final p = productos[i];
                  return ListTile(
                    title: Text(p['nombre'].toString()),
                    subtitle: Text(
                      _toDouble(p['precioVenta']).toStringAsFixed(2),
                    ),
                    trailing: Icon(Icons.add_circle, color: amarillo),
                    onTap: () {
                      _agregarProducto(p);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva Venta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cargandoDatos
          ? Center(child: CircularProgressIndicator(color: azulMarino))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empleado *',
                    style: TextStyle(
                      color: azulMarino,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: empleadoSeleccionado,
                    hint: const Text('Selecciona un empleado'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: azulMarino, width: 2),
                      ),
                    ),
                    items: empleados
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e['nombre'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => empleadoSeleccionado = v),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cliente (opcional)',
                    style: TextStyle(
                      color: azulMarino,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: clienteSeleccionado,
                    hint: const Text('Cliente general'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: azulMarino, width: 2),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Cliente general'),
                      ),
                      ...clientes.map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c['nombre'].toString()),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => clienteSeleccionado = v),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Metodo de pago *',
                    style: TextStyle(
                      color: azulMarino,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: metodoPago,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: azulMarino, width: 2),
                      ),
                    ),
                    items: metodos
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => metodoPago = v ?? 'Efectivo'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Productos',
                        style: TextStyle(
                          color: azulMarino,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _mostrarSelector,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulMarino,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  carrito.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Sin productos agregados',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: carrito.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final subtotal =
                                _toDouble(item['precioVenta']) *
                                (item['cantidad'] as int);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nombre'].toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            subtotal.toStringAsFixed(2),
                                            style: TextStyle(color: azulMarino),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () => _cambiarCantidad(i, -1),
                                    ),
                                    Text(
                                      item['cantidad'].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () => _cambiarCantidad(i, 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 16),
                  carrito.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0x141B2D5E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                totalCarrito.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: azulMarino,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: cargando ? null : _guardarVenta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: amarillo,
                        foregroundColor: azulMarino,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: cargando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Registrar Venta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
