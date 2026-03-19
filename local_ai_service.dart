import 'dart:io';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants.dart';

class LocalAIService {
  static final LocalAIService _instance = LocalAIService._internal();
  factory LocalAIService() => _instance;
  LocalAIService._internal();

  bool _isReady = false;
  bool get isReady => _isReady;

  Future<String> get modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${AppConstants.gemmaModelFileName}';
  }

  Future<bool> isModelDownloaded() async {
    final path = await modelPath;
    return File(path).existsSync();
  }

  Future<void> init() async {
    if (_isReady) return;
    final path = await modelPath;
    if (!File(path).existsSync()) return;
    try {
      await FlutterGemma.instance.init(
        maxTokens: 1024,
        temperature: 0.8,
        topK: 40,
        randomSeed: 1,
      );
      _isReady = true;
    } catch (e) {
      _isReady = false;
    }
  }

  Future<String> generate(String prompt) async {
    if (!_isReady) {
      return 'Offline AI is not ready. Please download the Gemma model from Assistant settings.';
    }
    try {
      final response = await FlutterGemma.instance.getResponse(
        prompt: prompt,
      );
      return response ?? 'No response generated.';
    } catch (e) {
      return 'Local AI error: $e';
    }
  }

  void dispose() {
    _isReady = false;
  }
}