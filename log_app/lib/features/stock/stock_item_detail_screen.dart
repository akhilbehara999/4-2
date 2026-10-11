import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class StockItemDetailScreen extends StatelessWidget {
  final int? itemId;
  final String? itemNameEn;
  final String? itemNameTe;

  const StockItemDetailScreen({
    super.key,
    this.itemId,
    this.itemNameEn,
    this.itemNameTe,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titleEn: itemNameEn ?? 'Stock Item Detail',
      titleTe: itemNameTe ?? 'వస్తువు వివరాలు',
      subtitleEn: 'Stock movement & forecast',
      subtitleTe: 'స్టాక్ మార్పులు & అంచనా',
      showBottomBar: false,
    );
  }
}
