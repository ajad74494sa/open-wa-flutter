import 'package:flutter_test/flutter_test.dart';
import 'package:open_wa/open_wa.dart';

void main() {
  group('OpenWaConfig Validation & Security Tests', () {
    test('OpenWaConfig validates HTTPS base URL requirement when enabled', () {
      expect(
        () => OpenWaConfig(
          baseUrl: 'http://insecure-api.com',
          apiKey: 'test_key',
          requireHttps: true,
        ),
        throwsArgumentError,
      );
    });

    test('OpenWaConfig redacts sensitive API key in toString()', () {
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'super_secret_api_key_xyz',
        requireHttps: true,
      );

      final logString = config.toString();
      expect(logString.contains('super_secret_api_key_xyz'), false);
      expect(logString.contains('supe***'), true);
    });
  });

  group('Cryptographic & Webhook Security Tests', () {
    test('HMAC SHA-256 computation and constant-time signature verification', () {
      const secret = 'my_webhook_secret_key_999';
      const payload = '{"event":"onMessage","data":{"id":"123"}}';

      final signature = SecurityUtils.computeHmacSha256(payload, secret);
      expect(signature.isNotEmpty, true);

      final isValid = SecurityUtils.verifyWebhookSignature(
        rawPayload: payload,
        signatureHeader: 'sha256=$signature',
        secret: secret,
      );

      expect(isValid, true);
    });

    test('Webhook signature fails with invalid secret or header', () {
      const payload = '{"event":"onMessage"}';

      expect(
        () => SecurityUtils.verifyWebhookSignature(
          rawPayload: payload,
          signatureHeader: 'sha256=invalid_digest',
          secret: 'wrong_secret',
        ),
        throwsA(isA<WebhookSignatureException>()),
      );
    });

    test('Log sanitizer redacts API keys and Bearer tokens', () {
      const rawLog = 'Sending request with Authorization: Bearer abc123secret and api_key=xyz987';
      final sanitized = SecurityUtils.sanitizeLog(rawLog);

      expect(sanitized.contains('abc123secret'), false);
      expect(sanitized.contains('xyz987'), false);
      expect(sanitized.contains('[REDACTED]'), true);
    });
  });

  group('Data Model Parsing Tests', () {
    test('SessionInfo parses JSON correctly', () {
      final json = {
        'sessionId': 'session_01',
        'status': 'CONNECTED',
        'phoneNumber': '1234567890@c.us',
        'battery': 95,
        'plugged': true,
        'isConnected': true,
      };

      final session = SessionInfo.fromJson(json);
      expect(session.sessionId, 'session_01');
      expect(session.status, SessionStatus.connected);
      expect(session.batteryLevel, 95);
      expect(session.isPlugged, true);
      expect(session.isConnected, true);
    });

    test('ChatMessage parses text message JSON correctly', () {
      final json = {
        'id': 'msg_001',
        'from': '1234567890@c.us',
        'to': '0987654321@c.us',
        'body': 'Hello World!',
        'type': 'chat',
        't': 1700000000,
        'isGroupMsg': false,
      };

      final message = ChatMessage.fromJson(json);
      expect(message.id, 'msg_001');
      expect(message.body, 'Hello World!');
      expect(message.type, MessageType.chat);
      expect(message.isGroupMsg, false);
    });
  });
}
