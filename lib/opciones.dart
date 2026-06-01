import 'package:flutter/material.dart';
import 'clientes_listado.dart';

class Opciones extends StatelessWidget {
  const Opciones({super.key});

  static const Color azulMarino = Color(0xFF1B2D5E);
  static const Color amarillo = Color(0xFFF5C300);

  final List<Map<String, dynamic>> modulos = const [
    {'titulo': 'Clientes', 'icono': Icons.people},
    {'titulo': 'Productos', 'icono': Icons.inventory_2},
    {'titulo': 'Empleados', 'icono': Icons.badge},
    {'titulo': 'Ventas', 'icono': Icons.point_of_sale},
    {'titulo': 'Inventario', 'icono': Icons.warehouse},
  ];

  @override
  Widget build(BuildContext context) {
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
                  final esClientes = modulo['titulo'] == 'Clientes';
                  return GestureDetector(
                    onTap: () {
                      if (esClientes) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClientesListado(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${modulo['titulo']}: próximamente'),
                            backgroundColor: azulMarino,
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: amarillo,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              modulo['icono'] as IconData,
                              color: azulMarino,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            modulo['titulo'] as String,
                            style: const TextStyle(
                              color: azulMarino,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
