import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ABOUT US',
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
        child: Column(
          children: [
            // AREA TEKS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'CRAFTING TIMELESS ELEGANCE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 32,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'For the Modern Woman',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Di Solher, kami percaya bahwa tas bukan sekadar wadah untuk membawa barang, melainkan sebuah pernyataan gaya dan refleksi dari kepribadian Anda. Kami berdedikasi untuk menciptakan karya yang memadukan keanggunan klasik dengan sentuhan modern.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.8,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Setiap jahitan, setiap potongan material kulit premium yang kami pilih, dikerjakan dengan presisi tingkat tinggi oleh pengrajin ahli kami. Kami memastikan setiap detail sempurna sebelum produk kami sampai ke tangan Anda.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.8,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Misi kami sederhana: Memberikan Anda rasa percaya diri yang tak tergoyahkan setiap kali Anda melangkah keluar dengan membawa koleksi dari Solher. Temukan kebebasan dalam berekspresi.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.8,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),

            // AREA MARQUEE / BANNER TEKS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.symmetric(
                    horizontal: BorderSide(color: Colors.grey.shade200)),
              ),
              child: const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      '  ELEVATE YOUR EVERYDAY STYLE   •   ELEVATE YOUR EVERYDAY STYLE   •   ELEVATE YOUR EVERYDAY STYLE  ',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // AREA GAMBAR
            // Pastikan Anda memodifikasi path asset sesuai dengan yang ada di pubspec.yaml Anda
            SizedBox(
              width: double.infinity,
              height: 400,
              child: Image.asset(
                'assets/images/second_banner.png', // Ganti dengan aset gambar yang relevan
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
