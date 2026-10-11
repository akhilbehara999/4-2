import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Settings',
      titleTe: 'సెట్టింగ్‌లు',
      subtitleEn: 'Preferences, shop details & backup',
      subtitleTe: 'అమరికలు & బ్యాకప్',
      showBottomBar: false,
    );
  }
}
