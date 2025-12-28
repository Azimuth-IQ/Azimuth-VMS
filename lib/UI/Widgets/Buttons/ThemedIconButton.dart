import 'package:flutter/material.dart';

/// Themed icon button with circular shape
class ThemedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  
  const ThemedIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size = 40.0,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bgColor = backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1);
    final Color fgColor = iconColor ?? theme.colorScheme.primary;
    
    final Widget button = Material(
      color: bgColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: fgColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}
