// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:solher_mobile/screens/auth/login_page.dart';

// class AffiliateLandingPage extends StatefulWidget {
//   const AffiliateLandingPage({super.key});

//   @override
//   State<AffiliateLandingPage> createState() => _AffiliateLandingPageState();
// }

// class _AffiliateLandingPageState extends State<AffiliateLandingPage> {
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey _formKey = GlobalKey();

//   final TextEditingController _socialUrlController = TextEditingController();
//   final TextEditingController _reasonController = TextEditingController();

//   bool _isSubmitting = false;
//   bool _alreadyAffiliate = false;
//   int? _activeFaqIndex;

//   final List<Map<String, String>> _faqs = [
//     {
//       'question': 'Apa syarat menjadi Solher Ambassador?',
//       'answer':
//           'Anda harus memiliki akun media sosial yang aktif dan relevan dengan audiens fesyen/lifestyle. Kami akan meninjau profil Anda sebelum memberikan persetujuan.'
//     },
//     {
//       'question': 'Berapa komisi yang saya dapatkan?',
//       'answer':
//           'Komisi standar mulai dari 5% hingga 15% dari total penjualan, tergantung pada level tier afiliasi Anda.'
//     },
//     {
//       'question': 'Kapan komisi dicairkan?',
//       'answer':
//           'Komisi akan berstatus "Settled" setelah pesanan pelanggan selesai. Pencairan dapat ditarik kapan saja ke rekening bank Anda dengan minimal penarikan Rp 100.000.'
//     },
//   ];

//   final List<Map<String, String>> _feedbacks = [
//     {
//       'name': 'Amanda T.',
//       'platform': 'Instagram Creator',
//       'comment':
//           'Sistem afiliasi paling transparan yang pernah saya ikuti. Tas Solher sangat mudah dijual karena kualitasnya memang premium!'
//     },
//     {
//       'name': 'Siti Rahma',
//       'platform': 'TikTok Affiliate',
//       'comment':
//           'Sangat menguntungkan! Dashboard afiliatornya sangat mudah digunakan untuk melacak klik dan komisi harian.'
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _checkAffiliateStatus();
//   }

//   Future<void> _checkAffiliateStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userDataStr = prefs.getString('user_data');
//     if (userDataStr != null) {
//       try {
//         final user = json.decode(userDataStr);
//         if (user['is_affiliate'] == 1 || user['is_affiliate'] == true) {
//           setState(() {
//             _alreadyAffiliate = true;
//           });
//         }
//       } catch (e) {
//         debugPrint('Error parsing user data: $e');
//       }
//     }
//   }

//   void _scrollToForm() {
//     if (_formKey.currentContext != null) {
//       Scrollable.ensureVisible(
//         _formKey.currentContext!,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.easeInOutQuart,
//       );
//     }
//   }

//   Future<void> _submitApplication() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');

//     if (token == null) {
//       if (!mounted) return;
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Login Diperlukan',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           content: const Text(
//               'Silakan login ke akun Anda terlebih dahulu untuk bergabung dengan program Afiliasi.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Batal', style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (_) => const LoginPage()));
//               },
//               child: const Text('Login', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     if (_socialUrlController.text.isEmpty || _reasonController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Semua kolom wajib diisi'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }

//     setState(() => _isSubmitting = true);

