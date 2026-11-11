import '../core/api_response.dart';
import '../core/http_client.dart';
import '../core/security_utils.dart';
import '../models/webhook_models.dart';

/// Webhook configuration and event signature verification service.
class WebhookService {
  final OpenWaHttpClient _client;

  WebhookService(this._client);

  /// Registers a new webhook listener URL for real-time events.
  Future<ApiResponse<WebhookConfig>> registerWebhook(WebhookConfig config) async {
    return _client.post<WebhookConfig>(
      '/webhooks/register',
      body: config.toJson(),
      parser: (json) => WebhookConfig.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Removes a registered webhook callback endpoint.
  Future<ApiResponse<bool>> unregisterWebhook(String url) async {
    return _client.post<bool>(
      '/webhooks/unregister',
      body: {'url': url},
      parser: (json) => json['unregistered'] as bool? ?? true,
    );
  }

  /// Retrieves list of all active registered webhooks.
  Future<ApiResponse<List<WebhookConfig>>> listWebhooks() async {
    return _client.get<List<WebhookConfig>>(
      '/webhooks',
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => WebhookConfig.fromJson(e as Map<String, dynamic>)).toList();
      },
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
