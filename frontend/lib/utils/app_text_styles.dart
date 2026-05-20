import 'package:flutter/material.dart';

/// Utility class for text styles used throughout the app.
/// We use custom fonts: Inter for body text and Syne for headings.
class AppTextStyles {
  // Private constructor - we only use static members
  AppTextStyles._();

  // Font family names (defined in pubspec.yaml)
  static const String bodyFont = 'Inter';
  static const String displayFont = 'Syne';

  // Large display text for main headings
  static const display = TextStyle(
    fontFamily: bodyFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  // Title text for section headings
  static const title = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  // Subtitle for descriptions
  static const subtitle = TextStyle(
    fontSize: 15,
    height: 1.45,
  );

  // Body text for regular content
  static const body = TextStyle(
    fontSize: 14,
    height: 1.45,
  );

  // Caption for small text and labels
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.4,
  );

  // Section label style (uppercase labels)
  static const sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
  );
}
