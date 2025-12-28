import 'package:flutter/material.dart';

/// Color-coded status badge for displaying item statuses
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final bool small;
  
  const StatusBadge({
    Key? key,
    required this.text,
    required this.type,
    this.small = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _StatusColors colors = _getColors(theme, type);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8.0 : 12.0,
        vertical: small ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(small ? 4.0 : 6.0),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.textColor,
          fontWeight: FontWeight.w600,
          fontSize: small ? 10 : 11,
        ),
      ),
    );
  }
  
  _StatusColors _getColors(ThemeData theme, StatusType type) {
    switch (type) {
      case StatusType.success:
        return _StatusColors(
          backgroundColor: const Color(0xFF22C55E).withOpacity(0.1),
          borderColor: const Color(0xFF22C55E).withOpacity(0.3),
          textColor: const Color(0xFF22C55E),
        );
      case StatusType.warning:
        return _StatusColors(
          backgroundColor: const Color(0xFFF59E0B).withOpacity(0.1),
          borderColor: const Color(0xFFF59E0B).withOpacity(0.3),
          textColor: const Color(0xFFF59E0B),
        );
      case StatusType.error:
        return _StatusColors(
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
          borderColor: const Color(0xFFEF4444).withOpacity(0.3),
          textColor: const Color(0xFFEF4444),
        );
      case StatusType.info:
        return _StatusColors(
          backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
          borderColor: const Color(0xFF3B82F6).withOpacity(0.3),
          textColor: const Color(0xFF3B82F6),
        );
      case StatusType.neutral:
        return _StatusColors(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          borderColor: theme.colorScheme.outline,
          textColor: theme.colorScheme.onSurface,
        );
      case StatusType.primary:
        return _StatusColors(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          borderColor: theme.colorScheme.primary.withOpacity(0.3),
          textColor: theme.colorScheme.primary,
        );
    }
  }
}

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
  primary,
}

class _StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  
  _StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}
