// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';

// class SolherClubPage extends StatefulWidget {
//   const SolherClubPage({super.key});

//   @override
//   State<SolherClubPage> createState() => _SolherClubPageState();
// }

// class _SolherClubPageState extends State<SolherClubPage> {
//   int _points = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserPoints();
//   }

//   Future<void> _loadUserPoints() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final userObj = json.decode(userStr);
//       if (mounted) {
//         setState(() {
//           // Tangani kemungkinan data poin berupa string dari API
//           _points = int.tryParse(userObj['point']?.toString() ?? '0') ?? 0;
//         });
//       }
//     }
//   }

//   // Fungsi pintar penghitung Tier Member
//   Map<String, dynamic> _getCurrentTier() {
//     if (_points < 2500) {
//       return {'name': 'Silver', 'icon': '🥈', 'next': 2500, 'nextName': 'Gold'};
//     } else if (_points < 10000) {
//       return {
//         'name': 'Gold',
//         'icon': '🥇',
//         'next': 10000,
//         'nextName': 'Platinum'
//       };
//     } else {
//       return {'name': 'Platinum', 'icon': '💎', 'next': null, 'nextName': null};
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, authState) {
//         final bool isAuthenticated = authState is AuthAuthenticated;
//         final tierInfo = _getCurrentTier();

//         return Scaffold(
//           backgroundColor: const Color(0xFFFAFAFA),
//           body: CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               // 👇 HERO BANNER (SLIVER APP BAR) 👇
//               SliverAppBar(
//                 expandedHeight: 400,
//                 pinned: true,
//                 stretch: true,
//                 backgroundColor: Colors.black,
//                 iconTheme: const IconThemeData(color: Colors.white),
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       // Placeholder jika gambar belum ada
//                       Container(color: Colors.black),
//                       Image.asset(
//                         'assets/images/solher_club.jpg', // Pastikan mengganti dengan aset 'solher_club.jpg' jika ada
//                         fit: BoxFit.cover,
//                         color: Colors.black.withOpacity(0.6),
//                         colorBlendMode: BlendMode.darken,
//                       ),
//                       Container(
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.black54, Colors.transparent],
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 60,
//                         left: 24,
//                         right: 24,
//                         child: Column(
//                           children: [
//                             const Text(
//                               'WELCOME TO SOLHER CLUB',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontFamily: 'serif',
//                                   fontSize: 32,
//                                   fontWeight: FontWeight.bold,
//                                   height: 1.1),
//                             ),
//                             const SizedBox(height: 12),
//                             const Text(
//                               'ELEVATE YOUR EVERYDAY STYLE AND EARN EXCLUSIVE REWARDS.',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2),
//                             ),
//                             if (!isAuthenticated) ...[
//                               const SizedBox(height: 32),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: Colors.black,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 32, vertical: 16),
//                                   shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.zero),
//                                 ),
//                                 onPressed: () {
//                                   // Navigasi ke halaman login (sesuaikan rute)
//                                   // Navigator.pushNamed(context, '/login');
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content:
//                                               Text('Menuju halaman Login...')));
//                                 },
//                                 child: const Text(
//                                   'JOIN NOW',
//                                   style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 2),
//                                 ),
//                               )
//                             ]
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),

//               // 👇 KONTEN HALAMAN 👇
//               SliverToBoxAdapter(
//                 child: Transform.translate(
//                   offset: const Offset(0, -30),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       children: [
//                         // KARTU MEMBER AKTIF (HANYA JIKA LOGIN)
//                         if (isAuthenticated) _buildMemberStatusCard(tierInfo),

//                         const SizedBox(height: 24),
//                         const Text(
//                           'HOW IT WORKS',
//                           style: TextStyle(
//                               fontFamily: 'serif',
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'It\'s simple. Shop your favorite items, earn points, and unlock exclusive rewards designed just for you.',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               fontSize: 12, color: Colors.grey, height: 1.5),
//                         ),
//                         const SizedBox(height: 40),

//                         _buildHowItWorksItem(
//                             icon: Icons.person_add_alt_1_outlined,
//                             title: '1. JOIN',
//                             desc:
//                                 'Create an account to automatically become a Solher Club member. It\'s completely free.'),
//                         const SizedBox(height: 32),
//                         _buildHowItWorksItem(
//                             icon: Icons.local_mall_outlined,
//                             title: '2. EARN',
//                             desc:
//                                 'Earn points every time you shop. Reach higher tiers for accelerated earning rates.'),
//                         const SizedBox(height: 32),
//                         _buildHowItWorksItem(
//                             icon: Icons.redeem_outlined,
//                             title: '3. REDEEM',
//                             desc:
//                                 'Use your points at checkout for discounts on your favorite items.'),

