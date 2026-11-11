import 'package:meta/meta.dart';

enum SessionStatus {
  created,
  connected,
  disconnected,
  pairing,
  qrReady,
  unpaired,
  initializing,
  timeout,
  ready,
  failed,
  actionRequired,
  unknown;

  static SessionStatus fromString(String status) {
    switch (status.toLowerCase().replaceAll('_', '')) {
      case 'created':
        return SessionStatus.created;
      case 'connected':
      case 'isconnected':
        return SessionStatus.connected;
      case 'disconnected':
        return SessionStatus.disconnected;
      case 'pairing':
      case 'qr':
      case 'qrready':
        return SessionStatus.qrReady;
      case 'unpaired':
        return SessionStatus.unpaired;
      case 'initializing':
      case 'init':
        return SessionStatus.initializing;
      case 'timeout':
        return SessionStatus.timeout;
      case 'ready':
        return SessionStatus.ready;
      case 'failed':
        return SessionStatus.failed;
      case 'actionrequired':
        return SessionStatus.actionRequired;
      default:
        return SessionStatus.unknown;
    }
  }
}

@immutable
class SessionInfo {
  final String sessionId;
  final String? name;
  final SessionStatus status;
  final String? qrCode;
  final String? phoneNumber;
  final int? batteryLevel;
  final bool isPlugged;
  final bool isConnected;

  const SessionInfo({
    required this.sessionId,
    this.name,
    required this.status,
    this.qrCode,
    this.phoneNumber,
    this.batteryLevel,
    this.isPlugged = false,
    this.isConnected = false,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      sessionId: json['id'] as String? ??
          json['sessionId'] as String? ??
          json['session'] as String? ??
          'default',
      name: json['name'] as String?,
      status: SessionStatus.fromString(json['status'] as String? ?? 'unknown'),
      qrCode: json['qr'] as String? ?? json['qrCode'] as String?,
      phoneNumber: json['phone'] as String? ??
          json['phoneNumber'] as String? ??
          json['wid'] as String?,
      batteryLevel: json['battery'] as int?,
      isPlugged: json['plugged'] as bool? ?? false,
      isConnected: json['engineLoaded'] as bool? ??
          json['isConnected'] as bool? ??
          const {'READY', 'CONNECTED'}.contains(
            (json['status'] as String?)?.toUpperCase(),
          ),
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'name': name,
        'status': status.name,
        'qrCode': qrCode,
        'phoneNumber': phoneNumber,
        'batteryLevel': batteryLevel,
        'isPlugged': isPlugged,
        'isConnected': isConnected,
      };
}

@immutable
class QrCodeResponse {
  final String sessionId;
  final String qrCodeBase64;
  final String? rawQrString;

  const QrCodeResponse({
    required this.sessionId,
    required this.qrCodeBase64,
    this.rawQrString,
  });

  factory QrCodeResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeResponse(
      sessionId: json['sessionId'] as String? ?? 'default',
      qrCodeBase64: json['qr'] as String? ?? json['qrCode'] as String? ?? '',
      rawQrString: json['raw'] as String?,
    );
  }
}
