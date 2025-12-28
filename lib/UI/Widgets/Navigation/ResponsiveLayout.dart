import 'package:flutter/material.dart';

/// Responsive layout wrapper that switches between mobile and desktop layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? desktop;
  final double breakpoint;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.desktop,
    this.breakpoint = 1024.0,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= breakpoint;
    
    if (isDesktop && desktop != null) {
      return desktop!;
    }
    return mobile;
  }
}
