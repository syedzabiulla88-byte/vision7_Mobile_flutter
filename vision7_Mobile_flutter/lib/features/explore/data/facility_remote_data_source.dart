import '../../../../core/network/dio_client.dart';
import '../domain/facility.dart';

class FacilityRemoteDataSource {
  final DioClient _client;
  FacilityRemoteDataSource(this._client);

  Future<List<Facility>> listPublic() async {
    final result = await _client.get<List<dynamic>>('/facilities/public');
    if (result == null) return [];
    return result
        .map((f) => Facility.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getAvailability(
    String slug,
    String date, // YYYY-MM-DD
  ) async {
    final result = await _client.get<Map<String, dynamic>>(
      '/facilities/public/$slug/availability',
      params: {'date': date},
    );
    if (result == null) throw Exception('No availability data');
    return result;
  }
}
