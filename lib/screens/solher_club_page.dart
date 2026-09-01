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
          // Tangani kemungkinan data poin berupa string dari API
          _points = int.tryParse(userObj['point']?.toString() ?? '0') ?? 0;
        });
      }
    }
  }

  // Fungsi pintar penghitung Tier Member
  Map<String, dynamic> _getCurrentTier() {
    if (_points < 2500) {
      return {'name': 'Silver', 'icon': '🥈', 'next': 2500, 'nextName': 'Gold'};
    } else if (_points < 10000) {
      return {
        'name': 'Gold',
        'icon': '🥇',
        'next': 10000,
        'nextName': 'Platinum'
      };
    } else {
      return {'name': 'Platinum', 'icon': '💎', 'next': null, 'nextName': null};
    }
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
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder jika gambar belum ada
                      Container(color: Colors.black),
                      Image.asset(
                        'assets/images/solher_club.jpg', // Pastikan mengganti dengan aset 'solher_club.jpg' jika ada
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.6),
                        colorBlendMode: BlendMode.darken,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black54, Colors.transparent],
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
                              'WELCOME TO SOLHER CLUB',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'serif',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  height: 1.1),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'ELEVATE YOUR EVERYDAY STYLE AND EARN EXCLUSIVE REWARDS.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2),
                            ),
                            if (!isAuthenticated) ...[
                              const SizedBox(height: 32),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero),
                                ),
                                onPressed: () {
                                  // Navigasi ke halaman login (sesuaikan rute)
                                  // Navigator.pushNamed(context, '/login');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Menuju halaman Login...')));
                                },
                                child: const Text(
                                  'JOIN NOW',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
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
                        // KARTU MEMBER AKTIF (HANYA JIKA LOGIN)
                        if (isAuthenticated) _buildMemberStatusCard(tierInfo),

                        const SizedBox(height: 24),
                        const Text(
                          'HOW IT WORKS',
                          style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'It\'s simple. Shop your favorite items, earn points, and unlock exclusive rewards designed just for you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey, height: 1.5),
                        ),
                        const SizedBox(height: 40),

                        _buildHowItWorksItem(
                            icon: Icons.person_add_alt_1_outlined,
                            title: '1. JOIN',
                            desc:
                                'Create an account to automatically become a Solher Club member. It\'s completely free.'),
                        const SizedBox(height: 32),
                        _buildHowItWorksItem(
                            icon: Icons.local_mall_outlined,
                            title: '2. EARN',
                            desc:
                                'Earn points every time you shop. Reach higher tiers for accelerated earning rates.'),
                        const SizedBox(height: 32),
                        _buildHowItWorksItem(
                            icon: Icons.redeem_outlined,
                            title: '3. REDEEM',
                            desc:
                                'Use your points at checkout for discounts on your favorite items.'),

                        const SizedBox(height: 64),
                        const Text(
                          'MEMBERSHIP TIERS',
                          style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),

                        // KARTU TIER
                        _buildTierCard(
                          title: 'Silver',
                          icon: '🥈',
                          points: '0 - 2,499 Pts',
                          benefits: [
                            'Earn 1 Point per Rp 1.000 spent',
                            'Standard Birthday Reward'
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildGoldTierCard(),
                        const SizedBox(height: 24),
                        _buildTierCard(
                          title: 'Platinum',
                          icon: '💎',
                          points: '10,000+ Pts',
                          isDark: true,
                          benefits: [
                            'Earn 2 Points per Rp 1.000 spent',
                            'Exclusive Birthday Gift',
                            'Priority VIP Customer Care',
                            'Free Shipping on All Orders'
                          ],
                        ),
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

  Widget _buildMemberStatusCard(Map<String, dynamic> tierInfo) {
    final int? nextPoints = tierInfo['next'];
    final double progress = nextPoints != null ? _points / nextPoints : 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text('YOUR STATUS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(tierInfo['icon'], style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tierInfo['name']} MEMBER',
                        style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        children: [
                          const TextSpan(text: 'You have '),
                          TextSpan(
                              text: '$_points',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16)),
                          const TextSpan(text: ' Points'),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
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
                minHeight: 8,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Earn ${nextPoints - _points} more points to unlock ${tierInfo['nextName']}.',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            )
          ] else ...[
            const Text('MAXIMUM TIER REACHED',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.indigo)),
          ]
        ],
      ),
    );
  }

  Widget _buildHowItWorksItem(
      {required IconData icon, required String title, required String desc}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        const SizedBox(height: 16),
        Text(title,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(desc,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
      ],
    );
  }

  Widget _buildTierCard(
      {required String title,
      required String icon,
      required String points,
      required List<String> benefits,
      bool isDark = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 16),
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: isDark ? Colors.indigo.shade200 : Colors.black)),
          const SizedBox(height: 4),
          Text(points,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: isDark ? Colors.indigo.shade400 : Colors.grey)),
          const SizedBox(height: 24),
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.check,
                        size: 16,
                        color:
                            isDark ? Colors.indigo.shade400 : Colors.black87),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(b,
                            style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.black87))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGoldTierCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFDF0), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFBEB9F)),
        boxShadow: [
          BoxShadow(
              color: Colors.amber.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.amber.shade500,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('🥇', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 16),
                const Text('GOLD',
                    style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.amber)),
                const SizedBox(height: 4),
                Text('2,500 - 9,999 PTS',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.amber.shade600)),
                const SizedBox(height: 24),
                _buildGoldBenefitItem('Earn 1.5 Points per Rp 1.000 spent',
                    isBold: true),
                _buildGoldBenefitItem('Premium Birthday Reward'),
                _buildGoldBenefitItem('Early Access to Sales'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoldBenefitItem(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.amber.shade600),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black87))),
        ],
      ),
    );
  }
}
