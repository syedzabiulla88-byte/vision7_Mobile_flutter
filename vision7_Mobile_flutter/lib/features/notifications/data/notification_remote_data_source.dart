import '../../../../core/network/dio_client.dart';
import '../domain/notification.dart';

class NotificationRemoteDataSource {
  final DioClient _client;
  NotificationRemoteDataSource(this._client);

  Future<List<Notification>> list() async {
    final result = await _client.get<List<dynamic>>('/notifications');
    if (result == null) return [];
    return result
        .map((n) => Notification.fromJson(n as Map<String, dynamic>))
        .toList();
  }

  Future<Notification> markRead(String id) async {
    final result = await _client.patch<Notification>(
      '/notifications/$id/read',
      {},
      fromJson: (json) => Notification.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Failed to mark as read');
    return result;
  }

  Future<void> markAllRead() async {
    await _client.patch('/notifications/read-all', {});
  }

  Future<void> delete(String id) async {
    await _client.delete('/notifications/$id');
  }

  Future<void> registerDeviceToken(String token, String platform) async {
    await _client.post('/notifications/device-token', {
      'token': token,
      'platform': platform,
    });
  }

  Future<void> unregisterDeviceToken(String token) async {
    await _client.delete('/notifications/device-token/$token');
  }
}
