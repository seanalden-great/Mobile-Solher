// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/auth/auth_bloc.dart';
// import '../../blocs/auth/auth_event.dart';
// import '../../blocs/auth/auth_state.dart';
// import '../main_navigation.dart';
// import 'register_page.dart';
// import 'forgot_password_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

// void _handleLogin() {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Email dan Password wajib diisi'),
//             backgroundColor: Colors.red),
//       );
//       return;
//     }

//     // Menembak event login ke BLoC dengan Secret Key API Mobile
//     context.read<AuthBloc>().add(LoginRequested(
//           email: email,
//           password: password,
//           captchaToken:
//               'mobile_solher_rahasia_123!@#', // Kunci yang sama dengan Backend
//         ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE5E7EB),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(40.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(48),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             // 👇 BlocConsumer memantau perubahan AuthState 👇
//             child: BlocConsumer<AuthBloc, AuthState>(
//               listener: (context, state) {
//                 if (state is AuthError) {
//                   // Munculkan alert gagal
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//                   );
//                 } else if (state is AuthAuthenticated) {
//                   // Munculkan alert sukses & pindah halaman
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Login Berhasil!'), backgroundColor: Colors.green),
//                   );
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const MainNavigation()),
//                     (route) => false,
//                   );
//                 }
//               },
//               builder: (context, state) {
//                 final isLoading = state is AuthLoading;

//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset('assets/images/solherbrandbook.png', height: 60),
//                     const SizedBox(height: 32),
//                     const Text('LOGIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
//                     const SizedBox(height: 32),

//                     _buildTextField('Email', _emailController, false),
//                     const SizedBox(height: 24),
//                     _buildTextField('Password', _passwordController, true),
//                     const SizedBox(height: 32),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0066FF),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                         ),
//                         onPressed: isLoading ? null : _handleLogin,
//                         child: isLoading
//                             ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//                       ),
//                     ),

//                     const SizedBox(height: 16),
//                     TextButton(
//                       onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
//                       child: const Text('Forgot your password?', style: TextStyle(color: Colors.grey, fontSize: 12)),
//                     ),

//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("Don't have any account? ", style: TextStyle(fontSize: 12, color: Colors.black54)),
//                         GestureDetector(
//                           onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
//                           child: const Text('Register here', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066FF))),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           obscureText: isPassword,
//           decoration: const InputDecoration(
//             filled: true,
//             fillColor: Color(0xFFD9D9D9),
//             border: InputBorder.none,
//             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF0066FF), width: 1)),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solher_mobile/screens/google_auth_webview.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../main_navigation.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // void _handleLogin() {
  //   final email = _emailController.text.trim();
  //   final password = _passwordController.text.trim();

  //   if (email.isEmpty || password.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text('Email dan Password wajib diisi'),
  //           backgroundColor: Colors.red),
  //     );
  //     return;
  //   }

  //   context.read<AuthBloc>().add(LoginRequested(
  //         email: email,
  //         password: password,
  //         captchaToken: 'mobile_solher_rahasia_123!@#',
  //       ));
  // }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email dan Password wajib diisi'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Pastikan di dalam AuthBloc Anda mengubah endpoint API yang ditembak
    // menjadi: /api/mobile/login
    context.read<AuthBloc>().add(LoginRequested(
          email: email,
          password: password,
          // 👇 Ganti dari captchaToken menjadi appSecret 👇
          appSecret: 'SOLHER_MOBILE_SECRET_2026_XYZ!',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // 👇 PERBAIKAN: Gunakan SafeArea agar dimensi tidak bertabrakan dengan Notch HP
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red),
                    );
                  } else if (state is AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Login Berhasil!'),
                          backgroundColor: Colors.green),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                      (route) => false,
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/solherbrandbook.png',
                          height: 60),
                      const SizedBox(height: 32),
                      const Text('LOGIN',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                      const SizedBox(height: 32),

                      _buildTextField('Email', _emailController, false),
                      const SizedBox(height: 24),
                      _buildTextField('Password', _passwordController, true),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)), // Lebih halus
                          ),
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('LOGIN',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5)),
                        ),
                      ),

                      // 👇 AREA GOOGLE SIGN IN 👇
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('ATAU',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    letterSpacing: 1.5)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const GoogleAuthWebView()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 👇 PERBAIKAN: Mengganti Image.network yang membikin Freeze dengan Icon Bawaan
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text('Lanjutkan dengan Google',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      // 👆 ======================= 👆

                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage())),
                        child: const Text('Forgot your password?',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have any account? ",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterPage())),
                            child: const Text('Register here',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0066FF))),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                const Color(0xFFF3F4F6), // Warna abu-abu yang lebih modern
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF0066FF), width: 1.5)),
          ),
        ),
      ],
    );
  }
}
