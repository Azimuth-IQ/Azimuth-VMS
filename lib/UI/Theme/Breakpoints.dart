import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 640;
  static const double tablet = 1024;
  static const double desktop = 1280;

  static bool isMobile(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return width >= desktop;
  }
}
