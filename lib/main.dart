import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SatdimApp());
}

class SatdimApp extends StatelessWidget {
  const SatdimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satdim.az',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
      ),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const platform = MethodChannel('com.satdim.app/security');

  @override
  void initState() {
    super.initState();
    _enableSecureFlag();
    _initWebView();
  }

  Future<void> _enableSecureFlag() async {
    try {
      await platform.invokeMethod('enableSecureFlag');
    } catch (e) {
      debugPrint('Secure flag error: $e');
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            // Disable right-click and selection via JS
            _controller.runJavaScript('''
              document.addEventListener('contextmenu', function(e) {
                e.preventDefault();
                return false;
              });
              document.addEventListener('selectstart', function(e) {
                e.preventDefault();
                return false;
              });
              document.addEventListener('copy', function(e) {
                e.preventDefault();
                return false;
              });
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://satdim.az'));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
