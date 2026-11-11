import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/message_models.dart';

/// Service responsible for all messaging operations (send, receive, media, formatting, chat actions).
class MessageService {
  final OpenWaHttpClient _client;

  MessageService(this._client);

  /// Sends a plain text message to a contact or group.
  Future<ApiResponse<ChatMessage>> sendText(
    String chatId,
    String content, {
    String? replyToId,
  }) async {
    final payload = SendTextMessageRequest(
      chatId: chatId,
      content: content,
      replyToMessageId: replyToId,
    );
    return _client.post<ChatMessage>(
      '/messages/sendText',
      body: payload.toJson(),
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends an image file via multipart upload.
  Future<ApiResponse<ChatMessage>> sendImage(
    String chatId,
    List<int> imageBytes,
    String fileName, {
    String? caption,
  }) async {
    final fields = {'to': chatId};
    if (caption != null) fields['caption'] = caption;

    return _client.uploadMedia<ChatMessage>(
      '/messages/sendImage',
      fieldName: 'file',
      fileBytes: imageBytes,
      fileName: fileName,
      extraFields: fields,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a video file.
  Future<ApiResponse<ChatMessage>> sendVideo(
    String chatId,
    List<int> videoBytes,
    String fileName, {
    String? caption,
  }) async {
    final fields = {'to': chatId};
    if (caption != null) fields['caption'] = caption;

    return _client.uploadMedia<ChatMessage>(
      '/messages/sendVideo',
      fieldName: 'file',
      fileBytes: videoBytes,
      fileName: fileName,
      extraFields: fields,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a voice note / PTT audio recording.
  Future<ApiResponse<ChatMessage>> sendVoice(
    String chatId,
    List<int> audioBytes,
    String fileName,
  ) async {
    return _client.uploadMedia<ChatMessage>(
      '/messages/sendVoice',
      fieldName: 'file',
      fileBytes: audioBytes,
      fileName: fileName,
      extraFields: {'to': chatId},
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a document or generic file.
  Future<ApiResponse<ChatMessage>> sendFile(
    String chatId,
    List<int> fileBytes,
    String fileName, {
    String? caption,
  }) async {
    final fields = {'to': chatId};
    if (caption != null) fields['caption'] = caption;

    return _client.uploadMedia<ChatMessage>(
      '/messages/sendFile',
      fieldName: 'file',
      fileBytes: fileBytes,
      fileName: fileName,
      extraFields: fields,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a custom image sticker.
  Future<ApiResponse<ChatMessage>> sendSticker(
    String chatId,
    List<int> imageBytes,
  ) async {
    return _client.uploadMedia<ChatMessage>(
      '/messages/sendSticker',
      fieldName: 'file',
      fileBytes: imageBytes,
      fileName: 'sticker.png',
      extraFields: {'to': chatId},
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends GPS location pins.
  Future<ApiResponse<ChatMessage>> sendLocation(
    String chatId,
    double latitude,
    double longitude, {
    String? title,
  }) async {
    final payload = SendLocationRequest(
      chatId: chatId,
      latitude: latitude,
      longitude: longitude,
      title: title,
    );
    return _client.post<ChatMessage>(
      '/messages/sendLocation',
      body: payload.toJson(),
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends vCard contact card.
  Future<ApiResponse<ChatMessage>> sendContact(
    String chatId,
    String contactId,
  ) async {
    final payload = SendContactRequest(chatId: chatId, contactId: contactId);
    return _client.post<ChatMessage>(
      '/messages/sendContact',
      body: payload.toJson(),
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends interactive buttons message.
  Future<ApiResponse<ChatMessage>> sendButtons(
    String chatId,
    String title,
    String body,
    String footer,
    List<String> buttons,
  ) async {
    final payload = SendButtonsRequest(
      chatId: chatId,
      title: title,
      body: body,
      footer: footer,
      buttons: buttons,
    );
    return _client.post<ChatMessage>(
      '/messages/sendButtons',
      body: payload.toJson(),
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Retrieves recent message history for a given chat.
  Future<ApiResponse<List<ChatMessage>>> getMessages(
    String chatId, {
    int limit = 50,
  }) async {
    return _client.get<List<ChatMessage>>(
      '/messages/$chatId',
      queryParameters: {'limit': limit},
      parser: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Retrieves a specific message by unique message ID.
  Future<ApiResponse<ChatMessage>> getMessageById(String messageId) async {
    return _client.get<ChatMessage>(
      '/messages/single/$messageId',
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Replies directly to an existing message.
  Future<ApiResponse<ChatMessage>> replyMessage(
    String chatId,
    String messageId,
    String content,
  ) async {
    return sendText(chatId, content, replyToId: messageId);
  }

  /// Deletes a message (optionally revoking for everyone).
  Future<ApiResponse<bool>> deleteMessage(
    String chatId,
    String messageId, {
    bool revoke = true,
  }) async {
    return _client.post<bool>(
      '/messages/delete',
      body: {
        'chatId': chatId,
        'messageId': messageId,
        'revoke': revoke,
      },
      parser: (json) => json['deleted'] as bool? ?? true,
    );
  }

  /// Forwards an existing message to another chat.
  Future<ApiResponse<ChatMessage>> forwardMessage(
    String toChatId,
    String messageId,
  ) async {
    return _client.post<ChatMessage>(
      '/messages/forward',
      body: {
        'to': toChatId,
        'messageId': messageId,
      },
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Stars or unstars a message.
  Future<ApiResponse<bool>> starMessage(
    String messageId, {
    bool star = true,
  }) async {
    return _client.post<bool>(
      '/messages/star',
      body: {
        'messageId': messageId,
        'star': star,
      },
      parser: (json) => json['starred'] as bool? ?? star,
    );
  }

  /// Clears message history in a chat.
  Future<ApiResponse<bool>> clearChat(String chatId) async {
    return _client.post<bool>(
      '/messages/clear',
      body: {'chatId': chatId},
      parser: (json) => json['cleared'] as bool? ?? true,
    );
  }
}
