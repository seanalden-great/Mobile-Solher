// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// // Import BLoC dan Repository Autentikasi
// import 'blocs/auth/auth_bloc.dart';
// import 'repositories/auth_repository.dart';

// // Import layar utama
// import 'screens/main_navigation.dart';

// void main() {
//   runApp(const SolherApp());
// }

// class SolherApp extends StatelessWidget {
//   const SolherApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Membungkus aplikasi dengan MultiBlocProvider agar State BLoC bersifat Global
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthBloc>(
//           create: (context) => AuthBloc(
//             authRepository: AuthRepository(),
//           ),
//         ),
//         // Nanti Anda bisa menambahkan CartBloc, ThemeBloc, dll di sini
//       ],
//       child: MaterialApp(
//         title: 'Solher',
//         debugShowCheckedModeBanner: false, // Menghilangkan pita merah "DEBUG" di pojok kanan atas
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
//           useMaterial3: true,
//           // Anda bisa menambahkan konfigurasi font global di sini nantinya
//         ),
//         // Aplikasi langsung memuat Navigasi Utama saat pertama kali dibuka
//         home: const MainNavigation(),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// // Import BLoC dan Repository Autentikasi
// import 'package:solher_mobile/blocs/auth/auth_bloc.dart';
// import 'package:solher_mobile/blocs/auth/auth_event.dart';
// import 'package:solher_mobile/blocs/cart/cart_bloc.dart';
// import 'package:solher_mobile/blocs/order/order_bloc.dart';
// import 'package:solher_mobile/repositories/auth_repository.dart';
// import 'package:solher_mobile/repositories/cart_repository.dart';
// import 'package:solher_mobile/repositories/order_repository.dart';

// // Import layar utama
// import 'package:solher_mobile/screens/main_navigation.dart';

// void main() {
//   runApp(const SolherApp());
// }

// class SolherApp extends StatelessWidget {
//   const SolherApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthBloc>(
//           create: (context) => AuthBloc(
//             authRepository: AuthRepository(),
//           )..add(
//               CheckLoginStatusEvent()), // 👇 [PENTING] Eksekusi cek sesi di sini! 👇
//         ),
//         BlocProvider<OrderBloc>(
//           create: (context) => OrderBloc(
//             orderRepository: OrderRepository(),
//           ),
//         ),
//         BlocProvider<CartBloc>(
//             create: (context) => CartBloc(
//               cartRepository: CartRepository(),
//           )
//         )
//       ],
//       child: MaterialApp(
//         title: 'Solher',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
//           useMaterial3: true,
//         ),
//         home: const MainNavigation(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// 👇 [BARU] Import HydratedBloc dan PathProvider
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// Import BLoC dan Repository
import 'package:solher_mobile/blocs/auth/auth_bloc.dart';
import 'package:solher_mobile/blocs/auth/auth_event.dart';
import 'package:solher_mobile/blocs/cart/cart_bloc.dart';
import 'package:solher_mobile/blocs/order/order_bloc.dart';
import 'package:solher_mobile/repositories/auth_repository.dart';
import 'package:solher_mobile/repositories/cart_repository.dart';
import 'package:solher_mobile/repositories/order_repository.dart';

// Import layar utama
import 'package:solher_mobile/screens/main_navigation.dart';
import 'package:solher_mobile/utils/notification_controller.dart';

// 👇 PERBAIKAN: Ubah main() menjadi async 👇
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Wajib ada untuk akses memori native

  // Inisialisasi Storage Lokal sebelum App berjalan
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  // 👇 INISIALISASI NOTIFIKASI 👇
  await NotificationController.initializeLocalNotifications();
  await NotificationController.startListeningNotificationEvents();

  runApp(const SolherApp());
}

class SolherApp extends StatelessWidget {
  const SolherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          )..add(CheckLoginStatusEvent()),
        ),
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(
            orderRepository: OrderRepository(),
          ),
        ),
        BlocProvider<CartBloc>(
            create: (context) => CartBloc(
                  cartRepository: CartRepository(),
                ))
      ],
      child: MaterialApp(
        title: 'Solher',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
          useMaterial3: true,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
