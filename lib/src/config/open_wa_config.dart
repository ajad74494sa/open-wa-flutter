import 'package:meta/meta.dart';

/// Configuration options for the OpenWA API Client.
///
/// Designed with immutability and security best practices to protect sensitive API credentials.
@immutable
class OpenWaConfig {
  /// The base URL of your OpenWA server (e.g., `https://api.yourdomain.com`).
  final String baseUrl;

  /// Secret API Key used to authenticate HTTP requests.
  final String apiKey;

  /// Optional secret used for verifying webhook signature HMAC SHA-256 hashes.
  final String? webhookSecret;

  /// Request timeout duration. Defaults to 30 seconds.
  final Duration timeout;

  /// Maximum number of retries for transient network failures. Defaults to 3.
  final int maxRetries;

  /// Whether to strictly enforce HTTPS URLs for API security. Defaults to true.
  final bool requireHttps;

  /// Custom default headers to append to every request.
  final Map<String, String> defaultHeaders;

  OpenWaConfig({
    required this.baseUrl,
    required this.apiKey,
    this.webhookSecret,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.requireHttps = true,
    this.defaultHeaders = const {},
  }) {
    _validate();
  }

  void _validate() {
    if (baseUrl.isEmpty) {
      throw ArgumentError('baseUrl must not be empty.');
    }
    if (apiKey.isEmpty) {
      throw ArgumentError('apiKey must not be empty.');
    }
    if (requireHttps && !baseUrl.toLowerCase().startsWith('https://')) {
      throw ArgumentError(
        'Base URL must use HTTPS for secure communication when requireHttps is enabled.',
      );
    }
    if (maxRetries < 0) {
      throw ArgumentError('maxRetries cannot be negative.');
    }
  }

  /// Sanitized normalized base URI without trailing slash.
  Uri get baseUri {
    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse(cleanUrl);
  }

  /// Redacts sensitive information when printing configuration.
  @override
  String toString() {
    final redactedKey = apiKey.length > 4
        ? '${apiKey.substring(0, 4)}***'
        : '***';
    return 'OpenWaConfig(baseUrl: $baseUrl, apiKey: $redactedKey, timeout: ${timeout.inSeconds}s, maxRetries: $maxRetries)';
  }
}
