import '../domain/auth_result.dart';
import '../domain/user.dart';

abstract class AuthRepository {
  Future<void> acceptConsent(String type, String version);
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? gender,
  });
  Future<User?> getProfile();
  Future<void> forgotPassword(String email);
  Future<void> deleteAccount();
  Future<void> logout();
  Future<User?> getStoredUser();
  Future<void> saveUser(User user);
  Future<void> saveToken(String token);
  Future<String?> getStoredToken();
  Future<void> clearAll();
}
