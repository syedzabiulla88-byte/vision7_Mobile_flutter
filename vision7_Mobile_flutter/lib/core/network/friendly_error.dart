import 'package:dio/dio.dart';

/// Turns a raw exception (almost always a [DioException] from the network
/// layer) into a short, user-facing message instead of the multi-paragraph
/// technical dump `DioException.toString()` produces.
String friendlyAuthErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'Network error. Please check your connection and try again.';
      default:
        break;
    }
    // Prefer the backend's actual message — it's already a safe, specific
    // NestJS exception message (e.g. "Invalid credentials", "Token audience
    // mismatch", "Account is inactive"), not a raw stack trace. Falling
    // back to a blanket "Invalid email or password" for every 401 was
    // wrong: that endpoint-agnostic message also fired for Google/Apple
    // sign-in failures, which have nothing to do with a password.
    final serverMessage = error.response?.data is Map ? error.response?.data['message'] : null;
    if (serverMessage is String && serverMessage.isNotEmpty) return serverMessage;

    final status = error.response?.statusCode;
    if (status == 401) return 'Invalid email or password. Please try again.';
    if (status == 409) return 'An account with this email already exists.';
    if (status != null && status >= 500) {
      return 'Something went wrong on our end. Please try again shortly.';
    }
  }
  return 'Something went wrong. Please try again.';
}
