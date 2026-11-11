import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/session_models.dart';

/// Manages WhatsApp Sessions (Creation, Authentication, QR Codes, Lifecycle).
class SessionService {
  final OpenWaHttpClient _client;

  SessionService(this._client);

  /// Creates a new named session and returns its server-assigned UUID.
  Future<ApiResponse<SessionInfo>> createSession(String name) async {
    return _client.post<SessionInfo>(
      '/api/sessions',
      body: {'name': name},
      parser: (json) => SessionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Initializes or starts a WhatsApp session.
  Future<ApiResponse<SessionInfo>> startSession(String sessionId) async {
    return _client.post<SessionInfo>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}/start',
      parser: (json) => SessionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Stops an active session safely.
  Future<ApiResponse<bool>> stopSession(String sessionId) async {
    return _client.post<bool>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}/stop',
      parser: (_) => true,
    );
  }

  /// Restarts an existing session.
  Future<ApiResponse<SessionInfo>> restartSession(String sessionId) async {
    await stopSession(sessionId);
    return startSession(sessionId);
  }

  /// Fetches current status and metadata of a session.
  Future<ApiResponse<SessionInfo>> getSessionInfo(String sessionId) async {
    return _client.get<SessionInfo>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}',
      parser: (json) => SessionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Obtains QR Code for device pairing.
  Future<ApiResponse<QrCodeResponse>> getQrCode(String sessionId) async {
    return _client.get<QrCodeResponse>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}/qr',
      parser: (json) => QrCodeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Terminates and logs out session.
  Future<ApiResponse<bool>> logoutSession(String sessionId) async {
    return _client.post<bool>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}/logout',
      parser: (_) => true,
    );
  }

  /// Force kills a stuck session process.
  Future<ApiResponse<bool>> killSession(String sessionId) async {
    return _client.post<bool>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}/force-kill',
      parser: (json) => true,
    );
  }

  /// Lists all active sessions running on the server.
  Future<ApiResponse<List<SessionInfo>>> listSessions() async {
    return _client.get<List<SessionInfo>>(
      '/api/sessions',
      parser: _parseSessions,
    );
  }

  /// Checks authentication state of session.
  Future<ApiResponse<bool>> checkAuthStatus(String sessionId) async {
    return _client.get<bool>(
      '/api/sessions/${Uri.encodeComponent(sessionId)}',
      parser: (json) =>
          (json['status'] as String?)?.toLowerCase() == 'ready',
    );
  }
}

List<SessionInfo> _parseSessions(dynamic json) {
  if (json is List) {
    return json.map((item) {
      if (item is! Map) {
        throw const FormatException('Session entries must be JSON objects.');
      }
      return SessionInfo.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    for (final key in ['sessions', 'items', 'instances']) {
      if (map.containsKey(key)) {
        return _parseSessions(map[key]);
      }
    }

    if (map.containsKey('id') ||
        map.containsKey('sessionId') ||
        map.containsKey('session') ||
        map.containsKey('status')) {
      return [SessionInfo.fromJson(map)];
    }

    if (map.isEmpty) return [];

    final sessions = <SessionInfo>[];
    for (final entry in map.entries) {
      if (entry.value is String) {
        final status = SessionStatus.fromString(entry.value as String);
        sessions.add(
          SessionInfo(sessionId: entry.key, status: status),
        );
      } else if (entry.value is Map) {
        final session = Map<String, dynamic>.from(entry.value as Map);
        session.putIfAbsent('sessionId', () => entry.key);
        sessions.add(SessionInfo.fromJson(session));
      } else {
        throw const FormatException(
          'Session response must be a list or session object.',
        );
      }
    }
    return sessions;
  }

  throw const FormatException(
    'Session response must be a list or session object.',
  );
}
