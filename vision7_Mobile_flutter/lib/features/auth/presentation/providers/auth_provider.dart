import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user.dart';
import '../../../../shared/services/push_notification_service.dart';
import '../../../../core/network/friendly_error.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final PushNotificationService? _push;
  User? _user;
  bool _isLoading = true;
  String? _error;

  AuthProvider(this._repository, [this._push]) {
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
          unawaited(_push?.initialize());
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
      unawaited(_push?.initialize());
      return true;
    } catch (e) {
      _error = friendlyAuthErrorMessage(e);
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
      unawaited(_push?.initialize());
      return true;
    } catch (e) {
      _error = friendlyAuthErrorMessage(e);
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
      _error = friendlyAuthErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _push?.onLogout();
    await _repository.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  /// Permanently deletes the account server-side, then clears local session
  /// state the same way logout() does.
  Future<bool> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      await _push?.onLogout();
      await _repository.logout();
      _user = null;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = friendlyAuthErrorMessage(e);
      notifyListeners();
      return false;
    }
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

  /// Record acceptance of a versioned legal document (terms/privacy). Never
  /// blocks the caller on failure — consent recording shouldn't stop the
  /// user from proceeding into the app they just registered for.
  Future<void> acceptConsent(String type, String version) async {
    try {
      await _repository.acceptConsent(type, version);
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
