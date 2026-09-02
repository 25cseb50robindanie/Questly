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
  Completer<void>? _initCompleter;
  String? _modelPath;
  String? _lastError;

  bool get isModelLoaded => _isModelLoaded && _llama != null;
  bool get isLoadingModel => _isLoadingModel;
  String? get lastError => _lastError;
  String? get modelPath => _modelPath;

  /// Initializes and caches the Qwen 2.5 0.5B Instruct GGUF model in application storage
  Future<void> initializeModel({String modelAssetName = 'qwen2.5-0.5b-instruct-q4_k_m.gguf'}) async {
    if (_isModelLoaded && _llama != null) return;
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    _isLoadingModel = true;
    _lastError = null;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${appDocDir.path}/$modelAssetName');
      final localAssetFile = File('assets/models/$modelAssetName');

      if (await localAssetFile.exists() && localAssetFile.lengthSync() > 10000000) {
        _modelPath = localAssetFile.path;
        debugPrint('[LlamaEngine] Using local asset file: $_modelPath (${(localAssetFile.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB)');
      } else if (await targetFile.exists() && targetFile.lengthSync() > 10000000) {
        _modelPath = targetFile.path;
        debugPrint('[LlamaEngine] Using cached storage file: $_modelPath (${(targetFile.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB)');
      } else {
        try {
          debugPrint('[LlamaEngine] Unpacking model asset to storage (${targetFile.path})...');
          final byteData = await rootBundle.load('assets/models/$modelAssetName');
          final buffer = byteData.buffer;
          await targetFile.writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
            flush: true,
          );
          _modelPath = targetFile.path;
          debugPrint('[LlamaEngine] Model unpacked successfully: $_modelPath (${(targetFile.lengthSync() / (1024 * 1024)).toStringAsFixed(1)} MB)');
        } catch (e) {
          _lastError = 'Asset unpacking error: $e';
          debugPrint('[LlamaEngine] Asset bundle load error: $e');
        }
      }

      if (_modelPath != null && File(_modelPath!).existsSync()) {
        debugPrint('[LlamaEngine] Loading native C++ libraries (libllama.so, libmtmd.so)...');
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
        debugPrint('[LlamaEngine] Model load success: Qwen 2.5 0.5B Instruct GGUF');
        debugPrint('[LlamaEngine] Inference ready.');
        _isModelLoaded = true;
      } else {
        _lastError ??= 'Model file not found at path: $_modelPath';
        debugPrint('[LlamaEngine] Error: $_lastError');
      }
    } catch (e) {
      _lastError = 'Native initialization exception: $e';
      debugPrint('[LlamaEngine] Native Llama init exception: $e');
    } finally {
      _isLoadingModel = false;
      _initCompleter?.complete();
      _initCompleter = null;
    }
  }

  /// Streams token-by-token output directly from the Qwen 2.5 0.5B Instruct GGUF neural network
  Stream<String> generateStreaming({
    required String prompt,
    String? userQuery,
    required String curriculumContext,
    int maxTokens = 150,
    double temperature = 0.3,
  }) async* {
    if (_llama == null || !_isModelLoaded) {
      debugPrint('[LlamaEngine] Awaiting model initialization...');
      await initializeModel();
    }

    if (_llama != null) {
      try {
        final formattedPrompt = prompt.contains('<|im_start|>')
            ? prompt
            : '<|im_start|>system\n'
                'You are Dendy, Questly\'s friendly fox learning companion.\n'
                'Rules:\n'
                '- Only answer using the curriculum below.\n'
                '- Keep answers simple, short, and encourage the student.\n\n'
                'Curriculum:\n$curriculumContext<|im_end|>\n'
                '<|im_start|>user\n${userQuery ?? prompt}<|im_end|>\n'
                '<|im_start|>assistant\n';

        debugPrint('[LlamaEngine] Starting native inference (${formattedPrompt.length} chars prompt)...');
        _llama!.setPrompt(formattedPrompt);
        
        final tokenStream = _llama!.generateText();
        int tokenCount = 0;

        await for (final token in tokenStream) {
          if (token.contains('<|im_end|>') || token.contains('<|endoftext|>')) {
            break;
          }
          tokenCount++;
          yield token;
        }
        debugPrint('[LlamaEngine] Generation complete ($tokenCount tokens generated by Qwen 2.5)');
        return;
      } catch (e) {
        debugPrint('[LlamaEngine] Native token generation error: $e');
        yield '[Dendy AI]: Error during neural network generation ($e).';
        return;
      }
    }

    // If model failed to load on device, provide explicit diagnostic info
    final errorMsg = _lastError ?? "Model file could not be loaded into RAM.";
    yield '🦊 [Dendy Offline AI Notice]:\n\n'
        'Model status: $errorMsg\n\n'
        'Path: ${_modelPath ?? "Not unpacked yet"}\n\n'
        'Please ensure the app has storage permission and wait a few seconds while the 443 MB model finishes unpacking.';
  }
}