//     try {
//       const String baseUrl = 'https://back.solher.co.id/api';
//       final response = await http.post(
//         Uri.parse('$baseUrl/affiliate/apply'),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode({
//           'social_media_url': _socialUrlController.text.trim(),
//           'reason': _reasonController.text.trim(),
//         }),
//       );

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text('Pendaftaran Berhasil! Data Anda sedang kami tinjau.'),
//           backgroundColor: Colors.green,
//         ));
//         _socialUrlController.clear();
//         _reasonController.clear();
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content:
//               Text(responseData['message'] ?? 'Gagal mengirim pendaftaran.'),
//           backgroundColor: Colors.red,
//         ));
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Terjadi kesalahan jaringan.'),
//         backgroundColor: Colors.red,
//       ));
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _socialUrlController.dispose();
//     _reasonController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             _buildHeroSection(),
//             _buildHowItWorksSection(),
//             _buildBenefitsSection(),
//             _buildTestimonialSection(),
//             _buildFaqSection(),
//             _buildFormSection(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeroSection() {
//     return Stack(
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height * 0.8,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(
//                   'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?q=80&w=2000'),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.8,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//               colors: [Colors.black, Colors.black.withOpacity(0.4)],
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 60,
//           left: 24,
//           right: 24,
//           child: Column(
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white30),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   'PROGRAM EKSKLUSIF',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Solher\nAmbassador.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 40,
//                     fontFamily: 'serif',
//                     height: 1.1),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Ubah pengaruh Anda menjadi penghasilan. Dapatkan komisi khusus dengan membagikan koleksi premium Solher ke audiens Anda.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero),
//                   ),
//                   onPressed: _scrollToForm,
//                   child: const Text('DAFTAR SEKARANG',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 2,
//                           fontSize: 12)),
//                 ),
//               )
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildHowItWorksSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text(
//             'Cara Bergabung',
//             style: TextStyle(fontSize: 28, fontFamily: 'serif'),
//           ),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.black,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           _buildStepItem(Icons.edit_document, '1. Isi Formulir',
//               'Lengkapi data profil dan tautan media sosial utama Anda.'),
//           _buildStepItem(Icons.hourglass_empty, '2. Proses Review',
//               'Tim kami akan meninjau kelayakan profil Anda dalam 1x24 jam.'),
//           _buildStepItem(Icons.lock_open, '3. Akses Dibuka',
//               'Dapatkan tautan unik dan akses ke Dasbor Afiliator.'),
//           _buildStepItem(
//               Icons.monetization_on_outlined,
//               '4. Mulai Menghasilkan',
//               'Bagikan tautan Anda dan dapatkan komisi dari setiap pesanan.'),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepItem(IconData icon, String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 32.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Icon(icon, color: Colors.black87),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 8),
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         letterSpacing: 1)),
//                 const SizedBox(height: 8),
//                 Text(desc,
//                     style: const TextStyle(
//                         color: Colors.grey, fontSize: 12, height: 1.5)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitsSection() {
//     return Container(
//       width: double.infinity,
//       color: const Color(0xFF111111),
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text('Keuntungan',
//               style: TextStyle(
//                   color: Colors.white, fontSize: 28, fontFamily: 'serif')),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.white54,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           _buildBenefitItem(
//               Icons.account_balance_wallet_outlined,
//               'KOMISI KOMPETITIF',
//               'Dapatkan persentase komisi yang menarik tanpa batas maksimal penghasilan bulanan.'),
//           const SizedBox(height: 32),
//           _buildBenefitItem(Icons.inventory_2_outlined, 'PRODUK PREMIUM',
//               'Jual produk dengan kualitas butik yang sudah dipercaya oleh ribuan pelanggan.'),
//           const SizedBox(height: 32),
//           _buildBenefitItem(Icons.analytics_outlined, 'DASBOR EKSKLUSIF',
//               'Lacak performa tautan, klik, dan penghasilan Anda secara real-time kapan saja.'),
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitItem(IconData icon, String title, String desc) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration:
//               const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           child: Icon(icon, color: Colors.black, size: 28),
//         ),
//         const SizedBox(height: 16),
//         Text(title,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//                 letterSpacing: 1.5)),
//         const SizedBox(height: 8),
//         Text(desc,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 color: Colors.white60, fontSize: 12, height: 1.5)),
//       ],
//     );
//   }

//   Widget _buildTestimonialSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text('Kisah Sukses',
//               style: TextStyle(fontSize: 28, fontFamily: 'serif')),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.black,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           SizedBox(
//             height: 200,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               itemCount: _feedbacks.length,
//               itemBuilder: (context, index) {
//                 final fb = _feedbacks[index];
//                 return Container(
//                   width: 280,
//                   margin: const EdgeInsets.only(right: 16),
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(color: Colors.grey.shade200),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.02),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4))
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(children: [
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                       ]),
//                       Text('"${fb['comment']}"',
//                           style: const TextStyle(
//                               fontSize: 12,
//                               fontStyle: FontStyle.italic,
//                               color: Colors.grey,
//                               height: 1.5),
//                           maxLines: 4,
//                           overflow: TextOverflow.ellipsis),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(fb['name']!,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 13)),
//                           Text(fb['platform']!,
//                               style: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1)),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildFaqSection() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text('FAQ',
//               style: TextStyle(fontSize: 28, fontFamily: 'serif')),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.black,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           ...List.generate(_faqs.length, (index) {
//             final faq = _faqs[index];
//             final isActive = _activeFaqIndex == index;
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _activeFaqIndex = isActive ? null : index;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: isActive ? Colors.white : Colors.grey.shade50,
//                   border: Border.all(color: Colors.grey.shade200),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               child: Text(faq['question']!,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 13))),
//                           Icon(
//                               isActive
//                                   ? Icons.keyboard_arrow_up
//                                   : Icons.keyboard_arrow_down,
//                               color: Colors.grey),
//                         ],
//                       ),
//                     ),
//                     if (isActive)
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 20.0, right: 20.0, bottom: 20.0),
//                         child: Text(faq['answer']!,
//                             style: const TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: 12,
//                                 height: 1.5)),
//                       )
//                   ],
//                 ),
//               ),
//             );
//           })
//         ],
//       ),
//     );
//   }

