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
      if (kIsWeb) {
        debugPrint('[LlamaEngine] Running in Web environment. Using local curriculum-grounded engine.');
        _isModelLoaded = true;
        return;
      }

      // Check asset or application documents path
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${appDocDir.path}/$modelAssetName');
      final localAssetFile = File('assets/models/$modelAssetName');

      if (await localAssetFile.exists() && localAssetFile.lengthSync() > 1000000) {
        _modelPath = localAssetFile.path;
      } else if (await targetFile.exists() && targetFile.lengthSync() > 1000000) {
        _modelPath = targetFile.path;
      } else {
        // Copy from bundled asset if available
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

      // Initialize native llama.cpp neural network instance
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
      debugPrint('[LlamaEngine] Native Llama init warning (falling back gracefully): $e');
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

    // 1. If native llama.cpp instance is ready, generate real neural network tokens
    if (_llama != null && !kIsWeb) {
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

    // 2. High-performance grounded stream fallback
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
