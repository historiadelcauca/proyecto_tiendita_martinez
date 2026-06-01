import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'clientes_listado.dart' show azul, amarillo, baseUrl, Cliente;

class ClientesFormulario extends StatefulWidget {
  final Cliente? cliente;
  const ClientesFormulario({super.key, this.cliente});

  @override
  State<ClientesFormulario> createState() => _ClientesFormularioState();
}

class _ClientesFormularioState extends State<ClientesFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _puntosCtrl = TextEditingController();
  bool _guardando = false;
  bool get _esEdicion => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreCtrl.text = widget.cliente!.nombre;
      _telefonoCtrl.text = widget.cliente!.telefono;
      _puntosCtrl.text = widget.cliente!.puntosAcumulados.toString();
    } else {
      _puntosCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _puntosCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final datos = {
      'nombre': _nombreCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'puntosAcumulados': int.tryParse(_puntosCtrl.text.trim()) ?? 0,
    };
    try {
      http.Response response;
      if (_esEdicion) {
        response = await http
            .put(
              Uri.parse('$baseUrl/${widget.cliente!.idCliente}'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(datos),
            )
            .timeout(const Duration(seconds: 10));
      } else {
        response = await http
            .post(
              Uri.parse(baseUrl),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(datos),
            )
            .timeout(const Duration(seconds: 10));
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        final body = json.decode(response.body);
        _mostrarError(body['mensaje'] ?? 'Error al guardar');
      }
    } catch (e) {
      _mostrarError('No se pudo conectar al servidor.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esEdicion ? 'Editar Cliente' : 'Nuevo Cliente',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'La Tiendita Martínez',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: azul,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: amarillo,
                      radius: 28,
                      child: Icon(
                        _esEdicion ? Icons.edit : Icons.person_add,
                        color: azul,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _esEdicion
                              ? 'Modificar registro'
                              : 'Registrar cliente',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Completa todos los campos',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildCampo(
                controlador: _nombreCtrl,
                etiqueta: 'Nombre completo',
                icono: Icons.person,
                validador: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El nombre es obligatorio';
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCampo(
                controlador: _telefonoCtrl,
                etiqueta: 'Teléfono',
                icono: Icons.phone,
                teclado: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validador: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'El teléfono es obligatorio';
                  if (v.trim().length < 7) return 'Teléfono inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildCampo(
                controlador: _puntosCtrl,
                etiqueta: 'Puntos acumulados',
                icono: Icons.star,
                teclado: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validador: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Ingresa los puntos';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarillo,
                    foregroundColor: azul,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: azul,
                          ),
                        )
                      : Icon(_esEdicion ? Icons.save : Icons.check_circle),
                  label: Text(
                    _guardando
                        ? 'Guardando...'
                        : (_esEdicion
                              ? 'Guardar cambios'
                              : 'Registrar cliente'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: _guardando ? null : _guardar,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: azul,
                    side: const BorderSide(color: azul, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validador,
  }) {
    return TextFormField(
      controller: controlador,
      keyboardType: teclado,
      inputFormatters: inputFormatters,
      validator: validador,
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: azul),
        prefixIcon: Icon(icono, color: azul),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE3EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE3EF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: azul, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
