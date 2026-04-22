import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dummy_data.dart';
import '../../../../models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(DummyData.notifications);
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                isRead: true,
                ticketId: n.ticketId,
                ticketNumber: n.ticketNumber,
                createdAt: n.createdAt,
              ))
          .toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Semua notifikasi ditandai sudah dibaca',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'ticket_status_changed':
        return Icons.sync_rounded;
      case 'new_comment':
        return Icons.chat_bubble_outline_rounded;
      case 'ticket_assigned':
        return Icons.person_add_alt_1_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _notifIconColor(String type) {
    switch (type) {
      case 'ticket_status_changed':
        return AppColors.statusInProgress;
      case 'new_comment':
        return AppColors.primary;
      case 'ticket_assigned':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Baca Semua',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 72,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _NotifItem(
                  notif: notif,
                  icon: _notifIcon(notif.type),
                  iconColor: _notifIconColor(notif.type),
                  timeAgo: _timeAgo(notif.createdAt),
                  onTap: () {
                    // Mark as read
                    setState(() {
                      _notifications[index] = NotificationModel(
                        id: notif.id,
                        type: notif.type,
                        title: notif.title,
                        body: notif.body,
                        isRead: true,
                        ticketId: notif.ticketId,
                        ticketNumber: notif.ticketNumber,
                        createdAt: notif.createdAt,
                      );
                    });
                    // Navigate to ticket
                    if (notif.ticketId != null) {
                      final ticket = DummyData.tickets.firstWhere(
                        (t) => t.id == notif.ticketId,
                        orElse: () => DummyData.tickets.first,
                      );
                      Navigator.of(context).pushNamed(
                        '/ticket-detail',
                        arguments: ticket,
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada notifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notif.isRead ? Colors.transparent : AppColors.primarySurface.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
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
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight:
                                notif.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.textPrimary,
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
