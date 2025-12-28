import 'package:flutter/material.dart';

/// Theme 3: Team Leader Theme (Gold/Dark)
/// Represents leadership, coordination, and excellence
class Theme3 {
  // Primary Colors
  static const Color primary = Color(0xFFEAB308);
  static const Color primaryHover = Color(0xFFCA8A04);
  static const Color primaryPressed = Color(0xFFA16207);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF09090B);
  static const Color surfaceDark = Color(0xFF18181B);
  static const Color surfaceBorder = Color(0xFF27272A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color textOnPrimary = Color(0xFF000000);
  
  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Font Family - Serif for formal leadership feel
  static const String fontFamily = 'Noto Serif';
  static const String fontFamilyAlt = 'Noto Sans';
  
  // Text Theme
  static const TextTheme textTheme = TextTheme(
    // Display styles - Serif for headers
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w900,
      height: 1.2,
      letterSpacing: -0.5,
      color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w900,
      height: 1.2,
      letterSpacing: -0.5,
      color: textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.3,
      letterSpacing: -0.5,
      color: textPrimary,
    ),
    // Headline styles - Serif for emphasis
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      height: 1.4,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.4,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.4,
      color: textPrimary,
    ),
    // Title styles - Sans for UI elements
    titleLarge: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.5,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 1.5,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      height: 1.5,
      color: textPrimary,
    ),
    // Body styles - Sans for readability
    bodyLarge: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.6,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.6,
      color: textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.6,
      color: textMuted,
    ),
    // Label styles - Sans for controls
    labelLarge: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamilyAlt,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.1,
      color: textMuted,
    ),
  );
  
  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: fontFamilyAlt,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: textOnPrimary,
        secondary: primaryHover,
        onSecondary: textOnPrimary,
        tertiary: primaryPressed,
        onTertiary: textOnPrimary,
        error: error,
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceBorder,
        outline: surfaceBorder,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: backgroundDark,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: fontFamilyAlt,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: fontFamilyAlt,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surfaceBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: surfaceBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        labelStyle: const TextStyle(color: textPrimary, fontFamily: fontFamilyAlt),
        side: const BorderSide(color: surfaceBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
