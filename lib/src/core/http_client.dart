import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/open_wa_config.dart';
import 'api_response.dart';
import 'exceptions.dart';

/// Secure HTTP client wrapper tailored for OpenWA API communication.
class OpenWaHttpClient {
  final OpenWaConfig config;
  final http.Client _client;

  OpenWaHttpClient(this.config, {http.Client? client})
      : _client = client ?? http.Client();

  /// Standard HTTP headers populated with secure Auth credentials.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${config.apiKey}',
        'api_key': config.apiKey,
        'User-Agent': 'OpenWA-Dart-SDK/1.0.0',
        ...config.defaultHeaders,
      };

  /// Constructs full Uri for an endpoint path with query parameters.
  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final baseUri = config.baseUri;

    Map<String, String>? stringQueryParams;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      stringQueryParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    }

    return baseUri.replace(
      path: '${baseUri.path}$cleanPath',
      queryParameters: stringQueryParams,
    );
  }

  /// Executes GET request with automatic retries and secure exception mapping.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _executeWithRetry(() => _client.get(uri, headers: _headers), parser: parser);
  }

  /// Executes POST request with JSON payload.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final jsonBody = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () => _client.post(uri, headers: _headers, body: jsonBody),
      parser: parser,
    );
  }

  /// Executes PUT request with JSON payload.
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final jsonBody = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () => _client.put(uri, headers: _headers, body: jsonBody),
      parser: parser,
    );
  }

  /// Executes DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final jsonBody = body != null ? jsonEncode(body) : null;
    return _executeWithRetry(
      () => _client.delete(uri, headers: _headers, body: jsonBody),
      parser: parser,
    );
  }

  /// Uploads binary media files (e.g., images, documents, audio) via Multipart request.
  Future<ApiResponse<T>> uploadMedia<T>(
    String path, {
    required String fieldName,
    required List<int> fileBytes,
    required String fileName,
    Map<String, String>? extraFields,
    T Function(dynamic json)? parser,
  }) async {
    final uri = _buildUri(path);
    
    Future<http.Response> requestFn() async {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headers);
      request.headers.remove('Content-Type'); // Let multipart set boundary

      if (extraFields != null) {
        request.fields.addAll(extraFields);
      }

      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(config.timeout);
      return http.Response.fromStream(streamedResponse);
    }

    return _executeWithRetry(requestFn, parser: parser);
  }

  /// Internal request runner with exponential backoff retries and security mapping.
  Future<ApiResponse<T>> _executeWithRetry<T>(
    Future<http.Response> Function() requestAction, {
    T Function(dynamic json)? parser,
  }) async {
    int attempts = 0;
    Duration delay = const Duration(milliseconds: 500);

    while (true) {
      attempts++;
      try {
        final response = await requestAction().timeout(config.timeout);
        return _parseResponse<T>(response, parser);
      } on SocketException catch (e) {
        if (attempts > config.maxRetries) {
          throw NetworkException('Network failure. Cannot reach OpenWA server.', e.message);
        }
      } on TimeoutException catch (e) {
        if (attempts > config.maxRetries) {
          throw NetworkException('Request timed out after ${config.timeout.inSeconds}s.', e.message);
        }
      } catch (e) {
        if (e is OpenWaException) rethrow;
        if (attempts > config.maxRetries) {
          throw NetworkException('Unexpected network error occurred.', e.toString());
        }
      }

      await Future.delayed(delay);
      delay *= 2; // Exponential backoff
    }
  }

  /// Parses raw HTTP response and converts server errors to explicit exception types.
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(dynamic json)? parser,
  ) {
    dynamic jsonResponseBody;
    try {
      if (response.body.isNotEmpty) {
        jsonResponseBody = jsonDecode(response.body);
      }
    } catch (_) {
      // Non-JSON response body
      jsonResponseBody = {'raw': response.body};
    }

    final statusCode = response.statusCode;

    // Handle Security & HTTP Auth Status Codes
    if (statusCode == 401 || statusCode == 403) {
      final msg = _extractErrorMessage(jsonResponseBody) ?? 'Unauthorized access. Check API key.';
      throw AuthenticationException(message: msg, statusCode: statusCode, details: jsonResponseBody);
    }

    if (statusCode == 429) {
      final msg = _extractErrorMessage(jsonResponseBody) ?? 'Rate limit exceeded.';
      throw RateLimitException(message: msg, statusCode: statusCode, details: jsonResponseBody);
    }

    if (statusCode >= 400 && statusCode < 500) {
      final msg = _extractErrorMessage(jsonResponseBody) ?? 'Client error request failed.';
      throw OpenWaApiException(message: msg, statusCode: statusCode, details: jsonResponseBody);
    }

    if (statusCode >= 500) {
      final msg = _extractErrorMessage(jsonResponseBody) ?? 'OpenWA Internal Server Error.';
      throw OpenWaApiException(message: msg, statusCode: statusCode, details: jsonResponseBody);
    }

    Map<String, dynamic> responseMap;
    if (jsonResponseBody is Map<String, dynamic>) {
      responseMap = jsonResponseBody;
    } else {
      responseMap = {'data': jsonResponseBody};
    }

    return ApiResponse.fromJson(responseMap, statusCode, parser: parser);
  }

  String? _extractErrorMessage(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json['message'] as String? ?? json['error'] as String? ?? json['reason'] as String?;
    }
    return null;
  }

  /// Closes underlying client connection.
  void close() {
    _client.close();
  }
}
