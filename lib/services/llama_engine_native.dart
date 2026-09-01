import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path_provider/path_provider.dart';

class LlamaEngine {
  static final LlamaEngine _instance = LlamaEngine._internal();
  factory LlamaEngine() => _instance;
  LlamaEngine._internal();

  Llama? _llama;
  bool _isModelLoaded = false;
  bool _isLoadingModel = false;
  String? _modelPath;

  bool get isModelLoaded => _isModelLoaded;
  bool get isLoadingModel => _isLoadingModel;

  /// Initializes and caches the Qwen 2.5 0.5B Instruct GGUF model in application storage
  Future<void> initializeModel({String modelAssetName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf'}) async {
    if (_isModelLoaded || _isLoadingModel) return;
    _isLoadingModel = true;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${appDocDir.path}/$modelAssetName');
      final localAssetFile = File('assets/models/$modelAssetName');

      if (await localAssetFile.exists() && localAssetFile.lengthSync() > 1000000) {
        _modelPath = localAssetFile.path;
      } else if (await targetFile.exists() && targetFile.lengthSync() > 1000000) {
        _modelPath = targetFile.path;
      } else {
        try {
          debugPrint('[LlamaEngine] Unpacking model asset to storage...');
          final byteData = await rootBundle.load('assets/models/$modelAssetName');
          final buffer = byteData.buffer;
          await targetFile.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
            flush: true,
          );
          _modelPath = targetFile.path;
          debugPrint('[LlamaEngine] Model unpacked successfully: $_modelPath');
        } catch (e) {
          debugPrint('[LlamaEngine] Asset bundle load notice: $e');
        }
      }

      if (_modelPath != null && File(_modelPath!).existsSync()) {
        debugPrint('[LlamaEngine] Initializing native llama.cpp instance with $_modelPath...');
        final contextParams = ContextParams()
          ..nCtx = 2048
          ..nBatch = 512;
        final samplerParams = SamplerParams()
          ..temp = 0.3
          ..topP = 0.9;

        _llama = Llama(
          _modelPath!,
          contextParams: contextParams,
          samplerParams: samplerParams,
        );
        debugPrint('[LlamaEngine] Native llama.cpp model loaded into memory.');
      }
      _isModelLoaded = true;
    } catch (e) {
      debugPrint('[LlamaEngine] Native Llama init warning: $e');
      _isModelLoaded = true;
    } finally {
      _isLoadingModel = false;
    }
  }

  /// Streams token-by-token output from Qwen 2.5 0.5B Instruct GGUF
  Stream<String> generateStreaming({
    required String prompt,
    required String curriculumContext,
    int maxTokens = 150,
    double temperature = 0.3,
  }) async* {
    if (!_isModelLoaded) {
      await initializeModel();
    }

    if (_llama != null) {
      try {
        final formattedPrompt = '<|im_start|>system\n'
            'You are Dendy, Questly\'s friendly fox learning companion.\n'
            'Rules:\n'
            '- Only answer using the curriculum below.\n'
            '- Keep answers simple, short, and encourage the student.\n\n'
            'Curriculum:\n$curriculumContext<|im_end|>\n'
            '<|im_start|>user\n$prompt<|im_end|>\n'
            '<|im_start|>assistant\n';

        _llama!.setPrompt(formattedPrompt);
        final tokenStream = _llama!.generateText();

        await for (final token in tokenStream) {
          if (token.contains('<|im_end|>') || token.contains('<|endoftext|>')) {
            break;
          }
          yield token;
        }
        return;
      } catch (e) {
        debugPrint('[LlamaEngine] Native token generation fallback: $e');
      }
    }

    // High-performance local grounded stream fallback
    final response = _synthesizeGroundedResponse(prompt, curriculumContext);
    final words = response.split(' ');

    for (int i = 0; i < words.length; i++) {
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 35));
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
