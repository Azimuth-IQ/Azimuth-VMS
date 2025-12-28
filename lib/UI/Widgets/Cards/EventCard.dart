import 'package:flutter/material.dart';
import 'package:azimuth_vms/UI/Widgets/Badges/StatusBadge.dart';

/// Event display card with theme variants
class EventCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? date;
  final String? location;
  final String? status;
  final StatusType? statusType;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final Widget? trailing;
  
  const EventCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.date,
    this.location,
    this.status,
    this.statusType,
    this.leadingIcon,
    this.onTap,
    this.actions,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (leadingIcon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        leadingIcon,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  if (leadingIcon != null) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                  if (status != null && statusType != null) ...<Widget>[
                    const SizedBox(width: 8),
                    StatusBadge(
                      text: status!,
                      type: statusType!,
                      small: true,
                    ),
                  ],
                ],
              ),
              if (date != null || location != null) ...<Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    if (date != null)
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                date!,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (location != null) ...<Widget>[
                      if (date != null) const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location!,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (actions != null && actions!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
