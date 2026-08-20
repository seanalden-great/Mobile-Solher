import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const SolherApp());
}

class SolherApp extends StatelessWidget {
  const SolherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solher',
      debugShowCheckedModeBanner: false, // Menghilangkan pita merah "DEBUG" di pojok kanan atas
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        // Anda bisa menambahkan konfigurasi font global di sini nantinya
      ),
      // Aplikasi langsung memuat Navigasi Utama saat pertama kali dibuka
      home: const MainNavigation(), 
    );
  }
}