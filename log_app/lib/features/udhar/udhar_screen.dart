import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class UdharScreen extends StatelessWidget {
  const UdharScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Udhar',
      titleTe: 'ఉధార్',
      subtitleEn: 'Customer ledger & credit balances',
      subtitleTe: 'ఖాతా పుస్తకం & బాకీలు',
      showBottomBar: true,
      bottomBarIndex: 1,
    );
  }
}