//                         const SizedBox(height: 64),
//                         const Text(
//                           'MEMBERSHIP TIERS',
//                           style: TextStyle(
//                               fontFamily: 'serif',
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 32),

//                         // KARTU TIER
//                         _buildTierCard(
//                           title: 'Silver',
//                           icon: '🥈',
//                           points: '0 - 2,499 Pts',
//                           benefits: [
//                             'Earn 1 Point per Rp 1.000 spent',
//                             'Standard Birthday Reward'
//                           ],
//                         ),
//                         const SizedBox(height: 24),
//                         _buildGoldTierCard(),
//                         const SizedBox(height: 24),
//                         _buildTierCard(
//                           title: 'Platinum',
//                           icon: '💎',
//                           points: '10,000+ Pts',
//                           isDark: true,
//                           benefits: [
//                             'Earn 2 Points per Rp 1.000 spent',
//                             'Exclusive Birthday Gift',
//                             'Priority VIP Customer Care',
//                             'Free Shipping on All Orders'
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMemberStatusCard(Map<String, dynamic> tierInfo) {
//     final int? nextPoints = tierInfo['next'];
//     final double progress = nextPoints != null ? _points / nextPoints : 1.0;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 20,
//               offset: const Offset(0, 10))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('YOUR STATUS',
//               style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                   color: Colors.grey)),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Text(tierInfo['icon'], style: const TextStyle(fontSize: 40)),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('${tierInfo['name']} MEMBER',
//                         style: const TextStyle(
//                             fontFamily: 'serif',
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     RichText(
//                       text: TextSpan(
//                         style:
//                             const TextStyle(color: Colors.grey, fontSize: 12),
//                         children: [
//                           const TextSpan(text: 'You have '),
//                           TextSpan(
//                               text: '$_points',
//                               style: const TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w900,
//                                   fontSize: 16)),
//                           const TextSpan(text: ' Points'),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(height: 24),
//           if (nextPoints != null) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(tierInfo['name'].toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                         letterSpacing: 1)),
//                 Text(tierInfo['nextName'].toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                         letterSpacing: 1)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: progress,
//                 minHeight: 8,
//                 backgroundColor: Colors.grey.shade100,
//                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Earn ${nextPoints - _points} more points to unlock ${tierInfo['nextName']}.',
//               style: const TextStyle(fontSize: 10, color: Colors.grey),
//             )
//           ] else ...[
//             const Text('MAXIMUM TIER REACHED',
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 2,
//                     color: Colors.indigo)),
//           ]
//         ],
//       ),
//     );
//   }

//   Widget _buildHowItWorksItem(
//       {required IconData icon, required String title, required String desc}) {
//     return Column(
//       children: [
//         Container(
//           width: 70,
//           height: 70,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 28, color: Colors.black87),
//         ),
//         const SizedBox(height: 16),
//         Text(title,
//             style: const TextStyle(
//                 fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
//         const SizedBox(height: 8),
//         Text(desc,
//             textAlign: TextAlign.center,
//             style:
//                 const TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
//       ],
//     );
//   }

//   Widget _buildTierCard(
//       {required String title,
//       required String icon,
//       required String points,
//       required List<String> benefits,
//       bool isDark = false}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF111827) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: isDark ? null : Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 32)),
//           const SizedBox(height: 16),
//           Text(title.toUpperCase(),
//               style: TextStyle(
//                   fontFamily: 'serif',
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                   color: isDark ? Colors.indigo.shade200 : Colors.black)),
//           const SizedBox(height: 4),
//           Text(points,
//               style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                   color: isDark ? Colors.indigo.shade400 : Colors.grey)),
//           const SizedBox(height: 24),
//           ...benefits.map((b) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check,
//                         size: 16,
//                         color:
//                             isDark ? Colors.indigo.shade400 : Colors.black87),
//                     const SizedBox(width: 12),
//                     Expanded(
//                         child: Text(b,
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 color: isDark
//                                     ? Colors.grey.shade300
//                                     : Colors.black87))),
//                   ],
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildGoldTierCard() {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFFFFDF0), Colors.white],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFFBEB9F)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.amber.withOpacity(0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10))
//         ],
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.amber.shade500,
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: const Text(
//                 'MOST POPULAR',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: 2),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 16),
//                 const Text('🥇', style: TextStyle(fontSize: 32)),
//                 const SizedBox(height: 16),
//                 const Text('GOLD',
//                     style: TextStyle(
//                         fontFamily: 'serif',
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                         color: Colors.amber)),
//                 const SizedBox(height: 4),
//                 Text('2,500 - 9,999 PTS',
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                         color: Colors.amber.shade600)),
//                 const SizedBox(height: 24),
//                 _buildGoldBenefitItem('Earn 1.5 Points per Rp 1.000 spent',
//                     isBold: true),
//                 _buildGoldBenefitItem('Premium Birthday Reward'),
//                 _buildGoldBenefitItem('Early Access to Sales'),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildGoldBenefitItem(String text, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Icon(Icons.check, size: 16, color: Colors.amber.shade600),
//           const SizedBox(width: 12),
//           Expanded(
//               child: Text(text,
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                       color: Colors.black87))),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/auth/auth_state.dart';

