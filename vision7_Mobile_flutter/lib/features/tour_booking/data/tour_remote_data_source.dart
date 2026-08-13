import '../../../../core/network/dio_client.dart';
import '../domain/tour_models.dart';

class TourRemoteDataSource {
  final DioClient _client;
  TourRemoteDataSource(this._client);

  Future<TourAvailability> getAvailability(String date) async {
    final result = await _client.get<Map<String, dynamic>>(
      '/tours/availability',
      params: {'date': date},
    );
    if (result == null) throw Exception('No availability data');
    return TourAvailability.fromJson(result);
  }

  Future<TourWindow> getWindow() async {
    final result = await _client.get<Map<String, dynamic>>('/tours/window');
    if (result == null) throw Exception('No window data');
    return TourWindow.fromJson(result);
  }

  Future<TourBookingResult> book(Map<String, dynamic> body) async {
    final result = await _client.post<TourBookingResult>(
      '/tours/book',
      body,
      fromJson: (json) => TourBookingResult.fromJson(
          json as Map<String, dynamic>),
    );
    if (result == null) throw Exception('Booking failed');
    return result;
  }
}
