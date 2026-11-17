import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';
import 'package:bikershop/screens/cliente/producto_detalle_screen.dart';

class CategoriasScreen extends StatefulWidget {
  final String categoria; // recibirá 'bicicletas', 'accesorios', 'refacciones'
  const CategoriasScreen({super.key, required this.categoria});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<dynamic> productos = [];
  List<dynamic> filteredProductos = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProductos();
  }

  Future<void> _loadProductos() async {
    setState(() => isLoading = true);
    try {
      final allProducts = await ApiService.getProducts();
      // Filtrar por la categoría (comparar con categoria_nombre en minúsculas)
      final filtered = allProducts.where((p) {
        final cat = p['categoria_nombre']?.toString().toLowerCase();
        return cat == widget.categoria.toLowerCase();
      }).toList();
      setState(() {
        productos = filtered;
        filteredProductos = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  void _filterProductos(String query) {
    setState(() {
      searchQuery = query;
      filteredProductos = productos
          .where((p) => p['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriaMostrar =
        widget.categoria[0].toUpperCase() + widget.categoria.substring(1);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.65),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: Text(
          categoriaMostrar,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar en $categoriaMostrar...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterProductos,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProductos.isEmpty
                ? const Center(
                    child: Text(
                      'No hay productos en esta categoría',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                    itemCount: filteredProductos.length,
                    itemBuilder: (ctx, index) {
                      final p = filteredProductos[index];
                      return _productoCard(p);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _productoCard(Map<String, dynamic> p) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                p['url_imagen'] ?? 'https://via.placeholder.com/200',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    Text(
                      p['nombre'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "\$${p['precio']}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
