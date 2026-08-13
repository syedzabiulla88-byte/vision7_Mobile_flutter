import '../domain/tour_models.dart';
import '../domain/tour_repository.dart';
import '../data/tour_remote_data_source.dart';

class TourRepositoryImpl implements TourRepository {
  final TourRemoteDataSource _remote;
  TourRepositoryImpl(this._remote);

  @override
  Future<TourAvailability> getAvailability(String date) =>
      _remote.getAvailability(date);

  @override
  Future<TourWindow> getWindow() => _remote.getWindow();

  @override
  Future<TourBookingResult> book(Map<String, dynamic> body) =>
      _remote.book(body);
}
