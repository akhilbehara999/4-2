import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class PlatformHelper {
  static bool get isWeb => kIsWeb;

  static bool get isTest =>
      WidgetsBinding.instance.runtimeType.toString().contains('Test');

  // Android only
  static bool get isAndroid =>
      !kIsWeb && !isTest && defaultTargetPlatform == TargetPlatform.android;

  static bool get isMobile =>
      !kIsWeb &&
      !isTest &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
