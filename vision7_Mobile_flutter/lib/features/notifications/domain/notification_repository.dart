import 'notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> list();
  Future<Notification> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
}
