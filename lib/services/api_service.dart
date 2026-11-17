import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ Cambia según tu entorno:
  // - Android Emulator: 10.0.2.2
  // - iOS Simulator: localhost
  // - Dispositivo físico: IP de tu computadora en la red local
  static const String baseUrl = 'http://localhost:3000/api';

  // Obtener headers con token si existe
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ------------------- AUTENTICACIÓN -------------------
  static Future<Map<String, dynamic>> register(
    String nombre,
    String correo,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'contraseña': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'success': true, 'message': data['message']};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> login(
    String correo,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contraseña': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user', jsonEncode(data['user']));
      return {'success': true, 'user': data['user'], 'token': data['token']};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) return jsonDecode(userStr);
    return null;
  }

  // ------------------- PRODUCTOS -------------------
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List<dynamic> products = jsonDecode(response.body);
      // Asegurar que precio sea num
      for (var p in products) {
        if (p['precio'] is String) {
          p['precio'] = double.tryParse(p['precio']) ?? 0.0;
        }
      }
      return products;
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  static Future<Map<String, dynamic>> getProductById(int id) async {
    final url = Uri.parse('$baseUrl/products/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Producto no encontrado');
    }
  }

  // ------------------- RESERVACIONES -------------------
  static Future<Map<String, dynamic>> createReservation(
    List<Map<String, dynamic>> productos,
  ) async {
    final url = Uri.parse('$baseUrl/reservations');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'productos': productos}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {
        'success': true,
        'folio': data['folio'],
        'expiracion': data['fecha_expiracion'],
      };
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<List<dynamic>> getMyReservations() async {
    final url = Uri.parse('$baseUrl/reservations');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar reservas');
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String nombre,
    String correo,
  ) async {
    final url = Uri.parse('$baseUrl/users/me');
    final headers = await _getHeaders();
    try {
      final response = await http
          .put(
            url,
            headers: headers,
            body: jsonEncode({'nombre': nombre, 'correo': correo}),
          )
          .timeout(const Duration(seconds: 10)); // ⏱️ Timeout de 10 segundos

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Actualizar datos en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final currentUser = await getCurrentUser();
        if (currentUser != null) {
          currentUser['nombre'] = nombre;
          currentUser['correo'] = correo;
          await prefs.setString('user', jsonEncode(currentUser));
        }
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar',
        };
      }
    } catch (e) {
      print('Error en updateProfile: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ------------------- ADMIN: PRODUCTOS -------------------
  static Future<List<dynamic>> getInventory() async {
    final url = Uri.parse('$baseUrl/admin/inventory');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al cargar inventario');
  }

  static Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> product,
  ) async {
    final url = Uri.parse('$baseUrl/admin/products');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(product),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201)
      return {'success': true, 'product': data['product']};
    return {'success': false, 'message': data['message']};
  }

  static Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> product,
  ) async {
    final url = Uri.parse('$baseUrl/admin/products/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(product),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'product': data['product']};
    return {'success': false, 'message': data['message']};
  }

  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/admin/products/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'message': data['message']};
    return {'success': false, 'message': data['message']};
  }

  // ------------------- ADMIN: PROVEEDORES -------------------
  static Future<List<dynamic>> getSuppliers() async {
    final url = Uri.parse('$baseUrl/admin/suppliers');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al cargar proveedores');
  }

  static Future<Map<String, dynamic>> createSupplier(
    Map<String, dynamic> supplier,
  ) async {
    final url = Uri.parse('$baseUrl/admin/suppliers');
    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(supplier),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201)
      return {'success': true, 'supplier': data['supplier']};
    return {'success': false, 'message': data['message']};
  }

  static Future<Map<String, dynamic>> updateSupplier(
    int id,
    Map<String, dynamic> supplier,
  ) async {
    final url = Uri.parse('$baseUrl/admin/suppliers/$id');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(supplier),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'supplier': data['supplier']};
    return {'success': false, 'message': data['message']};
  }

  static Future<Map<String, dynamic>> deleteSupplier(int id) async {
    final url = Uri.parse('$baseUrl/admin/suppliers/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'message': data['message']};
    return {'success': false, 'message': data['message']};
  }

  // ------------------- ADMIN: RESERVAS -------------------
  static Future<List<dynamic>> getAllReservations() async {
    final url = Uri.parse('$baseUrl/admin/reservations');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al cargar reservas');
  }

  static Future<Map<String, dynamic>> cancelReservationAdmin(String id) async {
    final url = Uri.parse('$baseUrl/admin/reservations/$id/cancel');
    final headers = await _getHeaders();
    final response = await http.put(url, headers: headers);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'message': data['message']};
    return {'success': false, 'message': data['message']};
  }

  static Future<Map<String, dynamic>> confirmDelivery(String id) async {
    final url = Uri.parse('$baseUrl/admin/reservations/$id/deliver');
    final headers = await _getHeaders();
    final response = await http.put(url, headers: headers);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'message': data['message']};
    return {'success': false, 'message': data['message']};
  }

  // ------------------- ADMIN: USUARIOS -------------------
  static Future<List<dynamic>> getUsers() async {
    final url = Uri.parse('$baseUrl/admin/users');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al cargar usuarios');
  }

  static Future<Map<String, dynamic>> validateUser(
    int id,
    bool validado,
  ) async {
    final url = Uri.parse('$baseUrl/admin/users/$id/validate');
    final headers = await _getHeaders();
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode({'validado': validado}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'message': data['message']};
    return {'success': false, 'message': data['message']};
  }

  static Future<Map<String, dynamic>> disableUser(int id) async {
    final url = Uri.parse('$baseUrl/admin/users/$id');
    final headers = await _getHeaders();
    final response = await http.delete(url, headers: headers);
    final data = jsonDecode(response.body);
    if (response.statusCode == 200)
      return {'success': true, 'message': data['message']};
    return {'success': false, 'message': data['message']};
  }
}
