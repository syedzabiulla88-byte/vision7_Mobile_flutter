class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    final success = json['success'] ?? json['status'] == 'success' ?? true;
    final data = json['data'];
    final message = json['message'];
    final error = json['error'];

    T? parsedData;
    if (data != null && fromJson != null) {
      parsedData = fromJson(data);
    } else if (data != null) {
      parsedData = data as T;
    }

    return ApiResponse<T>(
      success: success,
      data: parsedData,
      message: message,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data,
      if (message != null) 'message': message,
      if (error != null) 'error': error,
    };
  }
}
