import 'package:flutter/material.dart';

/// Elevation shadows for consistent depth across the application
class Shadows {
  /// No elevation
  static const List<BoxShadow> none = <BoxShadow>[];
  
  /// Small elevation (4dp)
  static const List<BoxShadow> small = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Medium elevation (8dp)
  static const List<BoxShadow> medium = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Large elevation (16dp)
  static const List<BoxShadow> large = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Extra large elevation (24dp)
  static const List<BoxShadow> extraLarge = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Glow effect for primary color elements
  static List<BoxShadow> glow(Color color, {double opacity = 0.3}) {
    return <BoxShadow>[
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 16,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ),
    ];
  }
  
  /// Inner shadow effect (for inset appearance)
  static const List<BoxShadow> inner = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -2,
    ),
  ];
}
