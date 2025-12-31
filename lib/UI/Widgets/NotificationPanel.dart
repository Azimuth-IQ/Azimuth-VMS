import 'package:flutter/material.dart' hide Notification;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../Theme/Breakpoints.dart';
import '../../Models/Notification.dart';
import '../../Providers/NotificationsProvider.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        elevation: 0,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount > 0) {
                return TextButton.icon(
                  onPressed: () => provider.markAllAsRead(),
                  icon: const Icon(Icons.done_all, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.markAllRead, style: const TextStyle(color: Colors.white)),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => context.read<NotificationsProvider>().refresh(), tooltip: 'Refresh notifications'),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.errorLoadingNotifications, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Text(provider.errorMessage!, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 11 : 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(onPressed: () => provider.refresh(), icon: const Icon(Icons.refresh), label: Text(AppLocalizations.of(context)!.retry)),
                ],
              ),
            );
          }

          if (provider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.noNotificationsYet, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.notificationsWillAppearHere, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 11 : 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _NotificationCard(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Notification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotificationsProvider>();

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.notificationDeleted), duration: const Duration(seconds: 2)));
      },
      child: Card(
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead ? Theme.of(context).colorScheme.surface.withOpacity(0.5) : Theme.of(context).colorScheme.surface,
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon based on notification type
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _getNotificationColor(notification.type).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getNotificationIcon(notification.type), color: _getNotificationColor(notification.type), size: 24),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(notification.title, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 13 : 16, fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(notification.message, style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 11 : 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(_formatDateTime(notification.dateTime), style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 10 : 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.Info:
        return Icons.info_outline;
      case NotificationType.Alert:
        return Icons.warning_amber_rounded;
      case NotificationType.Warning:
        return Icons.error_outline;
      case NotificationType.Reminder:
        return Icons.alarm;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.Info:
        return Colors.blue;
      case NotificationType.Alert:
        return Colors.orange;
      case NotificationType.Warning:
        return Colors.red;
      case NotificationType.Reminder:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
