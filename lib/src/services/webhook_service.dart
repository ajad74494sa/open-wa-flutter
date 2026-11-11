import '../core/api_response.dart';
import '../core/exceptions.dart';
import '../core/http_client.dart';
import '../core/security_utils.dart';
import '../models/webhook_models.dart';

/// Webhook configuration and event signature verification service.
class WebhookService {
  final OpenWaHttpClient _client;

  WebhookService(this._client);

  /// Registers a new webhook listener URL for real-time events.
  /// 
  /// Automatically tries multiple standard OpenWA server path conventions
  /// (/webhooks/register, /webhook, /sessions/{sessionId}/webhook) to prevent 404 errors.
  Future<ApiResponse<WebhookConfig>> registerWebhook(
    WebhookConfig config, {
    String sessionId = 'default',
  }) async {
    final paths = [
      '/webhooks/register',
      '/webhook',
      '/sessions/$sessionId/webhook',
      '/api/webhook',
    ];

    OpenWaApiException? lastException;

    for (final path in paths) {
      try {
        return await _client.post<WebhookConfig>(
          path,
          body: config.toJson(),
          parser: (json) => WebhookConfig.fromJson(json as Map<String, dynamic>),
        );
      } on OpenWaApiException catch (e) {
        lastException = e;
        if (e.statusCode != 404) {
          rethrow; // If it's 401, 400, 500 etc., throw immediately
        }
        // If 404, try next path format
      }
    }

    throw lastException ?? const OpenWaApiException(
      message: 'Failed to register webhook: All endpoint paths returned 404.',
      statusCode: 404,
    );
  }

  /// Removes a registered webhook callback endpoint.
  Future<ApiResponse<bool>> unregisterWebhook(String url, {String sessionId = 'default'}) async {
    final paths = [
      '/webhooks/unregister',
      '/webhook',
      '/sessions/$sessionId/webhook',
    ];

    OpenWaApiException? lastException;

    for (final path in paths) {
      try {
        return await _client.delete<bool>(
          path,
          body: {'url': url},
          parser: (json) => json['unregistered'] as bool? ?? json['success'] as bool? ?? true,
        );
      } on OpenWaApiException catch (e) {
        lastException = e;
        if (e.statusCode != 404) rethrow;
      }
    }

    throw lastException ?? const OpenWaApiException(
      message: 'Failed to unregister webhook: All endpoint paths returned 404.',
      statusCode: 404,
    );
  }

  /// Retrieves list of all active registered webhooks.
  Future<ApiResponse<List<WebhookConfig>>> listWebhooks({String sessionId = 'default'}) async {
    final paths = [
      '/webhooks',
      '/webhook',
      '/sessions/$sessionId/webhook',
    ];

    OpenWaApiException? lastException;

    for (final path in paths) {
      try {
        return await _client.get<List<WebhookConfig>>(
          path,
          parser: (json) {
            if (json is List) {
              return json.map((e) => WebhookConfig.fromJson(e as Map<String, dynamic>)).toList();
            } else if (json is Map && json['webhooks'] is List) {
              return (json['webhooks'] as List).map((e) => WebhookConfig.fromJson(e as Map<String, dynamic>)).toList();
            }
            return [];
          },
        );
      } on OpenWaApiException catch (e) {
        lastException = e;
        if (e.statusCode != 404) rethrow;
      }
    }

    throw lastException ?? const OpenWaApiException(
      message: 'Failed to list webhooks: All endpoint paths returned 404.',
      statusCode: 404,
    );
  }

  /// Validates signature digest of an incoming webhook push payload using configured secret.
  bool verifySignature({
    required String rawPayload,
    required String signatureHeader,
    required String secret,
  }) {
    return SecurityUtils.verifyWebhookSignature(
      rawPayload: rawPayload,
      signatureHeader: signatureHeader,
      secret: secret,
    );
  }
}
