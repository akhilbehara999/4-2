import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class WeeklyRecountScreen extends StatelessWidget {
  const WeeklyRecountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Weekly Recount',
      titleTe: 'వారపు స్టాక్ లెక్క',
      subtitleEn: 'Correct drift and update stock levels',
      subtitleTe: 'స్టాక్ తేడాలను సరిచేయండి',
      showBottomBar: false,
    );
  }
}
