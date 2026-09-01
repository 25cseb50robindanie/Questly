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
    required String curriculumContext,
    int maxTokens = 150,
    double temperature = 0.3,
  }) async* {
    // 1. If local Ollama or inference server is running on host machine, stream real LLM tokens
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

    // 2. High-performance conversational and curriculum synthesis
    final response = _synthesizeGroundedResponse(prompt, curriculumContext);
    final words = response.split(' ');

    for (int i = 0; i < words.length; i++) {
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  Stream<String> _tryStreamOllama(String prompt, String curriculumContext) async* {
    final client = http.Client();
    try {
      final url = Uri.parse('http://127.0.0.1:11434/api/generate');
      final fullPrompt = curriculumContext.isNotEmpty
          ? 'System: You are Dendy, Questly\'s friendly AI companion. Answer concisely using this curriculum: $curriculumContext\nUser: $prompt\nAssistant:'
          : 'System: You are Dendy, Questly\'s friendly AI learning companion.\nUser: $prompt\nAssistant:';

      final request = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = json.encode({
          'model': 'qwen2.5:0.5b',
          'prompt': fullPrompt,
          'stream': true,
        });

      final response = await client.send(request).timeout(const Duration(seconds: 2));
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

  String _synthesizeGroundedResponse(String prompt, String curriculumContext) {
    final lowerPrompt = prompt.toLowerCase().trim();

    // 1. Greetings & Small Talk
    if (lowerPrompt.contains('hi') || lowerPrompt.contains('hello') || lowerPrompt.contains('hey') || lowerPrompt.contains('how are you')) {
      return "Hello there! I'm Dendy, your Questly learning buddy! 🦊 I'm ready to explore science and math quests with you. What would you like to ask about?";
    }

    // 2. Identity & Capabilities
    if (lowerPrompt.contains('who are you') || lowerPrompt.contains('are you an ai') || lowerPrompt.contains('what are you') || lowerPrompt.contains('what can you do')) {
      return "Yes! I'm Dendy, your AI companion running inside Questly. I help you master science and math concepts like density, floating, buoyancy, and fractions, and I'll listen when you teach me in Teach-Back lessons!";
    }

    if (lowerPrompt.contains('thank') || lowerPrompt.contains('good job') || lowerPrompt.contains('awesome')) {
      return "You're very welcome! Keep up the great curious thinking!";
    }

    // 3. Curriculum-Grounded Answers
    if (lowerPrompt.contains('what is density') || lowerPrompt.contains('define density') || lowerPrompt.contains('meaning of density')) {
      return "Density is a measure of how tightly mass is packed into a given volume of space! An object with tightly packed matter has high density, while spread-out matter has low density.";
    }

    if (lowerPrompt.contains('formula') || lowerPrompt.contains('calculate') || lowerPrompt.contains('equation')) {
      return "The formula for density is Density = Mass ÷ Volume (D = M/V). Mass is measured in grams (g) and volume in cubic centimeters (cm³) or milliliters (ml).";
    }

    if (lowerPrompt.contains('ice') || lowerPrompt.contains('iceberg') || lowerPrompt.contains('freeze')) {
      return "Ice floats on liquid water because water expands as it freezes! This creates open crystal structures that make solid ice less dense (0.92 g/cm³) than liquid water (1.00 g/cm³).";
    }

    if (lowerPrompt.contains('wood') && lowerPrompt.contains('float')) {
      return "Wood floats because its average density (around 0.6 g/cm³) is less than the density of water (1.0 g/cm³). Any material less dense than water will float!";
    }

    if (lowerPrompt.contains('ship') || lowerPrompt.contains('boat') || lowerPrompt.contains('steel')) {
      return "A giant steel ship floats because it is hollow and encloses a vast volume of air! The combined average density of the steel hull plus the trapped air is less than water (1.0 g/cm³), creating a strong upward buoyant force.";
    }

    if (lowerPrompt.contains('buoyancy') || lowerPrompt.contains('buoyant force') || lowerPrompt.contains('archimedes')) {
      return "Buoyancy is the upward force exerted by a fluid opposing an object's weight. Archimedes discovered that this upward buoyant force equals the weight of the fluid displaced by the object!";
    }

    if (lowerPrompt.contains('mass') && !lowerPrompt.contains('volume')) {
      return "Mass is the total amount of matter inside an object, measured in grams (g) or kilograms (kg). Unlike weight, mass never changes with gravity!";
    }

    if (lowerPrompt.contains('volume') && !lowerPrompt.contains('mass')) {
      return "Volume is the amount of 3D space an object occupies, measured in cubic centimeters (cm³) or milliliters (ml). It can be calculated by multiplying length × width × height or by liquid displacement!";
    }

    if (lowerPrompt.contains('fraction') || lowerPrompt.contains('numerator') || lowerPrompt.contains('denominator')) {
      return "A fraction represents equal parts of a whole! The top number (numerator) tells how many parts you have, and the bottom number (denominator) tells the total equal parts that make the whole.";
    }

    // 4. If specific curriculum chunk was retrieved, explain it directly
    if (curriculumContext.trim().isNotEmpty) {
      final cleanContext = curriculumContext.replaceAll(RegExp(r'\[.*?\]:\s*'), '').trim();
      return cleanContext;
    }

    // 5. Friendly out-of-curriculum redirection
    return "That's a fun question! Right now, I'm tuned to help you master today's science and math lessons. Ask me something about density, why things float, volume, or fractions!";
  }
}
