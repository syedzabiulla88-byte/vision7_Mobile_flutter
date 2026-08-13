import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user';
  static const _modeKey = 'vision7-mode';
  static const _langKey = 'vision7-lang';
  static const _onboardingKey = 'vision7-onboarding-done';
  static const _pushTokenKey = 'vision7-push-token';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  StorageService(this._secureStorage, this._prefs);

  // Token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (_) {
      return _prefs.getString(_tokenKey);
    }
  }

  Future<void> setToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (_) {
      await _prefs.setString(_tokenKey, token);
    }
  }

  // User
  Future<void> setUser(Map<String, dynamic> user) async {
    try {
      await _secureStorage.write(key: _userKey, value: jsonEncode(user));
    } catch (_) {
      await _prefs.setString(_userKey, jsonEncode(user));
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final raw = await _secureStorage.read(key: _userKey);
      if (raw != null) return jsonDecode(raw);
    } catch (_) {
      final raw = _prefs.getString(_userKey);
      if (raw != null) return jsonDecode(raw);
    }
    return null;
  }

  // Mode
  Future<String?> getMode() async => _prefs.getString(_modeKey);
  Future<void> setMode(String mode) async => await _prefs.setString(_modeKey, mode);

  // Language
  Future<String?> getLanguage() async => _prefs.getString(_langKey);
  Future<void> setLanguage(String lang) async => await _prefs.setString(_langKey, lang);

  // Onboarding
  Future<bool> isOnboardingDone() async => _prefs.getBool(_onboardingKey) ?? false;
  Future<void> setOnboardingDone() async => await _prefs.setBool(_onboardingKey, true);

  // Push token
  Future<String?> getPushToken() async => _prefs.getString(_pushTokenKey);
  Future<void> setPushToken(String token) async => await _prefs.setString(_pushTokenKey, token);

  // Clear all
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