// class SolherClubPage extends StatefulWidget {
//   const SolherClubPage({super.key});

//   @override
//   State<SolherClubPage> createState() => _SolherClubPageState();
// }

// class _SolherClubPageState extends State<SolherClubPage> {
//   int _points = 0;

//   // 👇 Array Privileges Sesuai Arahan Boss 👇
//   final List<String> musePrivileges = [
//     "Welcome gift",
//     "Early access to selected launches",
//     "Member-only privileges",
//     "Birthday month benefit",
//     "Access to SOLHÉR events",
//     "First access to limited collections"
//   ];

//   final List<String> elanPrivileges = [
//     "All Muse privileges",
//     "5% member privilege on selected purchases",
//     "Early access to new collections",
//     "Complimentary gift wrapping",
//     "Exclusive seasonal gifts",
//     "Priority access to limited pieces",
//     "Birthday month gift",
//     "Private event invitations",
//     "Priority customer service"
//   ];

//   final List<String> heritagePrivileges = [
//     "All Élan privileges",
//     "10% member privilege on selected purchases",
//     "First access to new collections",
//     "Priority reservation of limited pieces",
//     "Exclusive Héritage gift",
//     "Personal styling & bag consultation",
//     "Complimentary care service",
//     "Private previews & intimate events",
//     "Exclusive Héritage experiences",
//     "Special anniversary & birthday gift"
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserPoints();
//   }

//   Future<void> _loadUserPoints() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final userObj = json.decode(userStr);
//       if (mounted) {
//         setState(() {
//           _points = int.tryParse(userObj['point']?.toString() ?? '0') ?? 0;
//         });
//       }
//     }
//   }

//   // 👇 Logika Tier "The Solhér Circle" 👇
//   Map<String, dynamic> _getCurrentTier() {
//     if (_points < 2500) {
//       return {'name': 'Muse', 'icon': '✧', 'next': 2500, 'nextName': 'Élan'};
//     } else if (_points < 10000) {
//       return {
//         'name': 'Élan',
//         'icon': '✦',
//         'next': 10000,
//         'nextName': 'Héritage'
//       };
//     } else {
//       return {'name': 'Héritage', 'icon': '❈', 'next': null, 'nextName': null};
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AuthBloc, AuthState>(
//       builder: (context, authState) {
//         final bool isAuthenticated = authState is AuthAuthenticated;
//         final tierInfo = _getCurrentTier();

//         return Scaffold(
//           backgroundColor: const Color(0xFFFAFAFA),
//           body: CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               // 👇 HERO BANNER (SLIVER APP BAR) 👇
//               SliverAppBar(
//                 expandedHeight: 450,
//                 pinned: true,
//                 stretch: true,
//                 backgroundColor: Colors.black,
//                 iconTheme: const IconThemeData(color: Colors.white),
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Container(color: Colors.black),
//                       Image.asset(
//                         'assets/images/solher_club.jpg',
//                         fit: BoxFit.cover,
//                         color: Colors.black.withOpacity(0.5), // Opacity ala Vue
//                         colorBlendMode: BlendMode.darken,
//                       ),
//                       Container(
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Colors.black87, Colors.transparent],
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 60,
//                         left: 24,
//                         right: 24,
//                         child: Column(
//                           children: [
//                             const Text(
//                               'THE SOLHÉR CIRCLE',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontFamily: 'serif',
//                                   fontSize: 34,
//                                   fontWeight: FontWeight.bold,
//                                   height: 1.1),
//                             ),
//                             const SizedBox(height: 12),
//                             const Text(
//                               'MORE THAN MEMBERSHIP. A PLACE TO BELONG.',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600,
//                                   letterSpacing: 2.5),
//                             ),
//                             if (!isAuthenticated) ...[
//                               const SizedBox(height: 32),
//                               ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: Colors.black,
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 36, vertical: 16),
//                                   shape: const RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.zero),
//                                   elevation: 5,
//                                 ),
//                                 onPressed: () {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text(
//                                               'Menuju halaman Login...')));
//                                 },
//                                 child: const Text(
//                                   'JOIN THE CIRCLE',
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w900,
//                                       letterSpacing: 2),
//                                 ),
//                               )
//                             ]
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),

