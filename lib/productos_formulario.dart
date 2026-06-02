import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductosFormulario extends StatefulWidget {
  final Map<String, dynamic>? producto;

  const ProductosFormulario({super.key, this.producto});

  @override
  State<ProductosFormulario> createState() => _ProductosFormularioState();
}

class _ProductosFormularioState extends State<ProductosFormulario> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _codigoBarraCtrl = TextEditingController();
  final TextEditingController _precioVentaCtrl = TextEditingController();
  final TextEditingController _precioCompraCtrl = TextEditingController();
  final TextEditingController _categoriaCtrl = TextEditingController();
  final TextEditingController _unidadMedidaCtrl = TextEditingController();
  final TextEditingController _fechaVencimientoCtrl = TextEditingController();

  int? _categoriaId;
  bool _cargando = false;

  final String baseUrl = 'http://10.0.2.2:3000/app/productos';

  static const Color azulMarino = Color(0xFF1B2D5E);
  static const Color amarillo = Color(0xFFF5C300);

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final p = widget.producto!;
      _nombreCtrl.text = p['nombre'] ?? '';
      _codigoBarraCtrl.text = p['codigoBarra'] ?? '';
      _precioVentaCtrl.text = (p['precioVenta'] ?? '').toString();
      _precioCompraCtrl.text = (p['precioCompra'] ?? '').toString();
      _categoriaCtrl.text = p['categoria'] ?? '';
      _unidadMedidaCtrl.text = p['unidadMedida'] ?? '';
      _fechaVencimientoCtrl.text = p['fechaVencimiento'] != null
          ? p['fechaVencimiento'].toString().substring(0, 10)
          : '';
      _categoriaId = p['categoria_id'] != null
          ? int.tryParse(p['categoria_id'].toString())
          : null;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoBarraCtrl.dispose();
    _precioVentaCtrl.dispose();
    _precioCompraCtrl.dispose();
    _categoriaCtrl.dispose();
    _unidadMedidaCtrl.dispose();
    _fechaVencimientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'CO'),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _fechaVencimientoCtrl.text = formatted;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final body = {
      'categoria_id': _categoriaId,
      'nombre': _nombreCtrl.text.trim(),
      'codigoBarra': _codigoBarraCtrl.text.trim(),
      'precioVenta': double.tryParse(_precioVentaCtrl.text.trim()) ?? 0.0,
      'precioCompra': double.tryParse(_precioCompraCtrl.text.trim()) ?? 0.0,
      'categoria': _categoriaCtrl.text.trim(),
      'unidadMedida': _unidadMedidaCtrl.text.trim(),
      if (_fechaVencimientoCtrl.text.isNotEmpty)
        'fechaVencimiento': _fechaVencimientoCtrl.text.trim(),
    };

    try {
      http.Response respuesta;

      if (_esEdicion) {
        final id = widget.producto!['idProducto'];
        respuesta = await http.put(
          Uri.parse('$baseUrl/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      } else {
        respuesta = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      }

      final data = jsonDecode(respuesta.body);

      if (!mounted) return;

      if (data['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Producto actualizado correctamente'
                  : 'Producto creado correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['mensaje'] ?? 'Error al guardar el producto'),
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
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: azulMarino),
      prefixIcon: Icon(icono, color: azulMarino),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: azulMarino, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: amarillo, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar Producto' : 'Nuevo Producto',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Encabezado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: azulMarino,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2, color: amarillo, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _esEdicion
                            ? 'Editando: ${widget.producto!['nombre'] ?? ''}'
                            : 'Registrar nuevo producto',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: _decoracion('Nombre del producto', Icons.label),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              // Código de barra
              TextFormField(
                controller: _codigoBarraCtrl,
                decoration: _decoracion('Código de barra', Icons.qr_code),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El código de barra es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              // Categoría ID
              TextFormField(
                initialValue: _categoriaId?.toString(),
                decoration: _decoracion('ID de categoría', Icons.numbers),
                keyboardType: TextInputType.number,
                onChanged: (v) => _categoriaId = int.tryParse(v.trim()),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El ID de categoría es obligatorio';
                  if (int.tryParse(v.trim()) == null)
                    return 'Debe ser un número entero';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoría (texto)
              TextFormField(
                controller: _categoriaCtrl,
                decoration: _decoracion('Categoría', Icons.category),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'La categoría es obligatoria'
                    : null,
              ),
              const SizedBox(height: 16),

              // Precio de venta
              TextFormField(
                controller: _precioVentaCtrl,
                decoration: _decoracion('Precio de venta', Icons.attach_money),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El precio de venta es obligatorio';
                  if (double.tryParse(v.trim()) == null)
                    return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Precio de compra
              TextFormField(
                controller: _precioCompraCtrl,
                decoration: _decoracion(
                  'Precio de compra',
                  Icons.shopping_cart,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El precio de compra es obligatorio';
                  if (double.tryParse(v.trim()) == null)
                    return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Unidad de medida
              TextFormField(
                controller: _unidadMedidaCtrl,
                decoration: _decoracion('Unidad de medida', Icons.straighten),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'La unidad de medida es obligatoria'
                    : null,
              ),
              const SizedBox(height: 16),

              // Fecha de vencimiento
              TextFormField(
                controller: _fechaVencimientoCtrl,
                decoration:
                    _decoracion(
                      'Fecha de vencimiento (opcional)',
                      Icons.calendar_today,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.date_range, color: azulMarino),
                        onPressed: _seleccionarFecha,
                      ),
                    ),
                readOnly: true,
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _cargando ? null : _guardar,
                  icon: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: azulMarino,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save, color: azulMarino),
                  label: Text(
                    _cargando
                        ? 'Guardando...'
                        : (_esEdicion
                              ? 'Actualizar producto'
                              : 'Guardar producto'),
                    style: const TextStyle(
                      color: azulMarino,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarillo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
