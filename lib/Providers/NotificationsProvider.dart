import 'package:flutter/material.dart' hide Notification;
import '../Helpers/NotificationHelperFirebase.dart';
import '../Models/Notification.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationHelperFirebase _notificationHelper = NotificationHelperFirebase();

  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserId;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications(String userId) async {
    if (userId.isEmpty) {
      print('⚠️ Cannot load notifications - userId is empty');
      return;
    }

    _currentUserId = userId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('📬 Loading notifications for user: $userId');
      _notifications = await _notificationHelper.getNotifications(userId);
      _notifications.sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Most recent first
      print('✓ Loaded ${_notifications.length} notifications (${unreadCount} unread)');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading notifications: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      _notificationHelper.markAsRead(notificationId, _currentUserId!);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;

    try {
      for (var notification in _notifications.where((n) => !n.isRead)) {
        _notificationHelper.markAsRead(notification.id, _currentUserId!);
        notification.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      _notificationHelper.deleteNotification(notificationId, _currentUserId!);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void refresh() {
    if (_currentUserId != null) {
      loadNotifications(_currentUserId!);
    }
  }
}
