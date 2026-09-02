import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LlamaEngine {
  static final LlamaEngine _instance = LlamaEngine._internal();
  factory LlamaEngine() => _instance;
  LlamaEngine._internal();

  bool _isModelLoaded = false;
  bool _isLoadingModel = false;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoadingModel => _isLoadingModel;

  Future<void> initializeModel({String modelAssetName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf'}) async {
    _isModelLoaded = true;
  }

  Stream<String> generateStreaming({
    required String prompt,
    String? userQuery,
    required String curriculumContext,
    int maxTokens = 150,
    double temperature = 0.3,
  }) async* {
    // 1. If local Ollama server is running on localhost (11434), stream real LLM tokens
    bool usedServer = false;
    try {
      final ollamaStream = _tryStreamOllama(prompt, curriculumContext);
      await for (final token in ollamaStream) {
        usedServer = true;
        yield token;
      }
    } catch (_) {
      usedServer = false;
    }

    if (usedServer) return;

    // 2. Clear notification explaining Web vs Android
    final notice = "🦊 [Dendy Local AI Notice]:\n\n"
        "You are currently viewing Questly in Google Chrome.\n"
        "Google Chrome is a web browser and cannot run native C++ neural network files (.gguf) directly on the web page.\n\n"
        "• To run the REAL 100% offline Qwen 2.5 Neural Network: Install Questly-Offline-AI.apk on your Android phone!\n"
        "• To test in Chrome: Run 'ollama run qwen2.5:0.5b' in your terminal and Chrome will connect directly.";
    
    final words = notice.split(' ');
    for (int i = 0; i < words.length; i++) {
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  Stream<String> _tryStreamOllama(String prompt, String curriculumContext) async* {
    final client = http.Client();
    try {
      final url = Uri.parse('http://127.0.0.1:11434/api/generate');
      final fullPrompt = prompt.contains('<|im_start|>')
          ? prompt
          : (curriculumContext.isNotEmpty
              ? 'System: You are Dendy, Questly\'s friendly AI companion. Answer concisely using this curriculum: $curriculumContext\nUser: $prompt\nAssistant:'
              : 'System: You are Dendy, Questly\'s friendly AI learning companion.\nUser: $prompt\nAssistant:');

      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = json.encode({
          'model': 'qwen2.5:0.5b',
          'prompt': fullPrompt,
          'stream': true,
        });

      final response = await client.send(request).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());
        await for (final line in stream) {
          if (line.trim().isEmpty) continue;
          try {
            final data = json.decode(line) as Map<String, dynamic>;
            final token = data['response'] as String? ?? '';
            if (token.isNotEmpty) yield token;
          } catch (_) {}
        }
      }
    } finally {
      client.close();
    }
  }
}
