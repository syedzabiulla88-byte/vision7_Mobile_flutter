import 'package:vision7/core/network/dio_client.dart';
import '../domain/auth_result.dart';
import '../domain/user.dart';

class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource(this._client);

  Future<void> acceptConsent(String type, String version) async {
    await _client.post('/me/consent', {'type': type, 'version': version});
  }

  Future<AuthResult> login(String email, String password) async {
    final result = await _client.post<AuthResult>(
      '/auth/login',
      {'email': email, 'password': password},
      fromJson: (json) => AuthResult(
        accessToken: json['accessToken'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      ),
    );
    if (result == null) throw Exception('Login failed');
    return result;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
    };
    final result = await _client.post<AuthResult>(
      '/auth/register',
      body,
      fromJson: (json) => AuthResult(
        accessToken: json['accessToken'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      ),
    );
    if (result == null) throw Exception('Registration failed');
    return result;
  }

  Future<User?> getProfile() async {
    final result = await _client.get<User>(
      '/auth/profile',
      fromJson: (json) => User.fromJson(json as Map<String, dynamic>),
    );
    return result;
  }

  Future<void> forgotPassword(String email) async {
    await _client.post('/auth/forgot-password', {'email': email});
  }

  Future<void> deleteAccount() async {
    await _client.delete('/me/account');
  }
}
