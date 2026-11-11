import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/api_endpoint_catalog.dart';

class OpenWaApiFile {
  final String fieldName;
  final String fileName;
  final List<int> bytes;

  const OpenWaApiFile({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
  });
}

/// Dispatches any operation in the official OpenWA endpoint catalog.
class OpenWaApiService {
  static const endpoints = openWaApiEndpoints;
  static final _endpointsById = {
    for (final endpoint in endpoints) endpoint.operationId: endpoint,
  };

  final OpenWaHttpClient _client;

  OpenWaApiService(this._client);

  static OpenWaApiEndpoint endpointFor(String operationId) {
    final endpoint = _endpointsById[operationId];
    if (endpoint == null) {
      throw ArgumentError.value(
        operationId,
        'operationId',
        'Unknown OpenWA API operation.',
      );
    }
    return endpoint;
  }

  Future<ApiResponse<dynamic>> invoke(
    String operationId, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? body,
    List<OpenWaApiFile> files = const [],
    Map<String, String> headers = const {},
  }) async {
    final endpoint = endpointFor(operationId);
    final missingPathParameters = endpoint.pathParameters
        .where(
          (parameter) =>
              parameter.required &&
              (pathParameters[parameter.name]?.trim().isEmpty ?? true),
        )
        .map((parameter) => parameter.name)
        .toList();
    if (missingPathParameters.isNotEmpty) {
      throw FormatException(
        'Missing required path parameter(s): ${missingPathParameters.join(', ')}.',
      );
    }

    final missingQueryParameters = endpoint.queryParameters
        .where(
          (parameter) =>
              parameter.required &&
              (queryParameters[parameter.name] == null ||
                  queryParameters[parameter.name].toString().isEmpty),
        )
        .map((parameter) => parameter.name)
        .toList();
    if (missingQueryParameters.isNotEmpty) {
      throw FormatException(
        'Missing required query parameter(s): ${missingQueryParameters.join(', ')}.',
      );
    }
    final missingHeaderParameters = endpoint.parameters
        .where(
          (parameter) =>
              parameter.location == 'header' &&
              parameter.required &&
              _headerValue(headers, parameter.name) == null,
        )
        .map((parameter) => parameter.name)
        .toList();
    if (missingHeaderParameters.isNotEmpty) {
      throw FormatException(
        'Missing required header(s): ${missingHeaderParameters.join(', ')}.',
      );
    }
    if (endpoint.requestBodyRequired && body == null) {
      throw const FormatException('This operation requires a request body.');
    }

    final path = endpoint.path.replaceAllMapped(RegExp(r'\{([^}]+)\}'), (
      match,
    ) {
      final name = match.group(1)!;
      final value = pathParameters[name];
      if (value == null || value.trim().isEmpty) {
        throw FormatException('Missing path parameter "$name".');
      }
      return Uri.encodeComponent(value);
    });
    final nonNullQueryParameters = Map<String, dynamic>.fromEntries(
      queryParameters.entries.where((entry) => entry.value != null),
    );

    if (endpoint.requestContentType == 'multipart/form-data') {
      if (body != null && body is! Map<String, dynamic>) {
        throw const FormatException(
          'Multipart request fields must be provided as a JSON object.',
        );
      }
      if (files.isEmpty) {
        throw const FormatException(
          'This multipart operation requires at least one file.',
        );
      }
      final fields = <String, String>{};
      if (body is Map<String, dynamic>) {
        for (final entry in body.entries) {
          final value = entry.value;
          fields[entry.key] = value is String ? value : jsonEncode(value);
        }
      }
      return _client.uploadMultipart<dynamic>(
        path,
        method: endpoint.method,
        fields: fields,
        files: files
            .map(
              (file) =>
                  () => http.MultipartFile.fromBytes(
                    file.fieldName,
                    file.bytes,
                    filename: file.fileName,
                  ),
            )
            .toList(),
        queryParameters: nonNullQueryParameters,
        headers: headers,
        parser: (json) => json,
      );
    }

    if (files.isNotEmpty) {
      throw const FormatException(
        'Files are only supported by multipart/form-data operations.',
      );
    }
    return _client.request<dynamic>(
      endpoint.method,
      path,
      body: body,
      queryParameters: nonNullQueryParameters,
      headers: headers,
      parser: (json) => json,
    );
  }

  String? _headerValue(Map<String, String> headers, String name) {
    if (name.toLowerCase() == 'x-api-key') return _client.config.apiKey;
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) return entry.value;
    }
    return null;
  }
}
