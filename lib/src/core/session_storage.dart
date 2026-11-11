import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// File-based persistent storage for OpenWA session credentials.
class SessionStorage {
  SessionStorage._();

  static Future<File> get _file async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/open_wa_session.json');
  }

  static Future<Map<String, String?>> loadSession() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        return {
          'baseUrl': data['baseUrl'] as String?,
          'apiKey': data['apiKey'] as String?,
        };
      }
    } catch (_) {}
    return {'baseUrl': null, 'apiKey': null};
  }

  static Future<void> saveSession(String baseUrl, String apiKey) async {
    try {
      final file = await _file;
      final data = {'baseUrl': baseUrl, 'apiKey': apiKey};
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  static Future<void> clearSession() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
