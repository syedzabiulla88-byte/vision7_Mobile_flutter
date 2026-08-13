import 'facility.dart';

abstract class FacilityRepository {
  Future<List<Facility>> listPublic();
  Future<Map<String, dynamic>> getAvailability(String slug, String date);
}
