import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Ask Assistant',
      titleTe: 'అడగండి',
      subtitleEn: 'Ask questions about your shop in Telugu',
      subtitleTe: 'మీ దుకాణం వివరాలు అడగండి',
      showBottomBar: true,
      bottomBarIndex: 1,
    );
  }
}
