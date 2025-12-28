import 'package:flutter/material.dart';

class AppShadows {
  // Small shadow for subtle elevation
  static const List<BoxShadow> small = <BoxShadow>[BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1))];

  // Medium shadow for cards
  static const List<BoxShadow> medium = <BoxShadow>[BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2))];

  // Large shadow for modals and dialogs
  static const List<BoxShadow> large = <BoxShadow>[BoxShadow(color: Color(0x26000000), blurRadius: 15, offset: Offset(0, 4))];

  // Extra large shadow for floating elements
  static const List<BoxShadow> xl = <BoxShadow>[BoxShadow(color: Color(0x33000000), blurRadius: 25, offset: Offset(0, 8))];
}
