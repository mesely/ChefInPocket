import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Theme configuration for the app.
/// We use Material 3 design and customize colors, fonts, and component styles.
class AppTheme {
  // Private constructor - we only use static members
  AppTheme._();

  /// Returns the light theme for the app.
  /// This configures all the default styles for buttons, inputs, etc.
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.bodyFont,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.primary,
            secondary: AppColors.warmAccent,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontFamily: AppTextStyles.bodyFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontFamily: AppTextStyles.displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: AppTextStyles.displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          height: 1.45,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.45,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.4,
          color: AppColors.textMuted,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.textMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButton,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.bodyFont,
      scaffoldBackgroundColor: const Color(0xFF111111),
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.primary,
            secondary: AppColors.warmAccent,
            surface: const Color(0xFF1A1A1A),
            onSurface: Colors.white,
          ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          fontFamily: AppTextStyles.bodyFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: Colors.white,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontFamily: AppTextStyles.displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.1,
          color: Colors.white,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontFamily: AppTextStyles.displayFont,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.1,
          color: Colors.white,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          height: 1.45,
          color: Colors.white,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          height: 1.45,
          color: Colors.white,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.4,
          color: const Color(0xFFB7B7B7),
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: const Color(0xFFB7B7B7),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: const Color(0xFFB7B7B7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2F2F2F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2F2F2F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
