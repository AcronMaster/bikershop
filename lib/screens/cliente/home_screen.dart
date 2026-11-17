import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';
import 'package:bikershop/services/cart_service.dart';
import 'package:bikershop/widgets/buscador.dart';
import 'package:bikershop/widgets/comentarios.dart';
import 'package:bikershop/widgets/contacto.dart';
import 'package:bikershop/screens/cliente/carrito_screen.dart';
import 'package:bikershop/screens/cliente/user_screen.dart';
import 'package:bikershop/screens/cliente/producto_detalle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> productos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await ApiService.getProducts();
      setState(() {
        productos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar productos')),
      );
    }
  }

  Widget heroSection() {
    return Column(
      children: [
        const Text(
          "Encuentra Tu Bicicleta Perfecta",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const Text(
          "Descubre nuestra amplia selección...",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget productosDestacados() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (productos.isEmpty)
      return const Center(
        child: Text('No hay productos', style: TextStyle(color: Colors.white)),
      );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: productos.length > 2 ? 2 : productos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 300,
        ),
        itemBuilder: (ctx, index) {
          final p = productos[index];
          return productoCard(p);
        },
      ),
    );
  }

  Widget seccionCategorias() {
    final Map<String, List<dynamic>> grouped = {};
    for (var p in productos) {
      final cat = p['categoria_nombre'] ?? 'Otros';
      grouped.putIfAbsent(cat, () => []).add(p);
    }
    return Column(
      children: grouped.entries.map((entry) {
        return Column(
          children: [
            tituloSeccion(entry.key),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: entry.value
                  .take(4)
                  .map((p) => SizedBox(width: 200, child: productoCard(p)))
                  .toList(),
            ),
            const SizedBox(height: 30),
          ],
        );
      }).toList(),
    );
  }

  Widget tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          titulo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget productoCard(Map<String, dynamic> p) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductoDetalleScreen(producto: p)),
        );
        if (result != null && result is Map<String, dynamic>) {
          // Convertir precio a double si es necesario
          if (result['precio'] is String) {
            result['precio'] = double.tryParse(result['precio']) ?? 0.0;
          }
          CartService().addItem(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto agregado al carrito')),
          );
        }
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
              height: 200,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  p['url_imagen'] ?? 'https://via.placeholder.com/200',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Image.asset('assets/images/fondo.jpg', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              p['nombre'],
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "\$${p['precio']}",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        backgroundColor: Colors.black.withValues(alpha: 0.65),
        title: const Center(
          child: Text("UrbanBikerShop", style: TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CarritoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PerfilScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                const Buscador(),
                heroSection(),
                productosDestacados(),
                seccionCategorias(),
                comentarios(),
                contacto(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
