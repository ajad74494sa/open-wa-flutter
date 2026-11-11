import 'package:meta/meta.dart';

enum WebhookEvent {
  onMessage,
  onAck,
  onAddedToGroup,
  onIncomingCall,
  onStateChange,
  onBattery,
  onPlugged,
  unknown;

  static WebhookEvent fromString(String event) {
    switch (event.toLowerCase()) {
      case 'onmessage':
      case 'message':
        return WebhookEvent.onMessage;
      case 'onack':
      case 'ack':
        return WebhookEvent.onAck;
      case 'onaddedtogroup':
        return WebhookEvent.onAddedToGroup;
      case 'onincomingcall':
        return WebhookEvent.onIncomingCall;
      case 'onstatechange':
        return WebhookEvent.onStateChange;
      case 'onbattery':
        return WebhookEvent.onBattery;
      case 'onplugged':
        return WebhookEvent.onPlugged;
      default:
        return WebhookEvent.unknown;
    }
  }
}

@immutable
class WebhookConfig {
  final String url;
  final List<WebhookEvent> events;
  final String? secret;
  final bool isEnabled;

  const WebhookConfig({
    required this.url,
    required this.events,
    this.secret,
    this.isEnabled = true,
  });

  factory WebhookConfig.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];
    return WebhookConfig(
      url: json['url'] as String? ?? '',
      events: rawEvents
          .map((e) => WebhookEvent.fromString(e.toString()))
          .toList(),
      secret: json['secret'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'events': events.map((e) => e.name).toList(),
        if (secret != null) 'secret': secret,
        'isEnabled': isEnabled,
      };
}

@immutable
class WebhookPayload {
  final WebhookEvent event;
  final String sessionId;
  final int timestamp;
  final dynamic data;

  const WebhookPayload({
    required this.event,
    required this.sessionId,
    required this.timestamp,
    required this.data,
  });

  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    return WebhookPayload(
      event: WebhookEvent.fromString(json['event'] as String? ?? 'unknown'),
      sessionId: json['sessionId'] as String? ?? json['session'] as String? ?? 'default',
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      data: json['data'] ?? json['payload'],
    );
  }
}
