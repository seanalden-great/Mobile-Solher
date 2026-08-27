// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_event.dart';
// import '../blocs/auth/auth_state.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Profile',
//             style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: BlocBuilder<AuthBloc, AuthState>(
//         builder: (context, state) {
//           if (state is AuthAuthenticated) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircleAvatar(
//                     radius: 50,
//                     backgroundImage: NetworkImage(
//                         'https://ui-avatars.com/api/?name=User&background=000&color=fff'),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Selamat Datang!',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Profil Anda aman dilindungi otentikasi.',
//                     style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                   ),
//                   const SizedBox(height: 40),

//                   // 👇 Tombol Logout 👇
//                   ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red.shade50,
//                         foregroundColor: Colors.red,
//                         elevation: 0,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 12)),
//                     icon: const Icon(Icons.logout),
//                     label: const Text('Logout',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     onPressed: () {
//                       // Trigger event logout ke BLoC (pastikan LogoutRequested sudah ada di AuthEvent Anda)
//                       context.read<AuthBloc>().add(LogoutRequested());
//                     },
//                   )
//                 ],
//               ),
//             );
//           }

//           return const Center(child: Text('Akses Ditolak.'));
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_event.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_event.dart';
// import '../blocs/address/address_state.dart';
// import '../repositories/address_repository.dart';
// import 'package:solher_mobile/models/address_model.dart'; // Sesuaikan

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   // Logika Tier Solher Club
//   Map<String, dynamic> _getUserTier(int points) {
//     if (points < 2500) {
//       return {
//         'name': 'Silver',
//         'colors': [Colors.grey.shade400, Colors.grey.shade600],
//         'icon': '🥈',
//         'next': 2500,
//         'nextName': 'Gold'
//       };
//     } else if (points < 10000) {
//       return {
//         'name': 'Gold',
//         'colors': [Colors.amber.shade400, Colors.orange.shade700],
//         'icon': '🥇',
//         'next': 10000,
//         'nextName': 'Platinum'
//       };
//     } else {
//       return {
//         'name': 'Platinum',
//         'colors': [Colors.indigo.shade400, Colors.purple.shade700],
//         'icon': '💎',
//         'next': null,
//         'nextName': null
//       };
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       // 👇 Memicu pengambilan data alamat saat halaman dibuka 👇
//       create: (context) => AddressBloc(addressRepository: AddressRepository())
//         ..add(FetchAddresses()),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9FAFB), // bg-gray-50
//         appBar: AppBar(
//           title: const Text('My Account',
//               style:
//                   TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//           centerTitle: false,
//         ),
//         body: BlocBuilder<AuthBloc, AuthState>(
//           builder: (context, state) {
//             if (state is AuthAuthenticated) {
//               // Asumsi UserModel Anda bisa diakses via state.user
//               // Jika propertinya berbeda (misal: user.firstName), silakan disesuaikan
//               final user = state.user;

//               // Fallback nilai (sesuaikan dengan UserModel aktual Anda)
//               final String firstName = user.firstName ?? '';
//               final String email = user.email ?? '';
//               final String phone = user.phone ?? '';
//               final int points = user.point ?? 0;
//               final String avatarUrl = user.profileImage ??
//                   'https://ui-avatars.com/api/?name=$firstName&background=000&color=fff';

//               return SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- HEADER SECTION ---
//                     const Text('Manage your details and address',
//                         style: TextStyle(color: Colors.grey, fontSize: 14)),
//                     const SizedBox(height: 24),

//                     // --- GAMIFIKASI BANNER (Opsional disederhanakan) ---
//                     _buildCompletenessBanner(firstName, email, phone),
//                     const SizedBox(height: 24),

//                     // --- PROFILE CARD ---
//                     _buildProfileCard(
//                         context, firstName, email, phone, avatarUrl),
//                     const SizedBox(height: 24),

//                     // --- SOLHER CLUB TIER CARD ---
//                     _buildSolherClubCard(points),
//                     const SizedBox(height: 24),

//                     // --- SHORTCUT BUTTONS ---
//                     _buildMenuButton(Icons.favorite_border, 'My Wishlist',
//                         'View your saved items', Colors.red, () {}),
//                     const SizedBox(height: 12),
//                     _buildMenuButton(
//                         Icons.campaign_outlined,
//                         'Program Afiliasi',
//                         'Dapatkan Komisi Khusus!',
//                         Colors.amber.shade600,
//                         () {}),
//                     const SizedBox(height: 32),

//                     // --- ADDRESSES SECTION (TERHUBUNG KE BLOC) ---
//                     const Text('Shipping Addresses',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 16),
//                     _buildAddressSection(),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               );
//             }

//             return const Center(child: Text('Akses Ditolak. Silakan Login.'));
//           },
//         ),
//       ),
//     );
//   }

