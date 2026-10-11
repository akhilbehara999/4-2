import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/constants/app_constants.dart';
import '../core/platform/platform_helper.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isAvailable => _isInitialized;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (PlatformHelper.isTest) {
      _isInitialized = true;
      return true;
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('SpeechService error: $error');
        },
        onStatus: (status) {
          debugPrint('SpeechService status: $status');
        },
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('SpeechService init failed: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String text) onResult,
    String localeId = AppConstants.teluguLocale,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (e) {
      debugPrint('SpeechService startListening error: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('SpeechService stopListening error: $e');
    }
  }
}
