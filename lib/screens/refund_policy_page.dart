import 'package:flutter/material.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('REFUND POLICY',
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
                'Kebijakan Pengembalian Dana',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Pengembalian Dana Otomatis (Pembatalan)',
              'Jika pesanan Anda dibatalkan sebelum diproses oleh mitra logistik kami, atau jika pihak logistik menolak penjemputan, sistem kami akan secara otomatis memproses pengembalian dana penuh ke metode pembayaran awal Anda. Poin Loyalitas apa pun yang digunakan juga akan langsung dikembalikan ke akun Anda.',
            ),
            _buildRichSection(
                '2. Permintaan Pengembalian Dana Manual',
                [
                  'Kami menerima permintaan pengembalian barang dan dana dalam waktu 3 hari sejak tanggal pengiriman. Agar memenuhi syarat untuk pengembalian, barang Anda harus belum digunakan, dalam kondisi yang sama seperti saat Anda menerimanya, dan berada dalam kemasan aslinya (termasuk tas anti debu/dust bag dan label harga).',
                  'Anda dapat mengajukan permintaan pengembalian dana secara langsung melalui halaman "Pesanan" Anda. Video unboxing yang wajib disertakan atau foto yang jelas dari cacat produk harus diunggah sebagai bukti pengajuan.',
                ],
                highlightText:
                    'Video unboxing yang wajib disertakan atau foto yang jelas'),
            _buildSection(
              '3. Pemrosesan Pengembalian Dana Anda',
              'Setelah barang retur Anda kami terima dan periksa, kami akan memberi tahu Anda mengenai persetujuan atau penolakan pengembalian dana Anda. Jika disetujui, pengembalian dana akan segera diproses. Harap diperhatikan bahwa mungkin diperlukan beberapa waktu bagi bank atau perusahaan kartu kredit Anda untuk secara resmi membukukan pengembalian dana tersebut.',
            ),
            _buildSection(
              '4. Barang yang Tidak Dapat Dikembalikan',
              'Jenis barang tertentu tidak dapat dikembalikan, termasuk barang diskon (sale), produk dengan desain khusus, atau barang yang rusak akibat perawatan yang tidak tepat. Biaya pengiriman tidak dapat dikembalikan.',
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

  Widget _buildRichSection(String title, List<String> paragraphs,
      {required String highlightText}) {
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
          ...paragraphs.map((para) {
            if (para.contains(highlightText)) {
              final parts = para.split(highlightText);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade700, height: 1.6),
                    children: [
                      TextSpan(text: parts[0]),
                      TextSpan(
                          text: highlightText,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      if (parts.length > 1) TextSpan(text: parts[1]),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                para,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade700, height: 1.6),
              ),
            );
          }),
        ],
      ),
    );
  }
}
