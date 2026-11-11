import 'package:meta/meta.dart';

enum MessageType {
  chat,
  image,
  video,
  audio,
  ptt, // Push-to-talk / voice note
  document,
  sticker,
  location,
  vcard,
  multiVcard,
  buttons,
  list,
  unknown;

  static MessageType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'chat':
      case 'text':
        return MessageType.chat;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'ptt':
      case 'voice':
        return MessageType.ptt;
      case 'document':
        return MessageType.document;
      case 'sticker':
        return MessageType.sticker;
      case 'location':
        return MessageType.location;
      case 'vcard':
        return MessageType.vcard;
      case 'buttons':
        return MessageType.buttons;
      case 'list':
        return MessageType.list;
      default:
        return MessageType.unknown;
    }
  }
}

String normalizeChatId(String input) {
  final chatId = input.trim();
  if (RegExp(r'^[^\s@]+@[^\s@]+$').hasMatch(chatId)) {
    return chatId;
  }

  final phoneNumber = chatId.replaceAll(RegExp(r'[\s()+-]'), '');
  if (RegExp(r'^\d+$').hasMatch(phoneNumber)) {
    return '$phoneNumber@c.us';
  }

  throw const FormatException(
    'Enter a phone number or a WhatsApp chat JID (for example 966...@c.us).',
  );
}

@immutable
class ChatMessage {
  final String id;
  final String from;
  final String to;
  final String body;
  final MessageType type;
  final int timestamp;
  final bool fromMe;
  final bool isGroupMsg;
  final String? senderName;
  final String? mediaUrl;
  final String? caption;
  final bool isStarred;
  final bool isForwarded;
  final String? replyToId;

  const ChatMessage({
    required this.id,
    required this.from,
    required this.to,
    required this.body,
    required this.type,
    required this.timestamp,
    this.fromMe = false,
    this.isGroupMsg = false,
    this.senderName,
    this.mediaUrl,
    this.caption,
    this.isStarred = false,
    this.isForwarded = false,
    this.replyToId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? json['_serialized'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      body: json['body'] as String? ?? json['caption'] as String? ?? '',
      type: MessageType.fromString(json['type'] as String? ?? 'chat'),
      timestamp: json['t'] as int? ?? json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      fromMe: json['fromMe'] as bool? ?? json['isFromMe'] as bool? ?? false,
      isGroupMsg: json['isGroupMsg'] as bool? ?? false,
      senderName: json['notifyName'] as String? ?? json['sender']?['name'] as String?,
      mediaUrl: json['deprecatedMms3Url'] as String? ?? json['mediaUrl'] as String?,
      caption: json['caption'] as String?,
      isStarred: json['isStarred'] as bool? ?? false,
      isForwarded: json['isForwarded'] as bool? ?? false,
      replyToId: json['quotedMsgId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'to': to,
        'body': body,
        'type': type.name,
        'timestamp': timestamp,
        'fromMe': fromMe,
        'isGroupMsg': isGroupMsg,
        'senderName': senderName,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'isStarred': isStarred,
        'isForwarded': isForwarded,
        'replyToId': replyToId,
      };
}

@immutable
class SendTextMessageRequest {
  final String chatId;
  final String content;
  final String? replyToMessageId;

  const SendTextMessageRequest({
    required this.chatId,
    required this.content,
    this.replyToMessageId,
  });

  Map<String, dynamic> toJson() => {
        'to': chatId,
        'chatId': chatId,
        'content': content,
        'text': content,
        'message': content,
        if (replyToMessageId != null) ...{
          'replyTo': replyToMessageId,
          'quotedMessageId': replyToMessageId,
        },
      };
}

@immutable
class SendLocationRequest {
  final String chatId;
  final double latitude;
  final double longitude;
  final String? title;

  const SendLocationRequest({
    required this.chatId,
    required this.latitude,
    required this.longitude,
    this.title,
  });

  Map<String, dynamic> toJson() => {
        'to': chatId,
        'chatId': chatId,
        'lat': latitude,
        'latitude': latitude,
        'lng': longitude,
        'longitude': longitude,
        if (title != null) 'title': title,
      };
}

@immutable
class SendContactRequest {
  final String chatId;
  final String contactId;

  const SendContactRequest({
    required this.chatId,
    required this.contactId,
  });

  Map<String, dynamic> toJson() => {
        'to': chatId,
        'chatId': chatId,
        'contactId': contactId,
      };
}

@immutable
class SendButtonsRequest {
  final String chatId;
  final String title;
  final String body;
  final String footer;
  final List<String> buttons;

  const SendButtonsRequest({
    required this.chatId,
    required this.title,
    required this.body,
    required this.footer,
    required this.buttons,
  });

  Map<String, dynamic> toJson() => {
        'to': chatId,
        'title': title,
        'body': body,
        'footer': footer,
        'buttons': buttons,
      };
}
