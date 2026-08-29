import 'package:flutter/material.dart';

class CustomerCarePage extends StatelessWidget {
  const CustomerCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CUSTOMER CARE',
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang di\nLayanan Pelanggan!\nSolHer',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 40,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Kami hadir untuk membantu Anda menemukan solusi alami terbaik bagi kesehatan dan kesejahteraan Anda.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),

            // Bagian Kontak
            Row(
              children: [
                const Text('📞', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'HUBUNGI KAMI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactRow('Telepon / WhatsApp:', '+62 888 388 8585'),
            const SizedBox(height: 8),
            _buildContactRow('Email:', 'care@solherbag.com'),
            const SizedBox(height: 40),

            // Bagian Jam Operasional
            Row(
              children: [
                const Text('🕒', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'JAM OPERASIONAL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Layanan pelanggan kami tersedia pada jadwal berikut:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _buildHoursRow('Senin – Jumat:', '08:00 – 17:00 (WIB)'),
            const SizedBox(height: 8),
            _buildHoursRow('Sabtu:', '09:00 – 14:00 (WIB)'),
            const SizedBox(height: 8),
            _buildHoursRow('Minggu & Libur Nasional:', 'Tutup', isClosed: true),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursRow(String day, String hours, {bool isClosed = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 170,
          child: Text(
            day,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              color: isClosed ? Colors.grey.shade500 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
