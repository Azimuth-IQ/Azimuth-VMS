import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Theme1.dart';
import 'Theme2.dart';
import 'Theme3.dart';

enum ThemeSelection { theme1, theme2, theme3 }

class ThemeProvider with ChangeNotifier {
  ThemeSelection _currentThemeSelection = ThemeSelection.theme1;
  late ThemeData _currentTheme;

  // Custom color overrides (for theme customization)
  Color? _customMainColor;
  Color? _customAccentColor;
  Color? _customBackgroundColor;

  ThemeProvider() {
    _currentTheme = Theme1.themeData;
    _loadThemeFromFirebase();
  }

  ThemeData get currentTheme => _currentTheme;
  ThemeSelection get currentThemeSelection => _currentThemeSelection;

  // Load theme selection from Firebase
  Future<void> _loadThemeFromFirebase() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/settings/theme');
      final DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        final String? themeName = snapshot.child('selected').value as String?;
        if (themeName != null) {
          setTheme(_getThemeFromString(themeName), saveToFirebase: false);
        }

        // Load custom colors if they exist
        final String? mainColorHex = snapshot.child('customColors/main').value as String?;
        final String? accentColorHex = snapshot.child('customColors/accent').value as String?;
        final String? backgroundColorHex = snapshot.child('customColors/background').value as String?;

        if (mainColorHex != null) {
          _customMainColor = Color(int.parse(mainColorHex.replaceFirst('#', '0xFF')));
        }
        if (accentColorHex != null) {
          _customAccentColor = Color(int.parse(accentColorHex.replaceFirst('#', '0xFF')));
        }
        if (backgroundColorHex != null) {
          _customBackgroundColor = Color(int.parse(backgroundColorHex.replaceFirst('#', '0xFF')));
        }
      }
    } catch (e) {
      print('Error loading theme from Firebase: $e');
    }
  }

  // Set theme (called from admin panel)
  void setTheme(ThemeSelection theme, {bool saveToFirebase = true}) {
    _currentThemeSelection = theme;

    ThemeData selectedTheme;
    switch (theme) {
      case ThemeSelection.theme1:
        selectedTheme = Theme1.themeData;
        break;
      case ThemeSelection.theme2:
        selectedTheme = Theme2.themeData;
        break;
      case ThemeSelection.theme3:
        selectedTheme = Theme3.themeData;
        break;
    }

    // Apply custom color overrides if set
    if (_customMainColor != null || _customAccentColor != null || _customBackgroundColor != null) {
      selectedTheme = _applyCustomColors(selectedTheme);
    }

    _currentTheme = selectedTheme;
    notifyListeners();

    if (saveToFirebase) {
      _saveThemeToFirebase();
    }
  }

  // Save theme selection to Firebase (so all users see it)
  Future<void> _saveThemeToFirebase() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/settings/theme');
      await ref.set({'selected': _currentThemeSelection.name, 'updatedAt': ServerValue.timestamp});
    } catch (e) {
      print('Error saving theme to Firebase: $e');
    }
  }

  // Customize theme colors (admin only)
  void customizeColors({Color? mainColor, Color? accentColor, Color? backgroundColor}) {
    _customMainColor = mainColor;
    _customAccentColor = accentColor;
    _customBackgroundColor = backgroundColor;

    setTheme(_currentThemeSelection);
    _saveCustomColorsToFirebase();
  }

  // Apply custom colors to theme
  ThemeData _applyCustomColors(ThemeData baseTheme) {
    return baseTheme.copyWith(
      primaryColor: _customMainColor ?? baseTheme.primaryColor,
      scaffoldBackgroundColor: _customBackgroundColor ?? baseTheme.scaffoldBackgroundColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _customMainColor ?? baseTheme.colorScheme.primary,
        secondary: _customAccentColor ?? baseTheme.colorScheme.secondary,
        surface: _customBackgroundColor ?? baseTheme.colorScheme.surface,
      ),
    );
  }

  // Save custom colors to Firebase
  Future<void> _saveCustomColorsToFirebase() async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref('ihs/settings/theme/customColors');
      await ref.set({
        'main': _customMainColor != null ? '#${_customMainColor!.value.toRadixString(16).substring(2)}' : null,
        'accent': _customAccentColor != null ? '#${_customAccentColor!.value.toRadixString(16).substring(2)}' : null,
        'background': _customBackgroundColor != null ? '#${_customBackgroundColor!.value.toRadixString(16).substring(2)}' : null,
      });
    } catch (e) {
      print('Error saving custom colors to Firebase: $e');
    }
  }

  // Helper to convert string to theme
  ThemeSelection _getThemeFromString(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'theme1':
        return ThemeSelection.theme1;
      case 'theme2':
        return ThemeSelection.theme2;
      case 'theme3':
        return ThemeSelection.theme3;
      default:
        return ThemeSelection.theme1;
    }
  }

  // Reset to default theme colors
  void resetToDefaultColors() {
    _customMainColor = null;
    _customAccentColor = null;
    _customBackgroundColor = null;
    setTheme(_currentThemeSelection);
  }
}
