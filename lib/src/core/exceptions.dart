/// Base exception class for all OpenWA errors.
abstract class OpenWaException implements Exception {
  final String message;
  final dynamic details;

  const OpenWaException(this.message, [this.details]);

  @override
  String toString() => 'OpenWaException: $message${details != null ? ' ($details)' : ''}';
}

/// Thrown when the OpenWA server returns an HTTP error status.
class OpenWaApiException extends OpenWaException {
  final int statusCode;

  const OpenWaApiException({
    required String message,
    required this.statusCode,
    dynamic details,
  }) : super(message, details);

  @override
  String toString() => 'OpenWaApiException [$statusCode]: $message';
}

/// Thrown when authentication fails (401 Unauthorized / 403 Forbidden).
class AuthenticationException extends OpenWaApiException {
  const AuthenticationException({
    required super.message,
    required super.statusCode,
    super.details,
  });
}

/// Thrown when rate limiting is exceeded (429 Too Many Requests).
class RateLimitException extends OpenWaApiException {
  final Duration? retryAfter;

  const RateLimitException({
    required super.message,
    required super.statusCode,
    this.retryAfter,
    super.details,
  });
}

/// Thrown when a network error occurs (timeout, DNS failure, socket error).
class NetworkException extends OpenWaException {
  const NetworkException(super.message, [super.details]);
}

/// Thrown when request payload validation fails on client or server side.
class ValidationException extends OpenWaException {
  const ValidationException(super.message, [super.details]);
}

/// Thrown when webhook signature HMAC verification fails.
class WebhookSignatureException extends OpenWaException {
  const WebhookSignatureException(super.message, [super.details]);
}
