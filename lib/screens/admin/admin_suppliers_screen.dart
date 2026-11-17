import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';

class AdminSuppliersScreen extends StatefulWidget {
  const AdminSuppliersScreen({super.key});

  @override
  State<AdminSuppliersScreen> createState() => _AdminSuppliersScreenState();
}

class _AdminSuppliersScreenState extends State<AdminSuppliersScreen> {
  List<dynamic> suppliers = [];
  List<dynamic> filtered = [];
  bool isLoading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getSuppliers();
      setState(() {
        suppliers = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar('Error al cargar proveedores');
    }
  }

  void _filter(String q) {
    setState(() {
      search = q;
      filtered = suppliers
          .where((s) => s['nombre'].toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showSupplierForm({Map<String, dynamic>? supplier}) async {
    final isEditing = supplier != null;
    final nombreCtrl = TextEditingController(text: supplier?['nombre'] ?? '');
    final telefonoCtrl = TextEditingController(
      text: supplier?['telefono'] ?? '',
    );
    final correoCtrl = TextEditingController(text: supplier?['correo'] ?? '');

    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: correoCtrl,
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
            onPressed: () => Navigator.pop(context, {
              'nombre': nombreCtrl.text,
              'telefono': telefonoCtrl.text,
              'correo': correoCtrl.text,
            }),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => isLoading = true);
      Map<String, dynamic> response;
      if (isEditing) {
        response = await ApiService.updateSupplier(
          supplier['id_proveedor'],
          result,
        );
      } else {
        response = await ApiService.createSupplier(result);
      }
      setState(() => isLoading = false);
      if (response['success']) {
        _showSnackbar(isEditing ? 'Proveedor actualizado' : 'Proveedor creado');
        _loadSuppliers();
      } else {
        _showSnackbar(response['message'] ?? 'Error');
      }
    }
  }

  Future<void> _deleteSupplier(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text('¿Eliminar proveedor $nombre?'),
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
      final res = await ApiService.deleteSupplier(id);
      setState(() => isLoading = false);
      if (res['success']) {
        _showSnackbar('Proveedor eliminado');
        _loadSuppliers();
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
        onPressed: () => _showSupplierForm(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar proveedores...',
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
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            s['nombre'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${s['telefono'] ?? ''} - ${s['correo'] ?? ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showSupplierForm(supplier: s),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteSupplier(
                                  s['id_proveedor'],
                                  s['nombre'],
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