//   Widget _buildFormSection() {
//     return Container(
//       key: _formKey,
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10))
//           ],
//         ),
//         child: _alreadyAffiliate
//             ? Column(
//                 children: [
//                   const CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.black,
//                     child: Icon(Icons.check, color: Colors.white, size: 30),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text('Anda Telah Bergabung!',
//                       style: TextStyle(
//                           fontSize: 22,
//                           fontFamily: 'serif',
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 16),
//                   const Text('Anda sudah terdaftar sebagai Solher Ambassador.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 12)),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           padding: const EdgeInsets.symmetric(vertical: 18)),
//                       onPressed: () {
//                         // Navigasi ke dasbor afiliasi (jika sudah dibuat)
//                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                             content: Text(
//                                 'Dasbor Afiliasi sedang dalam pengembangan untuk versi mobile.')));
//                       },
//                       child: const Text('BUKA DASBOR',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2,
//                               fontSize: 12)),
//                     ),
//                   )
//                 ],
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Center(
//                     child: Text('Mulai Perjalanan Anda',
//                         style: TextStyle(
//                             fontSize: 24,
//                             fontFamily: 'serif',
//                             fontWeight: FontWeight.bold)),
//                   ),
//                   const SizedBox(height: 8),
//                   const Center(
//                     child: Text(
//                         'Lengkapi formulir di bawah ini untuk mendaftar.',
//                         style: TextStyle(color: Colors.grey, fontSize: 12)),
//                   ),
//                   const SizedBox(height: 32),
//                   const Text('LINK MEDIA SOSIAL UTAMA',
//                       style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.5)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _socialUrlController,
//                     decoration: InputDecoration(
//                       hintText: 'https://instagram.com/username',
//                       hintStyle:
//                           const TextStyle(fontSize: 13, color: Colors.grey),
//                       filled: true,
//                       fillColor: Colors.grey.shade50,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey.shade300)),
//                       focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.black)),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text('ALASAN BERGABUNG',
//                       style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.5)),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _reasonController,
//                     maxLines: 4,
//                     decoration: InputDecoration(
//                       hintText: 'Ceritakan sedikit tentang audiens Anda...',
//                       hintStyle:
//                           const TextStyle(fontSize: 13, color: Colors.grey),
//                       filled: true,
//                       fillColor: Colors.grey.shade50,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.grey.shade300)),
//                       focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: const BorderSide(color: Colors.black)),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         padding: const EdgeInsets.symmetric(vertical: 18),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: _isSubmitting ? null : _submitApplication,
//                       child: _isSubmitting
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2))
//                           : const Text('KIRIM PENDAFTARAN',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2,
//                                   fontSize: 12)),
//                     ),
//                   )
//                 ],
//               ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:solher_mobile/screens/auth/login_page.dart';

// // 👇 IMPORT BLOC YANG DIBUTUHKAN 👇
// import '../../blocs/auth/auth_bloc.dart';
// import '../../blocs/auth/auth_state.dart';
// import '../../blocs/affiliate/affiliate_bloc.dart';
// import '../../blocs/affiliate/affiliate_event.dart';
// import '../../blocs/affiliate/affiliate_state.dart';
// import '../../repositories/affiliate_repository.dart';

// class AffiliateLandingPage extends StatefulWidget {
//   const AffiliateLandingPage({super.key});

//   @override
//   State<AffiliateLandingPage> createState() => _AffiliateLandingPageState();
// }

// class _AffiliateLandingPageState extends State<AffiliateLandingPage> {
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey _formKey = GlobalKey();

//   final TextEditingController _socialUrlController = TextEditingController();
//   final TextEditingController _reasonController = TextEditingController();

//   int? _activeFaqIndex;

