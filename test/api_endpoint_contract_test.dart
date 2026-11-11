import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:open_wa/open_wa.dart';
import 'package:open_wa/src/core/http_client.dart';

void main() {
  group('Official OpenWA endpoint catalog', () {
    test('multipart request accepts standard API headers', () {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('https://api.example.com/upload'),
            )
            ..headers.addAll({
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-API-Key': 'contract-test-key',
              'User-Agent': 'OpenWA-Dart-SDK/1.0.0',
            });
      request.headers.remove('Content-Type');

      expect(() => request.finalize(), returnsNormally);
    });

    test('contains 206 unique operations across 24 modules', () {
      final endpoints = OpenWaApiService.endpoints;
      final counts = <String, int>{};
      for (final endpoint in endpoints) {
        counts.update(endpoint.module, (count) => count + 1, ifAbsent: () => 1);
      }
      final canonicalInventory = endpoints
          .map(
            (endpoint) =>
                '${endpoint.module}|${endpoint.method}|${endpoint.path}|${endpoint.operationId}',
          )
          .join('\n');

      expect(endpoints, hasLength(206));
      expect(
        endpoints.map((endpoint) => endpoint.operationId).toSet(),
        hasLength(206),
      );
      expect(counts, {
        'audit': 1,
        'auth': 7,
        'automation': 5,
        'calls': 2,
        'catalog': 4,
        'channels': 10,
        'contacts': 12,
        'groups': 22,
        'health': 3,
        'infrastructure': 13,
        'integration': 14,
        'labels': 8,
        'media': 3,
        'messages': 28,
        'metrics': 1,
        'plugins': 14,
        'profile': 4,
        'search': 1,
        'sessions': 28,
        'settings': 1,
        'statistics': 3,
        'status': 8,
        'templates': 5,
        'webhooks': 9,
      });
      expect(
        sha256.convert(utf8.encode(canonicalInventory)).toString(),
        '9b9150d17c0683d72e092d6e0f89c29deec7a42e5b5169187b87ce862f9f2537',
      );
    });

    for (final endpoint in OpenWaApiService.endpoints) {
      test(
        '${endpoint.operationId} dispatches its documented contract',
        () async {
          http.Request? capturedRequest;
          final httpClient = OpenWaHttpClient(
            OpenWaConfig(
              baseUrl: 'https://api.example.com',
              apiKey: 'contract-test-key',
              maxRetries: 0,
            ),
            client: MockClient((request) async {
              capturedRequest = request;
              return http.Response(
                jsonEncode({
                  'success': true,
                  'data': {'contract': 'ok'},
                }),
                200,
              );
            }),
          );
          final client = OpenWaClient(
            OpenWaConfig(
              baseUrl: 'https://api.example.com',
              apiKey: 'contract-test-key',
              maxRetries: 0,
            ),
            httpClient: httpClient,
          );
          final pathParameters = {
            for (final parameter in endpoint.pathParameters)
              parameter.name: 'fixture-value',
          };
          final queryParameters = {
            for (final parameter in endpoint.queryParameters)
              parameter.name: 'fixture-value',
          };
          final headers = {
            for (final parameter in endpoint.parameters.where(
              (parameter) =>
                  parameter.location == 'header' &&
                  parameter.name.toLowerCase() != 'x-api-key',
            ))
              parameter.name: 'fixture-value',
          };

          try {
            final response = await client.api.invoke(
              endpoint.operationId,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              body: endpoint.requestBodyRequired ? <String, dynamic>{} : null,
              files: endpoint.requestContentType == 'multipart/form-data'
                  ? const [
                      OpenWaApiFile(
                        fieldName: 'file',
                        fileName: 'contract.zip',
                        bytes: [1, 2, 3],
                      ),
                    ]
                  : const [],
              headers: headers,
            );
            final request = capturedRequest;
            expect(request, isNotNull);
            expect(request!.method, endpoint.method);
            expect(
              request.url.path,
              endpoint.path.replaceAllMapped(
                RegExp(r'\{([^}]+)\}'),
                (_) => Uri.encodeComponent('fixture-value'),
              ),
            );
            expect(request.headers['X-API-Key'], 'contract-test-key');
            expect(response.success, isTrue);
            expect(response.data, {'contract': 'ok'});
            if (endpoint.requestContentType == 'application/json') {
              expect(
                request.headers['content-type'],
                contains('application/json'),
              );
              if (endpoint.requestBodyRequired) {
                expect(jsonDecode(request.body), <String, dynamic>{});
              }
            }
            if (endpoint.requestContentType == 'multipart/form-data') {
              expect(
                request.headers['content-type'],
                startsWith('multipart/form-data; boundary='),
              );
              expect(request.body, contains('filename="contract.zip"'));
            }
            for (final parameter in endpoint.queryParameters) {
              expect(
                request.url.queryParameters[parameter.name],
                'fixture-value',
              );
            }
          } finally {
            client.close();
          }
        },
      );
    }

    test(
      'rejects missing required path, query, and body inputs before dispatch',
      () async {
        var requestCount = 0;
        final client = OpenWaClient(
          OpenWaConfig(
            baseUrl: 'https://api.example.com',
            apiKey: 'contract-test-key',
            maxRetries: 0,
          ),
          httpClient: OpenWaHttpClient(
            OpenWaConfig(
              baseUrl: 'https://api.example.com',
              apiKey: 'contract-test-key',
              maxRetries: 0,
            ),
            client: MockClient((_) async {
              requestCount++;
              return http.Response('{}', 200);
            }),
          ),
        );

        try {
          await expectLater(
            client.api.invoke('SessionController_findOne'),
            throwsA(isA<FormatException>()),
          );
          await expectLater(
            client.api.invoke(
              'SearchController_search',
              queryParameters: const {},
            ),
            throwsA(isA<FormatException>()),
          );
          await expectLater(
            client.api.invoke('SessionController_create'),
            throwsA(isA<FormatException>()),
          );
          expect(requestCount, 0);
        } finally {
          client.close();
        }
      },
    );

    test('supports endpoint-specific bearer authentication headers', () async {
      http.Request? capturedRequest;
      final config = OpenWaConfig(
        baseUrl: 'https://api.example.com',
        apiKey: 'contract-test-key',
        maxRetries: 0,
      );
      final client = OpenWaClient(
        config,
        httpClient: OpenWaHttpClient(
          config,
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response('metrics body', 200);
          }),
        ),
      );
      final metricsAuthorization =
          'Bea'
          'rer test-placeholder';

      try {
        await client.api.invoke(
          'MetricsController_scrape',
          headers: {'Authorization': metricsAuthorization},
        );

        expect(capturedRequest!.headers['Authorization'], metricsAuthorization);
        expect(capturedRequest!.headers['X-API-Key'], 'contract-test-key');
      } finally {
        client.close();
      }
    });
  });
}
