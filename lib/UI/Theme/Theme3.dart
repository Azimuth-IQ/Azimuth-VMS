import 'package:flutter/material.dart';

/// Theme 3: Gold/Dark - Warmth and Leadership
/// Visual Style: Dark theme with gold as main color
/// Use Case: Elegant, premium applications
class Theme3 {
  // ==================== MAIN COLORS ====================
  // Primary action color - Used for main buttons, links, highlighted elements
  static const Color mainColor = Color(0xFFF4C025); // Gold - Warmth and leadership

  // Secondary action color - Used for hover states and secondary actions
  static const Color accentColor = Color(0xFFD6A410); // Dark Gold

  // Legacy aliases for backward compatibility
  static const Color primary = mainColor;
  static const Color primaryDark = accentColor;

  // ==================== BACKGROUND COLORS ====================
  // Main page background for light mode (rarely used - this is dark theme)
  static const Color backgroundLight = Color(0xFFF8F8F5); // Off-White

  // Main page background for dark mode
  static const Color backgroundDark = Color(0xFF013220); // Very Dark Green - Deep elegance

  // Card/surface color for dark mode
  static const Color backgroundCard = Color(0xFF004D33); // Dark Green Card

  // Header/elevated surface color for dark mode
  static const Color backgroundHeader = Color(0xFF00281A); // Darkest Green

  // ==================== TEXT COLORS ====================
  // Primary text color for dark mode - Main content
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure White - Maximum readability

  // Secondary/accent text color for dark mode - Warm tone
  static const Color textOffWhite = Color(0xFFF5F5DC); // Beige/Warm White

  // Muted text color for descriptions
  static const Color textSecondary = Color(0xFFBFBFBF); // Light Gray

  // ==================== BORDER COLORS ====================
  // Border color for dark mode - Dividers, card borders
  static const Color borderDark = Color(0xFF065F46); // Muted Dark Green

  // ==================== STATUS COLORS ====================
  // Success state color - Active, approved
  static const Color statusActive = Color(0xFF10B981); // Green
  static const Color statusSuccess = statusActive;

  // Warning state color - Pending, attention needed
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusWarning = statusPending;

  // Error state color - Absent, rejected
  static const Color statusAbsent = Color(0xFFEF4444); // Red
  static const Color statusError = statusAbsent;

  // Info state color
  static const Color statusInfo = Color(0xFF3B82F6); // Blue

  // Fonts
  static const String displayFontFamily = 'Noto Serif'; // Elegant serif for headings
  static const String bodyFontFamily = 'Noto Sans'; // Clean sans for body text

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: mainColor,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: bodyFontFamily,
      colorScheme: const ColorScheme.dark(
        primary: mainColor,
        secondary: accentColor,
        surface: backgroundCard,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textPrimaryDark,
        error: statusError,
      ),
      dividerColor: borderDark,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: displayFontFamily),
        displayMedium: TextStyle(fontFamily: displayFontFamily),
        displaySmall: TextStyle(fontFamily: displayFontFamily),
        headlineLarge: TextStyle(fontFamily: displayFontFamily),
        headlineMedium: TextStyle(fontFamily: displayFontFamily),
        headlineSmall: TextStyle(fontFamily: displayFontFamily),
        titleLarge: TextStyle(fontFamily: displayFontFamily),
        titleMedium: TextStyle(fontFamily: bodyFontFamily),
        titleSmall: TextStyle(fontFamily: bodyFontFamily),
        bodyLarge: TextStyle(fontFamily: bodyFontFamily),
        bodyMedium: TextStyle(fontFamily: bodyFontFamily),
        bodySmall: TextStyle(fontFamily: bodyFontFamily),
      ),
      cardTheme: CardThemeData(color: backgroundCard, elevation: 2),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundHeader,
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mainColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          foregroundColor: backgroundDark,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: mainColor,
        inactiveTrackColor: borderDark,
        thumbColor: mainColor,
        overlayColor: mainColor.withOpacity(0.2),
        valueIndicatorColor: mainColor,
        valueIndicatorTextStyle: TextStyle(color: backgroundDark),
      ),
    );
  }
}