//   // 👇 BANNER KELENGKAPAN PROFIL 👇
//   Widget _buildCompletenessBanner(String name, String email, String phone) {
//     int score = 0;
//     if (name.isNotEmpty) score += 30;
//     if (email.isNotEmpty) score += 30;
//     if (phone.isNotEmpty) score += 40; // Simulasi logic

//     if (score == 100) return const SizedBox.shrink();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             colors: [Colors.blue.shade900, Colors.blue.shade800]),
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Sempurnakan Profil Anda',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                     color: Colors.blue.shade100,
//                     borderRadius: BorderRadius.circular(20)),
//                 child: Text('$score%',
//                     style: TextStyle(
//                         color: Colors.blue.shade900,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12)),
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//               'Lengkapi data diri Anda untuk pengalaman belanja yang lebih aman.',
//               style: TextStyle(color: Colors.blue.shade200, fontSize: 12)),
//           const SizedBox(height: 16),
//           LinearProgressIndicator(
//               value: score / 100,
//               backgroundColor: Colors.blue.shade900,
//               color: Colors.cyanAccent),
//         ],
//       ),
//     );
//   }

//   // 👇 KARTU INFORMASI PENGGUNA 👇
//   Widget _buildProfileCard(BuildContext context, String name, String email,
//       String phone, String avatar) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 80,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   colors: [Color(0xFFE5E7EB), Color(0xFFF3F4F6)]),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24), topRight: Radius.circular(24)),
//             ),
//           ),
//           Transform.translate(
//             offset: const Offset(0, -40),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                     radius: 46,
//                     backgroundColor: Colors.white,
//                     child: CircleAvatar(
//                         radius: 42, backgroundImage: NetworkImage(avatar))),
//                 const SizedBox(height: 12),
//                 Text(name,
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       _buildInfoRow(Icons.email_outlined, 'Email', email),
//                       const SizedBox(height: 12),
//                       _buildInfoRow(Icons.phone_outlined, 'Telepon',
//                           phone.isEmpty ? '(Belum diisi)' : phone),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12))),
//                           onPressed: () {}, // TODO: Modal Edit Profile
//                           child: const Text('Edit Profil',
//                               style: TextStyle(color: Colors.black87)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       IconButton(
//                         style: IconButton.styleFrom(
//                             backgroundColor: Colors.red.shade50,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12))),
//                         icon: const Icon(Icons.logout,
//                             color: Colors.red, size: 20),
//                         onPressed: () {
//                           // Trigger logout
//                           context.read<AuthBloc>().add(LogoutRequested());
//                         },
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: Row(
//         children: [
//           Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                   color: Colors.white, borderRadius: BorderRadius.circular(8)),
//               child: Icon(icon, size: 16, color: Colors.grey.shade600)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                         letterSpacing: 1)),
//                 Text(value,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w500, fontSize: 13),
//                     overflow: TextOverflow.ellipsis),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // 👇 KARTU TIER SOLHER CLUB 👇
//   Widget _buildSolherClubCard(int points) {
//     final tier = _getUserTier(points);

//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             colors: tier['colors'],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//               color: tier['colors'][0].withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 6))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('SOLHER CLUB',
//               style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2)),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Text(tier['icon'], style: const TextStyle(fontSize: 24)),
//               const SizedBox(width: 8),
//               Text('${tier['name']} TIER',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 1)),
//             ],
//           ),
//           const SizedBox(height: 24),
//           const Text('AVAILABLE POINTS',
//               style: TextStyle(
//                   color: Colors.white70, fontSize: 10, letterSpacing: 1)),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text('$points',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 40,
//                       fontWeight: FontWeight.w900)),
//               const Padding(
//                   padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
//                   child: Text('Pts',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold))),
//             ],
//           ),
//           if (tier['next'] != null) ...[
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(tier['name'],
//                     style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold)),
//                 Text(tier['nextName'],
//                     style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//             const SizedBox(height: 6),
//             LinearProgressIndicator(
//                 value: points / tier['next'],
//                 backgroundColor: Colors.black26,
//                 color: Colors.white,
//                 minHeight: 6,
//                 borderRadius: BorderRadius.circular(10)),
//           ]
//         ],
//       ),
//     );
//   }

//   // 👇 TOMBOL MENU 👇
//   Widget _buildMenuButton(IconData icon, String title, String subtitle,
//       Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(20)),
//         child: Row(
//           children: [
//             Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Icon(icon, color: color)),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14)),
//                   Text(subtitle,
//                       style: const TextStyle(color: Colors.grey, fontSize: 11)),
//                 ],
//               ),
//             ),
//             Icon(Icons.chevron_right, color: Colors.grey.shade400)
//           ],
//         ),
//       ),
//     );
//   }

//   // 👇 DAFTAR ALAMAT DENGAN BLOC 👇
//   Widget _buildAddressSection() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade200),
//           borderRadius: BorderRadius.circular(24)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.blue.shade700,
//                   side: BorderSide(color: Colors.blue.shade100),
//                   backgroundColor: Colors.blue.shade50,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12))),
//               icon: const Icon(Icons.add),
//               label: const Text('Tambah Alamat Baru',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               onPressed: () {
//                 // TODO: Buka BottomSheet untuk form tambah alamat
//               },
//             ),
//           ),
//           const SizedBox(height: 24),
//           BlocConsumer<AddressBloc, AddressState>(
//             listener: (context, state) {
//               if (state is AddressActionSuccess) {
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message),
//                     backgroundColor: Colors.green));
//               } else if (state is AddressError) {
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message), backgroundColor: Colors.red));
//               }
//             },
//             builder: (context, state) {
//               if (state is AddressLoading || state is AddressInitial) {
//                 return const Center(
//                     child: Padding(
//                         padding: EdgeInsets.all(20.0),
//                         child: CircularProgressIndicator()));
//               } else if (state is AddressLoaded) {
//                 if (state.addresses.isEmpty) {
//                   return const Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 20),
//                       child: Text('Belum ada alamat pengiriman.',
//                           style: TextStyle(color: Colors.grey)),
//                     ),
//                   );
//                 }

