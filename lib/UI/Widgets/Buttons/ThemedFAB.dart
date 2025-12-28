import 'package:flutter/material.dart';
import 'package:azimuth_vms/UI/Theme/Shadows.dart';

/// Themed Floating Action Button with optional glow effect
class ThemedFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool withGlow;
  final bool mini;
  
  const ThemedFAB({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.withGlow = false,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color onPrimaryColor = theme.colorScheme.onPrimary;
    
    Widget fab = FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      elevation: 4,
      mini: mini,
      child: Icon(icon),
    );
    
    if (withGlow) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: Shadows.glow(primaryColor, opacity: 0.4),
        ),
        child: fab,
      );
    }
    
    return fab;
  }
}
