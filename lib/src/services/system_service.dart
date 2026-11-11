import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/system_models.dart';

/// Server health monitoring, system statistics, and infrastructure metrics service.
class SystemService {
  final OpenWaHttpClient _client;

  SystemService(this._client);

  /// Obtains overall OpenWA server health status.
  Future<ApiResponse<ServerHealth>> getHealth() async {
    return _client.get<ServerHealth>(
      '/health',
      parser: (json) => ServerHealth.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Obtains messaging and webhook server performance metrics.
  Future<ApiResponse<ServerMetrics>> getMetrics() async {
    return _client.get<ServerMetrics>(
      '/metrics',
      parser: (json) => ServerMetrics.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Retrieves server audit history log entries.
  Future<ApiResponse<List<Map<String, dynamic>>>> getAuditLogs() async {
    return _client.get<List<Map<String, dynamic>>>(
      '/audit',
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
  }

  /// Fetches system statistics overview.
  Future<ApiResponse<Map<String, dynamic>>> getStatistics() async {
    return _client.get<Map<String, dynamic>>(
      '/statistics',
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );
  }
}
