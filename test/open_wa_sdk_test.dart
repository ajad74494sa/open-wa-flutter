import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:open_wa/open_wa.dart';
import 'package:open_wa/src/core/http_client.dart';

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
    test(
      'HMAC SHA-256 computation and constant-time signature verification',
      () {
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
      },
    );

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
      const rawLog =
          'Sending request with Authorization: Bearer abc123secret and api_key=xyz987';
      final sanitized = SecurityUtils.sanitizeLog(rawLog);

      expect(sanitized.contains('abc123secret'), false);
      expect(sanitized.contains('xyz987'), false);
      expect(sanitized.contains('[REDACTED]'), true);
    });
  });

  group('Data Model Parsing Tests', () {
    test('normalizes phone numbers and preserves valid WhatsApp JIDs', () {
      expect(normalizeChatId('+966 56-162-6285'), '966561626285@c.us');
      expect(normalizeChatId('966561626285@c.us'), '966561626285@c.us');
      expect(
        normalizeChatId('120363000000000000@g.us'),
        '120363000000000000@g.us',
      );
      expect(
        () => normalizeChatId('not a phone number'),
        throwsFormatException,
      );
    });

    test('parses chat summaries from the OpenWA chat list shape', () {
      final chat = ChatSummary.fromJson({
        'chatId': '1234567890@c.us',
        'name': 'Alice',
        'lastMessage': {'body': 'See you soon', 'timestamp': 1700000000},
        'unreadCount': 2,
      });

      expect(chat.id, '1234567890@c.us');
      expect(chat.name, 'Alice');
      expect(chat.lastMessage, 'See you soon');
      expect(chat.unreadCount, 2);
      expect(chat.isGroup, false);
    });

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

  group('Session service response parsing', () {
    test('parses sessions returned as an ID-to-status map', () async {
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
      );
      final client = OpenWaHttpClient(
        config,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'default': 'CONNECTED', 'secondary': 'DISCONNECTED'}),
            200,
          ),
        ),
      );

      try {
        final response = await SessionService(client).listSessions();

        expect(response.data, hasLength(2));
        expect(response.data![0].sessionId, 'default');
        expect(response.data![0].status, SessionStatus.connected);
        expect(response.data![1].sessionId, 'secondary');
        expect(response.data![1].status, SessionStatus.disconnected);
      } finally {
        client.close();
      }
    });

    test('keeps sessions with unrecognized statuses selectable', () async {
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
      );
      final client = OpenWaHttpClient(
        config,
        client: MockClient(
          (_) async => http.Response(jsonEncode({'default': 'WORKING'}), 200),
        ),
      );

      try {
        final response = await SessionService(client).listSessions();

        expect(response.data, hasLength(1));
        expect(response.data!.single.sessionId, 'default');
        expect(response.data!.single.status, SessionStatus.unknown);
      } finally {
        client.close();
      }
    });

    test('parses sessions wrapped in a sessions array', () async {
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
      );
      final client = OpenWaHttpClient(
        config,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'sessions': [
                {'sessionId': 'default', 'status': 'CONNECTED'},
              ],
            }),
            200,
          ),
        ),
      );

      try {
        final response = await SessionService(client).listSessions();

        expect(response.data, hasLength(1));
        expect(response.data!.single.sessionId, 'default');
        expect(response.data!.single.status, SessionStatus.connected);
      } finally {
        client.close();
      }
    });

    test('parses OpenWA session UUID, name, and ready status', () async {
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
      );
      final client = OpenWaHttpClient(
        config,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode([
              {
                'id': 'session-uuid',
                'name': 'my-bot',
                'status': 'ready',
                'phone': '1234567890',
                'engineLoaded': true,
              },
            ]),
            200,
          ),
        ),
      );

      try {
        final response = await SessionService(client).listSessions();

        expect(response.data!.single.sessionId, 'session-uuid');
        expect(response.data!.single.name, 'my-bot');
        expect(response.data!.single.status, SessionStatus.ready);
        expect(response.data!.single.phoneNumber, '1234567890');
        expect(response.data!.single.isConnected, true);
      } finally {
        client.close();
      }
    });

    test('lists sessions using the OpenWA API path and API-key header', () async {
      http.Request? capturedRequest;
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
      );
      final client = OpenWaHttpClient(
        config,
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('[]', 200);
        }),
      );

      try {
        await SessionService(client).listSessions();

        expect(capturedRequest!.url.path, '/api/sessions');
        expect(capturedRequest!.headers['X-API-Key'], 'test-key');
      } finally {
        client.close();
      }
    });

    test('starts a session with its UUID-scoped API route', () async {
      http.Request? capturedRequest;
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'test-key',
      );
      final client = OpenWaHttpClient(
        config,
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 'session-uuid',
              'name': 'my-bot',
              'status': 'initializing',
            }),
            200,
          );
        }),
      );

      try {
        final response = await SessionService(client).startSession(
          'session-uuid',
        );

        expect(capturedRequest!.url.path, '/api/sessions/session-uuid/start');
        expect(capturedRequest!.method, 'POST');
        expect(response.data!.sessionId, 'session-uuid');
      } finally {
        client.close();
      }
    });

    test('creates a session with a name and parses its server UUID', () async {
      http.Request? capturedRequest;
      final client = OpenWaHttpClient(
        OpenWaConfig(baseUrl: 'https://api.example.com', apiKey: 'test-key'),
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 'new-session-uuid',
              'name': 'my-bot',
              'status': 'created',
            }),
            201,
          );
        }),
      );

      try {
        final response = await SessionService(client).createSession('my-bot');

        expect(capturedRequest!.url.path, '/api/sessions');
        expect(capturedRequest!.method, 'POST');
        expect(jsonDecode(capturedRequest!.body), {'name': 'my-bot'});
        expect(response.data!.sessionId, 'new-session-uuid');
      } finally {
        client.close();
      }
    });
  });

  test('sends text using the session-scoped OpenWA endpoint and DTO', () async {
    http.Request? capturedRequest;
    final config = OpenWaConfig(
      baseUrl: 'https://api.example.com',
      apiKey: 'test-key',
    );
    final client = OpenWaHttpClient(
      config,
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'id': 'message-01',
            'from': 'sender@c.us',
            'to': '1234567890@c.us',
            'body': 'Hello',
            'type': 'chat',
            'timestamp': 1700000000,
          }),
          201,
        );
      }),
    );

    try {
      await MessageService(client).sendText(
        '1234567890@c.us',
        'Hello',
        sessionId: 'default',
      );

      expect(
        capturedRequest!.url.path,
        '/api/sessions/default/messages/send-text',
      );
      expect(capturedRequest!.method, 'POST');
      expect(capturedRequest!.headers['X-API-Key'], 'test-key');
      expect(jsonDecode(capturedRequest!.body), {
        'chatId': '1234567890@c.us',
        'text': 'Hello',
      });
    } finally {
      client.close();
    }
  });

  test('lists chats with the selected session UUID', () async {
    http.Request? capturedRequest;
    final client = OpenWaHttpClient(
      OpenWaConfig(baseUrl: 'https://api.example.com', apiKey: 'test-key'),
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode([
            {
              'chatId': '1234567890@c.us',
              'name': 'Alice',
              'lastMessage': 'Hi',
              'unreadCount': 1,
            },
          ]),
          200,
        );
      }),
    );

    try {
      final response = await ChatService(client).listChats('session-uuid');

      expect(capturedRequest!.url.path, '/api/sessions/session-uuid/chats');
      expect(capturedRequest!.headers['X-API-Key'], 'test-key');
      expect(response.data!.single.name, 'Alice');
      expect(response.data!.single.lastMessage, 'Hi');
    } finally {
      client.close();
    }
  });

  test('loads persisted messages by session and chat ID', () async {
    http.Request? capturedRequest;
    final client = OpenWaHttpClient(
      OpenWaConfig(baseUrl: 'https://api.example.com', apiKey: 'test-key'),
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'messages': [
              {
                'id': 'message-01',
                'from': 'sender@c.us',
                'to': '1234567890@c.us',
                'body': 'Hello',
                'type': 'chat',
                'timestamp': 1700000000,
                'fromMe': true,
              },
            ],
            'total': 1,
          }),
          200,
        );
      }),
    );

    try {
      final response = await MessageService(client).getMessages(
        'session-uuid',
        '1234567890@c.us',
      );

      expect(
        capturedRequest!.url.path,
        '/api/sessions/session-uuid/messages',
      );
      expect(capturedRequest!.url.queryParameters['chatId'], '1234567890@c.us');
      expect(response.data!.single.fromMe, true);
      expect(response.data!.single.body, 'Hello');
    } finally {
      client.close();
    }
  });
}