//               // 👇 KONTEN HALAMAN 👇
//               SliverToBoxAdapter(
//                 child: Transform.translate(
//                   offset: const Offset(0, -30),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       children: [
//                         // KARTU CIRCLE STATUS (HANYA JIKA LOGIN)
//                         if (isAuthenticated) _buildMemberStatusCard(tierInfo),

//                         const SizedBox(height: 40),
                        
//                         // 👇 STORYTELLING INTRODUCTION 👇
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 16.0),
//                           child: Text(
//                             '"Every SOLHÉR piece is made to accompany a woman through the chapters of her life. The SOLHÉR Circle is our way of celebrating the women who choose to carry those stories with us."',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontFamily: 'serif',
//                                 fontStyle: FontStyle.italic,
//                                 fontSize: 16,
//                                 color: Color(0xFF4B5563),
//                                 height: 1.6),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 24.0),
//                           child: Text(
//                             'From your first piece to the ones you keep for years to come, enjoy thoughtful privileges, early access, and invitations created exclusively for our community.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: Color(0xFF6B7280),
//                                 height: 1.8),
//                           ),
//                         ),
//                         const SizedBox(height: 64),

//                         // 👇 KARTU TIER MUSE 👇
//                         _buildMuseTierCard(tierInfo['name'], isAuthenticated),
//                         const SizedBox(height: 24),

//                         // 👇 KARTU TIER ÉLAN 👇
//                         _buildElanTierCard(tierInfo['name'], isAuthenticated),
//                         const SizedBox(height: 24),

//                         // 👇 KARTU TIER HÉRITAGE 👇
//                         _buildHeritageTierCard(tierInfo['name'], isAuthenticated),
                        
