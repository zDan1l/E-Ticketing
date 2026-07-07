import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/notification_model.dart';
import '../../../../models/ticket_model.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/ticket_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notifService = NotificationService();
  final TicketService _ticketService = TicketService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifs = await _notifService.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = notifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat notifikasi: ${e.toString()}';
          _isLoading = false;
          _notifications = [];
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    final success = await _notifService.markAllAsRead();

    if (success) {
      await _loadNotifications();

      if (mounted) {
        context.showSuccessSnackBar('Semua notifikasi ditandai sudah dibaca');
      }
    } else {
      if (mounted) {
        context.showErrorSnackBar('Gagal menandai semua sebagai dibaca');
      }
    }
  }

  Future<void> _markAsRead(String notifId, int index) async {
    final success = await _notifService.markNotificationAsRead(notifId);

    if (success && mounted) {
      setState(() {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          type: _notifications[index].type,
          title: _notifications[index].title,
          body: _notifications[index].body,
          ticketId: _notifications[index].ticketId,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
      });
    }
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
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Notifikasi',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          if (_notifications.isNotEmpty && _notifications.any((n) => !n.isRead))
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
      body: _isLoading
          ? const FullPageLoading(message: 'Memuat notifikasi...')
          : _errorMessage != null
              ? EmptyStates.serverError(
                  onRetry: _loadNotifications,
                )
              : _notifications.isEmpty
                  ? EmptyStates.noNotifications()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return _NotifItem(
                          notif: notif,
                          icon: _notifIcon(notif.type),
                          iconColor: _notifIconColor(notif.type),
                          timeAgo: _timeAgo(notif.createdAt),
                          onTap: () async {
                            // Mark as read
                            if (!notif.isRead) {
                              await _markAsRead(notif.id, index);
                            }
                            // Navigate to ticket if applicable
                            if (notif.ticketId != null && mounted) {
                              // Fetch the ticket and navigate
                              try {
                                final ticket = await _ticketService.getTicketById(notif.ticketId!);
                                if (ticket != null && mounted) {
                                  Navigator.of(context).pushNamed(
                                    '/ticket-detail',
                                    arguments: ticket,
                                  );
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