//                 return ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: state.addresses.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                   itemBuilder: (context, index) {
//                     final addr = state.addresses[index];
//                     return _buildAddressCard(context, addr);
//                   },
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAddressCard(BuildContext context, AddressModel addr) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//             color:
//                 addr.isDefault ? Colors.blue.shade300 : Colors.grey.shade200),
//         boxShadow: addr.isDefault
//             ? [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)]
//             : [],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.location_on,
//                       color: Colors.blue.shade500, size: 20),
//                   const SizedBox(width: 8),
//                   Text('${addr.firstName} ${addr.lastName}',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14)),
//                 ],
//               ),
//               if (addr.isDefault)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(8)),
//                   child: Text('UTAMA',
//                       style: TextStyle(
//                           color: Colors.blue.shade700,
//                           fontSize: 9,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1)),
//                 )
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(addr.location,
//               style: const TextStyle(
//                   color: Colors.black87, fontSize: 12, height: 1.5),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis),
//           const SizedBox(height: 4),
//           Text('${addr.city}, ${addr.province} ${addr.postalCode}',
//               style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                 onPressed: () {}, // TODO: Modal Edit
//                 child: const Text('Edit',
//                     style: TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12)),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Trigger Hapus Alamat
//                   context.read<AddressBloc>().add(DeleteAddressEvent(addr.id!));
//                 },
//                 child: const Text('Hapus',
//                     style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12)),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';

// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_event.dart';
// import '../blocs/auth/auth_state.dart';
// import '../blocs/address/address_bloc.dart';
// import '../blocs/address/address_event.dart';
// import '../blocs/address/address_state.dart';
// import '../repositories/address_repository.dart';

// import 'package:solher_mobile/models/address_model.dart';
// import 'package:solher_mobile/models/user_model.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   // --- FUNGSI AMBIL GAMBAR DARI GALERI ---
//   Future<void> _pickImage(BuildContext context) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );

//     if (pickedFile != null && context.mounted) {
//       context
//           .read<AuthBloc>()
//           .add(UpdateProfileImageRequested(pickedFile.path));
//     }
//   }

//   // --- MODAL EDIT PROFIL ---
//   void _showEditProfileModal(BuildContext context, UserModel user) {
//     final firstNameCtrl = TextEditingController(text: user.firstName);
//     final lastNameCtrl = TextEditingController(text: user.lastName);
//     final emailCtrl = TextEditingController(text: user.email);
//     final phoneCtrl = TextEditingController(text: user.phone ?? '');

//     showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         builder: (ctx) {
//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(ctx).viewInsets.bottom,
//               left: 24,
//               right: 24,
//               top: 24,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('Edit Profil',
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'serif')),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () => Navigator.pop(ctx),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   _buildInput('Nama Depan', firstNameCtrl),
//                   _buildInput('Nama Belakang', lastNameCtrl),
//                   _buildInput('Email', emailCtrl, isEmail: true),
//                   _buildInput('Nomor Telepon', phoneCtrl, isPhone: true),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(ctx);
//                         context.read<AuthBloc>().add(UpdateProfileRequested(
//                               firstName: firstNameCtrl.text.trim(),
//                               lastName: lastNameCtrl.text.trim(),
//                               email: emailCtrl.text.trim(),
//                               phone: phoneCtrl.text.trim(),
//                             ));
//                       },
//                       child: const Text(
//                         'SIMPAN PERUBAHAN',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   // --- MODAL TAMBAH & EDIT ALAMAT ---
//   void _showAddressModal(BuildContext context, {AddressModel? address}) {
//     final isEdit = address != null;

