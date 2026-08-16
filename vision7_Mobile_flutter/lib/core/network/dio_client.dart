import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String defaultApiBaseUrl = 'https://api.vision7.sa/api';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _activeRefresh;

  DioClient._internal() {
    final env = dotenv.env;
    final baseUrl = env['API_BASE_URL'] ?? defaultApiBaseUrl;

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Request interceptor — attach auth token
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}
        return handler.next(options);
      },
    ));

    // Response interceptor — handle 401 with single-flight refresh
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode != 401) {
          return handler.next(error);
        }

        final extra = error.requestOptions.extra;
        if (extra['retry'] == true) {
          return handler.next(error);
        }

        // Single-flight: one refresh at a time
        if (_activeRefresh == null) {
          final refreshFuture = _refreshToken();
          _activeRefresh = 'pending';
          final newToken = await refreshFuture;
          _activeRefresh = null;

          if (newToken != null) {
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            opts.extra['retry'] = true;
            try {
              final retryResponse = await dio.fetch(opts);
              return handler.resolve(retryResponse);
            } catch (e) {
              return handler.next(error);
            }
          }
        } else {
          // Wait for in-flight refresh
          while (_activeRefresh == 'pending') {
            await Future.delayed(const Duration(milliseconds: 50));
          }
          // After waiting, check if we can retry with the new token
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null && token != error.requestOptions.headers['Authorization']) {
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $token';
            opts.extra['retry'] = true;
            try {
              final retryResponse = await dio.fetch(opts);
              return handler.resolve(retryResponse);
            } catch (e) {
              return handler.next(error);
            }
          }
        }

        // Clear and redirect to login
        await _secureStorage.delete(key: 'auth_token');
        await _secureStorage.delete(key: 'user');
        return handler.next(error);
      },
    ));
  }

  Future<String?> _refreshToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await dio.get('/auth/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final newToken = response.data?['data']?['accessToken'];
      if (newToken != null) {
        await _secureStorage.write(key: 'auth_token', value: newToken);
        return newToken;
      }
    } catch (_) {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user');
    }
    return null;
  }

  Future<T?> get<T>(String path, {Map<String, dynamic>? params, T Function(dynamic)? fromJson}) async {
    final response = await dio.get(path, queryParameters: params);
    final data = response.data?['data'];
    if (data == null) return null;
    return fromJson != null ? fromJson(data) : data as T;
  }

  Future<T?> post<T>(String path, dynamic data, {T Function(dynamic)? fromJson}) async {
    final response = await dio.post(path, data: data);
    final resultData = response.data?['data'];
    if (resultData == null) return null;
    return fromJson != null ? fromJson(resultData) : resultData as T;
  }

  Future<T?> put<T>(String path, dynamic data, {T Function(dynamic)? fromJson}) async {
    final response = await dio.put(path, data: data);
    final resultData = response.data?['data'];
    if (resultData == null) return null;
    return fromJson != null ? fromJson(resultData) : resultData as T;
  }

  Future<T?> patch<T>(String path, dynamic data, {T Function(dynamic)? fromJson}) async {
    final response = await dio.patch(path, data: data);
    final resultData = response.data?['data'];
    if (resultData == null) return null;
    return fromJson != null ? fromJson(resultData) : resultData as T;
  }

  Future<void> delete(String path, {Map<String, dynamic>? data}) async {
    await dio.delete(path, data: data);
  }
}
