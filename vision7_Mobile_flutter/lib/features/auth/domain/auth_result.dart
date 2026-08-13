import 'user.dart';

class AuthResult {
  final String accessToken;
  final User user;

  const AuthResult({
    required this.accessToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    accessToken: json['accessToken'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'user': user.toJson(),
  };
}
