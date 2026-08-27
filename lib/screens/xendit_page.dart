import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'success_page.dart';
import 'failed_page.dart';

class XenditPage extends StatefulWidget {
  final String checkoutUrl;

  const XenditPage({super.key, required this.checkoutUrl});

  @override
  State<XenditPage> createState() => _XenditPageState();
}

class _XenditPageState extends State<XenditPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();

            // 👇 DETEKSI CALLBACK DARI XENDIT (Sesuaikan string dengan URL sukses di Laravel Anda)
            if (url.contains('payment-success') || url.contains('success')) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const SuccessPage()));
              return NavigationDecision
                  .prevent; // Hentikan WebView memuat halaman
            } else if (url.contains('payment-failed') ||
                url.contains('failure')) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const FailedPage()));
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pembayaran Aman',
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // Jika pengguna klik tombol close X, anggap batal/gagal
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const FailedPage()));
          },
        ),
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
