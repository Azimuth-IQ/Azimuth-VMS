import 'package:flutter/material.dart';

/// Theme 2: Green/Light - Growth and Community
/// Visual Style: Light theme with green as main color
/// Use Case: Welcoming, friendly applications
class Theme2 {
  // ==================== MAIN COLORS ====================
  // Primary action color - Used for main buttons, links, highlighted elements
  static const Color mainColor = Color(0xFF059669); // Green - Growth and community

  // Secondary action color - Used for hover states and secondary actions
  static const Color accentColor = Color(0xFF047857); // Dark Green

  // Legacy aliases for backward compatibility
  static const Color primary = mainColor;
  static const Color primaryHover = accentColor;
  static const Color primaryDark = Color(0xFF064E3B); // Very Dark Green - Rarely used

  // ==================== BACKGROUND COLORS ====================
  // Main page background for light mode
  static const Color backgroundLight = Color(0xFFF0FDF4); // Very Light Green Tint

  // Main page background for dark mode (future use)
  static const Color backgroundDark = Color(0xFF064E3B); // Very Dark Green

  // Card/surface color for light mode
  static const Color card = Color(0xFFFFFFFF); // White - Clean cards

  // Card/surface color for dark mode (future use)
  static const Color cardDark = Color(0xFF065F46); // Dark Green

  // ==================== TEXT COLORS ====================
  // Primary text color for light mode - Main content
  static const Color textPrimary = Color(0xFF022C22); // Almost Black with Green Tint

  // Secondary text color for light mode - Descriptions, labels
  static const Color textSecondary = Color(0xFF065F46); // Muted Dark Green

  // Primary text color for dark mode - Main content (future use)
  static const Color textPrimaryDark = Color(0xFFECFDF5); // Very Light Green

  // Secondary text color for dark mode - Descriptions, labels (future use)
  static const Color textSecondaryDark = Color(0xFFA7F3D0); // Light Green

  // ==================== BORDER COLORS ====================
  // Border color for light mode - Dividers, card borders
  static const Color borderLight = Color(0xFFD1FAE5); // Light Green Tint

  // Border color for dark mode - Dividers, card borders (future use)
  static const Color borderDark = Color(0xFF047857); // Dark Green

  // ==================== STATUS COLORS ====================
  // Success state color
  static const Color statusSuccess = Color(0xFF059669); // Same as mainColor

  // Warning state color
  static const Color statusWarning = Color(0xFFF59E0B); // Amber

  // Info state color
  static const Color statusInfo = Color(0xFF3B82F6); // Blue

  // Error state color
  static const Color statusError = Color(0xFFEF4444); // Red

  // Font
  static const String fontFamily = 'Lexend';

  // Theme Data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: mainColor,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: fontFamily,
      colorScheme: const ColorScheme.light(
        primary: mainColor,
        secondary: accentColor,
        background: backgroundLight,
        surface: card,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      dividerColor: borderLight,
    );
  }
}
