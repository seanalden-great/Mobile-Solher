// import 'package:flutter/material.dart';
// // 👇 UBAH IMPORT INI ke file yang menampung Bottom Navigation Bar Anda 👇
// // Contoh: import 'package:solher_mobile/screens/main_page.dart';
// import 'package:solher_mobile/screens/main_navigation.dart'; // Sesuaikan nama file-nya!

// class SuccessPage extends StatelessWidget {
//   const SuccessPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                     color: Colors.green.shade50, shape: BoxShape.circle),
//                 child: const Icon(Icons.check_circle,
//                     color: Colors.green, size: 80),
//               ),
//               const SizedBox(height: 32),
//               const Text('Pembayaran Berhasil!',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w900,
//                       fontFamily: 'serif')),
//               const SizedBox(height: 12),
//               const Text(
//                   'Terima kasih atas pesanan Anda. Kami sedang menyiapkan pesanan Anda untuk dikirim.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(color: Colors.grey, height: 1.5)),
//               const SizedBox(height: 48),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16))),
//                   onPressed: () {
//                     // 👇 UBAH TARGET NAVIGASI KE MAIN PAGE / HALAMAN WRAPPER NAVBAR 👇
//                     Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) =>
//                                 const MainNavigation()), // Sesuaikan dengan nama class Navbar Anda
//                         (route) => false);
//                   },
//                   child: const Text('KEMBALI KE BERANDA',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.5)),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 👇 GANTI DENGAN ROUTE HALAMAN UTAMA APLIKASI ANDA 👇
import 'package:solher_mobile/screens/main_navigation.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  bool _isAuthenticated = false;
  String _guestEmail = "";

  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  bool _isClaiming = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndGuestData();
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      final lastEmail = prefs.getString('last_guest_email');
      if (lastEmail != null && lastEmail.isNotEmpty) {
        setState(() {
          _isAuthenticated = false;
          _guestEmail = lastEmail;
        });
      }
    }
  }

  // 👇 FUNGSI UNTUK MENGKLAIM AKUN (MEMBUAT PASSWORD) 👇
  Future<void> _claimAccount() async {
    if (_guestEmail.isEmpty) return;

    if (_passCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Kata sandi minimal 8 karakter.'),
          backgroundColor: Colors.orange));
      return;
    }

    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok.'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isClaiming = true);

    try {
      final response = await http.post(
          Uri.parse('https://back.solher.co.id/api/claim-account'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: json.encode({
            'email': _guestEmail,
            'password': _passCtrl.text,
            'password_confirmation': _confirmPassCtrl.text
          }));

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Berhasil! Simpan Token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user_data', json.encode(data['user']));
        await prefs.remove('last_guest_email');

        if (mounted) {
          setState(() {
            _isAuthenticated =
                true; // Langsung ubah UI agar muncul "LIHAT PESANAN"
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Akun Aktif! Sekarang Anda bisa melacak pesanan.'),
              backgroundColor: Colors.green));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(data['message'] ?? 'Gagal memproses permintaan.'),
              backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Kesalahan jaringan.'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              const Text('Pembayaran Berhasil! 🎉',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'serif')),
              const SizedBox(height: 12),
              const Text(
                  'Terima kasih atas pesanan Anda. Kami sedang memproses pengiriman.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 48),

              // 👇 OPSI UNTUK MEMBER (SUDAH LOGIN) 👇
              if (_isAuthenticated) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainNavigation()),
                          (route) => false);
                    },
                    child: const Text('LIHAT PESANAN SAYA',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainNavigation()),
                          (route) => false);
                    },
                    child: const Text('KEMBALI KE BERANDA',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
              ]
              // 👇 OPSI UNTUK GUEST (BELUM LOGIN) 👇
              else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade50),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('TRACK YOUR ORDER',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade800,
                                letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Klaim Akun Anda',
                          style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          'Buat kata sandi untuk $_guestEmail agar dapat melacak pesanan ini dan mendapatkan Poin Loyalitas!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey, height: 1.5)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Create Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPassCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          onPressed: _isClaiming ? null : _claimAccount,
                          child: _isClaiming
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('SIMPAN & LACAK PESANAN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainNavigation()),
                        (route) => false);
                  },
                  child: const Text('Lewati, kembali ke Beranda',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
