import 'profile_models.dart';

abstract class MeRepository {
  Future<Profile> getProfile();
  Future<Dashboard> getDashboard();
  Future<void> updateProfilePhoto(String photoPath);
}