//   final List<Map<String, String>> _faqs = [
//     {
//       'question': 'Apa syarat menjadi Solher Ambassador?',
//       'answer':
//           'Anda harus memiliki akun media sosial yang aktif dan relevan dengan audiens fesyen/lifestyle. Kami akan meninjau profil Anda sebelum memberikan persetujuan.'
//     },
//     {
//       'question': 'Berapa komisi yang saya dapatkan?',
//       'answer':
//           'Komisi standar mulai dari 5% hingga 15% dari total penjualan, tergantung pada level tier afiliasi Anda.'
//     },
//     {
//       'question': 'Kapan komisi dicairkan?',
//       'answer':
//           'Komisi akan berstatus "Settled" setelah pesanan pelanggan selesai. Pencairan dapat ditarik kapan saja ke rekening bank Anda dengan minimal penarikan Rp 100.000.'
//     },
//   ];

//   final List<Map<String, String>> _feedbacks = [
//     {
//       'name': 'Amanda T.',
//       'platform': 'Instagram Creator',
//       'comment':
//           'Sistem afiliasi paling transparan yang pernah saya ikuti. Tas Solher sangat mudah dijual karena kualitasnya memang premium!'
//     },
//     {
//       'name': 'Siti Rahma',
//       'platform': 'TikTok Affiliate',
//       'comment':
//           'Sangat menguntungkan! Dashboard afiliatornya sangat mudah digunakan untuk melacak klik dan komisi harian.'
//     },
//   ];

//   void _scrollToForm() {
//     if (_formKey.currentContext != null) {
//       Scrollable.ensureVisible(
//         _formKey.currentContext!,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.easeInOutQuart,
//       );
//     }
//   }

//   void _submitApplication(BuildContext blocContext, AuthState authState) {
//     if (authState is! AuthAuthenticated) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Login Diperlukan',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           content: const Text(
//               'Silakan login ke akun Anda terlebih dahulu untuk bergabung dengan program Afiliasi.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Batal', style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (_) => const LoginPage()));
//               },
//               child: const Text('Login', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     if (_socialUrlController.text.isEmpty || _reasonController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Semua kolom wajib diisi'),
//         backgroundColor: Colors.red,
//       ));
//       return;
//     }

