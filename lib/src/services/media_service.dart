import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/media_models.dart';
import '../models/message_models.dart';

/// Media handling and media decryption service.
class MediaService {
  final OpenWaHttpClient _client;

  MediaService(this._client);

  /// Downloads and decrypts raw media attached to a message.
  Future<ApiResponse<MediaData>> decryptMedia(ChatMessage message) async {
    return _client.post<MediaData>(
      '/media/decrypt',
      body: {'messageId': message.id},
      parser: (json) => MediaData.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Uploads media asset to OpenWA server and returns stored URI.
  Future<ApiResponse<String>> uploadMedia(
    List<int> bytes,
    String fileName,
    String mimeType,
  ) async {
    return _client.uploadMedia<String>(
      '/media/upload',
      fieldName: 'file',
      fileBytes: bytes,
      fileName: fileName,
      extraFields: {'mimeType': mimeType},
      parser: (json) => json['url'] as String? ?? json['mediaUrl'] as String? ?? '',
    );
  }
}
