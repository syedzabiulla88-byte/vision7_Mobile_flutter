import '../domain/me_repository.dart';
import '../data/me_remote_data_source.dart';
import '../domain/profile_models.dart';

class MeRepositoryImpl implements MeRepository {
  final MeRemoteDataSource _remote;
  MeRepositoryImpl(this._remote);

  @override
  Future<Profile> getProfile() => _remote.getProfile();

  @override
  Future<Dashboard> getDashboard() => _remote.getDashboard();

  @override
  Future<void> updateProfilePhoto(String photoPath) =>
      _remote.updateProfilePhoto(photoPath);
}