//     final firstNameCtrl = TextEditingController(text: address?.firstName ?? '');
//     final lastNameCtrl = TextEditingController(text: address?.lastName ?? '');
//     final locationCtrl = TextEditingController(text: address?.location ?? '');
//     final cityCtrl = TextEditingController(text: address?.city ?? '');
//     final provinceCtrl = TextEditingController(text: address?.province ?? '');
//     final postalCtrl = TextEditingController(text: address?.postalCode ?? '');
//     bool isDefault = address?.isDefault ?? false;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (ctx) {
//         return StatefulBuilder(
//           builder: (BuildContext ctx, StateSetter setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
//                 left: 24,
//                 right: 24,
//                 top: 24,
//               ),
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           isEdit ? 'Edit Alamat' : 'Tambah Alamat Baru',
//                           style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'serif'),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Navigator.pop(ctx),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: _buildInput(
//                                 'Nama Depan Penerima', firstNameCtrl)),
//                         const SizedBox(width: 12),
//                         Expanded(
//                             child: _buildInput('Nama Belakang', lastNameCtrl))
//                       ],
//                     ),
//                     // _buildInput('Nomor Telepon', phoneCtrl, isPhone: true),
//                     _buildInput(
//                         'Alamat Lengkap (Jalan, RT/RW, Patokan)', locationCtrl,
//                         maxLines: 3),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: _buildInput('Kota/Kabupaten', cityCtrl)),
//                         const SizedBox(width: 12),
//                         Expanded(child: _buildInput('Provinsi', provinceCtrl))
//                       ],
//                     ),
//                     _buildInput('Kode Pos', postalCtrl, isPhone: true),
//                     CheckboxListTile(
//                       contentPadding: EdgeInsets.zero,
//                       activeColor: Colors.black,
//                       title: const Text('Jadikan sebagai alamat utama',
//                           style: TextStyle(
//                               fontSize: 13, fontWeight: FontWeight.w600)),
//                       value: isDefault,
//                       onChanged: (val) =>
//                           setModalState(() => isDefault = val ?? false),
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(ctx);
//                           final newAddress = AddressModel(
//                             id: isEdit ? address.id : null,
//                             firstName: firstNameCtrl.text.trim(),
//                             lastName: lastNameCtrl.text.trim(),
//                             // phone: phoneCtrl.text.trim(),
//                             location: locationCtrl.text.trim(),
//                             city: cityCtrl.text.trim(),
//                             province: provinceCtrl.text.trim(),
//                             postalCode: postalCtrl.text.trim(),
//                             isDefault: isDefault,
//                             region: '',
//                           );

//                           if (isEdit) {
//                             context.read<AddressBloc>().add(
//                                 UpdateAddressEvent(address.id!, newAddress));
//                           } else {
//                             context
//                                 .read<AddressBloc>()
//                                 .add(CreateAddressEvent(newAddress));
//                           }
//                         },
//                         child: Text(
//                           isEdit ? 'SIMPAN ALAMAT' : 'TAMBAHKAN ALAMAT',
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ), // 👇 INI ADALAH KURUNG TUTUP YANG HILANG SEBELUMNYA 👇
//             );
//           },
//         );
//       },
//     );
//   }

//   // --- MODAL KONFIRMASI HAPUS ALAMAT ---
//   void _confirmDeleteAddress(BuildContext context, AddressModel address) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Hapus Alamat?',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         content: const Text(
//             'Anda yakin ingin menghapus alamat ini? Tindakan ini tidak dapat dibatalkan.',
//             style: TextStyle(fontSize: 14)),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(ctx);
//               context.read<AddressBloc>().add(DeleteAddressEvent(address.id!));
//             },
//             child:
//                 const Text('YA, HAPUS', style: TextStyle(color: Colors.white)),
//           )
//         ],
//       ),
//     );
//   }

