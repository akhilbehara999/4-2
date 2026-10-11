import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('te-IN');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      debugPrint('TtsService init warning: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      if (!_isInitialized) await initialize();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TtsService speak warning: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TtsService stop warning: $e');
    }
  }
}
