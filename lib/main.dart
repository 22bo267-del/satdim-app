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
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36')
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) {
            setState(() => _isLoading = false);
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
          onWebResourceError: (error) {
            debugPrint('Web error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://satdim.az'));
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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