//                         // 👇 CLOSING FOOTER 👇
//                         const SizedBox(height: 64),
//                         Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))
//                           ),
//                           padding: const EdgeInsets.only(top: 48, bottom: 48),
//                           child: Column(
//                             children: [
//                               const Text(
//                                 'YOUR STORY.\nYOUR PIECES.\nYOUR CIRCLE.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: 'serif',
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 2,
//                                   height: 1.5,
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               const Text(
//                                 'Because the most meaningful things we carry are not simply possessions.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: 'serif',
//                                   fontStyle: FontStyle.italic,
//                                   fontSize: 13,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 'They become part of who we are.',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: 'serif',
//                                   fontStyle: FontStyle.italic,
//                                   fontSize: 13,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 48),
//                               Container(
//                                 padding: const EdgeInsets.only(bottom: 8),
//                                 decoration: const BoxDecoration(
//                                   border: Border(bottom: BorderSide(color: Colors.black, width: 1.5))
//                                 ),
//                                 child: const Text(
//                                   'WELCOME TO THE SOLHÉR CIRCLE.',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w900,
//                                     letterSpacing: 3,
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildMemberStatusCard(Map<String, dynamic> tierInfo) {
//     final int? nextPoints = tierInfo['next'];
//     final double progress = nextPoints != null ? _points / nextPoints : 1.0;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 20,
//               offset: const Offset(0, 10))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('YOUR CIRCLE STATUS',
//               style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                   color: Colors.grey)),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Text(tierInfo['icon'], style: const TextStyle(fontSize: 32, color: Colors.grey)),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(tierInfo['name'].toUpperCase(),
//                         style: const TextStyle(
//                             fontFamily: 'serif',
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     RichText(
//                       text: TextSpan(
//                         style:
//                             const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
//                         children: [
//                           const TextSpan(text: 'You carry '),
//                           TextSpan(
//                               text: '$_points',
//                               style: const TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w900,
//                                   fontSize: 16)),
//                           const TextSpan(text: ' stories (points)'),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(height: 32),
//           if (nextPoints != null) ...[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(tierInfo['name'].toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                         letterSpacing: 1)),
//                 Text(tierInfo['nextName'].toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey,
//                         letterSpacing: 1)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: progress,
//                 minHeight: 4,
//                 backgroundColor: Colors.grey.shade100,
//                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Accumulate ${nextPoints - _points} more to discover ${tierInfo['nextName']}.',
//               style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
//             )
//           ] else ...[
//             const Align(
//               alignment: Alignment.centerRight,
//               child: Text('HIGHEST CIRCLE REACHED',
//                   style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                       color: Colors.black)),
//             ),
//           ]
//         ],
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET KHUSUS TIER: MUSE
//   // ==========================================
//   Widget _buildMuseTierCard(String currentTierName, bool isAuthenticated) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.only(bottom: 24),
//             decoration: BoxDecoration(
//               border: Border(bottom: BorderSide(color: Colors.grey.shade100))
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('✧', style: TextStyle(fontSize: 24, color: Colors.grey)),
//                 const SizedBox(height: 12),
//                 const Text('MUSE',
//                     style: TextStyle(
//                         fontFamily: 'serif',
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                         color: Colors.black)),
//                 const SizedBox(height: 8),
//                 const Text('"Your beginning with SOLHÉR."',
//                     style: TextStyle(
//                         fontFamily: 'serif',
//                         fontStyle: FontStyle.italic,
//                         fontSize: 12,
//                         color: Colors.grey)),
//                 const SizedBox(height: 16),
//                 Text('0 - 2,499 Pts',
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                         color: Colors.grey.shade400)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           const SizedBox(
//             height: 48,
//             child: Text(
//               'A complimentary membership for every woman who chooses to become part of our story.',
//               style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...musePrivileges.map((b) => Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(top: 5),
//                       width: 6,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         shape: BoxShape.circle
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                         child: Text(b,
//                             style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black54))),
//                   ],
//                 ),
//               )),
//           const SizedBox(height: 16),
//           if (!isAuthenticated)
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   side: const BorderSide(color: Colors.black),
//                   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
//                 ),
//                 onPressed: () { /* Navigator ke Login */ },
//                 child: const Text('BECOME A MUSE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
//               ),
//             )
//           else if (currentTierName == 'Muse')
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               color: Colors.grey.shade100,
//               alignment: Alignment.center,
//               child: const Text('YOUR CURRENT STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
//             )
//         ],
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET KHUSUS TIER: ÉLAN
//   // ==========================================
//   Widget _buildElanTierCard(String currentTierName, bool isAuthenticated) {
//     const Color elanCream = Color(0xFFFDFBF7);
//     const Color elanBorder = Color(0xFFE8E2D2);
//     const Color elanText = Color(0xFF8B7355);

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: elanCream,
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: elanBorder),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 15,
//               offset: const Offset(0, 8))
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: double.infinity,
//             color: elanBorder,
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: const Text(
//               'THE NEXT CHAPTER',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: elanText,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 2),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(32),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.only(bottom: 24),
//                   decoration: const BoxDecoration(
//                     border: Border(bottom: BorderSide(color: elanBorder))
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('✦', style: TextStyle(fontSize: 24, color: elanText)),
//                       const SizedBox(height: 12),
//                       const Text('ÉLAN',
//                           style: TextStyle(
//                               fontFamily: 'serif',
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2,
//                               color: elanText)),
//                       const SizedBox(height: 8),
//                       const Text('"For the woman in motion."',
//                           style: TextStyle(
//                               fontFamily: 'serif',
//                               fontStyle: FontStyle.italic,
//                               fontSize: 12,
//                               color: Colors.grey)),
//                       const SizedBox(height: 16),
//                       Text('2,500 - 9,999 Pts',
//                           style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 2,
//                               color: elanText.withOpacity(0.7))),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 const SizedBox(
//                   height: 48,
//                   child: Text(
//                     'Created for our returning community — women who continue to evolve, grow, and create their own story.',
//                     style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ...elanPrivileges.map((b) => Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(top: 5),
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: elanText.withOpacity(0.5),
//                               shape: BoxShape.circle
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                               child: Text(b,
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w500,
//                                       color: Colors.black87))),
//                         ],
//                       ),
//                     )),
//                 const SizedBox(height: 16),
//                 if (!isAuthenticated)
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: elanText,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         elevation: 0,
//                         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
//                       ),
//                       onPressed: () { /* Navigator ke Login */ },
//                       child: const Text('DISCOVER ÉLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
//                     ),
//                   )
//                 else if (currentTierName == 'Élan')
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     color: elanText.withOpacity(0.1),
//                     alignment: Alignment.center,
//                     child: const Text('YOUR CURRENT STATUS', style: TextStyle(color: elanText, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
//                   )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // ==========================================
//   // WIDGET KHUSUS TIER: HÉRITAGE
//   // ==========================================
//   Widget _buildHeritageTierCard(String currentTierName, bool isAuthenticated) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111111),
//         borderRadius: BorderRadius.circular(4),
//         border: Border.all(color: const Color(0xFF333333)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.only(bottom: 24),
//             decoration: const BoxDecoration(
//               border: Border(bottom: BorderSide(color: Color(0xFF333333)))
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('❈', style: TextStyle(fontSize: 24, color: Colors.white70)),
//                 const SizedBox(height: 12),
//                 const Text('HÉRITAGE',
//                     style: TextStyle(
//                         fontFamily: 'serif',
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                         color: Colors.white)),
//                 const SizedBox(height: 8),
//                 const Text('"For the stories that stay."',
//                     style: TextStyle(
//                         fontFamily: 'serif',
//                         fontStyle: FontStyle.italic,
//                         fontSize: 12,
//                         color: Colors.white70)),
//                 const SizedBox(height: 16),
//                 const Text('10,000+ Pts',
//                     style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 2,
//                         color: Colors.grey)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//           const SizedBox(
//             height: 48,
//             child: Text(
//               'Our most intimate circle, created for women who have made SOLHÉR part of their journey.',
//               style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...heritagePrivileges.map((b) => Padding(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(top: 5),
//                       width: 6,
//                       height: 6,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.5),
//                         shape: BoxShape.circle
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                         child: Text(b,
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey.shade300))),
//                   ],
//                 ),
//               )),
//           const SizedBox(height: 16),
//           if (!isAuthenticated)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
//                 ),
//                 onPressed: () { /* Navigator ke Login */ },
//                 child: const Text('DISCOVER HÉRITAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
//               ),
//             )
//           else if (currentTierName == 'Héritage')
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               color: Colors.white10,
//               alignment: Alignment.center,
//               child: const Text('YOUR CURRENT STATUS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
//             )
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class SolherClubPage extends StatefulWidget {
  const SolherClubPage({super.key});

  @override
  State<SolherClubPage> createState() => _SolherClubPageState();
}

