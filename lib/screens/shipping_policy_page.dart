import 'package:flutter/material.dart';

class ShippingPolicyPage extends StatelessWidget {
  const ShippingPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SHIPPING POLICY',
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
                'Kebijakan Pengiriman',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Waktu Pemrosesan',
              'Semua pesanan diproses dalam waktu 1-2 hari kerja (tidak termasuk akhir pekan dan hari libur nasional) setelah kami menerima email konfirmasi pesanan Anda. Anda akan menerima pemberitahuan selanjutnya ketika pesanan Anda telah dikirimkan.',
            ),
            _buildSectionWithList(
              '2. Tarif & Estimasi Pengiriman',
              'Kami bermitra dengan berbagai penyedia layanan logistik tepercaya untuk menawarkan tarif dan waktu pengiriman terbaik bagi Anda. Biaya pengiriman untuk pesanan Anda akan dihitung dan ditampilkan pada saat pembayaran (checkout) berdasarkan berat volumetrik barang dan alamat tujuan Anda.',
              [
                {
                  'label': 'Instan/Hari yang Sama',
                  'desc':
                      'Pengiriman pada hari yang sama jika pesanan dilakukan sebelum pukul 14:00 WIB.'
                },
                {
                  'label': 'Hari Berikutnya (Next Day)',
                  'desc': 'Dikirim pada hari kerja berikutnya.'
                },
                {
                  'label': 'Reguler',
                  'desc':
                      'Biasanya memakan waktu 2-5 hari kerja tergantung pada lokasi Anda.'
                },
              ],
            ),
            _buildSection(
              '3. Pelacakan Pesanan',
              'Setelah pesanan Anda dikirimkan, Anda dapat melacak status waktu nyatanya (real-time) secara langsung dari halaman "Pesanan" di dasbor akun Anda. Harap tunggu hingga 24 jam agar portal pelacakan diperbarui oleh pihak logistik.',
            ),
            _buildSection(
              '4. Pengambilan di Toko (In-Store Pickup)',
              'Anda dapat melewati biaya pengiriman dengan opsi pengambilan lokal gratis di lokasi stan fisik kami atau toko mitra selama acara khusus berlangsung. Setelah melakukan pemesanan dan memilih opsi pengambilan lokal saat pembayaran, pesanan Anda akan disiapkan dan siap untuk diambil dalam waktu 1 hari kerja.',
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

  Widget _buildSectionWithList(
      String title, String content, List<Map<String, String>> items) {
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
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5),
                          children: [
                            TextSpan(
                                text: '${item['label']}: ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            TextSpan(text: item['desc']),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
