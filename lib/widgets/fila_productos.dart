import 'package:flutter/material.dart';
import 'package:bikershop/widgets/producto_card.dart';

// 🛍️ FILA PRODUCTOS
Widget filaProductos(BuildContext context) {
  final List<Map<String, dynamic>> productos = [
    {"nombre": "Bicicleta MTB", "precio": 500},
    {"nombre": "Casco", "precio": 150},
    {"nombre": "Guantes", "precio": 90},
  ];
  return Wrap(
    spacing: 18,
    runSpacing: 18,
    alignment: WrapAlignment.center,
    children: productos.map((p) {
      return SizedBox(width: 200, child: productoCard(p, context));
    }).toList(),
  );
}
