import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InteractiveSimView extends StatefulWidget {
  final String simulationPath;
  final String viewKey;
  final void Function(Map<String, dynamic> data)? onMessage;

  const InteractiveSimView({
    Key? key,
    required this.simulationPath,
    required this.viewKey,
    this.onMessage,
  }) : super(key: key);

  @override
  State<InteractiveSimView> createState() => _InteractiveSimViewState();
}

class _InteractiveSimViewState extends State<InteractiveSimView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    String assetPath = widget.simulationPath;
    if (assetPath.startsWith('/')) {
      assetPath = assetPath.substring(1);
    }
    if (!assetPath.startsWith('assets/simulations/')) {
      assetPath = 'assets/simulations/$assetPath';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'QuestlyBridge',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data is Map) {
              widget.onMessage?.call(Map<String, dynamic>.from(data));
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Inject two-way postMessage bridge for embedded simulations
            _controller.runJavaScript('''
              (function() {
                var handler = function(data) {
                  try {
                    if (window.QuestlyBridge) {
                      window.QuestlyBridge.postMessage(typeof data === 'object' ? JSON.stringify(data) : String(data));
                    }
                  } catch(err) {}
                };
                window.parent = { postMessage: handler };
                window.addEventListener('message', function(e) {
                  handler(e.data);
                });
              })();
            ''');
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadFlutterAsset(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.amberAccent),
          ),
      ],
    );
  }
}
