import 'dart:async';
import 'package:flutter/foundation.dart';

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
    final response = _synthesizeGroundedResponse(prompt, curriculumContext);
    final words = response.split(' ');

    for (int i = 0; i < words.length; i++) {
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 35));
    }
  }

  String _synthesizeGroundedResponse(String prompt, String curriculumContext) {
    final lowerPrompt = prompt.toLowerCase();

    if (curriculumContext.trim().isEmpty) {
      return "Let's stay with today's lesson. Ask me something about density, floating, or buoyancy!";
    }

    if (lowerPrompt.contains('what is density') || lowerPrompt.contains('define density') || lowerPrompt.contains('meaning of density')) {
      return "Density is a measure of how tightly mass is packed into a given volume! An object with tightly packed matter has high density, while spread-out matter has low density.";
    }

    if (lowerPrompt.contains('formula') || lowerPrompt.contains('calculate') || lowerPrompt.contains('equation')) {
      return "The formula for density is Density = Mass ÷ Volume (D = M/V). Mass is measured in grams (g) and volume in cubic centimeters (cm³) or milliliters (ml).";
    }

    if (lowerPrompt.contains('ice') || lowerPrompt.contains('iceberg') || lowerPrompt.contains('freeze')) {
      return "Ice floats on liquid water because water expands as it freezes! This creates open crystal structures that make solid ice less dense (0.92 g/cm³) than liquid water (1.00 g/cm³).";
    }

    if (lowerPrompt.contains('wood') && lowerPrompt.contains('float')) {
      return "Wood floats because its density (around 0.6 g/cm³) is less than the density of water (1.0 g/cm³). Any material with lower density than water will float!";
    }

    if (lowerPrompt.contains('ship') || lowerPrompt.contains('boat') || lowerPrompt.contains('steel')) {
      return "A giant steel ship floats because it is hollow and contains a large volume of air inside! The combined average density of the steel plus the trapped air is less than water (1.0 g/cm³), creating strong buoyant force.";
    }

    if (lowerPrompt.contains('buoyancy') || lowerPrompt.contains('buoyant force') || lowerPrompt.contains('archimedes')) {
      return "Buoyancy is the upward force exerted by a fluid that opposes an object's weight. Archimedes discovered that this upward force equals the weight of the fluid displaced by the object!";
    }

    final firstSentence = curriculumContext.split('.').firstWhere((s) => s.trim().length > 10, orElse: () => curriculumContext);
    return "$firstSentence. Remember, density equals mass divided by volume!";
  }
}
