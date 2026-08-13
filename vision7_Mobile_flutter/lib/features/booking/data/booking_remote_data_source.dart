import '../../../../core/network/dio_client.dart';
import '../domain/booking.dart';

class BookingRemoteDataSource {
  final DioClient _client;
  BookingRemoteDataSource(this._client);

  // Public booking (no auth)
  Future<Booking> createPublic(Map<String, dynamic> dto) async {
    final result = await _client.post<Booking>(
      '/bookings/public',
      dto,
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Booking creation failed');
    return result;
  }

  // Auth user's bookings
  Future<List<Booking>> listMyBookings() async {
    final result = await _client.get<List<dynamic>>('/me/bookings');
    if (result == null) return [];
    return result
        .map((b) => Booking.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> getById(String id) async {
    final result = await _client.get<Booking>(
      '/bookings/$id',
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Booking not found');
    return result;
  }

  // Admin endpoints (optional, kept for completeness)
  Future<List<Booking>> list(Map<String, dynamic> query) async {
    final result = await _client.get<List<dynamic>>('/bookings', params: query);
    if (result == null) return [];
    return result
        .map((b) => Booking.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> create(Map<String, dynamic> dto) async {
    final result = await _client.post<Booking>(
      '/bookings',
      dto,
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Booking creation failed');
    return result;
  }

  Future<Booking> updateStatus(String id, String status) async {
    final result = await _client.patch<Booking>(
      '/bookings/$id/status',
      {'status': status},
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Status update failed');
    return result;
  }

  Future<void> delete(String id) async {
    await _client.delete('/bookings/$id');
  }
}
