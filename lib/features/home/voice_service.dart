import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _activeLocaleId = 'te_IN';

  VoidCallback? _onDone;
  void Function(dynamic error)? _onError;

  String get activeLocaleId => _activeLocaleId;
  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> init() async {
    if (_isInitialized) return true;

    if (!kIsWeb) {
      try {
        final status = await Permission.microphone.request();
        if (!status.isGranted) {
          debugPrint('Microphone permission not granted');
          return false;
        }
      } catch (e) {
        debugPrint('Permission handler error: $e');
      }
    }

    try {
      _isInitialized = await _speech.initialize(
        onError: (err) {
          debugPrint('SpeechToText error: $err');
          _isListening = false;
          _onError?.call(err);
        },
        onStatus: (status) {
          debugPrint('SpeechToText status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            _onDone?.call();
          }
        },
      );

      if (_isInitialized) {
        final locales = await _speech.locales();
        final teLocale = locales.where((l) => l.localeId.toLowerCase().startsWith('te')).toList();
        if (teLocale.isNotEmpty) {
          _activeLocaleId = teLocale.first.localeId;
        } else {
          final enInLocale = locales.where((l) => l.localeId.toLowerCase().startsWith('en_in')).toList();
          if (enInLocale.isNotEmpty) {
            _activeLocaleId = 'en_IN';
          } else if (locales.isNotEmpty) {
            _activeLocaleId = locales.first.localeId;
          } else {
            _activeLocaleId = 'en_IN';
          }
        }
      }
      return _isInitialized;
    } catch (e) {
      debugPrint('VoiceService init exception: $e');
      _isListening = false;
      return false;
    }
  }

  Future<bool> start({
    required void Function(String text, bool isFinal) onResult,
    VoidCallback? onDone,
    void Function(dynamic error)? onError,
  }) async {
    _onDone = onDone;
    _onError = onError;

    final ok = await init();
    if (!ok) {
      _isListening = false;
      return false;
    }

    try {
      _isListening = true;
      await _speech.listen(
        // ignore: deprecated_member_use
        localeId: _activeLocaleId,
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
      );
      return true;
    } catch (e) {
      debugPrint('Speech listen error: $e');
      _isListening = false;
      return false;
    }
  }

  Future<void> stop() async {
    _isListening = false;
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      debugPrint('Speech stop error: $e');
    }
  }
}
