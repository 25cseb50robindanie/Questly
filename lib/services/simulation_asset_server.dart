import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class SimulationAssetServer {
  static SimulationAssetServer? _instance;
  static SimulationAssetServer get instance => _instance ??= SimulationAssetServer._();

  HttpServer? _server;
  int? _port;
  Completer<int>? _startingCompleter;

  SimulationAssetServer._();

  Future<int> getPort() async {
    if (_port != null) return _port!;
    if (_startingCompleter != null) return _startingCompleter!.future;

    _startingCompleter = Completer<int>();

    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      _port = _server!.port;

      _server!.listen(_handleRequest, onError: (e) {
        // Log server error if any
      });

      _startingCompleter!.complete(_port);
      return _port!;
    } catch (e) {
      _startingCompleter!.completeError(e);
      _startingCompleter = null;
      rethrow;
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final response = request.response;

    // Add permissive CORS headers for local simulation assets
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      response.statusCode = HttpStatus.ok;
      await response.close();
      return;
    }

    String path = request.uri.path;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    if (path.isEmpty) {
      path = 'fraction_module/index.html';
    }

    String assetPath;
    if (path.startsWith('assets/simulations/')) {
      assetPath = path;
    } else if (path.startsWith('simulations/')) {
      assetPath = 'assets/$path';
    } else {
      assetPath = 'assets/simulations/$path';
    }

    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

      final mimeType = _resolveMimeType(assetPath);
      response.headers.set('Content-Type', mimeType);
      response.statusCode = HttpStatus.ok;
      response.add(bytes);
      await response.close();
    } catch (e) {
      response.statusCode = HttpStatus.notFound;
      response.write('Asset not found: $assetPath');
      await response.close();
    }
  }

  String _resolveMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.html') || lower.endsWith('.htm')) {
      return 'text/html; charset=utf-8';
    }
    if (lower.endsWith('.js') || lower.endsWith('.mjs')) {
      return 'application/javascript; charset=utf-8';
    }
    if (lower.endsWith('.css')) {
      return 'text/css; charset=utf-8';
    }
    if (lower.endsWith('.json')) {
      return 'application/json; charset=utf-8';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.svg')) {
      return 'image/svg+xml';
    }
    if (lower.endsWith('.ico')) {
      return 'image/x-icon';
    }
    if (lower.endsWith('.ttf')) {
      return 'font/ttf';
    }
    if (lower.endsWith('.woff')) {
      return 'font/woff';
    }
    if (lower.endsWith('.woff2')) {
      return 'font/woff2';
    }
    if (lower.endsWith('.mp3')) {
      return 'audio/mpeg';
    }
    if (lower.endsWith('.wav')) {
      return 'audio/wav';
    }
    return 'application/octet-stream';
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _port = null;
    _startingCompleter = null;
  }
}
