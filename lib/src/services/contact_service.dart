import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/contact_models.dart';

/// Service for managing WhatsApp contacts, number validation, and blocklists.
class ContactService {
  final OpenWaHttpClient _client;

  ContactService(this._client);

  /// Fetches all contacts saved on the WhatsApp account.
  Future<ApiResponse<List<Contact>>> getAllContacts() async {
    return _client.get<List<Contact>>(
      '/contacts',
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => Contact.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Retrieves detailed information for a single contact.
  Future<ApiResponse<Contact>> getContact(String contactId) async {
    return _client.get<Contact>(
      '/contacts/$contactId',
      parser: (json) => Contact.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Validates whether a phone number exists and is registered on WhatsApp.
  Future<ApiResponse<NumberStatus>> checkNumberStatus(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return _client.get<NumberStatus>(
      '/contacts/check/$cleanNumber',
      parser: (json) => NumberStatus.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Blocks a contact.
  Future<ApiResponse<bool>> blockContact(String contactId) async {
    return _client.post<bool>(
      '/contacts/block',
      body: {'contactId': contactId},
      parser: (json) => json['blocked'] as bool? ?? true,
    );
  }

  /// Unblocks a contact.
  Future<ApiResponse<bool>> unblockContact(String contactId) async {
    return _client.post<bool>(
      '/contacts/unblock',
      body: {'contactId': contactId},
      parser: (json) => json['unblocked'] as bool? ?? true,
    );
  }

  /// Gets the profile picture URL for a given contact.
  Future<ApiResponse<String>> getProfilePic(String contactId) async {
    return _client.get<String>(
      '/contacts/$contactId/profilePic',
      parser: (json) => json['url'] as String? ?? json['profilePic'] as String? ?? '',
    );
  }
}
