// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/auth/auth_bloc.dart';
// import '../../blocs/auth/auth_event.dart';
// import '../../blocs/auth/auth_state.dart';
// import 'login_page.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final TextEditingController _emailCtrl = TextEditingController();
//   final TextEditingController _firstNameCtrl = TextEditingController();
//   final TextEditingController _lastNameCtrl = TextEditingController();
//   final TextEditingController _passwordCtrl = TextEditingController();
//   final TextEditingController _confirmPasswordCtrl = TextEditingController();

//   void _handleRegister() {
//     final password = _passwordCtrl.text;
//     final confirmPassword = _confirmPasswordCtrl.text;

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Passwords do not match!'), backgroundColor: Colors.red),
//       );
//       return;
//     }

//     if (password.length < 8) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password must be at least 8 characters long.'), backgroundColor: Colors.orange),
//       );
//       return;
//     }

//     // Tembak event registrasi ke BLoC
//     context.read<AuthBloc>().add(RegisterRequested(
//           firstName: _firstNameCtrl.text.trim(),
//           lastName: _lastNameCtrl.text.trim(),
//           email: _emailCtrl.text.trim(),
//           password: password,
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
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(40.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(48),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             // 👇 Pantau BLoC untuk Pendaftaran 👇
//             child: BlocConsumer<AuthBloc, AuthState>(
//               listener: (context, state) {
//                 if (state is AuthError) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//                   );
//                 } else if (state is AuthActionSuccess) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text(state.message), backgroundColor: Colors.green),
//                   );
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const LoginPage()),
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
//                     const Text('REGISTER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
//                     const SizedBox(height: 32),
                    
//                     _buildTextField('Email', _emailCtrl, false),
//                     const SizedBox(height: 16),
//                     _buildTextField('First Name', _firstNameCtrl, false),
//                     const SizedBox(height: 16),
//                     _buildTextField('Last Name', _lastNameCtrl, false),
//                     const SizedBox(height: 16),
//                     _buildTextField('Password', _passwordCtrl, true),
//                     const SizedBox(height: 16),
//                     _buildTextField('Confirm Password', _confirmPasswordCtrl, true),
//                     const SizedBox(height: 32),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF0066FF),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
//                         ),
//                         onPressed: isLoading ? null : _handleRegister,
//                         child: isLoading
//                             ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : const Text('REGISTER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
//                       ),
//                     ),

//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("Already have an account? ", style: TextStyle(fontSize: 12, color: Colors.black54)),
//                         GestureDetector(
//                           onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
//                           child: const Text('Login here', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0066FF))),
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
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  void _handleRegister() {
    final password = _passwordCtrl.text;
    final confirmPassword = _confirmPasswordCtrl.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 8 characters long.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // Tembak event registrasi ke BLoC
    context.read<AuthBloc>().add(RegisterRequested(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: password,
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
      // 👇 PERBAIKAN: Gunakan SafeArea
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                border: Border.all(color: Colors.grey.shade300),
              ),
              // 👇 Pantau BLoC untuk Pendaftaran 👇
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red),
                    );
                  } else if (state is AuthActionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.green),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
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
                      const Text('REGISTER',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                      const SizedBox(height: 32),

                      _buildTextField('Email', _emailCtrl, false),
                      const SizedBox(height: 16),
                      _buildTextField('First Name', _firstNameCtrl, false),
                      const SizedBox(height: 16),
                      _buildTextField('Last Name', _lastNameCtrl, false),
                      const SizedBox(height: 16),
                      _buildTextField('Password', _passwordCtrl, true),
                      const SizedBox(height: 16),
                      _buildTextField(
                          'Confirm Password', _confirmPasswordCtrl, true),
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
                          onPressed: isLoading ? null : _handleRegister,
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('REGISTER',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5)),
                        ),
                      ),

                      // 👇 AREA GOOGLE SIGN UP 👇
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
                              // Ikon G anti-freeze
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
                              const Text('Daftar dengan Google',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      // 👆 ======================= 👆

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage())),
                            child: const Text('Login here',
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

  // 👇 Desain Input disamakan dengan Login Page
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
            fillColor: const Color(0xFFF3F4F6),
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
