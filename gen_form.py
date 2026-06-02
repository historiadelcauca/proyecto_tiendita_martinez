import pathlib

contenido = """import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmpleadosFormulario extends StatefulWidget {
  final Map<String, dynamic>? empleado;
  const EmpleadosFormulario({super.key, this.empleado});

  @override
  State<EmpleadosFormulario> createState() => _EmpleadosFormularioState();
}

class _EmpleadosFormularioState extends State<EmpleadosFormulario> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = 'http://10.0.2.2:3000/app/empleados';
  final Color azulMarino = const Color(0xFF1B2D5E);
  final Color amarillo = const Color(0xFFF5C300);
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _rolCtrl = TextEditingController();
  final TextEditingController _usuarioCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _verPassword = false;
  bool _cargando = false;

  bool get esEdicion => widget.empleado != null;

  @override
  void initState() {
    super.initState();
    if (esEdicion) {
      _nombreCtrl.text = widget.empleado!['nombre'] ?? '';
      _rolCtrl.text = widget.empleado!['rol'] ?? '';
      _usuarioCtrl.text = widget.empleado!['usuario'] ?? '';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _rolCtrl.dispose();
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    final Map<String, dynamic> datos = {
      'nombre': _nombreCtrl.text.trim(),
      'rol': _rolCtrl.text.trim(),
      'usuario': _usuarioCtrl.text.trim(),
    };
    if (!esEdicion || _passwordCtrl.text.trim().isNotEmpty) {
      datos['password'] = _passwordCtrl.text.trim();
    }
    try {
      http.Response respuesta;
      if (esEdicion) {
        final idEmpleado = widget.empleado!['idEmpleado'];
        respuesta = await http.put(
          Uri.parse(baseUrl + '/' + idEmpleado.toString()),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(datos),
        );
      } else {
        respuesta = await http.post(
          Uri.parse(baseUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(datos),
        );
      }
      final body = jsonDecode(respuesta.body);
      if (!mounted) return;
      if (body['ok'] == true) {
        Navigator.pop(context, true);
      } else {
        _mostrarError(body['mensaje'] ?? 'Error al guardar.');
      }
    } catch (e) {
      _mostrarError('Error de conexion: ' + e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _campo({
    required String etiqueta,
    required TextEditingController controlador,
    bool obligatorio = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controlador,
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: TextStyle(color: azulMarino),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: azulMarino, width: 2),
          ),
        ),
        validator: obligatorio
            ? (v) {
                if (v == null || v.trim().isEmpty) return 'El campo ' + etiqueta + ' es obligatorio.';
                return null;
              }
            : null,
      ),
    );
  }

  Widget _campoPassword() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _passwordCtrl,
        obscureText: !_verPassword,
        decoration: InputDecoration(
          labelText: esEdicion ? 'Contrasena (vacio = sin cambio)' : 'Contrasena',
          labelStyle: TextStyle(color: azulMarino),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: azulMarino, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _verPassword ? Icons.visibility_off : Icons.visibility,
              color: azulMarino,
            ),
            onPressed: () => setState(() => _verPassword = !_verPassword),
          ),
        ),
        validator: !esEdicion
            ? (v) {
                if (v == null || v.trim().isEmpty) return 'La contrasena es obligatoria.';
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicion ? 'Editar Empleado' : 'Nuevo Empleado',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: azulMarino,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campo(etiqueta: 'Nombre', controlador: _nombreCtrl),
              _campo(etiqueta: 'Rol', controlador: _rolCtrl),
              _campo(etiqueta: 'Usuario', controlador: _usuarioCtrl),
              _campoPassword(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: amarillo,
                    foregroundColor: azulMarino,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _cargando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Text(
                          esEdicion ? 'Actualizar' : 'Guardar',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
"""

pathlib.Path(r'C:\proyectos\proyecto_tiendita_martinez\lib\empleados_formulario.dart').write_text(contenido, encoding='utf-8')
print('OK')