//   // Input Teks Cepat
//   Widget _buildInput(String label, TextEditingController controller,
//       {bool isEmail = false, bool isPhone = false, int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextField(
//         controller: controller,
//         keyboardType: isEmail
//             ? TextInputType.emailAddress
//             : isPhone
//                 ? TextInputType.phone
//                 : TextInputType.text,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
//           filled: true,
//           fillColor: Colors.grey.shade100,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.black),
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic> _getUserTier(int points) {
//     if (points < 2500) {
//       return {
//         'name': 'Silver',
//         'colors': [Colors.grey.shade400, Colors.grey.shade600],
//         'icon': '🥈',
//         'next': 2500,
//         'nextName': 'Gold'
//       };
//     } else if (points < 10000) {
//       return {
//         'name': 'Gold',
//         'colors': [Colors.amber.shade400, Colors.orange.shade700],
//         'icon': '🥇',
//         'next': 10000,
//         'nextName': 'Platinum'
//       };
//     } else {
//       return {
//         'name': 'Platinum',
//         'colors': [Colors.indigo.shade400, Colors.purple.shade700],
//         'icon': '💎',
//         'next': null,
//         'nextName': null
//       };
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => AddressBloc(addressRepository: AddressRepository())
//         ..add(FetchAddresses()),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9FAFB),
//         appBar: AppBar(
//           title: const Text('My Account',
//               style:
//                   TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//           centerTitle: false,
//         ),
//         body: BlocConsumer<AuthBloc, AuthState>(
//           listener: (context, state) {
//             if (state is AuthActionSuccess) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: Text(state.message), backgroundColor: Colors.green));
//             } else if (state is AuthError) {
//               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                   content: Text(state.message), backgroundColor: Colors.red));
//             }
//           },
//           builder: (context, state) {
//             if (state is AuthLoading) {
//               return const Center(
//                   child: CircularProgressIndicator(color: Colors.black));
//             }

//             if (state is AuthAuthenticated) {
//               final user = state.user;
//               final String firstName = user.firstName;
//               final String lastName = user.lastName;
//               final String email = user.email;
//               final String phone = user.phone ?? '';
//               final int points = user.point;
//               final String avatarUrl = user.profileImage ??
//                   'https://ui-avatars.com/api/?name=$firstName&background=000&color=fff';

//               return SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Manage your details and address',
//                         style: TextStyle(color: Colors.grey, fontSize: 14)),
//                     const SizedBox(height: 24),
//                     _buildProfileCard(context, user, firstName, lastName, email,
//                         phone, avatarUrl),
//                     const SizedBox(height: 24),
//                     _buildSolherClubCard(points),
//                     const SizedBox(height: 24),
//                     _buildMenuButton(Icons.favorite_border, 'My Wishlist',
//                         'View your saved items', Colors.red, () {}),
//                     const SizedBox(height: 12),
//                     _buildMenuButton(
//                         Icons.campaign_outlined,
//                         'Program Afiliasi',
//                         'Dapatkan Komisi Khusus!',
//                         Colors.amber.shade600,
//                         () {}),
//                     const SizedBox(height: 32),
//                     const Text('Shipping Addresses',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 16),
//                     _buildAddressSection(),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               );
//             }

//             return const Center(child: Text('Akses Ditolak. Silakan Login.'));
//           },
//         ),
//       ),
//     );
//   }

//   // --- KARTU PROFIL ---
//   Widget _buildProfileCard(BuildContext context, UserModel user, String fName,
//       String lName, String email, String phone, String avatar) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.02),
//               blurRadius: 10,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             height: 80,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                   colors: [Color(0xFFE5E7EB), Color(0xFFF3F4F6)]),
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24), topRight: Radius.circular(24)),
//             ),
//           ),
//           Transform.translate(
//             offset: const Offset(0, -40),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: () => _pickImage(context),
//                   child: Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       CircleAvatar(
//                           radius: 46,
//                           backgroundColor: Colors.white,
//                           child: CircleAvatar(
//                               radius: 42,
//                               backgroundImage: NetworkImage(avatar))),
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                             color: Colors.black,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2)),
//                         child: const Icon(Icons.camera_alt,
//                             color: Colors.white, size: 14),
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text('$fName $lName',
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       _buildInfoRow(Icons.email_outlined, 'Email', email),
//                       const SizedBox(height: 12),
//                       _buildInfoRow(Icons.phone_outlined, 'Telepon',
//                           phone.isEmpty ? '(Belum diisi)' : phone),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12))),
//                           onPressed: () => _showEditProfileModal(context, user),
//                           child: const Text('Edit Profil',
//                               style: TextStyle(color: Colors.black87)),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       IconButton(
//                         style: IconButton.styleFrom(
//                             backgroundColor: Colors.red.shade50,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12))),
//                         icon: const Icon(Icons.logout,
//                             color: Colors.red, size: 20),
//                         onPressed: () {
//                           showDialog(
//                               context: context,
//                               builder: (ctx) => AlertDialog(
//                                       title: const Text('Log Out'),
//                                       content:
//                                           const Text('Yakin ingin keluar?'),
//                                       actions: [
//                                         TextButton(
//                                             onPressed: () => Navigator.pop(ctx),
//                                             child: const Text('Batal')),
//                                         ElevatedButton(
//                                             style: ElevatedButton.styleFrom(
//                                                 backgroundColor: Colors.red),
//                                             onPressed: () {
//                                               Navigator.pop(ctx);
//                                               context
//                                                   .read<AuthBloc>()
//                                                   .add(LogoutRequested());
//                                             },
//                                             child: const Text('Keluar'))
//                                       ]));
//                         },
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//           color: Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: Row(
//         children: [
//           Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                   color: Colors.white, borderRadius: BorderRadius.circular(8)),
//               child: Icon(icon, size: 16, color: Colors.grey.shade600)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                         letterSpacing: 1)),
//                 Text(value,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w500, fontSize: 13),
//                     overflow: TextOverflow.ellipsis),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // --- KARTU SOLHER CLUB ---
//   Widget _buildSolherClubCard(int points) {
//     final tier = _getUserTier(points);
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//             colors: tier['colors'],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//               color: tier['colors'][0].withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 6))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('SOLHER CLUB',
//               style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2)),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Text(tier['icon'], style: const TextStyle(fontSize: 24)),
//               const SizedBox(width: 8),
//               Text('${tier['name']} TIER',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 1)),
//             ],
//           ),
//           const SizedBox(height: 24),
//           const Text('AVAILABLE POINTS',
//               style: TextStyle(
//                   color: Colors.white70, fontSize: 10, letterSpacing: 1)),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text('$points',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 40,
//                       fontWeight: FontWeight.w900)),
//               const Padding(
//                   padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
//                   child: Text('Pts',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // --- TOMBOL MENU ---
//   Widget _buildMenuButton(IconData icon, String title, String subtitle,
//       Color color, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border.all(color: Colors.grey.shade200),
//             borderRadius: BorderRadius.circular(20)),
//         child: Row(
//           children: [
//             Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Icon(icon, color: color)),
//             const SizedBox(width: 16),
//             Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                   Text(title,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14)),
//                   Text(subtitle,
//                       style: const TextStyle(color: Colors.grey, fontSize: 11))
//                 ])),
//             Icon(Icons.chevron_right, color: Colors.grey.shade400)
//           ],
//         ),
//       ),
//     );
//   }

//   // --- AREA ALAMAT ---
//   Widget _buildAddressSection() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.grey.shade200),
//           borderRadius: BorderRadius.circular(24)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.blue.shade700,
//                   side: BorderSide(color: Colors.blue.shade100),
//                   backgroundColor: Colors.blue.shade50,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12))),
//               icon: const Icon(Icons.add),
//               label: const Text('Tambah Alamat Baru',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               onPressed: () => _showAddressModal(context),
//             ),
//           ),
//           const SizedBox(height: 24),
//           BlocConsumer<AddressBloc, AddressState>(
//             listener: (context, state) {
//               if (state is AddressActionSuccess) {
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message),
//                     backgroundColor: Colors.green));
//               } else if (state is AddressError) {
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                     content: Text(state.message), backgroundColor: Colors.red));
//               }
//             },
//             builder: (context, state) {
//               if (state is AddressLoading || state is AddressInitial) {
//                 return const Center(
//                     child: Padding(
//                         padding: EdgeInsets.all(20.0),
//                         child: CircularProgressIndicator(color: Colors.black)));
//               } else if (state is AddressLoaded) {
//                 if (state.addresses.isEmpty) {
//                   return const Center(
//                       child: Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Text('Belum ada alamat pengiriman.',
//                               style: TextStyle(color: Colors.grey))));
//                 }
//                 return ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: state.addresses.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                   itemBuilder: (context, index) =>
//                       _buildAddressCard(context, state.addresses[index]),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           )
//         ],
//       ),
//     );
//   }

