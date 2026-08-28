import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/simulation_asset_server.dart';

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
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant InteractiveSimView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simulationPath != widget.simulationPath) {
      _reloadSimulation();
    }
  }

  Future<void> _reloadSimulation() async {
    if (_controller == null) {
      _initWebView();
      return;
    }
    try {
      final port = await SimulationAssetServer.instance.getPort();
      String path = widget.simulationPath;
      if (!path.startsWith('/')) {
        path = '/$path';
      }
      final url = 'http://127.0.0.1:$port$path';
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _controller?.loadRequest(Uri.parse(url));
    } catch (_) {}
  }

  Future<void> _initWebView() async {
    try {
      final port = await SimulationAssetServer.instance.getPort();
      String path = widget.simulationPath;
      if (!path.startsWith('/')) {
        path = '/$path';
      }

      final url = 'http://127.0.0.1:$port$path';

      final controller = WebViewController()
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
            onPageFinished: (String loadedUrl) {
              // Inject two-way postMessage bridge for embedded simulations
              _controller?.runJavaScript('''
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
            onWebResourceError: (WebResourceError error) {
              if (mounted && _isLoading && (error.isForMainFrame ?? true)) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.description;
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(url));

      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                'Unable to load simulation: ${_errorMessage ?? ""}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _initWebView();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        if (_controller != null) WebViewWidget(controller: _controller!),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.amberAccent),
          ),
      ],
    );
  }
}
