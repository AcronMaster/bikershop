import 'package:flutter/material.dart';
import 'package:bikershop/services/cart_service.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    // Asegurar que el precio sea double
    final precio = (producto['precio'] is num)
        ? (producto['precio'] as num).toDouble()
        : double.tryParse(producto['precio'].toString()) ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: Text(
          producto['nombre'] ?? 'Producto',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen completa sin recortes
            Container(
              color: const Color.fromARGB(255, 29, 28, 28),
              child: Center(
                child: Image.network(
                  producto['url_imagen'] ?? 'https://via.placeholder.com/400',
                  height: 350,
                  fit: BoxFit.contain, // ← Cambiado de cover a contain
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/Fondo2.jpeg',
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Información del producto
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nombre
                      Text(
                        producto['nombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Precio
                      Text(
                        '\$${precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      Text(
                        producto['descripcion'] ??
                            'Sin descripción disponible.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 44),

                      // Botón agregar al carrito
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Agregar al carrito usando CartService
                            final productToAdd = Map<String, dynamic>.from(
                              producto,
                            );
                            if (productToAdd['precio'] is String) {
                              productToAdd['precio'] =
                                  double.tryParse(productToAdd['precio']) ??
                                  0.0;
                            }
                            CartService().addItem(productToAdd);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Producto agregado al carrito'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );

                            // Opcional: regresar a la pantalla anterior
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Agregar al carrito',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
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
