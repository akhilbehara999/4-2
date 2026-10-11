import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const Color lightSeed = AppConstants.primaryLight;
  static const Color darkSeed = AppConstants.primaryDark;

  static TextTheme _buildTextTheme(TextTheme base) {
    // Roboto for Latin and numbers, fallback to Noto Sans Telugu for Telugu glyphs
    return GoogleFonts.robotoTextTheme(base).copyWith(
      headlineLarge: GoogleFonts.notoSansTelugu(
        textStyle: base.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      headlineMedium: GoogleFonts.notoSansTelugu(
        textStyle: base.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      titleLarge: GoogleFonts.notoSansTelugu(
        textStyle: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleMedium: GoogleFonts.notoSansTelugu(
        textStyle: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      bodyLarge: GoogleFonts.notoSansTelugu(
        textStyle: base.bodyLarge,
      ),
      bodyMedium: GoogleFonts.notoSansTelugu(
        textStyle: base.bodyMedium,
      ),
      labelLarge: GoogleFonts.notoSansTelugu(
        textStyle: base.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: lightSeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansTelugu(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE4E9F2), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightSeed,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52), // Large touch targets
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52), // Large touch targets
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: lightSeed, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDFF3EE),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: lightSeed,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF56607A),
          );
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkSeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F1524),
      textTheme: _buildTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF172036),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansTelugu(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF172036),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2B3856), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkSeed,
          foregroundColor: const Color(0xFF0F1524),
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: darkSeed, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: const Color(0xFF172036),
        indicatorColor: const Color(0xFF143A3A),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: darkSeed,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9AA5C0),
          );
        }),
      ),
    );
  }
}
