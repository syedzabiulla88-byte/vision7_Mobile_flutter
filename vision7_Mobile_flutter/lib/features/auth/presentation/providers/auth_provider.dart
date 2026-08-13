import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  User? _user;
  bool _isLoading = true;
  String? _error;

  AuthProvider(this._repository) {
    _loadUser();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _repository.getStoredUser();
      try {
        final profile = await _repository.getProfile();
        if (profile != null) {
          _user = profile;
          await _repository.saveUser(profile);
        }
      } on Exception {
        await _repository.clearAll();
        _user = null;
      }
    } on Exception {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.login(email, password);
      await _repository.saveToken(result.accessToken);
      await _repository.saveUser(result.user);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  }) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        gender: gender,
      );
      await _repository.saveToken(result.accessToken);
      await _repository.saveUser(result.user);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleLogin(String idToken) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.googleLogin(idToken);
      await _repository.saveToken(result.accessToken);
      await _repository.saveUser(result.user);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> appleLogin(String idToken, {Map<String, dynamic>? user}) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.appleLogin(idToken, user: user);
      await _repository.saveToken(result.accessToken);
      await _repository.saveUser(result.user);
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.forgotPassword(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _repository.getProfile();
      if (profile != null) {
        _user = profile;
        await _repository.saveUser(profile);
        notifyListeners();
      }
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
