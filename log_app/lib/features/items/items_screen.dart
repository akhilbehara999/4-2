import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Items Catalog',
      titleTe: 'వస్తువులు',
      subtitleEn: 'Products, prices and units',
      subtitleTe: 'వస్తువులు, ధరలు & కొలతలు',
      showBottomBar: false,
    );
  }
}
