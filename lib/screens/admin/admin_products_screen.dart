import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getInventory();
      setState(() {
        products = data;
        filteredProducts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar('Error al cargar productos');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products
          .where((p) => p['nombre'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showProductForm({Map<String, dynamic>? product}) async {
    final isEditing = product != null;
    final nombreCtrl = TextEditingController(text: product?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: product?['descripcion'] ?? '');
    final precioCtrl = TextEditingController(
      text: product?['precio']?.toString() ?? '',
    );
    final stockCtrl = TextEditingController(
      text: product?['stock']?.toString() ?? '',
    );
    final stockMinCtrl = TextEditingController(
      text: product?['stock_minimo']?.toString() ?? '',
    );
    final urlCtrl = TextEditingController(text: product?['url_imagen'] ?? '');
    int? idCategoria = product?['id_categoria'];

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: precioCtrl,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockMinCtrl,
                decoration: const InputDecoration(labelText: 'Stock mínimo'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: urlCtrl,
                decoration: const InputDecoration(labelText: 'URL imagen'),
              ),
              DropdownButtonFormField<int>(
                value: idCategoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: const [
                  DropdownMenuItem(value: 3, child: Text('bicicletas')),
                  DropdownMenuItem(value: 1, child: Text('accesorios')),
                  DropdownMenuItem(value: 2, child: Text('refacciones')),
                ],
                onChanged: (val) => idCategoria = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'nombre': nombreCtrl.text,
                'descripcion': descCtrl.text,
                'precio': double.tryParse(precioCtrl.text) ?? 0,
                'stock': int.tryParse(stockCtrl.text) ?? 0,
                'stock_minimo': int.tryParse(stockMinCtrl.text) ?? 0,
                'url_imagen': urlCtrl.text,
                'id_categoria': idCategoria,
              };
              Navigator.pop(context, data);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => isLoading = true);
      Map<String, dynamic> response;
      if (isEditing) {
        response = await ApiService.updateProduct(
          product['id_producto'],
          result,
        );
      } else {
        response = await ApiService.createProduct(result);
      }
      setState(() => isLoading = false);
      if (response['success']) {
        _showSnackbar(isEditing ? 'Producto actualizado' : 'Producto creado');
        _loadProducts();
      } else {
        _showSnackbar(response['message'] ?? 'Error');
      }
    }
  }

  Future<void> _deleteProduct(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => isLoading = true);
      final res = await ApiService.deleteProduct(id);
      setState(() => isLoading = false);
      if (res['success']) {
        _showSnackbar('Producto eliminado');
        _loadProducts();
      } else {
        _showSnackbar(res['message'] ?? 'Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () => _showProductForm(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, i) {
                      final p = filteredProducts[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: p['url_imagen'] != null
                              ? Image.network(
                                  p['url_imagen'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, size: 50),
                          title: Text(p['nombre']),
                          subtitle: Text(
                            '\$${p['precio']} - Stock: ${p['stock']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showProductForm(product: p),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteProduct(
                                  p['id_producto'],
                                  p['nombre'],
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
    );
  }
}
