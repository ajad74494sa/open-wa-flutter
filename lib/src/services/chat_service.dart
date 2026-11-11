import '../core/api_response.dart';
import '../core/http_client.dart';
import '../models/chat_models.dart';

class ChatService {
  final OpenWaHttpClient _client;

  ChatService(this._client);

  Future<ApiResponse<List<ChatSummary>>> listChats(
    String sessionId, {
    int limit = 100,
    int offset = 0,
  }) {
    return _client.get<List<ChatSummary>>(
      '/api/sessions/${_segment(sessionId)}/chats',
      queryParameters: {'limit': limit, 'offset': offset},
      parser: _parseChats,
    );
  }

  Future<ApiResponse<bool>> markRead(
    String sessionId,
    String chatId, {
    List<String>? messageIds,
  }) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/read',
      body: {'chatId': chatId, 'messageIds': ?messageIds},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> markUnread(String sessionId, String chatId) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/unread',
      body: {'chatId': chatId},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> setArchived(
    String sessionId,
    String chatId, {
    required bool archived,
  }) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/archive',
      body: {'chatId': chatId, 'archive': archived},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> setPinned(
    String sessionId,
    String chatId, {
    required bool pinned,
  }) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/pin',
      body: {'chatId': chatId, 'pin': pinned},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> setMuted(
    String sessionId,
    String chatId, {
    required int? muteUntil,
  }) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/mute',
      body: {'chatId': chatId, 'muteUntil': muteUntil},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> deleteChat(String sessionId, String chatId) {
    return _client.post<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/delete',
      body: {'chatId': chatId},
      parser: (_) => true,
    );
  }

  Future<ApiResponse<bool>> deleteMessages(String sessionId, String chatId) {
    return _client.delete<bool>(
      '/api/sessions/${_segment(sessionId)}/chats/${_segment(chatId)}/messages',
      parser: (_) => true,
    );
  }
}

String _segment(String value) => Uri.encodeComponent(value);

List<ChatSummary> _parseChats(dynamic json) {
  if (json is List) {
    return json.map(_parseChat).toList();
  }
  if (json is Map) {
    final map = Map<String, dynamic>.from(json);
    for (final key in ['chats', 'items', 'data', 'results']) {
      if (map.containsKey(key)) return _parseChats(map[key]);
    }
    throw const FormatException('Chat list response has no chats array.');
  }
  throw const FormatException('Chat list response must be a JSON array.');
}

ChatSummary _parseChat(dynamic json) {
  if (json is! Map) {
    throw const FormatException('Chat entries must be JSON objects.');
  }
  return ChatSummary.fromJson(Map<String, dynamic>.from(json));
}
