import '../domain/booking.dart';
import '../domain/booking_repository.dart';
import '../data/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;
  BookingRepositoryImpl(this._remote);

  @override
  Future<Booking> createPublic(Map<String, dynamic> dto) =>
      _remote.createPublic(dto);

  @override
  Future<List<Booking>> listMyBookings() => _remote.listMyBookings();

  @override
  Future<Booking> getById(String id) => _remote.getById(id);

  @override
  Future<List<Booking>> list(Map<String, dynamic> query) =>
      _remote.list(query);

  @override
  Future<Booking> create(Map<String, dynamic> dto) => _remote.create(dto);

  @override
  Future<Booking> updateStatus(String id, String status) =>
      _remote.updateStatus(id, status);

  @override
  Future<Booking> cancel(String id) => updateStatus(id, 'cancelled');

  @override
  Future<void> delete(String id) => _remote.delete(id);
}
