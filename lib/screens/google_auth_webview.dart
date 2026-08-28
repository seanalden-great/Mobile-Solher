import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import 'main_navigation.dart';

class GoogleAuthWebView extends StatefulWidget {
  const GoogleAuthWebView({super.key});

  @override
  State<GoogleAuthWebView> createState() => _GoogleAuthWebViewState();
}

class _GoogleAuthWebViewState extends State<GoogleAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _isLoading = false),
          onNavigationRequest: (request) {
            // Mencegat URL jika mengandung rute callback ke frontend Vue
            if (request.url.contains('/auth/callback?token=')) {
              _handleCallback(request.url);
              return NavigationDecision.prevent; // Hentikan WebView
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://back.solher.co.id/api/auth/google/redirect'));
  }

  void _handleCallback(String url) {
    try {
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'];
      final userStr = uri.queryParameters['user'];

      if (token != null && userStr != null) {
        // Tembak token dan data ke BLoC
        context.read<AuthBloc>().add(GoogleAuthSuccessEvent(
              token: token,
              userJsonString: userStr,
            ));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login Google Berhasil!'),
              backgroundColor: Colors.green),
        );

        // Arahkan masuk ke aplikasi utama
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      } else {
        _showError();
      }
    } catch (e) {
      _showError();
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Gagal terhubung dengan Google.'),
          backgroundColor: Colors.red),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login securely with Google',
            style: TextStyle(fontFamily: 'serif', fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        ],
      ),
    );
  }
}
