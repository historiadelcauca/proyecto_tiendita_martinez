import 'package:flutter/material.dart';
import 'clientes_listado.dart';
import 'productos_listado.dart';
import 'empleados_listado.dart';
import 'ventas_listado.dart';
import 'inventario_listado.dart';

class Opciones extends StatelessWidget {
  const Opciones({super.key});

  static const Color azulMarino = Color(0xFF1B2D5E);
  static const Color amarillo = Color(0xFFF5C300);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modulos = [
      {
        'titulo': 'Clientes',
        'icono': Icons.people,
        'activo': true,
        'destino': const ClientesListado(),
      },
      {
        'titulo': 'Productos',
        'icono': Icons.inventory_2,
        'activo': true,
        'destino': const ProductosListado(),
      },
      {
        'titulo': 'Empleados',
        'icono': Icons.badge,
        'activo': true,
        'destino': const EmpleadosListado(),
      },
      {
        'titulo': 'Ventas',
        'icono': Icons.point_of_sale,
        'activo': true,
        'destino': const VentasListado(),
      },
      {
        'titulo': 'Inventario',
        'icono': Icons.warehouse,
        'activo': true,
        'destino': const InventarioListado(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: azulMarino,
        title: const Text(
          'La Tiendita Martínez',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: azulMarino,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido al sistema',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Panel de Control',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Módulos del sistema',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: azulMarino,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: modulos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final modulo = modulos[index];
                  final bool activo = modulo['activo'] as bool;

                  return GestureDetector(
                    onTap: () {
                      if (activo) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => modulo['destino'] as Widget,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${modulo['titulo']}: módulo en desarrollo',
                            ),
                            backgroundColor: azulMarino,
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: activo ? Colors.white : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: activo
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: activo ? amarillo : Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              modulo['icono'] as IconData,
                              color: activo ? azulMarino : Colors.grey,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            modulo['titulo'] as String,
                            style: TextStyle(
                              color: activo ? azulMarino : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activo ? 'Disponible' : 'Próximamente',
                            style: TextStyle(
                              fontSize: 11,
                              color: activo ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
