import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getUsers();
      final withoutAdmins = data.where((u) => u['rol'] != 'admin').toList();
      setState(() {
        users = withoutAdmins;
        filteredUsers = withoutAdmins;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar('Error al cargar usuarios');
    }
  }

  void _filter(String q) {
    setState(() {
      search = q;
      filteredUsers = users
          .where(
            (u) =>
                u['nombre'].toLowerCase().contains(q.toLowerCase()) ||
                u['correo'].toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _validateUser(int id, bool validado) async {
    final res = await ApiService.validateUser(id, validado);
    if (res['success']) {
      _showSnackbar(validado ? 'Usuario validado' : 'Usuario rechazado');
      _loadUsers();
    } else {
      _showSnackbar(res['message'] ?? 'Error');
    }
  }

  Future<void> _disableUser(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dar de baja'),
        content: Text('¿Dar de baja al usuario $nombre?'),
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
      final res = await ApiService.disableUser(id);
      setState(() => isLoading = false);
      if (res['success']) {
        _showSnackbar('Usuario dado de baja');
        _loadUsers();
      } else {
        _showSnackbar(res['message'] ?? 'Error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (ctx, i) {
                      final u = filteredUsers[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            u['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${u['correo']} - ${u['rol']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mostrar botón de validar solo si no está validado
                              if (!u['validado'])
                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  onPressed: () =>
                                      _validateUser(u['id_usuario'], true),
                                  tooltip: 'Validar usuario',
                                ),
                              if (u['validado'] && u['rol'] != 'admin')
                                IconButton(
                                  icon: const Icon(
                                    Icons.block,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () =>
                                      _validateUser(u['id_usuario'], false),
                                  tooltip: 'Invalidar usuario',
                                ),
                              if (u['activo'])
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _disableUser(
                                    u['id_usuario'],
                                    u['nombre'],
                                  ),
                                  tooltip: 'Dar de baja',
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
