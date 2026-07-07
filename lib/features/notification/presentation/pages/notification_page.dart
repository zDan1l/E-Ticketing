import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/notification_model.dart';
import '../../../../models/ticket_model.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../services/ticket_service.dart';
import '../../../../shared/widgets/main_navigation.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final TicketService _ticketService = TicketService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notifProvider.loadNotifications();
  }

  Future<void> _markAllRead() async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    final success = await notifProvider.markAllAsRead();

    if (success && mounted) {
      context.showSuccessSnackBar('Semua notifikasi ditandai sudah dibaca');
    } else if (mounted) {
      context.showErrorSnackBar('Gagal menandai semua sebagai dibaca');
    }
  }

  Future<void> _markAsRead(String notifId) async {
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notifProvider.markAsRead(notifId);
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'ticket_created':
        return Icons.confirmation_number_rounded;
      case 'ticket_assigned':
        return Icons.person_add_rounded;
      case 'ticket_updated':
        return Icons.update_rounded;
      case 'ticket_comment':
        return Icons.comment_rounded;
      case 'ticket_closed':
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _notifIconColor(String type) {
    switch (type) {
      case 'ticket_created':
        return AppColors.primary;
      case 'ticket_assigned':
        return AppColors.secondary;
      case 'ticket_updated':
        return AppColors.tertiary;
      case 'ticket_comment':
        return AppColors.successAccent;
      case 'ticket_closed':
        return AppColors.onSurfaceVariant;
      default:
        return AppColors.primary;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    if (diff.inDays < 7) return '${diff.inDays}h lalu';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;
    final isLoading = notifProvider.isLoading;
    final errorMessage = notifProvider.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Notifikasi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (notifications.isNotEmpty && notifications.any((n) => !n.isRead))
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: _markAllRead,
                icon: const Icon(Icons.done_all_rounded, size: 20),
                label: Text(
                  'Tandai Semua',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const FullPageLoading(message: 'Memuat notifikasi...')
          : errorMessage != null
              ? EmptyStates.serverError(
                  onRetry: _loadNotifications,
                )
              : notifications.isEmpty
                  ? EmptyStates.noNotifications()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return _NotifItem(
                          notif: notif,
                          icon: _notifIcon(notif.type),
                          iconColor: _notifIconColor(notif.type),
                          timeAgo: _timeAgo(notif.createdAt),
                          onTap: () async {
                            // Mark as read
                            if (!notif.isRead) {
                              await _markAsRead(notif.id);
                            }
                            // Navigate to ticket if applicable
                            if (notif.ticketId != null && mounted) {
                              // Fetch the ticket and navigate
                              try {
                                final ticket = await _ticketService.getTicketById(notif.ticketId!);
                                if (ticket != null && mounted) {
                                  final result = await Navigator.of(context).pushNamed(
                                    '/ticket-detail',
                                    arguments: ticket,
                                  );
                                  if (result == true && mounted) {
                                    context.showSuccessSnackBar('Tiket berhasil dihapus');
                                    final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                                    mainNavState?.setIndex(0);
                                  }
                                  _loadNotifications();
                                }
                              } catch (e) {
                                // Ignore navigation errors
                              }
                            }
                          },
                        );
                      },
                    ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final NotificationModel notif;
  final IconData icon;
  final Color iconColor;
  final String timeAgo;
  final VoidCallback onTap;

  const _NotifItem({
    required this.notif,
    required this.icon,
    required this.iconColor,
    required this.timeAgo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      glowColor: notif.isRead ? Colors.transparent : AppColors.primary,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!notif.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
