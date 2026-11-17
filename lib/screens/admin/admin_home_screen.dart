import 'package:bikershop/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:bikershop/screens/admin/admin_products_screen.dart';
import 'package:bikershop/screens/admin/admin_suppliers_screen.dart';
import 'package:bikershop/screens/admin/admin_reservations_screen.dart';
import 'package:bikershop/screens/admin/admin_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminProductsScreen(),
    AdminSuppliersScreen(),
    AdminReservationsScreen(),
    AdminUsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.89),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blueAccent),
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.65),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blueAccent),
            onPressed: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withValues(alpha: 0.65),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, color: Colors.black),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping, color: Colors.black),
            label: 'Proveedores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online, color: Colors.black),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, color: Colors.black),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
}
