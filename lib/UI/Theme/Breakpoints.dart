import 'package:flutter/material.dart';

/// Responsive breakpoints for the VMS application
class Breakpoints {
  // Breakpoint values
  static const double mobile = 640.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
  static const double wide = 1280.0;
  
  /// Check if the screen is mobile size (< 640px)
  static bool isMobile(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width < mobile;
  }
  
  /// Check if the screen is tablet size (>= 640px and < 1024px)
  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }
  
  /// Check if the screen is desktop size (>= 1024px)
  static bool isDesktop(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= desktop;
  }
  
  /// Check if the screen is wide desktop size (>= 1280px)
  static bool isWide(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= wide;
  }
  
  /// Get the current screen width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  /// Get the current screen height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  /// Get responsive value based on screen size
  static T getValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final double width = MediaQuery.of(context).size.width;
    
    if (width >= Breakpoints.wide && wide != null) {
      return wide;
    } else if (width >= Breakpoints.desktop && desktop != null) {
      return desktop;
    } else if (width >= Breakpoints.mobile && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
