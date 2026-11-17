import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'cart';
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<Map<String, dynamic>> _items = [];

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartStr = prefs.getString(_cartKey);
    if (cartStr != null) {
      _items = List<Map<String, dynamic>>.from(jsonDecode(cartStr));
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(_items));
  }

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> product) {
    final price = (product['precio'] is num)
        ? (product['precio'] as num).toDouble()
        : double.tryParse(product['precio'].toString()) ?? 0.0;

    final index = _items.indexWhere(
      (item) => item['id_producto'] == product['id_producto'],
    );
    if (index != -1) {
      _items[index]['cantidad']++;
    } else {
      _items.add({
        'id_producto': product['id_producto'],
        'nombre': product['nombre'].toString(),
        'precio': price,
        'cantidad': 1,
        'url_imagen': product['url_imagen'] ?? '', // Guardamos la URL
      });
    }
    _saveCart();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    _saveCart();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index]['cantidad'] = quantity;
    }
    _saveCart();
  }

  void clear() {
    _items.clear();
    _saveCart();
  }
}
