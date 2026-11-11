import 'package:meta/meta.dart';

@immutable
class ServerHealth {
  final String status;
  final int uptimeSeconds;
  final int activeSessions;
  final double cpuUsagePercent;
  final double memoryUsageMb;

  const ServerHealth({
    required this.status,
    required this.uptimeSeconds,
    required this.activeSessions,
    required this.cpuUsagePercent,
    required this.memoryUsageMb,
  });

  factory ServerHealth.fromJson(Map<String, dynamic> json) {
    return ServerHealth(
      status: json['status'] as String? ?? 'ok',
      uptimeSeconds: json['uptime'] as int? ?? 0,
      activeSessions: json['activeSessions'] as int? ?? 0,
      cpuUsagePercent: (json['cpu'] as num?)?.toDouble() ?? 0.0,
      memoryUsageMb: (json['memory'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

@immutable
class ServerMetrics {
  final int messagesSent;
  final int messagesReceived;
  final int webhooksTriggered;

  const ServerMetrics({
    required this.messagesSent,
    required this.messagesReceived,
    required this.webhooksTriggered,
  });

  factory ServerMetrics.fromJson(Map<String, dynamic> json) {
    return ServerMetrics(
      messagesSent: json['messagesSent'] as int? ?? 0,
      messagesReceived: json['messagesReceived'] as int? ?? 0,
      webhooksTriggered: json['webhooksTriggered'] as int? ?? 0,
    );
  }
}
