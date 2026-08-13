import 'package:flutter/material.dart' hide Notification;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../shared/providers/app_mode.dart';
import '../providers/notifications_provider.dart';
import '../../domain/notification.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final lang = context.watch<LanguageProvider>().lang;
    final notificationsProvider = context.watch<NotificationsProvider>();
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios, color: isAcademy ? AppColors.cream : AppColors.cream),
                  ),
                  Expanded(
                    child: Text(
                      t('notifications.title', fallback: 'Notifications'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  if (notificationsProvider.unreadCount > 0)
                    TextButton(
                      onPressed: () => notificationsProvider.markAllAsRead(),
                      child: Text(
                        t('notifications.markAllRead', fallback: 'Mark all read'),
                        style: const TextStyle(color: AppColors.gold, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: notificationsProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  : notificationsProvider.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                              const SizedBox(height: AppSpacing.md),
                              TextButton(
                                onPressed: () => notificationsProvider.loadNotifications(),
                                child: Text(t('common.retry', fallback: 'Retry')),
                              ),
                            ],
                          ),
                        )
                      : notificationsProvider.notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.muted),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    t('notifications.noNotifications', fallback: 'No notifications yet'),
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              itemCount: notificationsProvider.notifications.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final n = notificationsProvider.notifications[index];
                                return _NotificationTile(
                                  notification: n,
                                  lang: lang,
                                  onTap: () => notificationsProvider.markAsRead(n.id),
                                  onDismiss: () => notificationsProvider.deleteNotification(n.id),
                                  isAcademy: isAcademy,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Notification notification;
  final AppLanguage lang;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final bool isAcademy;

  const _NotificationTile({
    required this.notification,
    required this.lang,
    required this.onTap,
    required this.onDismiss,
    this.isAcademy = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _iconForType(notification.type);
    final iconColor = _colorForType(notification.type);
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;

    return Dismissible(
      key: Key(notification.id),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: notification.read
                ? cardBg
                : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: notification.read
                ? null
                : Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, size: 20, color: AppColors.text),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: notification.read ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt, context.read<LanguageProvider>().t),
                      style: Theme.of(context).textTheme.caption.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return Icons.event_available;
      case 'membership':
        return Icons.card_membership;
      case 'payment':
        return Icons.payment;
      case 'promotion':
        return Icons.local_offer;
      case 'tour':
        return Icons.tour;
      case 'event':
        return Icons.event;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return AppColors.success;
      case 'membership':
        return AppColors.gold;
      case 'payment':
        return AppColors.info;
      case 'promotion':
        return AppColors.notificationPurple;
      case 'tour':
        return AppColors.notificationCyan;
      case 'event':
        return AppColors.notificationOrange;
      default:
        return AppColors.muted;
    }
  }

  String _formatTime(String createdAt, String Function(String, {String? fallback}) t) {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return t('notifications.justNow', fallback: 'Just now');
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }
}
