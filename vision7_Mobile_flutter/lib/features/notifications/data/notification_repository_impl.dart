import '../domain/notification.dart';
import '../domain/notification_repository.dart';
import '../data/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remote;
  NotificationRepositoryImpl(this._remote);

  @override
  Future<List<Notification>> list() => _remote.list();

  @override
  Future<Notification> markRead(String id) => _remote.markRead(id);

  @override
  Future<void> markAllRead() => _remote.markAllRead();

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
