import 'package:bikershop/screens/cliente/categorias_screen.dart';
import 'package:flutter/material.dart';
import 'package:bikershop/screens/cliente/search_results_screen.dart';


class Buscador extends StatefulWidget {
  const Buscador({super.key});

  @override
  State<Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends State<Buscador> {
  final TextEditingController searchController = TextEditingController();

  void _buscar() {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                hintText: "Buscar productos...",
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => searchController.clear(),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blueAccent, size: 30),
            onPressed: _buscar,
          ),
          Builder(
            builder: (context) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.blueAccent),
                onSelected: (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoriasScreen(categoria: value),
                    ),
                  );
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: "bicicletas", child: Text("Bicicletas")),
                  PopupMenuItem(value: "accesorios", child: Text("Accesorios")),
                  PopupMenuItem(value: "refacciones", child: Text("Refacciones")),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}