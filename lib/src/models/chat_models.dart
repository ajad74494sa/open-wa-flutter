import 'package:meta/meta.dart';

@immutable
class ChatSummary {
  final String id;
  final String? name;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isGroup;
  final bool isArchived;
  final bool isPinned;
  final bool isMuted;

  const ChatSummary({
    required this.id,
    this.name,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isArchived = false,
    this.isPinned = false,
    this.isMuted = false,
  });

  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    final lastMessage = json['lastMessage'];
    final lastMessageText = lastMessage is Map
        ? lastMessage['body'] as String? ?? lastMessage['text'] as String?
        : lastMessage is String
        ? lastMessage
        : null;
    final rawTime = json['lastMessageAt'] ??
        json['lastMessageTimestamp'] ??
        (lastMessage is Map ? lastMessage['timestamp'] ?? lastMessage['t'] : null);

    return ChatSummary(
      id: json['chatId'] as String? ??
          json['id'] as String? ??
          json['_serialized'] as String? ??
          '',
      name: json['name'] as String? ??
          json['displayName'] as String? ??
          json['formattedTitle'] as String? ??
          json['pushName'] as String?,
      lastMessage: lastMessageText ??
          json['lastMessageBody'] as String? ??
          json['lastMessageText'] as String?,
      lastMessageAt: _parseDateTime(rawTime),
      unreadCount: _parseInt(json['unreadCount'] ?? json['unread']),
      isGroup: json['isGroup'] as bool? ??
          (json['chatId'] as String? ?? json['id'] as String? ?? '')
              .endsWith('@g.us'),
      isArchived: json['archived'] as bool? ?? false,
      isPinned: json['pinned'] as bool? ?? false,
      isMuted: json['muted'] as bool? ?? false,
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value < 1000000000000 ? value * 1000 : value);
  }
  if (value is String) return DateTime.tryParse(value);
  return null;
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