//     // Memicu Event BLoC untuk mendaftar afiliasi
//     blocContext.read<AffiliateBloc>().add(ApplyAffiliateEvent(
//           socialMediaUrl: _socialUrlController.text.trim(),
//           reason: _reasonController.text.trim(),
//         ));
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _socialUrlController.dispose();
//     _reasonController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 👇 Inject AffiliateBloc khusus untuk halaman ini 👇
//     return BlocProvider(
//       create: (context) => AffiliateBloc(
//         affiliateRepository: AffiliateRepository(),
//       ),
//       child: Builder(builder: (blocContext) {
//         return Scaffold(
//           backgroundColor: const Color(0xFFFAFAFA),
//           extendBodyBehindAppBar: true,
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             iconTheme: const IconThemeData(color: Colors.white),
//           ),
//           body: SingleChildScrollView(
//             controller: _scrollController,
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               children: [
//                 _buildHeroSection(),
//                 _buildHowItWorksSection(),
//                 _buildBenefitsSection(),
//                 _buildTestimonialSection(),
//                 _buildFaqSection(),

//                 // Form Section diinjeksi dengan context dari Builder agar BLoC terbaca
//                 _buildFormSection(blocContext),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildHeroSection() {
//     return Stack(
//       children: [
//         Container(
//           height: MediaQuery.of(context).size.height * 0.8,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(
//                   'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?q=80&w=2000'),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//         Container(
//           height: MediaQuery.of(context).size.height * 0.8,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//               colors: [Colors.black, Colors.black.withOpacity(0.4)],
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 60,
//           left: 24,
//           right: 24,
//           child: Column(
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.white30),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   'PROGRAM EKSKLUSIF',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Solher\nAmbassador.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 40,
//                     fontFamily: 'serif',
//                     height: 1.1),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Ubah pengaruh Anda menjadi penghasilan. Dapatkan komisi khusus dengan membagikan koleksi premium Solher ke audiens Anda.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     foregroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                     shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero),
//                   ),
//                   onPressed: _scrollToForm,
//                   child: const Text('DAFTAR SEKARANG',
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 2,
//                           fontSize: 12)),
//                 ),
//               )
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget _buildHowItWorksSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text(
//             'Cara Bergabung',
//             style: TextStyle(fontSize: 28, fontFamily: 'serif'),
//           ),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.black,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           _buildStepItem(Icons.edit_document, '1. Isi Formulir',
//               'Lengkapi data profil dan tautan media sosial utama Anda.'),
//           _buildStepItem(Icons.hourglass_empty, '2. Proses Review',
//               'Tim kami akan meninjau kelayakan profil Anda dalam 1x24 jam.'),
//           _buildStepItem(Icons.lock_open, '3. Akses Dibuka',
//               'Dapatkan tautan unik dan akses ke Dasbor Afiliator.'),
//           _buildStepItem(
//               Icons.monetization_on_outlined,
//               '4. Mulai Menghasilkan',
//               'Bagikan tautan Anda dan dapatkan komisi dari setiap pesanan.'),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepItem(IconData icon, String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 32.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Icon(icon, color: Colors.black87),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 8),
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         letterSpacing: 1)),
//                 const SizedBox(height: 8),
//                 Text(desc,
//                     style: const TextStyle(
//                         color: Colors.grey, fontSize: 12, height: 1.5)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitsSection() {
//     return Container(
//       width: double.infinity,
//       color: const Color(0xFF111111),
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text('Keuntungan',
//               style: TextStyle(
//                   color: Colors.white, fontSize: 28, fontFamily: 'serif')),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.white54,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           _buildBenefitItem(
//               Icons.account_balance_wallet_outlined,
//               'KOMISI KOMPETITIF',
//               'Dapatkan persentase komisi yang menarik tanpa batas maksimal penghasilan bulanan.'),
//           const SizedBox(height: 32),
//           _buildBenefitItem(Icons.inventory_2_outlined, 'PRODUK PREMIUM',
//               'Jual produk dengan kualitas butik yang sudah dipercaya oleh ribuan pelanggan.'),
//           const SizedBox(height: 32),
//           _buildBenefitItem(Icons.analytics_outlined, 'DASBOR EKSKLUSIF',
//               'Lacak performa tautan, klik, dan penghasilan Anda secara real-time kapan saja.'),
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefitItem(IconData icon, String title, String desc) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration:
//               const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//           child: Icon(icon, color: Colors.black, size: 28),
//         ),
//         const SizedBox(height: 16),
//         Text(title,
//             style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//                 letterSpacing: 1.5)),
//         const SizedBox(height: 8),
//         Text(desc,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//                 color: Colors.white60, fontSize: 12, height: 1.5)),
//       ],
//     );
//   }

//   Widget _buildTestimonialSection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text('Kisah Sukses',
//               style: TextStyle(fontSize: 28, fontFamily: 'serif')),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.black,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           SizedBox(
//             height: 200,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               itemCount: _feedbacks.length,
//               itemBuilder: (context, index) {
//                 final fb = _feedbacks[index];
//                 return Container(
//                   width: 280,
//                   margin: const EdgeInsets.only(right: 16),
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     border: Border.all(color: Colors.grey.shade200),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black.withOpacity(0.02),
//                           blurRadius: 10,
//                           offset: const Offset(0, 4))
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(children: [
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                         Icon(Icons.star, color: Colors.amber, size: 16),
//                       ]),
//                       Text('"${fb['comment']}"',
//                           style: const TextStyle(
//                               fontSize: 12,
//                               fontStyle: FontStyle.italic,
//                               color: Colors.grey,
//                               height: 1.5),
//                           maxLines: 4,
//                           overflow: TextOverflow.ellipsis),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(fb['name']!,
//                               style: const TextStyle(
//                                   fontWeight: FontWeight.bold, fontSize: 13)),
//                           Text(fb['platform']!,
//                               style: const TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1)),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildFaqSection() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Column(
//         children: [
//           const Text('FAQ',
//               style: TextStyle(fontSize: 28, fontFamily: 'serif')),
//           Container(
//               width: 40,
//               height: 2,
//               color: Colors.black,
//               margin: const EdgeInsets.only(top: 16, bottom: 40)),
//           ...List.generate(_faqs.length, (index) {
//             final faq = _faqs[index];
//             final isActive = _activeFaqIndex == index;
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _activeFaqIndex = isActive ? null : index;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 margin: const EdgeInsets.only(bottom: 12),
//                 decoration: BoxDecoration(
//                   color: isActive ? Colors.white : Colors.grey.shade50,
//                   border: Border.all(color: Colors.grey.shade200),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               child: Text(faq['question']!,
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 13))),
//                           Icon(
//                               isActive
//                                   ? Icons.keyboard_arrow_up
//                                   : Icons.keyboard_arrow_down,
//                               color: Colors.grey),
//                         ],
//                       ),
//                     ),
//                     if (isActive)
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             left: 20.0, right: 20.0, bottom: 20.0),
//                         child: Text(faq['answer']!,
//                             style: const TextStyle(
//                                 color: Colors.black54,
//                                 fontSize: 12,
//                                 height: 1.5)),
//                       )
//                   ],
//                 ),
//               ),
//             );
//           })
//         ],
//       ),
//     );
//   }