class _SolherClubPageState extends State<SolherClubPage> {
  int _points = 0;

  // State untuk FAQ (Menyimpan index yang sedang terbuka)
  int? _activeFaqIndex;

  final List<String> musePrivileges = [
    "Welcome gift",
    "Early access to selected launches",
    "Member-only privileges",
    "Birthday month benefit",
    "Access to SOLHÉR events",
    "First access to limited collections"
  ];

  final List<String> elanPrivileges = [
    "All Muse privileges",
    "5% member privilege on selected purchases",
    "Early access to new collections",
    "Complimentary gift wrapping",
    "Exclusive seasonal gifts",
    "Priority access to limited pieces",
    "Birthday month gift",
    "Private event invitations",
    "Priority customer service"
  ];

  final List<String> heritagePrivileges = [
    "All Élan privileges",
    "10% member privilege on selected purchases",
    "First access to new collections",
    "Priority reservation of limited pieces",
    "Exclusive Héritage gift",
    "Personal styling & bag consultation",
    "Complimentary care service",
    "Private previews & intimate events",
    "Exclusive Héritage experiences",
    "Special anniversary & birthday gift"
  ];

  // 👇 DATA FAQ 👇
  final List<Map<String, String>> _faqs = [
    {
      "question": "Bagaimana cara perhitungan Poin Solhér?",
      "answer":
          "Untuk setiap pembelanjaan Rp 1.000 pada koleksi kami, Anda akan mendapatkan 1 Poin sebagai Muse. Seiring peningkatan status, reward Anda berlipat ganda: anggota Élan mendapatkan 1,5 Poin, dan anggota Héritage mendapatkan 2 Poin untuk setiap Rp 1.000."
    },
    {
      "question": "Bagaimana cara menukarkan Poin yang terkumpul?",
      "answer":
          "Poin Anda memiliki nilai nyata. Anda dapat menggunakannya saat checkout untuk mengurangi total pembayaran. Setiap 1.000 Poin memberikan potongan langsung sebesar Rp 1.000."
    },
    {
      "question": "Apakah Status dan Poin saya bisa kedaluwarsa?",
      "answer":
          "Poin dan status tier Anda berlaku selama 12 bulan dari tanggal pembelian terakhir. Melanjutkan perjalanan Anda bersama kami dalam tahun tersebut secara otomatis memperpanjang masa berlakunya."
    },
    {
      "question": "Bagaimana cara mengklaim Keuntungan Bulan Ulang Tahun saya?",
      "answer":
          "Hak istimewa ulang tahun yang dirancang khusus akan dikirimkan secara eksklusif ke alamat email Anda yang terdaftar pada awal bulan ulang tahun Anda. Pastikan detail profil Anda telah lengkap."
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      final userObj = json.decode(userStr);
      if (mounted) {
        setState(() {
          _points = int.tryParse(userObj['point']?.toString() ?? '0') ?? 0;
        });
      }
    }
  }

