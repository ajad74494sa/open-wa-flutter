import 'package:meta/meta.dart';

/// Generic container for OpenWA API responses.
@immutable
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic rawJson;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.rawJson,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode, {
    T Function(dynamic json)? parser,
  }) {
    final status = statusCode >= 200 && statusCode < 300;
    final payload = json['response'] ?? json['data'] ?? json['result'] ?? json;
    
    return ApiResponse<T>(
      success: json['success'] as bool? ?? status,
      message: json['message'] as String? ?? json['error'] as String?,
      data: (parser != null && payload != null) ? parser(payload) : payload as T?,
      rawJson: json,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
  }
}
