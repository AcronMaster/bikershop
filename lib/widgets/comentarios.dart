import 'package:flutter/material.dart';

// 💬 COMENTARIOS
Widget comentarios() {
  return Padding(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        Text("Opiniones", style: TextStyle(color: Colors.white, fontSize: 22)),
        SizedBox(height: 15),
        SizedBox(
          width: 400,
          child: ListTile(
            title: Text(
              "Muy buena bici 🔥",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "Cliente satisfecho",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    ),
  );
}