//   // 👇 MENGGUNAKAN BLOC BUILDER & CONSUMER UNTUK FORM 👇
//   Widget _buildFormSection(BuildContext blocContext) {
//     return Container(
//       key: _formKey,
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 20,
//                 offset: const Offset(0, 10))
//           ],
//         ),
//         // 1. Pantau AuthBloc untuk melihat status afiliasi user
//         child: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, authState) {
//             bool isAffiliate = false;
//             if (authState is AuthAuthenticated) {
//               // Menyesuaikan dengan model user Anda. Jika atributnya is_affiliate
//               // Gunakan authState.user.isAffiliate (jika didefinisikan demikian di UserModel)
//               isAffiliate = authState.user.isAffiliate ?? false;
//             }

//             if (isAffiliate) {
//               return Column(
//                 children: [
//                   const CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.black,
//                     child: Icon(Icons.check, color: Colors.white, size: 30),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text('Anda Telah Bergabung!',
//                       style: TextStyle(
//                           fontSize: 22,
//                           fontFamily: 'serif',
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 16),
//                   const Text('Anda sudah terdaftar sebagai Solher Ambassador.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey, fontSize: 12)),
//                   const SizedBox(height: 32),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           padding: const EdgeInsets.symmetric(vertical: 18)),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                             content: Text(
//                                 'Dasbor Afiliasi sedang dalam pengembangan untuk versi mobile.')));
//                       },
//                       child: const Text('BUKA DASBOR',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2,
//                               fontSize: 12)),
//                     ),
//                   )
//                 ],
//               );
//             }

//             // 2. Pantau AffiliateBloc untuk proses pengiriman Form
//             return BlocConsumer<AffiliateBloc, AffiliateState>(
//               listener: (context, affiliateState) {
//                 if (affiliateState is AffiliateActionSuccess) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(affiliateState.message),
//                     backgroundColor: Colors.green,
//                   ));
//                   _socialUrlController.clear();
//                   _reasonController.clear();
//                 } else if (affiliateState is AffiliateError) {
//                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(affiliateState.message),
//                     backgroundColor: Colors.red,
//                   ));
//                 }
//               },
//               builder: (context, affiliateState) {
//                 final isSubmitting = affiliateState is AffiliateLoading;

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Center(
//                       child: Text('Mulai Perjalanan Anda',
//                           style: TextStyle(
//                               fontSize: 24,
//                               fontFamily: 'serif',
//                               fontWeight: FontWeight.bold)),
//                     ),
//                     const SizedBox(height: 8),
//                     const Center(
//                       child: Text(
//                           'Lengkapi formulir di bawah ini untuk mendaftar.',
//                           style: TextStyle(color: Colors.grey, fontSize: 12)),
//                     ),
//                     const SizedBox(height: 32),
//                     const Text('LINK MEDIA SOSIAL UTAMA',
//                         style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.5)),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _socialUrlController,
//                       decoration: InputDecoration(
//                         hintText: 'https://instagram.com/username',
//                         hintStyle:
//                             const TextStyle(fontSize: 13, color: Colors.grey),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(color: Colors.grey.shade300)),
//                         focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.black)),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     const Text('ALASAN BERGABUNG',
//                         style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.5)),
//                     const SizedBox(height: 8),
//                     TextField(
//                       controller: _reasonController,
//                       maxLines: 4,
//                       decoration: InputDecoration(
//                         hintText: 'Ceritakan sedikit tentang audiens Anda...',
//                         hintStyle:
//                             const TextStyle(fontSize: 13, color: Colors.grey),
//                         filled: true,
//                         fillColor: Colors.grey.shade50,
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide:
//                                 BorderSide(color: Colors.grey.shade300)),
//                         focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.black)),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           padding: const EdgeInsets.symmetric(vertical: 18),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: isSubmitting
//                             ? null
//                             : () => _submitApplication(blocContext, authState),
//                         child: isSubmitting
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                     color: Colors.white, strokeWidth: 2))
//                             : const Text('KIRIM PENDAFTARAN',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 2,
//                                     fontSize: 12)),
//                       ),
//                     )
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solher_mobile/screens/affiliate_dashboard.dart';
import 'package:solher_mobile/screens/auth/login_page.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/affiliate/affiliate_bloc.dart';
import '../../blocs/affiliate/affiliate_event.dart';
import '../../blocs/affiliate/affiliate_state.dart';
import '../../repositories/affiliate_repository.dart';

