import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'exceptions.dart';

/// Cryptographic and security utilities for OpenWA SDK.
class SecurityUtils {
  SecurityUtils._();

  /// Computes HMAC SHA-256 signature for a raw payload string using a secret key.
  static String computeHmacSha256(String payload, String secret) {
    final secretBytes = utf8.encode(secret);
    final payloadBytes = utf8.encode(payload);
    final hmac = Hmac(sha256, secretBytes);
    final digest = hmac.convert(payloadBytes);
    return digest.toString();
  }

  /// Verifies incoming webhook HMAC SHA-256 signature securely against timing attacks.
  ///
  /// Throws [WebhookSignatureException] if validation fails.
  static bool verifyWebhookSignature({
    required String rawPayload,
    required String signatureHeader,
    required String secret,
  }) {
    if (secret.isEmpty) {
      throw const WebhookSignatureException('Webhook secret is not configured.');
    }
    if (signatureHeader.isEmpty) {
      throw const WebhookSignatureException('Missing signature header.');
    }

    final expectedSignature = computeHmacSha256(rawPayload, secret);
    final cleanProvidedSignature = signatureHeader.replaceFirst('sha256=', '');

    final isValid = timingSafeEqual(expectedSignature, cleanProvidedSignature);
    if (!isValid) {
      throw const WebhookSignatureException('Invalid webhook signature HMAC digest.');
    }
    return true;
  }

  /// Constant-time string comparison to prevent timing side-channel attacks.
  static bool timingSafeEqual(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Redacts sensitive information from log outputs (e.g. phone numbers, auth tokens).
  static String sanitizeLog(String input) {
    // Redact bearer tokens
    var sanitized = input.replaceAllMapped(
      RegExp(r'(Bearer\s+)[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      (m) => '${m.group(1)}[REDACTED]',
    );
    // Redact api_key query parameters or JSON fields
    sanitized = sanitized.replaceAllMapped(
      RegExp(r'("apiKey"|"api_key"|api_key=)[^\s,&"]+', caseSensitive: false),
      (m) => '${m.group(1)}[REDACTED]',
    );
    return sanitized;
  }
}
