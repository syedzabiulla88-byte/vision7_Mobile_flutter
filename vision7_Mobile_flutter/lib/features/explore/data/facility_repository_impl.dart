import '../domain/facility.dart';
import '../domain/facility_repository.dart';
import '../data/facility_remote_data_source.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  final FacilityRemoteDataSource _remote;
  FacilityRepositoryImpl(this._remote);

  @override
  Future<List<Facility>> listPublic() => _remote.listPublic();

  @override
  Future<Map<String, dynamic>> getAvailability(String slug, String date) =>
      _remote.getAvailability(slug, date);
}
