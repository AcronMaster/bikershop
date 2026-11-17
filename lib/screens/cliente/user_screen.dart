import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = await ApiService.getCurrentUser();
    setState(() {
      user = userData;
      isLoading = false;
    });
  }

  Future<void> _updateProfile(String nombre, String correo) async {
    setState(() => isLoading = true);
    final result = await ApiService.updateProfile(nombre, correo);
    setState(() => isLoading = false);
    if (result['success']) {
      setState(() {
        user = result['user'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error al actualizar')),
      );
    }
  }

  void _editarPerfilDialog() {
    final nombreController = TextEditingController(text: user?['nombre']);
    final emailController = TextEditingController(text: user?['correo']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevoNombre = nombreController.text.trim();
              final nuevoEmail = emailController.text.trim();
              if (nuevoNombre.isNotEmpty && nuevoEmail.isNotEmpty) {
                Navigator.pop(context);
                _updateProfile(nuevoNombre, nuevoEmail);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: const Text("Perfil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withValues(alpha: 0.65),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?['nombre'] ?? 'Sin nombre',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?['correo'] ?? 'Sin correo',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: user?['validado'] == true
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?['validado'] == true
                          ? '✓ Cuenta validada'
                          : '⏳ Pendiente de validación',
                      style: TextStyle(
                        color: user?['validado'] == true
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      "Editar perfil",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _editarPerfilDialog,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "Cerrar sesión",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      await ApiService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
