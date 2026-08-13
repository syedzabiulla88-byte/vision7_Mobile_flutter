import './booking.dart';

abstract class BookingRepository {
  // Public (no auth)
  Future<Booking> createPublic(Map<String, dynamic> dto);

  // Authenticated user
  Future<List<Booking>> listMyBookings();
  Future<Booking> getById(String id);

  // Admin endpoints
  Future<List<Booking>> list(Map<String, dynamic> query);
  Future<Booking> create(Map<String, dynamic> dto);
  Future<Booking> updateStatus(String id, String status);
  Future<void> delete(String id);

  // Convenience: cancel a booking
  Future<Booking> cancel(String id) => updateStatus(id, 'cancelled');
}
