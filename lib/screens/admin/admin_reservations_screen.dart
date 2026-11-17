import 'package:flutter/material.dart';
import 'package:bikershop/services/api_service.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  List<dynamic> reservations = [];
  List<dynamic> filtered = [];
  bool isLoading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getAllReservations();
      setState(() {
        reservations = data;
        filtered = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar('Error al cargar reservas');
    }
  }

  void _filter(String q) {
    setState(() {
      search = q;
      filtered = reservations
          .where(
            (r) =>
                r['folio'].toLowerCase().contains(q.toLowerCase()) ||
                r['cliente_nombre'].toLowerCase().contains(q.toLowerCase()),
          )
          .toList();
    });
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _cancelReservation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text(
          '¿Estás seguro de cancelar esta reserva? Se devolverá el stock.',
        ),
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
      final res = await ApiService.cancelReservationAdmin(id);
      setState(() => isLoading = false);
      if (res['success']) {
        _showSnackbar('Reserva cancelada');
        _loadReservations();
      } else {
        _showSnackbar(res['message'] ?? 'Error');
      }
    }
  }

  Future<void> _confirmDelivery(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: const Text('¿Marcar esta reserva como completada?'),
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
      final res = await ApiService.confirmDelivery(id);
      setState(() => isLoading = false);
      if (res['success']) {
        _showSnackbar('Entrega confirmada');
        _loadReservations();
      } else {
        _showSnackbar(res['message'] ?? 'Error');
      }
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'activa':
        return Colors.green;
      case 'completada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      case 'expirada':
        return Colors.orange;
      default:
        return Colors.grey;
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
                hintText: 'Buscar por folio o cliente...',
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
                      final r = filtered[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Folio: ${r['id_reserva']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _estadoColor(
                                    r['estado'],
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  r['estado'],
                                  style: TextStyle(
                                    color: _estadoColor(r['estado']),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Cliente: ${r['cliente_nombre']} - ${r['cliente_correo']}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${r['fecha']}'),
                                  Text('Expira: ${r['fecha_expiracion']}'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Productos:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...(r['productos'] as List).map(
                                    (p) => Text(
                                      '• ${p['cantidad']} x Producto ID ${p['id_producto']}',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (r['estado'] == 'activa')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            size: 18,
                                          ),
                                          label: const Text('Entregar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () =>
                                              _confirmDelivery(r['id_reserva']),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.cancel,
                                            size: 18,
                                          ),
                                          label: const Text('Cancelar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () => _cancelReservation(
                                            r['id_reserva'],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
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
