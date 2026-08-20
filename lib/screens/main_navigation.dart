import 'package:flutter/material.dart';
import 'home_page.dart';
import 'order_page.dart';
import 'event_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Indeks halaman yang sedang aktif (dimulai dari 0 yaitu Home)
  int _selectedIndex = 0;

  // Daftar halaman yang akan dirender berdasarkan indeks
  final List<Widget> _pages = [
    const HomePage(),
    const OrderPage(),
    const EventPage(),
    const ProfilePage(),
  ];

  // Fungsi saat salah satu menu di bawah ditekan
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai dengan index yang aktif
      body: _pages[_selectedIndex],
      
      // Komponen Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Mencegah icon bergeser/animasi aneh
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black, // Tema monokrom elegan khas e-commerce
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            activeIcon: Icon(Icons.confirmation_number),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}