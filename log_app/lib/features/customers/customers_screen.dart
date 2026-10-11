import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenShell(
      titleEn: 'Customers',
      titleTe: 'ఖాతాదారులు',
      subtitleEn: 'Customer directory & contacts',
      subtitleTe: 'ఖాతాదారుల చిరునామాలు',
      showBottomBar: false,
    );
  }
}
