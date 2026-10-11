import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Dashboard',
      titleTe: 'డాష్‌బోర్డ్',
      subtitleEn: 'Sales, expenses and profit analytics',
      subtitleTe: 'అమ్మకాలు, ఖర్చులు మరియు లాభం',
      showBottomBar: true,
      bottomBarIndex: 1,
    );
  }
}
