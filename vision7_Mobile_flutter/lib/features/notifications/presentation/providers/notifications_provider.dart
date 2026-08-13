import 'package:flutter/material.dart' hide Notification;
import '../../domain/notification_repository.dart';
import '../../domain/notification.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationsProvider(this._repository);

  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.list();
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      final updated = await _repository.markRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) {
        _notifications[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllRead();
      _notifications =
          _notifications.map((n) => Notification(
                id: n.id,
                userId: n.userId,
                type: n.type,
                title: n.title,
                message: n.message,
                read: true,
                createdAt: n.createdAt,
              )).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.delete(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
