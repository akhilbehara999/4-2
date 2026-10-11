import 'package:flutter/material.dart';
import '../navigation/screen_shell.dart';

class UdharCustomerDetailScreen extends StatelessWidget {
  final int? customerId;
  final String? customerName;

  const UdharCustomerDetailScreen({
    super.key,
    this.customerId,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      titleEn: customerName != null ? '$customerName Due' : 'Customer Due Detail',
      titleTe: 'ఖాతాదారుని వివరాలు',
      subtitleEn: 'Credit history & repayment',
      subtitleTe: 'అప్పు చరిత్ర & చెల్లింపులు',
      showBottomBar: false,
    );
  }
}
