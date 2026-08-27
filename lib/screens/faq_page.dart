import 'package:flutter/material.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  String _searchQuery = '';

  // Data tiruan FAQ (sesuaikan dengan data Anda)
  final List<Map<String, String>> _allFaqs = [
    {
      'question': 'Berapa hari waktu pengiriman?',
      'answer':
          'Untuk wilayah Jabodetabek, pengiriman biasanya memakan waktu 1-3 hari kerja. Untuk luar pulau Jawa, estimasi pengiriman adalah 3-7 hari kerja tergantung dari ekspedisi yang dipilih.'
    },
    {
      'question':
          'Apakah saya bisa menukar atau mengembalikan barang (Refund)?',
      'answer':
          'Tentu. Anda dapat menukar atau mengembalikan barang maksimal 7 hari setelah barang diterima. Pastikan tag produk belum dilepas dan barang dalam kondisi belum pernah dipakai. Wajib sertakan video unboxing utuh tanpa jeda.'
    },
    {
      'question': 'Metode pembayaran apa saja yang tersedia?',
      'answer':
          'Kami menerima berbagai macam metode pembayaran yang didukung oleh Xendit, termasuk Transfer Bank (Virtual Account), E-Wallet (GoPay, OVO, DANA, ShopeePay), Kartu Kredit, hingga pembayaran via minimarket.'
    },
    {
      'question': 'Bagaimana cara melacak pesanan saya?',
      'answer':
          'Setelah pesanan Anda dikirim, kami akan mengirimkan nomor resi melalui email. Anda juga dapat melacaknya secara langsung melalui menu "Pesanan Saya" di dalam aplikasi.'
    },
    {
      'question': 'Apakah Solher menyediakan garansi produk?',
      'answer':
          'Ya, setiap produk tas Solher dilengkapi dengan garansi perangkat keras (hardware) seperti ritsleting dan pengait selama 6 bulan sejak tanggal pembelian.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Logika Pencarian
    final filteredFaqs = _allFaqs.where((faq) {
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      final search = _searchQuery.toLowerCase();
      return q.contains(search) || a.contains(search);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BANTUAN & FAQ',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // HEADER AREA
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 24),

                // SEARCH BAR
                TextField(
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari pertanyaan Anda...',
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIST FAQ
          Expanded(
            child: filteredFaqs.isEmpty
                ? const Center(
                    child: Text('Pertanyaan tidak ditemukan.',
                        style: TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            fontSize: 16)))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: Colors.black87,
                            ),
                          ),
                          iconColor: Colors.black,
                          collapsedIconColor: Colors.grey,
                          childrenPadding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          children: [
                            Text(
                              faq['answer']!,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.6),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
