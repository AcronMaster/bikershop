import 'package:flutter/material.dart';
import 'package:bikershop/screens/cliente/producto_detalle_screen.dart';
// 🧱 CARD (🔥 YA CORRECTO)

Widget productoCard(Map<String, dynamic> p, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductoDetalleScreen(producto: p)),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                'assets/images/fondo.jpg',

                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            p["nombre"],
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            "\$${p["precio"]}",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(height: 8),
        ],
      ),
    ),
  );
}