class AffiliateLandingPage extends StatefulWidget {
  const AffiliateLandingPage({super.key});

  @override
  State<AffiliateLandingPage> createState() => _AffiliateLandingPageState();
}

class _AffiliateLandingPageState extends State<AffiliateLandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _formKey = GlobalKey();

  final TextEditingController _socialUrlController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  int? _activeFaqIndex;
  bool _alreadyAffiliate = false;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'Apa syarat menjadi Solher Ambassador?',
      'answer':
          'Anda harus memiliki akun media sosial yang aktif dan relevan dengan audiens fesyen/lifestyle. Kami akan meninjau profil Anda sebelum memberikan persetujuan.'
    },
    {
      'question': 'Berapa komisi yang saya dapatkan?',
      'answer':
          'Komisi standar mulai dari 5% hingga 15% dari total penjualan, tergantung pada level tier afiliasi Anda.'
    },
    {
      'question': 'Kapan komisi dicairkan?',
      'answer':
          'Komisi akan berstatus "Settled" setelah pesanan pelanggan selesai. Pencairan dapat ditarik kapan saja ke rekening bank Anda dengan minimal penarikan Rp 100.000.'
    },
  ];

  final List<Map<String, String>> _feedbacks = [
    {
      'name': 'Amanda T.',
      'platform': 'Instagram Creator',
      'comment':
          'Sistem afiliasi paling transparan yang pernah saya ikuti. Tas Solher sangat mudah dijual karena kualitasnya memang premium!'
    },
    {
      'name': 'Siti Rahma',
      'platform': 'TikTok Affiliate',
      'comment':
          'Sangat menguntungkan! Dashboard afiliatornya sangat mudah digunakan untuk melacak klik dan komisi harian.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAffiliateStatus();
  }

  // Fungsi untuk menarik status afiliasi langsung dari JSON mentah di Storage
  Future<void> _checkAffiliateStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      try {
        final user = json.decode(userDataStr);
        if (user['is_affiliate'] == 1 || user['is_affiliate'] == true) {
          if (mounted) {
            setState(() {
              _alreadyAffiliate = true;
            });
          }
        }
      } catch (e) {
        debugPrint('Error parsing user data: $e');
      }
    }
  }

  void _scrollToForm() {
    if (_formKey.currentContext != null) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _submitApplication(BuildContext blocContext, AuthState authState) {
    if (authState is! AuthAuthenticated) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Diperlukan',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'Silakan login ke akun Anda terlebih dahulu untuk bergabung dengan program Afiliasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () async {
                Navigator.pop(context);
                // 👇 PERBAIKAN: Menunggu user login lalu refresh status otomatis 👇
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
                _checkAffiliateStatus();
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    if (_socialUrlController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Semua kolom wajib diisi'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    blocContext.read<AffiliateBloc>().add(ApplyAffiliateEvent(
          socialMediaUrl: _socialUrlController.text.trim(),
          reason: _reasonController.text.trim(),
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _socialUrlController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AffiliateBloc(
        affiliateRepository: AffiliateRepository(),
      ),
      child: Builder(builder: (blocContext) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeroSection(),
                _buildHowItWorksSection(),
                _buildBenefitsSection(),
                _buildTestimonialSection(),
                _buildFaqSection(),
                _buildFormSection(blocContext),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?q=80&w=2000'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black, Colors.black.withOpacity(0.4)],
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PROGRAM EKSKLUSIF',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Solher\nAmbassador.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontFamily: 'serif',
                    height: 1.1),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ubah pengaruh Anda menjadi penghasilan. Dapatkan komisi khusus dengan membagikan koleksi premium Solher ke audiens Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  onPressed: _scrollToForm,
                  child: const Text('DAFTAR SEKARANG',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 12)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Column(
        children: [
          const Text(
            'Cara Bergabung',
            style: TextStyle(fontSize: 28, fontFamily: 'serif'),
          ),
          Container(
              width: 40,
              height: 2,
              color: Colors.black,
              margin: const EdgeInsets.only(top: 16, bottom: 40)),
          _buildStepItem(Icons.edit_document, '1. Isi Formulir',
              'Lengkapi data profil dan tautan media sosial utama Anda.'),
          _buildStepItem(Icons.hourglass_empty, '2. Proses Review',
              'Tim kami akan meninjau kelayakan profil Anda dalam 1x24 jam.'),
          _buildStepItem(Icons.lock_open, '3. Akses Dibuka',
              'Dapatkan tautan unik dan akses ke Dasbor Afiliator.'),
          _buildStepItem(
              Icons.monetization_on_outlined,
              '4. Mulai Menghasilkan',
              'Bagikan tautan Anda dan dapatkan komisi dari setiap pesanan.'),
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Column(
        children: [
          const Text('Keuntungan',
              style: TextStyle(
                  color: Colors.white, fontSize: 28, fontFamily: 'serif')),
          Container(
              width: 40,
              height: 2,
              color: Colors.white54,
              margin: const EdgeInsets.only(top: 16, bottom: 40)),
          _buildBenefitItem(
              Icons.account_balance_wallet_outlined,
              'KOMISI KOMPETITIF',
              'Dapatkan persentase komisi yang menarik tanpa batas maksimal penghasilan bulanan.'),
          const SizedBox(height: 32),
          _buildBenefitItem(Icons.inventory_2_outlined, 'PRODUK PREMIUM',
              'Jual produk dengan kualitas butik yang sudah dipercaya oleh ribuan pelanggan.'),
          const SizedBox(height: 32),
          _buildBenefitItem(Icons.analytics_outlined, 'DASBOR EKSKLUSIF',
              'Lacak performa tautan, klik, dan penghasilan Anda secara real-time kapan saja.'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String desc) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 28),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white60, fontSize: 12, height: 1.5)),
      ],
    );
  }

  Widget _buildTestimonialSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Column(
        children: [
          const Text('Kisah Sukses',
              style: TextStyle(fontSize: 28, fontFamily: 'serif')),
          Container(
              width: 40,
              height: 2,
              color: Colors.black,
              margin: const EdgeInsets.only(top: 16, bottom: 40)),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _feedbacks.length,
              itemBuilder: (context, index) {
                final fb = _feedbacks[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                      ]),
                      Text('"${fb['comment']}"',
                          style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                              height: 1.5),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fb['name']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(fb['platform']!,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                        ],
                      )
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

  Widget _buildFaqSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Column(
        children: [
          const Text('FAQ',
              style: TextStyle(fontSize: 28, fontFamily: 'serif')),
          Container(
              width: 40,
              height: 2,
              color: Colors.black,
              margin: const EdgeInsets.only(top: 16, bottom: 40)),
          ...List.generate(_faqs.length, (index) {
            final faq = _faqs[index];
            final isActive = _activeFaqIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _activeFaqIndex = isActive ? null : index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(faq['question']!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))),
                          Icon(
                              isActive
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 20.0),
                        child: Text(faq['answer']!,
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                height: 1.5)),
                      )
                  ],
                ),
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext blocContext) {
    return Container(
      key: _formKey,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // 👇 PERBAIKAN: Gunakan variabel lokal _alreadyAffiliate 👇
            bool showDashboardPrompt =
                _alreadyAffiliate && authState is AuthAuthenticated;

            if (showDashboardPrompt) {
              return Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 24),
                  const Text('Anda Telah Bergabung!',
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Anda sudah terdaftar sebagai Solher Ambassador.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18)),
                      onPressed: () {
                        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        //     content: Text(
                        //         'Dasbor Afiliasi sedang dalam pengembangan untuk versi mobile.')));

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (context) => AffiliateBloc(
                                  affiliateRepository: AffiliateRepository(),
                                ),
                                child: const AffiliateDashboardPage(),
                              ),
                            ));
                      },
                      child: const Text('BUKA DASBOR',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 12)),
                    ),
                  )
                ],
              );
            }

            return BlocConsumer<AffiliateBloc, AffiliateState>(
              listener: (context, affiliateState) {
                if (affiliateState is AffiliateActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(affiliateState.message),
                    backgroundColor: Colors.green,
                  ));
                  _socialUrlController.clear();
                  _reasonController.clear();
                } else if (affiliateState is AffiliateError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(affiliateState.message),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              builder: (context, affiliateState) {
                final isSubmitting = affiliateState is AffiliateLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text('Mulai Perjalanan Anda',
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                          'Lengkapi formulir di bawah ini untuk mendaftar.',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    const SizedBox(height: 32),
                    const Text('LINK MEDIA SOSIAL UTAMA',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _socialUrlController,
                      decoration: InputDecoration(
                        hintText: 'https://instagram.com/username',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('ALASAN BERGABUNG',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ceritakan sedikit tentang audiens Anda...',
                        hintStyle:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => _submitApplication(blocContext, authState),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('KIRIM PENDAFTARAN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    fontSize: 12)),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
