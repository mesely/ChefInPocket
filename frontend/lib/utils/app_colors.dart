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
}
