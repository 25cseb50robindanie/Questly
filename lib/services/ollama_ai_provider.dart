import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_provider.dart';

class OllamaAIProvider implements AIProvider {
  @override
  Stream<String> streamResponse(String prompt, String baseUrl, String modelName) async* {
    final client = http.Client();
    final url = Uri.parse('$baseUrl/api/generate');

    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = json.encode({
        'model': modelName,
        'prompt': prompt,
        'stream': true,
      });

    try {
      final response = await client.send(request).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        yield "Error: AI server returned status code ${response.statusCode}.";
        client.close();
        return;
      }

      // Read streamed responses line-by-line
      final stream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in stream) {
        if (line.trim().isEmpty) continue;
        try {
          final decoded = json.decode(line) as Map<String, dynamic>;
          final token = decoded['response'] as String? ?? '';
          if (token.isNotEmpty) {
            yield token;
          }
        } catch (_) {
          // ignore malformed chunks
        }
      }
    } on TimeoutException {
      yield "Error: AI server response timed out.";
    } catch (e) {
      yield "Error: Unable to reach the local AI server ($e).";
    } finally {
      client.close();
    }
  }

  @override
  Future<bool> isAvailable(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableModels(String baseUrl) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final list = decoded['models'] as List<dynamic>? ?? [];
        return list
            .map((m) => (m as Map<String, dynamic>)['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // return empty
    }
    return [];
  }
}
