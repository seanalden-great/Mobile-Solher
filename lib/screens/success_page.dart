import 'package:flutter/material.dart';
// 👇 UBAH IMPORT INI ke file yang menampung Bottom Navigation Bar Anda 👇
// Contoh: import 'package:solher_mobile/screens/main_page.dart';
import 'package:solher_mobile/screens/main_navigation.dart'; // Sesuaikan nama file-nya!

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.green.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle,
                    color: Colors.green, size: 80),
              ),
              const SizedBox(height: 32),
              const Text('Pembayaran Berhasil!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'serif')),
              const SizedBox(height: 12),
              const Text(
                  'Terima kasih atas pesanan Anda. Kami sedang menyiapkan pesanan Anda untuk dikirim.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    // 👇 UBAH TARGET NAVIGASI KE MAIN PAGE / HALAMAN WRAPPER NAVBAR 👇
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const MainNavigation()), // Sesuaikan dengan nama class Navbar Anda
                        (route) => false);
                  },
                  child: const Text('KEMBALI KE BERANDA',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
