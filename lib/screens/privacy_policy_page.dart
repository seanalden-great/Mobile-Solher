import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PRIVACY POLICY',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Solher Indonesia',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Kebijakan Privasi',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Solher (\'kami\') menghargai privasi Anda dan berkomitmen untuk melindungi data pribadi Anda. Kebijakan privasi ini akan menginformasikan kepada Anda tentang bagaimana kami mengelola dan menjaga data pribadi Anda saat Anda mengunjungi situs web dan aplikasi kami.',
              style:
                  TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Data yang Kami Kumpulkan',
              'Kami dapat mengumpulkan, menggunakan, menyimpan, dan mentransfer berbagai jenis data pribadi tentang Anda, termasuk:\n\n'
                  '• Data Identitas: Nama depan, nama belakang.\n'
                  '• Data Kontak: Alamat tagihan, alamat pengiriman, alamat email, dan nomor telepon.\n'
                  '• Data Keuangan: Detail pembayaran yang diproses secara aman oleh pihak ketiga.\n'
                  '• Data Transaksi: Detail tentang rincian pesanan dan produk yang Anda beli.',
            ),
            _buildSection(
              '2. Penggunaan Data',
              'Secara umum, kami akan menggunakan data pribadi Anda untuk:\n\n'
                  '• Memproses pesanan, mengelola pembayaran, dan menghitung tarif ongkos kirim.\n'
                  '• Mengelola akun Solher Club Anda dan mengakumulasi poin.\n'
                  '• Mengirimkan buletin promosi (jika Anda telah berlangganan).',
            ),
            _buildSection(
              '3. Keamanan Data',
              'Kami telah menerapkan langkah-langkah keamanan yang ketat untuk mencegah data pribadi Anda hilang, digunakan, atau diakses tanpa izin. Akses data dibatasi hanya untuk staf logistik dan administrasi yang memiliki wewenang.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.shade700, height: 1.6),
          ),
        ],
      ),
    );
  }
}
