import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class ConfirmEntryScreen extends StatelessWidget {
  const ConfirmEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Confirm Entry',
      titleTe: 'లావాదేవీ సరిచూడండి',
      subtitleEn: 'Verify recognized fields before saving',
      subtitleTe: 'సేవ్ చేయడానికి ముందు వివరాలు సరిచూడండి',
      showBottomBar: false,
    );
  }
}
