import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/session_models.dart';

/// Manages WhatsApp Sessions (Creation, Authentication, QR Codes, Lifecycle).
class SessionService {
  final OpenWaHttpClient _client;

  SessionService(this._client);

  /// Initializes or starts a WhatsApp session.
  Future<ApiResponse<SessionInfo>> startSession(String sessionId) async {
    return _client.post<SessionInfo>(
      '/sessions/start',
      body: {'sessionId': sessionId},
      parser: (json) => SessionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Stops an active session safely.
  Future<ApiResponse<bool>> stopSession(String sessionId) async {
    return _client.post<bool>(
      '/sessions/stop',
      body: {'sessionId': sessionId},
      parser: (json) => json['stopped'] as bool? ?? true,
    );
  }

  /// Restarts an existing session.
  Future<ApiResponse<SessionInfo>> restartSession(String sessionId) async {
    return _client.post<SessionInfo>(
      '/sessions/restart',
      body: {'sessionId': sessionId},
      parser: (json) => SessionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches current status and metadata of a session.
  Future<ApiResponse<SessionInfo>> getSessionInfo(String sessionId) async {
    return _client.get<SessionInfo>(
      '/sessions/$sessionId',
      parser: (json) => SessionInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Obtains QR Code for device pairing.
  Future<ApiResponse<QrCodeResponse>> getQrCode(String sessionId) async {
    return _client.get<QrCodeResponse>(
      '/sessions/$sessionId/qr',
      parser: (json) => QrCodeResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Terminates and logs out session.
  Future<ApiResponse<bool>> logoutSession(String sessionId) async {
    return _client.post<bool>(
      '/sessions/logout',
      body: {'sessionId': sessionId},
      parser: (json) => json['loggedOut'] as bool? ?? true,
    );
  }

  /// Force kills a stuck session process.
  Future<ApiResponse<bool>> killSession(String sessionId) async {
    return _client.post<bool>(
      '/sessions/kill',
      body: {'sessionId': sessionId},
      parser: (json) => true,
    );
  }

  /// Lists all active sessions running on the server.
  Future<ApiResponse<List<SessionInfo>>> listSessions() async {
    return _client.get<List<SessionInfo>>(
      '/sessions',
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => SessionInfo.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Checks authentication state of session.
  Future<ApiResponse<bool>> checkAuthStatus(String sessionId) async {
    return _client.get<bool>(
      '/sessions/$sessionId/auth',
      parser: (json) => json['authenticated'] as bool? ?? false,
    );
  }
}
