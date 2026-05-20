import 'package:flutter/material.dart';

/// Utility class that holds all the colors used in the app.
/// This keeps our color scheme consistent across all screens.
class AppColors {
  // Private constructor - we only use static members
  AppColors._();

  // Background colors
  static const background = Color(0xFFF6F2EA);
  static const card = Colors.white;

  // Border and divider colors
  static const border = Color(0xFFE3DDD3);

  // Text colors
  static const textPrimary = Color(0xFF111111);
  static const textMuted = Color(0xFF8C857C);

  // Primary brand colors
  static const primary = Color(0xFF2563EB);
  static const primarySoft = Color(0xFFEDF3FF);

  // Accent and button colors
  static const warmAccent = Color(0xFFFFF4D8);
  static const darkButton = Color(0xFF111111);

  // Status colors
  static const success = Color(0xFF1B8D4A);
  static const danger = Color(0xFFD64545);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color pageBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF111111) : background;
  }

  static Color surface(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : Colors.white;
  }

  static Color softSurface(BuildContext context) {
    return isDark(context) ? const Color(0xFF202020) : const Color(0xFFF5F1E9);
  }

  static Color borderColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF2F2F2F) : border;
  }

  static Color primaryText(BuildContext context) {
    return isDark(context) ? Colors.white : textPrimary;
  }

  static Color mutedText(BuildContext context) {
    return isDark(context) ? const Color(0xFFB7B7B7) : textMuted;
  }

  static Color activeChipBackground(BuildContext context) {
    return isDark(context) ? const Color(0xFF163B78) : primarySoft;
  }
}