  Map<String, dynamic> _getCurrentTier() {
    if (_points < 2500) {
      return {'name': 'Muse', 'icon': '✧', 'next': 2500, 'nextName': 'Élan'};
    } else if (_points < 10000) {
      return {
        'name': 'Élan',
        'icon': '✦',
        'next': 10000,
        'nextName': 'Héritage'
      };
    } else {
      return {'name': 'Héritage', 'icon': '❈', 'next': null, 'nextName': null};
    }
  }

  // Fungsi penahan tombol UX Premium
  void _handleJoinClick() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Your Story',
              style:
                  TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold)),
          content: const Text(
              'Silakan buat akun atau login terlebih dahulu untuk bergabung dengan Solhér Circle.'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Menuju halaman pendaftaran...')));
              },
              child: const Text('Lanjutkan',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final bool isAuthenticated = authState is AuthAuthenticated;
        final tierInfo = _getCurrentTier();

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 👇 HERO BANNER (SLIVER APP BAR) 👇
              SliverAppBar(
                expandedHeight: 450,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.black),
                      Image.asset(
                        'assets/images/solher_club.jpg',
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.5),
                        colorBlendMode: BlendMode.darken,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black87, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: 24,
                        right: 24,
                        child: Column(
                          children: [
                            const Text(
                              'THE SOLHÉR CIRCLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'serif',
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'LEBIH DARI KEANGGOTAAN. TEMPAT UNTUK BERNAUNG.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5),
                            ),
                            if (!isAuthenticated) ...[
                              const SizedBox(height: 32),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 36, vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                  elevation: 5,
                                ),
                                onPressed: _handleJoinClick,
                                child: const Text(
                                  'BERGABUNG BERSAMA KAMI',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2),
                                ),
                              )
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // 👇 KONTEN HALAMAN 👇
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // KARTU CIRCLE STATUS (HANYA JIKA LOGIN)
                        if (isAuthenticated) _buildMemberStatusCard(tierInfo),

                        const SizedBox(height: 40),

                        // 👇 STORYTELLING INTRODUCTION 👇
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '"Setiap karya SOLHÉR dibuat untuk menemani seorang wanita melalui babak-babak dalam hidupnya. The SOLHÉR Circle adalah cara kami merayakan para wanita yang memilih untuk membawa cerita tersebut bersama kami."',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'serif',
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                                color: Color(0xFF4B5563),
                                height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Mulai dari karya pertama Anda hingga yang akan Anda simpan bertahun-tahun kemudian, nikmati keistimewaan, akses awal, dan undangan yang diciptakan khusus untuk komunitas kami.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                height: 1.8),
                          ),
                        ),
                        const SizedBox(height: 64),

                        // 👇 KARTU TIER MUSE 👇
                        _buildMuseTierCard(tierInfo['name'], isAuthenticated),
                        const SizedBox(height: 24),

                        // 👇 KARTU TIER ÉLAN 👇
                        _buildElanTierCard(tierInfo['name'], isAuthenticated),
                        const SizedBox(height: 24),

                        // 👇 KARTU TIER HÉRITAGE 👇
                        _buildHeritageTierCard(
                            tierInfo['name'], isAuthenticated),

                        // 👇 [BARU] FAQ SECTION 👇
                        const SizedBox(height: 64),
                        const Text(
                          'PERTANYAAN YANG SERING DIAJUKAN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildFaqSection(),
                        // 👆 ================= 👆

                        // 👇 CLOSING FOOTER 👇
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Color(0xFFE5E7EB)))),
                          padding: const EdgeInsets.only(top: 48, bottom: 48),
                          child: Column(
                            children: [
                              const Text(
                                'CERITA ANDA.\nKARYA ANDA.\nLINGKARAN ANDA.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Karena hal-hal paling bermakna yang kita bawa bukanlah sekadar kepemilikan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Mereka menjadi bagian dari siapa kita.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 48),
                              Container(
                                padding: const EdgeInsets.only(bottom: 8),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black, width: 1.5))),
                                child: const Text(
                                  'SELAMAT DATANG DI SOLHÉR CIRCLE.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 👇 FUNGSI UNTUK MERENDER DAFTAR FAQ 👇
  // ==========================================
  Widget _buildFaqSection() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final isExpanded = _activeFaqIndex == index;

          return Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeFaqIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _faqs[index]['question']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: isExpanded
                                  ? Colors.grey.shade500
                                  : Colors.black,
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded
                              ? 0.125
                              : 0.0, // Rotasi membentuk tanda (X)
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(Icons.add,
                              color: Colors.grey, size: 24),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(top: 16.0, right: 32.0),
                              child: Text(
                                _faqs[index]['answer']!,
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.6,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberStatusCard(Map<String, dynamic> tierInfo) {
    final int? nextPoints = tierInfo['next'];
    final double progress = nextPoints != null ? _points / nextPoints : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATUS CIRCLE ANDA',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(tierInfo['icon'],
                  style: const TextStyle(fontSize: 32, color: Colors.grey)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tierInfo['name'].toUpperCase(),
                        style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                        children: [
                          const TextSpan(text: 'Anda memiliki '),
                          TextSpan(
                              text: '$_points',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                          const TextSpan(text: ' cerita (poin)'),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          if (nextPoints != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tierInfo['name'].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1)),
                Text(tierInfo['nextName'].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kumpulkan ${nextPoints - _points} lagi untuk membuka ${tierInfo['nextName']}.',
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            )
          ] else ...[
            const Align(
              alignment: Alignment.centerRight,
              child: Text('LINGKARAN TERTINGGI TERCAPAI',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.black)),
            ),
          ]
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET KHUSUS TIER: MUSE
  // ==========================================
  Widget _buildMuseTierCard(String currentTierName, bool isAuthenticated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✧',
                    style: TextStyle(fontSize: 24, color: Colors.grey)),
                const SizedBox(height: 12),
                const Text('MUSE',
                    style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.black)),
                const SizedBox(height: 8),
                const Text('"Awal perjalanan Anda bersama SOLHÉR."',
                    style: TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey)),
                const SizedBox(height: 16),
                Text('0 - 2,499 Pts',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            height: 48,
            child: Text(
              'Keanggotaan gratis bagi setiap wanita yang memilih untuk menjadi bagian dari cerita kami.',
              style:
                  TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          ...musePrivileges.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(b,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          if (!isAuthenticated)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                onPressed: _handleJoinClick,
                child: const Text('MENJADI MUSE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
              ),
            )
          else if (currentTierName == 'Muse')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: const Text('STATUS ANDA SAAT INI',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            )
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET KHUSUS TIER: ÉLAN
  // ==========================================
  Widget _buildElanTierCard(String currentTierName, bool isAuthenticated) {
    const Color elanCream = Color(0xFFFDFBF7);
    const Color elanBorder = Color(0xFFE8E2D2);
    const Color elanText = Color(0xFF8B7355);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: elanCream,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: elanBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: elanBorder,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: const Text(
              'BABAK SELANJUTNYA',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: elanText,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 24),
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: elanBorder))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✦',
                          style: TextStyle(fontSize: 24, color: elanText)),
                      const SizedBox(height: 12),
                      const Text('ÉLAN',
                          style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: elanText)),
                      const SizedBox(height: 8),
                      const Text('"Untuk wanita yang terus melangkah."',
                          style: TextStyle(
                              fontFamily: 'serif',
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: Colors.grey)),
                      const SizedBox(height: 16),
                      Text('2,500 - 9,999 Pts',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: elanText.withOpacity(0.7))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(
                  height: 48,
                  child: Text(
                    'Diciptakan untuk komunitas kami yang kembali hadir — para wanita yang terus berkembang, bertumbuh, dan menciptakan cerita mereka sendiri.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.black54, height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                ...elanPrivileges.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: elanText.withOpacity(0.5),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87))),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                if (!isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: elanText,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                      onPressed: _handleJoinClick,
                      child: const Text('TEMUKAN ÉLAN',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                    ),
                  )
                else if (currentTierName == 'Élan')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: elanText.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: const Text('STATUS ANDA SAAT INI',
                        style: TextStyle(
                            color: elanText,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2)),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET KHUSUS TIER: HÉRITAGE
  // ==========================================
  Widget _buildHeritageTierCard(String currentTierName, bool isAuthenticated) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF333333)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('❈',
                    style: TextStyle(fontSize: 24, color: Colors.white70)),
                const SizedBox(height: 12),
                const Text('HÉRITAGE',
                    style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white)),
                const SizedBox(height: 8),
                const Text('"Untuk cerita yang abadi."',
                    style: TextStyle(
                        fontFamily: 'serif',
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.white70)),
                const SizedBox(height: 16),
                const Text('10,000+ Pts',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            height: 48,
            child: Text(
              'Lingkaran kami yang paling intim, diciptakan untuk wanita yang telah menjadikan SOLHÉR bagian dari perjalanannya.',
              style:
                  TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          ...heritagePrivileges.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(b,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade300))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          if (!isAuthenticated)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
                onPressed: _handleJoinClick,
                child: const Text('TEMUKAN HÉRITAGE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
              ),
            )
          else if (currentTierName == 'Héritage')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.white10,
              alignment: Alignment.center,
              child: const Text('STATUS ANDA SAAT INI',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            )
        ],
      ),
    );
  }
}
