import 'package:flutter/material.dart';

enum NotificationType { info, success, error }

class NotificationConfig {
  const NotificationConfig({
    required this.type,
    required this.title,
    this.message,
    this.duration,
    this.onTap,
    this.onClose,
  });

  factory NotificationConfig.success({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    return NotificationConfig(
      type: NotificationType.success,
      title: title,
      message: message,
      duration: duration ?? const Duration(milliseconds: 2200),
      onTap: onTap,
      onClose: onClose,
    );
  }

  factory NotificationConfig.info({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    return NotificationConfig(
      type: NotificationType.info,
      title: title,
      message: message,
      duration: duration ?? const Duration(milliseconds: 2400),
      onTap: onTap,
      onClose: onClose,
    );
  }

  factory NotificationConfig.error({
    required String title,
    String? message,
    Duration? duration,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    return NotificationConfig(
      type: NotificationType.error,
      title: title,
      message: message,
      duration: duration ?? const Duration(milliseconds: 3200),
      onTap: onTap,
      onClose: onClose,
    );
  }

  final NotificationType type;
  final String title;
  final String? message;
  final Duration? duration;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
}