//   // --- KARTU ALAMAT ---
//   Widget _buildAddressCard(BuildContext context, AddressModel addr) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//             color:
//                 addr.isDefault ? Colors.blue.shade300 : Colors.grey.shade200),
//         boxShadow: addr.isDefault
//             ? [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)]
//             : [],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.location_on,
//                       color: Colors.blue.shade500, size: 20),
//                   const SizedBox(width: 8),
//                   Text('${addr.firstName} ${addr.lastName}',
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14)),
//                 ],
//               ),
//               if (addr.isDefault)
//                 Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8)),
//                     child: Text('UTAMA',
//                         style: TextStyle(
//                             color: Colors.blue.shade700,
//                             fontSize: 9,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1)))
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(addr.location,
//               style: const TextStyle(
//                   color: Colors.black87, fontSize: 12, height: 1.5),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis),
//           const SizedBox(height: 4),
//           Text('${addr.city}, ${addr.province} ${addr.postalCode}',
//               style: const TextStyle(color: Colors.grey, fontSize: 12)),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                   onPressed: () => _showAddressModal(context, address: addr),
//                   child: const Text('Edit',
//                       style: TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12))),
//               TextButton(
//                   onPressed: () => _confirmDeleteAddress(context, addr),
//                   child: const Text('Hapus',
//                       style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12))),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solher_mobile/screens/favorite_page.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/address/address_bloc.dart';
import '../blocs/address/address_event.dart';
import '../blocs/address/address_state.dart';
import '../repositories/address_repository.dart';

import 'package:solher_mobile/models/address_model.dart';
import 'package:solher_mobile/models/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 👇 INI KUNCINYA: Menyimpan data user sementara agar UI tidak terlempar keluar 👇
  UserModel? _cachedUser;

  // --- FUNGSI AMBIL GAMBAR DARI GALERI ---
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null && context.mounted) {
      context
          .read<AuthBloc>()
          .add(UpdateProfileImageRequested(pickedFile.path));
    }
  }

  // --- MODAL EDIT PROFIL ---
  void _showEditProfileModal(BuildContext context, UserModel user) {
    final firstNameCtrl = TextEditingController(text: user.firstName);
    final lastNameCtrl = TextEditingController(text: user.lastName);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Profil',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif')),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInput('Nama Depan', firstNameCtrl),
                _buildInput('Nama Belakang', lastNameCtrl),
                _buildInput('Email', emailCtrl, isEmail: true),
                _buildInput('Nomor Telepon', phoneCtrl, isPhone: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<AuthBloc>().add(
                            UpdateProfileRequested(
                              firstName: firstNameCtrl.text.trim(),
                              lastName: lastNameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                            ),
                          );
                    },
                    child: const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODAL TAMBAH & EDIT ALAMAT ---
  void _showAddressModal(BuildContext context, {AddressModel? address}) {
    final isEdit = address != null;

    final firstNameCtrl = TextEditingController(text: address?.firstName ?? '');
    final lastNameCtrl = TextEditingController(text: address?.lastName ?? '');
    final locationCtrl = TextEditingController(text: address?.location ?? '');
    final cityCtrl = TextEditingController(text: address?.city ?? '');
    final provinceCtrl = TextEditingController(text: address?.province ?? '');
    final postalCtrl = TextEditingController(text: address?.postalCode ?? '');
    final regionCtrl = TextEditingController(
        text: address?.region ?? ''); // 👇 TAMBAHAN UNTUK REGION
    bool isDefault = address?.isDefault ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEdit ? 'Edit Alamat' : 'Tambah Alamat Baru',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInput('Nama Depan', firstNameCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInput('Nama Belakang', lastNameCtrl)),
                      ],
                    ),
                    // _buildInput('Nomor Telepon', phoneCtrl, isPhone: true),

                    // 👇 BARIS KHUSUS PROVINSI & KOTA
                    Row(
                      children: [
                        Expanded(child: _buildInput('Provinsi', provinceCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInput('Kota/Kabupaten', cityCtrl)),
                      ],
                    ),

                    // 👇 BARIS KHUSUS REGION & KODEPOS
                    Row(
                      children: [
                        Expanded(
                            child:
                                _buildInput('Kecamatan (Region)', regionCtrl)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInput('Kode Pos', postalCtrl,
                                isPhone: true)),
                      ],
                    ),

                    _buildInput(
                        'Alamat Lengkap (Jalan, RT/RW, Patokan)', locationCtrl,
                        maxLines: 3),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.black,
                      title: const Text('Jadikan sebagai alamat utama',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      value: isDefault,
                      onChanged: (val) =>
                          setModalState(() => isDefault = val ?? false),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          final newAddress = AddressModel(
                            id: isEdit ? address.id : null,
                            firstName: firstNameCtrl.text.trim(),
                            lastName: lastNameCtrl.text.trim(),
                            location: locationCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                            province: provinceCtrl.text.trim(),
                            region: regionCtrl.text.trim(), // Pastikan dikirim!
                            postalCode: postalCtrl.text.trim(),
                            isDefault: isDefault,
                          );

                          if (isEdit) {
                            context.read<AddressBloc>().add(
                                UpdateAddressEvent(address.id!, newAddress));
                          } else {
                            context
                                .read<AddressBloc>()
                                .add(CreateAddressEvent(newAddress));
                          }
                        },
                        child: Text(
                          isEdit ? 'SIMPAN ALAMAT' : 'TAMBAHKAN ALAMAT',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- MODAL KONFIRMASI HAPUS ALAMAT ---
  void _confirmDeleteAddress(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Anda yakin ingin menghapus alamat ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AddressBloc>().add(DeleteAddressEvent(address.id!));
            },
            child:
                const Text('YA, HAPUS', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Input Teks Cepat
  Widget _buildInput(String label, TextEditingController controller,
      {bool isEmail = false, bool isPhone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isPhone
                ? TextInputType.phone
                : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getUserTier(int points) {
    if (points < 2500) {
      return {
        'name': 'Silver',
        'colors': [Colors.grey.shade400, Colors.grey.shade600],
        'icon': '🥈',
        'next': 2500,
        'nextName': 'Gold'
      };
    } else if (points < 10000) {
      return {
        'name': 'Gold',
        'colors': [Colors.amber.shade400, Colors.orange.shade700],
        'icon': '🥇',
        'next': 10000,
        'nextName': 'Platinum'
      };
    } else {
      return {
        'name': 'Platinum',
        'colors': [Colors.indigo.shade400, Colors.purple.shade700],
        'icon': '💎',
        'next': null,
        'nextName': null
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddressBloc(addressRepository: AddressRepository())
        ..add(FetchAddresses()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('My Account',
              style:
                  TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif')),
          backgroundColor: Colors.grey[500],
          foregroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ));
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ));
            }
          },
          builder: (context, state) {
            // 👇 UPDATE CACHE JIKA SUKSES 👇
            if (state is AuthAuthenticated) {
              _cachedUser = state.user;
            }

            // Tampilkan loading HANYA JIKA memori masih kosong
            if (state is AuthLoading && _cachedUser == null) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.black));
            }

            // 👇 GUNAKAN DATA CACHE AGAR UI TIDAK BERKEDIP 👇
            if (_cachedUser != null) {
              final user = _cachedUser!;
              final String firstName = user.firstName ?? '';
              final String lastName = user.lastName ?? '';
              final String email = user.email ?? '';
              final String phone = user.phone ?? '';
              final int points = user.point ?? 0;
              final String avatarUrl = user.profileImage ??
                  'https://ui-avatars.com/api/?name=$firstName&background=000&color=fff';

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Manage your details and address',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 24),
                    _buildProfileCard(context, user, firstName, lastName, email,
                        phone, avatarUrl),
                    const SizedBox(height: 24),
                    _buildSolherClubCard(points),
                    const SizedBox(height: 24),
                    // _buildMenuButton(Icons.favorite_border, 'My Wishlist',
                    //     'View your saved items', Colors.red, () {}),
                    _buildMenuButton(Icons.favorite_border, 'My Wishlist',
                        'View your saved items', Colors.red, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritePage()),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildMenuButton(
                        Icons.campaign_outlined,
                        'Program Afiliasi',
                        'Dapatkan Komisi Khusus!',
                        Colors.amber.shade600,
                        () {}),
                    const SizedBox(height: 32),
                    const Text('Shipping Addresses',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildAddressSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }

            return const Center(child: Text('Akses Ditolak. Silakan Login.'));
          },
        ),
      ),
    );
  }

  // --- KARTU PROFIL ---
  Widget _buildProfileCard(BuildContext context, UserModel user, String fName,
      String lName, String email, String phone, String avatar) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFE5E7EB), Color(0xFFF3F4F6)]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                            radius: 42, backgroundImage: NetworkImage(avatar)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 14),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text('$fName $lName',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.email_outlined, 'Email', email),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.phone_outlined, 'Telepon',
                          phone.isEmpty ? '(Belum diisi)' : phone),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showEditProfileModal(context, user),
                          child: const Text('Edit Profil',
                              style: TextStyle(color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout,
                            color: Colors.red, size: 20),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Log Out'),
                              content: const Text('Yakin ingin keluar?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Batal')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context
                                        .read<AuthBloc>()
                                        .add(LogoutRequested());
                                  },
                                  child: const Text('Keluar'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1),
                ),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- KARTU SOLHER CLUB ---
  Widget _buildSolherClubCard(int points) {
    final tier = _getUserTier(points);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tier['colors'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: tier['colors'][0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SOLHER CLUB',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(tier['icon'], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text('${tier['name']} TIER',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('AVAILABLE POINTS',
              style: TextStyle(
                  color: Colors.white70, fontSize: 10, letterSpacing: 1)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$points',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900)),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                child: Text('Pts',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TOMBOL MENU ---
  Widget _buildMenuButton(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // --- AREA ALAMAT ---
  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade100),
                backgroundColor: Colors.blue.shade50,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Alamat Baru',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _showAddressModal(context),
            ),
          ),
          const SizedBox(height: 24),
          BlocConsumer<AddressBloc, AddressState>(
            listener: (context, state) {
              if (state is AddressActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green));
              } else if (state is AddressError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red));
              }
            },
            builder: (context, state) {
              if (state is AddressLoading || state is AddressInitial) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: Colors.black)));
              } else if (state is AddressLoaded) {
                if (state.addresses.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Belum ada alamat pengiriman.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildAddressCard(context, state.addresses[index]),
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }

  // --- KARTU ALAMAT ---
  Widget _buildAddressCard(BuildContext context, AddressModel addr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                addr.isDefault ? Colors.blue.shade300 : Colors.grey.shade200),
        boxShadow: addr.isDefault
            ? [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: Colors.blue.shade500, size: 20),
                  const SizedBox(width: 8),
                  Text('${addr.firstName} ${addr.lastName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (addr.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('UTAMA',
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addr.location,
            style: const TextStyle(
                color: Colors.black87, fontSize: 12, height: 1.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text('${addr.city}, ${addr.province} ${addr.postalCode}',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showAddressModal(context, address: addr),
                child: const Text('Edit',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              TextButton(
                onPressed: () => _confirmDeleteAddress(context, addr),
                child: const Text('Hapus',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
