import '../core/api_response.dart';
import '../core/http_client.dart';

/// WhatsApp Profile settings management service.
class ProfileService {
  final OpenWaHttpClient _client;

  ProfileService(this._client);

  /// Updates profile display name.
  Future<ApiResponse<bool>> setProfileName(String name) async {
    return _client.post<bool>(
      '/profile/setName',
      body: {'name': name},
      parser: (json) => json['updated'] as bool? ?? true,
    );
  }

  /// Updates profile about/status text.
  Future<ApiResponse<bool>> setProfileStatus(String statusText) async {
    return _client.post<bool>(
      '/profile/setStatus',
      body: {'status': statusText},
      parser: (json) => json['updated'] as bool? ?? true,
    );
  }

  /// Updates profile picture image.
  Future<ApiResponse<bool>> setProfilePicture(
    List<int> imageBytes,
    String fileName,
  ) async {
    return _client.uploadMedia<bool>(
      '/profile/setPicture',
      fieldName: 'file',
      fileBytes: imageBytes,
      fileName: fileName,
      parser: (json) => json['updated'] as bool? ?? true,
    );
  }
}
