import 'package:flutter/material.dart';

/// Small circular badge for notification counts
class NotificationBadge extends StatelessWidget {
  final int count;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  
  const NotificationBadge({
    Key? key,
    required this.count,
    this.size = 20.0,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bgColor = backgroundColor ?? theme.colorScheme.error;
    final Color fgColor = textColor ?? Colors.white;
    
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    
    final String displayCount = count > 99 ? '99+' : count.toString();
    
    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        displayCount,
        style: TextStyle(
          color: fgColor,
          fontSize: size * 0.6,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Widget that positions a NotificationBadge on top of a child widget
class BadgedWidget extends StatelessWidget {
  final Widget child;
  final int count;
  final double badgeSize;
  final Color? badgeColor;
  final Color? textColor;
  final EdgeInsetsGeometry? badgePadding;
  
  const BadgedWidget({
    Key? key,
    required this.child,
    required this.count,
    this.badgeSize = 20.0,
    this.badgeColor,
    this.textColor,
    this.badgePadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        if (count > 0)
          Positioned(
            top: badgePadding?.resolve(TextDirection.ltr).top ?? -4,
            right: badgePadding?.resolve(TextDirection.ltr).right ?? -4,
            child: NotificationBadge(
              count: count,
              size: badgeSize,
              backgroundColor: badgeColor,
              textColor: textColor,
            ),
          ),
      ],
    );
  }
}
