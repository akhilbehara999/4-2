import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Stock',
      titleTe: 'స్టాక్',
      subtitleEn: 'Inventory items & forecast alerts',
      subtitleTe: 'వస్తువులు & అలర్ట్‌లు',
      showBottomBar: true,
      bottomBarIndex: 1,
    );
  }
}
