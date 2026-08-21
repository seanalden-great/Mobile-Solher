// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'order_page.dart';
// import 'event_page.dart';
// import 'profile_page.dart';

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});

//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   // Indeks halaman yang sedang aktif (dimulai dari 0 yaitu Home)
//   int _selectedIndex = 0;

//   // Daftar halaman yang akan dirender berdasarkan indeks
//   final List<Widget> _pages = [
//     const HomePage(),
//     const OrderPage(),
//     const EventPage(),
//     const ProfilePage(),
//   ];

//   // Fungsi saat salah satu menu di bawah ditekan
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Body akan berubah sesuai dengan index yang aktif
//       body: _pages[_selectedIndex],

//       // Komponen Navigasi Bawah
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed, // Mencegah icon bergeser/animasi aneh
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.black, // Tema monokrom elegan khas e-commerce
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.white,
//         elevation: 10,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag_outlined),
//             activeIcon: Icon(Icons.shopping_bag),
//             label: 'Orders',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.confirmation_number_outlined),
//             activeIcon: Icon(Icons.confirmation_number),
//             label: 'Events',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'order_page.dart';
// import 'event_page.dart';
// import 'profile_page.dart';
// import 'auth/login_page.dart'; // [BARU] Import Halaman Login

// class MainNavigation extends StatefulWidget {
//   const MainNavigation({super.key});

//   @override
//   State<MainNavigation> createState() => _MainNavigationState();
// }

// class _MainNavigationState extends State<MainNavigation> {
//   int _selectedIndex = 0;

//   // 👇 [BARU] Dummy state untuk status otentikasi.
//   // Nanti ini akan diganti dengan BLoC Auth / pengecekan Token di SharedPreferences
//   final bool _isLoggedIn = false;

//   final List<Widget> _pages = [
//     const HomePage(),
//     const OrderPage(),
//     const EventPage(),
//     const ProfilePage(),
//   ];

//   // 👇 [PERBAIKAN] Logika pencegatan rute 👇
//   void _onItemTapped(int index) {
//     // Index 1 adalah Orders, Index 3 adalah Profile
//     if ((index == 1 || index == 3) && !_isLoggedIn) {
//       // Tampilkan Pop-up dan JANGAN pindah halaman
//       _showLoginBottomSheet(context);
//     } else {
//       // Jika halaman aman (Home/Events) atau user sudah login, pindah halaman
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   // 👇 [BARU] Desain Pop-Up Bawah yang Premium 👇
//   void _showLoginBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor:
//           Colors.transparent, // Transparan agar bisa pakai desain melengkung
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(24.0),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // Sesuaikan tinggi dengan konten
//             children: [
//               // Garis handle di atas
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(bottom: 24),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               const Icon(Icons.lock_outline, size: 56, color: Colors.black87),
//               const SizedBox(height: 16),
//               const Text(
//                 'Akses Terbatas',
//                 style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.w900,
//                     fontFamily: 'serif'),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Silakan login atau daftar terlebih dahulu untuk melihat riwayat pesanan dan mengatur profil Anda.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
//               ),
//               const SizedBox(height: 32),
//               // Tombol Login
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     elevation: 0,
//                   ),
//                   onPressed: () {
//                     // Tutup pop-up dulu
//                     Navigator.pop(context);
//                     // Pindah ke halaman Login
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const LoginPage()),
//                     );
//                   },
//                   child: const Text('Login ke Akun Saya',
//                       style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1)),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               // Tombol Batal
//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   style: TextButton.styleFrom(
//                     foregroundColor: Colors.black54,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   onPressed: () => Navigator.pop(context), // Tutup pop-up
//                   child: const Text('Mungkin Nanti',
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(
//                   height:
//                       16), // Jarak ekstra di bawah untuk area safe (poni iPhone/Android)
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.white,
//         elevation: 10,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_bag_outlined),
//               activeIcon: Icon(Icons.shopping_bag),
//               label: 'Orders'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.confirmation_number_outlined),
//               activeIcon: Icon(Icons.confirmation_number),
//               label: 'Events'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // [BARU] Import Bloc
import 'home_page.dart';
import 'order_page.dart';
import 'event_page.dart';
import 'profile_page.dart';
import 'auth/login_page.dart';
import '../blocs/auth/auth_bloc.dart'; // [BARU] Import AuthBloc
import '../blocs/auth/auth_state.dart'; // [BARU] Import AuthState

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OrderPage(),
    const EventPage(),
    const ProfilePage(),
  ];

  // 👇 PERBAIKAN: Baca status login langsung dari BLoC 👇
  void _onItemTapped(int index) {
    // Mengecek apakah state AuthBloc saat ini adalah AuthAuthenticated (sudah login)
    final bool isLoggedIn = context.read<AuthBloc>().state is AuthAuthenticated;

    // Index 1 adalah Orders, Index 3 adalah Profile
    if ((index == 1 || index == 3) && !isLoggedIn) {
      _showLoginBottomSheet(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Icon(Icons.lock_outline, size: 56, color: Colors.black87),
              const SizedBox(height: 16),
              const Text(
                'Akses Terbatas',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan login atau daftar terlebih dahulu untuk melihat riwayat pesanan dan mengatur profil Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: const Text('Login ke Akun Saya',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mungkin Nanti',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 👇 PERBAIKAN: Membungkus dengan BlocListener untuk Auto-Kick jika Token Habis 👇
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Jika user tiba-tiba menjadi tidak terotentikasi saat berada di tab Orders/Profile
        if (state is! AuthAuthenticated &&
            (_selectedIndex == 1 || _selectedIndex == 3)) {
          setState(() {
            _selectedIndex = 0; // Lempar kembali ke tab Home
          });
        }
      },
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 10,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                activeIcon: Icon(Icons.shopping_bag),
                label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                activeIcon: Icon(Icons.confirmation_number),
                label: 'Events'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
