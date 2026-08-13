import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/auth_result.dart';
import '../domain/user.dart';
import '../domain/auth_repository.dart';
import 'auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'user';

  AuthRepositoryImpl(this._remote, this._secureStorage, this._prefs);

  @override
  Future<AuthResult> login(String email, String password) =>
      _remote.login(email, password);

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) =>
      _remote.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        gender: gender,
      );

  @override
  Future<AuthResult> googleLogin(String idToken) => _remote.googleLogin(idToken);

  @override
  Future<AuthResult> appleLogin(String idToken, {Map<String, dynamic>? user}) =>
      _remote.appleLogin(idToken, user: user);

  @override
  Future<void> forgotPassword(String email) => _remote.forgotPassword(email);

  @override
  Future<User?> getProfile() => _remote.getProfile();

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<User?> getStoredUser() async {
    try {
      final raw = await _secureStorage.read(key: _userKey);
      if (raw != null) return User.fromJson(jsonDecode(raw));
    } catch (_) {
      final raw = _prefs.getString(_userKey);
      if (raw != null) return User.fromJson(jsonDecode(raw));
    }
    return null;
  }

  @override
  Future<void> saveUser(User user) async {
    final encoded = jsonEncode(user.toJson());
    try {
      await _secureStorage.write(key: _userKey, value: encoded);
    } catch (_) {
      await _prefs.setString(_userKey, encoded);
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (_) {
      await _prefs.setString(_tokenKey, token);
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (_) {
      return _prefs.getString(_tokenKey);
    }
  }

  @override
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
