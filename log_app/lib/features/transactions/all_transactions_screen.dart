import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'All Transactions',
      titleTe: 'అన్ని లావాదేవీలు',
      subtitleEn: 'Complete ledger entries',
      subtitleTe: 'మొత్తం లావాదేవీల జాబితా',
      showBottomBar: false,
    );
  }
}
