import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';
import 'package:bikershop/services/cart_service.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  List<Map<String, dynamic>> carrito = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    setState(() {
      carrito = List.from(CartService().items);
    });
  }

  double get total {
    double suma = 0;
    for (var item in carrito) {
      final price = _toDouble(item["precio"]);
      final quantity = (item["cantidad"] as int?) ?? 1;
      suma += price * quantity;
    }
    return suma;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<void> _realizarReserva() async {
    final logged = await ApiService.isLoggedIn();
    if (!logged) {
      _showSnackbar('Debes iniciar sesión para reservar');
      return;
    }

    final user = await ApiService.getCurrentUser();
    if (user == null || user['validado'] != true) {
      _showSnackbar(
        'Tu cuenta no está validada. Espera la aprobación del administrador.',
      );
      return;
    }

    if (carrito.isEmpty) {
      _showSnackbar('El carrito está vacío');
      return;
    }

    setState(() => isProcessing = true);

    final productosParaApi = carrito.map((item) {
      return {"id_producto": item["id_producto"], "cantidad": item["cantidad"]};
    }).toList();

    final result = await ApiService.createReservation(productosParaApi);
    setState(() => isProcessing = false);

    if (result['success']) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Center(
            child: Text(
              "Reserva realizada",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tu pedido fue registrado"),
              const SizedBox(height: 10),
              const Text(
                "Folio:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                result['folio'],
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Válido hasta: ${result['expiracion']}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                CartService().clear();
                _loadCart();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      _showSnackbar(result['message'] ?? 'Error al realizar reserva');
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      CartService().removeItem(index);
      setState(() {
        carrito.removeAt(index);
      });
    } else {
      CartService().updateQuantity(index, newQuantity);
      setState(() {
        carrito[index]['cantidad'] = newQuantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: const Text("Carrito", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withValues(alpha: 0.65),
      ),
      body: carrito.isEmpty
          ? const Center(
              child: Text(
                'Carrito vacío',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      final p = carrito[index];
                      final precioNum = _toDouble(p["precio"]);
                      return Card(
                        margin: const EdgeInsets.all(14),
                        child: ListTile(
                          leading:
                              p['url_imagen'] != null &&
                                  p['url_imagen'].toString().isNotEmpty
                              ? Image.network(
                                  p['url_imagen'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/Fondo2.jpeg',
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/Fondo2.jpeg',
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                          title: Text(
                            p["nombre"] ?? 'Producto',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "\$${precioNum.toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.green[900]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  final currentQ = p["cantidad"] as int;
                                  _updateQuantity(index, currentQ - 1);
                                },
                              ),
                              Text("${p["cantidad"]}"),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  final currentQ = p["cantidad"] as int;
                                  _updateQuantity(index, currentQ + 1);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _updateQuantity(index, 0);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.black,
                          ),
                          onPressed: isProcessing ? null : _realizarReserva,
                          child: isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Hacer reserva",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
