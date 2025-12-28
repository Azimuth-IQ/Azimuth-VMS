import 'package:flutter/material.dart';
import 'package:azimuth_vms/UI/Theme/Theme1.dart';
import 'package:azimuth_vms/UI/Theme/Theme2.dart';
import 'package:azimuth_vms/UI/Theme/Theme3.dart';

/// User roles that map to specific themes
enum UserRole { admin, volunteer, teamLeader }

/// Provider for managing theme switching based on user role
class ThemeProvider with ChangeNotifier {
  UserRole? _currentRole;
  late ThemeData _currentTheme;
  
  ThemeProvider() {
    _currentTheme = Theme1.themeData; // Default to Admin theme
  }
  
  /// Get the current theme
  ThemeData get currentTheme => _currentTheme;
  
  /// Get the current user role
  UserRole? get currentRole => _currentRole;
  
  /// Set theme based on user role
  void setThemeByRole(UserRole role) {
    _currentRole = role;
    ThemeData selectedTheme;
    
    switch (role) {
      case UserRole.admin:
        selectedTheme = Theme1.themeData;
        break;
      case UserRole.volunteer:
        selectedTheme = Theme2.themeData;
        break;
      case UserRole.teamLeader:
        selectedTheme = Theme3.themeData;
        break;
    }
    
    _currentTheme = selectedTheme;
    notifyListeners();
  }
  
  /// Reset to default theme (Admin)
  void resetTheme() {
    _currentRole = null;
    _currentTheme = Theme1.themeData;
    notifyListeners();
  }
}
