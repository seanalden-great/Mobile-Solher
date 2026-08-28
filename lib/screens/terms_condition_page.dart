import 'package:flutter/material.dart';

class TermsConditionPage extends StatelessWidget {
  const TermsConditionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('TERMS & CONDITIONS',
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
                'Syarat & Ketentuan',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Selamat datang di Solher. Dengan mengakses atau menggunakan situs web dan aplikasi kami, Anda setuju untuk terikat oleh Syarat dan Ketentuan ini.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Akun & Keanggotaan',
              'Saat Anda membuat akun bersama kami, Anda harus memberikan informasi yang akurat dan lengkap. Pengguna terdaftar baru mungkin memenuhi syarat untuk mendapatkan bonus selamat datang, seperti Poin Loyalitas. Poin yang terkumpul dapat digunakan sebagai diskon saat pembayaran, dengan tunduk pada batas potongan maksimum.',
            ),
            _buildSection(
              '2. Produk & Harga',
              'Kami telah berupaya semaksimal mungkin untuk menampilkan warna dan gambar produk kami secara akurat. Kami tidak dapat menjamin bahwa tampilan warna pada monitor/layar HP Anda akan sepenuhnya presisi. Semua harga dapat berubah sewaktu-waktu tanpa pemberitahuan.',
            ),
            _buildSection(
              '3. Batasan Pesanan & Stok',
              'Kami berhak menolak pesanan apa pun yang Anda ajukan. Jika terjadi selisih stok atau persaingan pesanan (race condition) selama lalu lintas penjualan yang tinggi, sistem kami secara ketat mengalokasikan stok berdasarkan prinsip siapa cepat, dia dapat. Jika pembayaran diproses tetapi stok habis, pengembalian dana otomatis akan diterbitkan.',
            ),
            _buildSection(
              '4. Keamanan Pembayaran',
              'Semua transaksi daring diproses secara aman melalui gerbang pembayaran resmi kami. Kami tidak menyimpan detail kartu kredit/debit Anda secara langsung di server kami.',
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
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