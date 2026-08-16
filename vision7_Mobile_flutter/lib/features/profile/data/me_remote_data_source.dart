import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../domain/profile_models.dart';

class MeRemoteDataSource {
  final DioClient _client;
  MeRemoteDataSource(this._client);

  Future<Profile> getProfile() async {
    final result = await _client.get<Profile>('/me/profile',
        fromJson: (json) => Profile.fromJson(json as Map<String, dynamic>));
    if (result == null) throw Exception('Failed to load profile');
    return result;
  }

  Future<Dashboard> getDashboard() async {
    final result = await _client.get<Dashboard>('/me/dashboard',
        fromJson: (json) => Dashboard.fromJson(json as Map<String, dynamic>));
    if (result == null) throw Exception('Failed to load dashboard');
    return result;
  }

  Future<void> updateProfilePhoto(String photoPath) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photoPath),
    });
    await _client.post('/me/profile/photo', formData);
  }
}
