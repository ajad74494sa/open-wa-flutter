import 'dart:convert';
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
    required String sessionId,
    String? replyToId,
  }) async {
    final payload = SendTextMessageRequest(
      chatId: normalizeChatId(chatId),
      content: content,
      replyToMessageId: replyToId,
    );
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-text',
      body: payload.toJson(),
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends an image photo from local device bytes as Base64 JSON.
  Future<ApiResponse<ChatMessage>> sendImage(
    String sessionId,
    String chatId,
    List<int> imageBytes,
    String fileName, {
    String? caption,
  }) async {
    final normalizedId = normalizeChatId(chatId);
    final ext = fileName.contains('.') ? fileName.split('.').last : 'jpeg';
    final base64Media = 'data:image/$ext;base64,${base64Encode(imageBytes)}';
    final payload = <String, dynamic>{
      'to': normalizedId,
      'chatId': normalizedId,
      'media': base64Media,
      'file': base64Media,
      'filename': fileName,
    };
    if (caption != null) {
      payload['caption'] = caption;
    }
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-image',
      body: payload,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a video from local device bytes as Base64 JSON.
  Future<ApiResponse<ChatMessage>> sendVideo(
    String sessionId,
    String chatId,
    List<int> videoBytes,
    String fileName, {
    String? caption,
  }) async {
    final normalizedId = normalizeChatId(chatId);
    final ext = fileName.contains('.') ? fileName.split('.').last : 'mp4';
    final base64Media = 'data:video/$ext;base64,${base64Encode(videoBytes)}';
    final payload = <String, dynamic>{
      'to': normalizedId,
      'chatId': normalizedId,
      'media': base64Media,
      'file': base64Media,
      'filename': fileName,
    };
    if (caption != null) {
      payload['caption'] = caption;
    }
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-video',
      body: payload,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a voice note / PTT audio recording as Base64 JSON.
  Future<ApiResponse<ChatMessage>> sendVoice(
    String sessionId,
    String chatId,
    List<int> audioBytes,
    String fileName,
  ) async {
    final normalizedId = normalizeChatId(chatId);
    final base64Media = 'data:audio/mp3;base64,${base64Encode(audioBytes)}';
    final payload = <String, dynamic>{
      'to': normalizedId,
      'chatId': normalizedId,
      'media': base64Media,
      'file': base64Media,
      'filename': fileName,
    };
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-audio',
      body: payload,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends an audio file via /api/sessions/{sessionId}/messages/send-audio.
  Future<ApiResponse<ChatMessage>> sendAudio(
    String sessionId,
    String chatId,
    List<int> audioBytes,
    String fileName,
  ) async {
    return sendVoice(sessionId, chatId, audioBytes, fileName);
  }

  /// Sends a document or file from local device bytes as Base64 JSON.
  Future<ApiResponse<ChatMessage>> sendFile(
    String sessionId,
    String chatId,
    List<int> fileBytes,
    String fileName, {
    String? caption,
  }) async {
    final normalizedId = normalizeChatId(chatId);
    final base64Media = 'data:application/octet-stream;base64,${base64Encode(fileBytes)}';
    final payload = <String, dynamic>{
      'to': normalizedId,
      'chatId': normalizedId,
      'media': base64Media,
      'file': base64Media,
      'filename': fileName,
    };
    if (caption != null) {
      payload['caption'] = caption;
    }
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-document',
      body: payload,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a custom image sticker as Base64 JSON.
  Future<ApiResponse<ChatMessage>> sendSticker(
    String sessionId,
    String chatId,
    List<int> imageBytes,
  ) async {
    final normalizedId = normalizeChatId(chatId);
    final base64Media = 'data:image/png;base64,${base64Encode(imageBytes)}';
    final payload = <String, dynamic>{
      'to': normalizedId,
      'chatId': normalizedId,
      'media': base64Media,
      'file': base64Media,
      'filename': 'sticker.png',
    };
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-sticker',
      body: payload,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends GPS map location.
  Future<ApiResponse<ChatMessage>> sendLocation(
    String sessionId,
    String chatId,
    double latitude,
    double longitude, {
    String? title,
  }) async {
    final payload = <String, dynamic>{
      'chatId': normalizeChatId(chatId),
      'lat': latitude,
      'lng': longitude,
    };
    if (title != null) {
      payload['title'] = title;
    }
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-location',
      body: payload,
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends vCard contact card.
  Future<ApiResponse<ChatMessage>> sendContact(
    String sessionId,
    String chatId,
    String contactId,
  ) async {
    final payload = {'chatId': normalizeChatId(chatId), 'contactId': contactId};
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/send-contact',
      body: payload,
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
    String sessionId,
    String chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return _client.get<List<ChatMessage>>(
      '/api/sessions/${_segment(sessionId)}/messages',
      queryParameters: {
        'chatId': chatId,
        'limit': limit,
        'offset': offset,
      },
      parser: _parseMessages,
    );
  }

  /// Fetches recent chat history directly from the WhatsApp engine.
  Future<ApiResponse<List<ChatMessage>>> getLiveHistory(
    String sessionId,
    String chatId, {
    int limit = 50,
    bool deep = false,
  }) {
    return _client.get<List<ChatMessage>>(
      '/api/sessions/${_segment(sessionId)}/messages/${_segment(chatId)}/history',
      queryParameters: {'limit': limit, 'deep': deep},
      parser: _parseMessages,
    );
  }

  /// Retrieves a specific message by unique message ID.
  Future<ApiResponse<ChatMessage>> getMessageById(String messageId) async {
    return _client.get<ChatMessage>(
      '/api/messages/${_segment(messageId)}',
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Replies directly to an existing message.
  Future<ApiResponse<ChatMessage>> replyMessage(
    String sessionId,
    String chatId,
    String messageId,
    String content,
  ) async {
    return sendText(
      chatId,
      content,
      sessionId: sessionId,
      replyToId: messageId,
    );
  }

  /// Deletes a message (optionally revoking for everyone).
  Future<ApiResponse<bool>> deleteMessage(
    String sessionId,
    String chatId,
    String messageId, {
    bool revoke = true,
  }) async {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/messages/delete',
      body: {'chatId': chatId, 'messageId': messageId},
      parser: (_) => true,
    );
  }

  /// Forwards an existing message to another chat.
  Future<ApiResponse<ChatMessage>> forwardMessage(
    String sessionId,
    String toChatId,
    String messageId,
  ) async {
    return _client.post<ChatMessage>(
      '/api/sessions/${_segment(sessionId)}/messages/forward',
      body: {'chatId': toChatId, 'messageId': messageId},
      parser: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Stars or unstars a message.
  Future<ApiResponse<bool>> starMessage(
    String sessionId,
    String chatId,
    String messageId, {
    bool star = true,
  }) async {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/messages/star',
      body: {'chatId': chatId, 'messageId': messageId, 'star': star},
      parser: (_) => true,
    );
  }

  /// Clears message history in a chat.
  Future<ApiResponse<bool>> clearChat(
    String sessionId,
    String chatId,
  ) {
    return _client.delete<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/${_segment(chatId)}/messages',
      parser: (_) => true,
    );
  }

  /// Sends bulk messages (text, photos, videos, or documents) to multiple recipients.
  Future<ApiResponse<dynamic>> sendBulk(
    String sessionId, {
    required List<String> recipients,
    required String content,
    String? mediaUrl,
  }) async {
    final body = <String, dynamic>{
      'recipients': recipients.map(normalizeChatId).toList(),
      'content': content,
    };
    if (mediaUrl != null) {
      body['mediaUrl'] = mediaUrl;
    }
    return _client.post<dynamic>(
      '/api/sessions/${_segment(sessionId)}/messages/send-bulk',
      body: body,
      parser: (json) => json,
    );
  }
}

String _segment(String value) => Uri.encodeComponent(value);

List<ChatMessage> _parseMessages(dynamic json) {
  if (json is List) {
    return json.map(_parseMessage).toList();
  }
  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    for (final key in ['messages', 'items', 'data', 'results']) {
      if (map.containsKey(key)) return _parseMessages(map[key]);
    }
    throw const FormatException('Message response has no messages array.');
  }
  throw const FormatException('Message response must be a JSON array.');
}

ChatMessage _parseMessage(dynamic json) {
  if (json is! Map) {
    throw const FormatException('Message entries must be JSON objects.');
  }
  return ChatMessage.fromJson(Map<String, dynamic>.from(json));
}
