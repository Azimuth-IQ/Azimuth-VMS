import 'package:flutter/material.dart';

/// Theme 1: Red/Dark - Authority and Urgency
/// Visual Style: Dark theme with red as main color
/// Use Case: Professional, serious applications
class Theme1 {
  // ============================================
  // MAIN COLORS - Primary brand colors
  // ============================================

  /// Main Color - Used for primary actions, buttons, highlights
  static const Color mainColor = Color(0xFFEC1313); // Bright Red

  /// Accent Color - Used for hover states, secondary actions
  static const Color accentColor = Color(0xFFC91010); // Dark Red

  // ============================================
  // BACKGROUND COLORS - Page and surface colors
  // ============================================

  /// Background Color (Light Mode) - Main page background for light theme
  static const Color backgroundLight = Color(0xFFF8F6F6); // Light Gray

  /// Background Color (Dark Mode) - Main page background for dark theme
  static const Color backgroundDark = Color(0xFF09090B); // Almost Black (zinc-950)

  /// Surface Color - Used for cards, dialogs, elevated components
  static const Color surfaceColor = Color(0xFF18181B); // zinc-900

  /// Border Color - Used for dividers, borders
  static const Color borderColor = Color(0xFF27272A); // zinc-800

  /// Highlight Color - Used for subtle highlights, hovers
  static const Color highlightColor = Color(0xFF3F3F46); // zinc-700

  // ============================================
  // TEXT COLORS - Typography colors
  // ============================================

  /// Primary Text Color (Dark Mode) - Main text on dark backgrounds
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White

  /// Secondary Text Color (Dark Mode) - Less important text on dark backgrounds
  static const Color textSecondaryDark = Color(0xFFA1A1AA); // zinc-400

  /// Muted Text Color (Dark Mode) - Disabled or very subtle text
  static const Color textMutedDark = Color(0xFF71717A); // zinc-500

  /// Primary Text Color (Light Mode) - Main text on light backgrounds
  static const Color textPrimaryLight = Color(0xFF0F172A); // slate-900

  /// Secondary Text Color (Light Mode) - Less important text on light backgrounds
  static const Color textSecondaryLight = Color(0xFF64748B); // slate-500

  // ============================================
  // STATUS COLORS - Semantic colors for states
  // ============================================

  /// Success Color - Used for success states, active status
  static const Color statusSuccess = Color(0xFF10B981); // green-500

  /// Warning Color - Used for warnings, pending status
  static const Color statusWarning = Color(0xFFF59E0B); // amber-500

  /// Info Color - Used for informational messages, completed status
  static const Color statusInfo = Color(0xFF6366F1); // indigo-500

  /// Error Color - Used for errors, cancelled status, destructive actions
  static const Color statusError = Color(0xFFEF4444); // red-500

  // Legacy aliases for backward compatibility
  static const Color primary = mainColor;
  static const Color primaryHover = accentColor;
  static const Color surfaceDark = surfaceColor;
  static const Color surfaceBorder = borderColor;
  static const Color surfaceHighlight = highlightColor;
  static const Color statusActive = statusSuccess;
  static const Color statusPending = statusWarning;
  static const Color statusCompleted = statusInfo;
  static const Color statusCancelled = statusError;

  // Font
  static const String fontFamily = 'Inter';

  // Text Theme
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
    displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.normal, height: 1.5),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.normal, height: 1.5),
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.normal, height: 1.4),
  );

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      fontFamily: fontFamily,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryHover,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
      ),
      dividerColor: borderColor,
    );
  }
}
