import 'package:flutter/material.dart';

// 📞 CONTACTO
Widget contacto() {
  return Padding(
    padding: EdgeInsets.all(30),
    child: Column(
      children: [
        Text("Contacto", style: TextStyle(color: Colors.white, fontSize: 22)),
        SizedBox(height: 10),
        Text(
          "Email: bikeshop@gmail.com",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        SizedBox(height: 6),
        Text(
          "Tel: 999-123-4567",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    ),
  );
}
