import 'package:flutter/material.dart';

/// Helper to render bilingual labels in the format "Telugu · English"
/// or structured bilingual text with clear typography.
class Bilingual {
  static String label(String telugu, String english) {
    if (telugu.trim().isEmpty) return english;
    if (english.trim().isEmpty) return telugu;
    return '$telugu · $english';
  }
}

/// A custom widget to display bilingual text cleanly with distinct visual hierarchy if desired
class BilingualText extends StatelessWidget {
  final String telugu;
  final String english;
  final TextStyle? style;
  final TextStyle? teluguStyle;
  final TextStyle? englishStyle;
  final bool inline;
  final TextAlign? textAlign;

  const BilingualText({
    super.key,
    required this.telugu,
    required this.english,
    this.style,
    this.teluguStyle,
    this.englishStyle,
    this.inline = true,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    if (inline) {
      return Text(
        Bilingual.label(telugu, english),
        style: baseStyle,
        textAlign: textAlign,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          telugu,
          style: teluguStyle ?? baseStyle?.copyWith(fontWeight: FontWeight.w600),
          textAlign: textAlign,
        ),
        Text(
          english,
          style: englishStyle ??
              baseStyle?.copyWith(
                fontSize: (baseStyle.fontSize ?? 14) * 0.88,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: textAlign,
        ),
      ],
    );
  }
}
