import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_spacing.dart';
import '../config/app_breakpoints.dart';
import '../logging/app_logger.dart';
import '../widgets/glass_notification.dart';
import 'notification_config.dart';

class AppNotificationService {
  AppNotificationService({required AppLogger logger}) : _logger = logger;

  static const int _maxOverlayNotifications = 4;

  final AppLogger _logger;
  final List<_OverlayNotification> _notifications = <_OverlayNotification>[];

  OverlayEntry? _overlayEntry;
  int _overlayNotificationIdCounter = 0;

  int get notificationCount => _notifications.length;

  void show(NotificationConfig config) {
    final BuildContext? overlayContext = Get.overlayContext;

    if (overlayContext == null) {
      _logger.warning(
        'Notification skipped because no overlay context is available.',
        tag: 'Notifications',
        context: <String, String>{
          'type': config.type.name,
          'title': config.title,
        },
      );
      return;
    }

    _enqueueOverlay(config);
    _updateOverlay(overlayContext);
  }

  void showSuccess({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    show(
      NotificationConfig.success(
        title: title,
        message: message,
        onTap: onTap,
        onClose: onClose,
      ),
    );
  }

  void showInfo({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    show(
      NotificationConfig.info(
        title: title,
        message: message,
        onTap: onTap,
        onClose: onClose,
      ),
    );
  }

  void showError({
    required String title,
    String? message,
    VoidCallback? onTap,
    VoidCallback? onClose,
  }) {
    show(
      NotificationConfig.error(
        title: title,
        message: message,
        onTap: onTap,
        onClose: onClose,
      ),
    );
  }

  void dismissAll() {
    for (final _OverlayNotification notification in _notifications) {
      _safeInvoke(notification.config.onClose, label: 'onClose (dismissAll)');
    }
    _notifications.clear();

    final BuildContext? overlayContext = Get.overlayContext;
    if (overlayContext != null) {
      _updateOverlay(overlayContext);
    } else {
      _removeOverlayEntry();
    }
  }

  void _enqueueOverlay(NotificationConfig config) {
    _notifications.add(
      _OverlayNotification(id: _overlayNotificationIdCounter++, config: config),
    );

    if (_notifications.length > _maxOverlayNotifications) {
      final _OverlayNotification overflowed = _notifications.removeAt(0);
      _safeInvoke(overflowed.config.onClose, label: 'onClose (overflow)');
    }

    _logger.debug(
      'Queued overlay notification.',
      tag: 'Notifications',
      context: <String, Object?>{
        'type': config.type.name,
        'title': config.title,
        'count': _notifications.length,
      },
    );
  }

  void _dismissById(int id) {
    final int index = _notifications.indexWhere(
      (_OverlayNotification notification) => notification.id == id,
    );
    if (index < 0) {
      return;
    }

    final _OverlayNotification removed = _notifications.removeAt(index);
    _safeInvoke(removed.config.onClose, label: 'onClose');

    final BuildContext? overlayContext = Get.overlayContext;
    if (overlayContext != null) {
      _updateOverlay(overlayContext);
    } else {
      _removeOverlayEntry();
    }
  }

  void _updateOverlay(BuildContext overlayContext) {
    if (_notifications.isEmpty) {
      _removeOverlayEntry();
      return;
    }

    if (_overlayEntry == null) {
      final OverlayState? overlay = Navigator.of(
        overlayContext,
        rootNavigator: true,
      ).overlay;
      if (overlay == null) {
        _logger.warning(
          'Notification skipped because root navigator overlay is unavailable.',
          tag: 'Notifications',
        );
        return;
      }
      _overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          final List<_OverlayNotification> items =
              List<_OverlayNotification>.unmodifiable(_notifications);

          if (items.isEmpty) {
            return const SizedBox.shrink();
          }

          return _NotificationOverlay(
            notifications: items,
            onDismiss: _dismissById,
            onTap: (_OverlayNotification item) {
              _safeInvoke(item.config.onTap, label: 'onTap');
            },
            enableHoverPause: _isDesktopOrWeb(),
          );
        },
      );
      overlay.insert(_overlayEntry!);
      return;
    }

    _overlayEntry!.markNeedsBuild();
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _safeInvoke(VoidCallback? callback, {required String label}) {
    if (callback == null) {
      return;
    }

    try {
      callback();
    } catch (error, stackTrace) {
      _logger.error(
        'Notification callback failed.',
        tag: 'Notifications',
        context: <String, String>{'label': label},
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static bool _isDesktopOrWeb() {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}

class _OverlayNotification {
  const _OverlayNotification({required this.id, required this.config});

  final int id;
  final NotificationConfig config;
}

class _NotificationOverlay extends StatelessWidget {
  const _NotificationOverlay({
    required this.notifications,
    required this.onDismiss,
    required this.onTap,
    required this.enableHoverPause,
  });

  final List<_OverlayNotification> notifications;
  final void Function(int id) onDismiss;
  final void Function(_OverlayNotification item) onTap;
  final bool enableHoverPause;

  @override
  Widget build(BuildContext context) {
    final bool isCompact =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Align(
          key: const Key('notification-overlay-align'),
          alignment: isCompact ? Alignment.topCenter : Alignment.topRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: notifications
                  .asMap()
                  .entries
                  .map(
                    (MapEntry<int, _OverlayNotification> entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.key < notifications.length - 1
                            ? AppSpacing.sm
                            : 0,
                      ),
                      child: _AnimatedNotification(
                        key: ValueKey<String>(
                          'overlay-notification-${entry.value.id}',
                        ),
                        id: entry.value.id,
                        config: entry.value.config,
                        enableHoverPause: enableHoverPause,
                        onTap: () => onTap(entry.value),
                        onDismiss: () => onDismiss(entry.value.id),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNotification extends StatefulWidget {
  const _AnimatedNotification({
    required this.id,
    required this.config,
    required this.enableHoverPause,
    required this.onTap,
    required this.onDismiss,
    super.key,
  });

  final int id;
  final NotificationConfig config;
  final bool enableHoverPause;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_AnimatedNotification> createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  Timer? _autoDismissTimer;
  Duration? _remainingAutoDismiss;
  DateTime? _autoDismissStartedAt;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
    _startOrResumeAutoDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startOrResumeAutoDismiss() {
    final Duration? duration = widget.config.duration;
    if (duration == null || _isClosing) {
      return;
    }

    final Duration remaining = _remainingAutoDismiss ?? duration;
    if (remaining <= Duration.zero) {
      _startClose();
      return;
    }

    _autoDismissStartedAt = DateTime.now();
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(remaining, _startClose);
  }

  void _pauseAutoDismiss() {
    if (!widget.enableHoverPause || _autoDismissTimer == null) {
      return;
    }

    final DateTime? startedAt = _autoDismissStartedAt;
    final Duration? duration = widget.config.duration;
    if (startedAt == null || duration == null) {
      return;
    }

    final Duration elapsed = DateTime.now().difference(startedAt);
    final Duration remaining = (_remainingAutoDismiss ?? duration) - elapsed;
    _remainingAutoDismiss = remaining.isNegative ? Duration.zero : remaining;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _autoDismissStartedAt = null;
  }

  void _resumeAutoDismiss() {
    if (!widget.enableHoverPause || widget.config.duration == null) {
      return;
    }

    if (_autoDismissTimer != null) {
      return;
    }

    _startOrResumeAutoDismiss();
  }

  void _handleTap() {
    widget.onTap();
    _startClose();
  }

  Future<void> _startClose() async {
    if (!mounted || _isClosing) {
      return;
    }

    _isClosing = true;
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _autoDismissStartedAt = null;

    await _controller.reverse();
    if (!mounted) {
      return;
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final NotificationType type = widget.config.type;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color accentColor = switch (type) {
      NotificationType.info => colorScheme.secondary,
      NotificationType.success => colorScheme.primary,
      NotificationType.error => colorScheme.error,
    };
    final IconData icon = switch (type) {
      NotificationType.info => Icons.info_outline_rounded,
      NotificationType.success => Icons.check_circle_rounded,
      NotificationType.error => Icons.error_rounded,
    };

    return MouseRegion(
      onEnter: (_) => _pauseAutoDismiss(),
      onExit: (_) => _resumeAutoDismiss(),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: GestureDetector(
            onTap: _handleTap,
            child: GlassNotification(
              title: widget.config.title,
              message: widget.config.message,
              icon: icon,
              color: accentColor,
              onClose: _startClose,
              closeButtonKey: Key('notification-close-${widget.id}'),
            ),
          ),
        ),
      ),
    );
  }
}
