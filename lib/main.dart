import 'package:flutter/material.dart';
import 'opciones.dart';

void main() {
  runApp(const TienditaMartinez());
}

class TienditaMartinez extends StatelessWidget {
  const TienditaMartinez({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Tiendita Martínez',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2D5E),
          primary: const Color(0xFF1B2D5E),
          secondary: const Color(0xFFF5C300),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B2D5E),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B2D5E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const PantallaBienvenida(),
    );
  }
}

class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2D5E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 220,
              height: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'LA TIENDITA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const Text(
              'MARTÍNEZ',
              style: TextStyle(
                color: Color(0xFFF5C300),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sistema de Gestión',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5C300),
                foregroundColor: const Color(0xFF1B2D5E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 14,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Opciones()),
                );
              },
              child: const Text('INGRESAR'),
            ),
          ],
        ),
      ),
    );
  }
}
