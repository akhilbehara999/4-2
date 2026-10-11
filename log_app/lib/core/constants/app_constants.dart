import 'package:flutter/material.dart';

class AppConstants {
  // Shop Details
  static const String shopNameEn = 'Sri Lakshmi Kirana';
  static const String shopNameTe = 'శ్రీ లక్ష్మి కిరాణా';
  static const String taglineEn = 'We Listen · Organise · Grow';
  static const String taglineTe = 'వింటాము · సర్దుతాము · ఎదుగుతాము';

  // Theme Colors
  static const Color primaryLight = Color(0xFF0B6E5F);
  static const Color primaryDark = Color(0xFF4FD1B8);

  // Forecast & Alert Colors
  static const Color stockRed = Color(0xFFD32F2F);   // <= 2 days
  static const Color stockAmber = Color(0xFFFFA000); // <= 6 days
  static const Color stockGreen = Color(0xFF2E7D32); // > 6 days
  static const Color stockGrey = Color(0xFF9E9E9E);  // Insufficient data

  // Business Rules
  static const int overdueDays = 15;
  static const int defaultStockAlertDays = 2;

  // Speech Locale
  static const String teluguLocale = 'te-IN';
}
