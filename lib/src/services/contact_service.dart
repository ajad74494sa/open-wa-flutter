import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/contact_models.dart';

/// Session-scoped contact operations.
class ContactService {
  final OpenWaHttpClient _client;

  ContactService(this._client);

  Future<ApiResponse<List<Contact>>> getAllContacts(
    String sessionId, {
    int limit = 100,
    int offset = 0,
  }) {
    return _client.get<List<Contact>>(
      '/api/sessions/${_segment(sessionId)}/contacts',
      queryParameters: {'limit': limit, 'offset': offset},
      parser: _parseContacts,
    );
  }

  Future<ApiResponse<Contact>> getContact(
    String sessionId,
    String contactId,
  ) {
    return _client.get<Contact>(
      '/api/sessions/${_segment(sessionId)}/contacts/${_segment(contactId)}',
      parser: (json) => Contact.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<NumberStatus>> checkNumberStatus(
    String sessionId,
    String phoneNumber,
  ) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return _client.get<NumberStatus>(
      '/api/sessions/${_segment(sessionId)}/contacts/check/${_segment(cleanNumber)}',
      parser: (json) =>
          NumberStatus.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<ApiResponse<bool>> blockContact(
    String sessionId,
    String contactId,
  ) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/contacts/${_segment(contactId)}/block',
      body: <String, dynamic>{},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> unblockContact(
    String sessionId,
    String contactId,
  ) {
    return _client.delete<bool>(
      '/api/sessions/${_segment(sessionId)}/contacts/${_segment(contactId)}/block',
      parser: (_) => true,
    );
  }

  Future<ApiResponse<String>> getProfilePic(
    String sessionId,
    String contactId,
  ) {
    return _client.get<String>(
      '/api/sessions/${_segment(sessionId)}/contacts/${_segment(contactId)}/profile-picture',
      parser: (json) =>
          (json as Map<String, dynamic>)['url'] as String? ?? '',
    );
  }
}

String _segment(String value) => Uri.encodeComponent(value);

List<Contact> _parseContacts(dynamic json) {
  if (json is List) {
    return json.map((contact) {
      if (contact is! Map) {
        throw const FormatException('Contact entries must be JSON objects.');
      }
      return Contact.fromJson(Map<String, dynamic>.from(contact));
    }).toList();
  }
  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    for (final key in ['contacts', 'items', 'data', 'results']) {
      if (map.containsKey(key)) return _parseContacts(map[key]);
    }
  }
  throw const FormatException('Contact response must contain a contact array.');
}
