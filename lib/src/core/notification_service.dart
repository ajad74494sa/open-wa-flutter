import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service for managing real-time notifications with sound across all platforms.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Global navigator key for showing floating notification banners.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// Callback when a notification is triggered.
  void Function(String title, String body)? onNotificationReceived;

  Future<void> init() async {
    // Initialization completed successfully
  }

  /// Triggers a real-time message notification with visual banner and audio sound.
  void showMessageNotification({
    required String title,
    required String body,
  }) {
    if (onNotificationReceived != null) {
      onNotificationReceived!(title, body);
    }

    // Play notification sound
    _playSound();

    // Show visual snackbar notification banner
    final context = navigatorKey?.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF075E54),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _playSound() {
    try {
      SystemSound.play(SystemSoundType.alert);
      if (!kIsWeb && Platform.isMacOS) {
        Process.run('afplay', ['/System/Library/Sounds/Glass.aiff']);
      }
    } catch (_) {}
  }
}
