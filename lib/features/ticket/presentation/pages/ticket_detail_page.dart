import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/ticket_model.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../shared/widgets/assign_ticket_dialog.dart';
import '../../../../shared/widgets/status_update_buttons.dart';
import '../../../../shared/components/components.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TicketDetailPage
//
// Changes from original:
//   • AppColors.primarySurface (deleted) → AppColors.primaryContainer
//   • AppColors.successAccent.withOpacity(0.1) → AppColors.surfaceContainerLow
//     (lightest tinted surface — reads as a very faint green-adjacent wash
//      without opacity math; intent preserved)
//   • AppColors.primary.withOpacity(0.1) on avatar backgrounds
//     → AppColors.primaryFixed (the lightest primary tint in the token system)
//   • AppColors.onSurfaceVariant.withOpacity(0.3) on unset avatar
//     → AppColors.surfaceContainerHigh (solid medium-light neutral)
//   • AppColors.primary.withValues(alpha: 0.1) on attachment icon bg
//     → AppColors.primaryFixed
//   • _PersonInfo: AppColors.primary.withValues(alpha: 0.1)
//     → AppColors.primaryFixed
//   • _PersonInfo: AppColors.disabled.withValues(alpha: 0.3) (unset avatar)
//     → AppColors.surfaceContainerHigh
// ─────────────────────────────────────────────────────────────────────────────

class TicketDetailPage extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  late TicketModel _ticket;
  final AuthService _authService = AuthService();
  final TicketService _ticketService = TicketService();

  List<TicketTimeline> _timeline = [];
  List<CommentModel> _comments = [];
  List<AttachmentModel> _attachments = [];
  bool _isLoadingTimeline = true;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _loadTimelineAndComments();
  }

  Future<void> _loadTimelineAndComments() async {
    try {
      final results = await Future.wait([
        _ticketService.getTimelineForTicket(_ticket.id),
        _ticketService.getCommentsForTicket(_ticket.id),
        _ticketService.getAttachmentsForTicket(_ticket.id),
      ]);

      if (mounted) {
        setState(() {
          _timeline = results[0] as List<TicketTimeline>;
          _comments = results[1] as List<CommentModel>;
          _attachments = results[2] as List<AttachmentModel>;
          _isLoadingTimeline = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTimeline = false);
      }
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    setState(() => _isSubmittingComment = true);

    final success =
        await _ticketService.addComment(_ticket.id, commentText);

    if (mounted) {
      setState(() => _isSubmittingComment = false);

      if (success) {
        _commentController.clear();
        await _loadTimelineAndComments();
        DashboardPage.dashboardKey.currentState?.refreshDashboard();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Komentar berhasil ditambahkan'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menambahkan komentar'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleStatusUpdate(String newStatus) async {
    final success =
        await _ticketService.updateTicketStatus(_ticket.id, newStatus);

    if (success) {
      setState(() {
        _ticket = _ticket.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      });
      DashboardPage.dashboardKey.currentState?.refreshDashboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status berhasil diupdate ke ${_statusLabel(newStatus)}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengupdate status'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleAssign(UserModel assignee) async {
    final success = assignee.id.isEmpty
        ? true
        : await _ticketService.assignTicket(_ticket.id, assignee.id);

    if (success) {
      setState(() {
        _ticket = _ticket.copyWith(
          assigneeId: assignee.id.isEmpty ? null : assignee.id,
          assigneeName: assignee.id.isEmpty ? null : assignee.name,
          assigneeAvatar: assignee.id.isEmpty ? null : assignee.avatar,
          updatedAt: DateTime.now(),
        );
      });
      DashboardPage.dashboardKey.currentState?.refreshDashboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(assignee.id.isEmpty
                ? 'Tiket berhasil di-unassign'
                : 'Tiket di-assign ke ${assignee.name}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengassign tiket'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Tiket', style: AppTheme().headlineSmall),
        content: Text(
          'Apakah Anda yakin ingin menghapus tiket ini? '
          'Tindakan ini tidak dapat dibatalkan.',
          style: AppTheme().bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          ClayButton(
            text: 'Batal',
            isGhost: true,
            onPressed: () => Navigator.pop(context),
          ),
          ClayButton(
            text: 'Hapus',
            backgroundColor: AppColors.error,
            textColor: AppColors.onError,
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await _ticketService.deleteTicket(_ticket.id);
              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tiket berhasil dihapus'),
                      backgroundColor: AppColors.successAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                  DashboardPage.dashboardKey.currentState
                      ?.refreshDashboard();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus tiket'),
                      backgroundColor: AppColors.error,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAttachmentDialog(AttachmentModel attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Lampiran', style: AppTheme().headlineSmall),
        content: Text(
          'Apakah Anda yakin ingin menghapus lampiran '
          '"${attachment.fileName}"?',
          style: AppTheme().bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          ClayButton(
            text: 'Batal',
            isGhost: true,
            onPressed: () => Navigator.pop(context),
          ),
          ClayButton(
            text: 'Hapus',
            backgroundColor: AppColors.error,
            textColor: AppColors.onError,
            onPressed: () async {
              Navigator.pop(context);
              final success = await _ticketService.deleteAttachment(
                  _ticket.id, attachment.id);
              if (success) {
                if (mounted) {
                  setState(() {
                    _attachments.remove(attachment);
                    _ticket = _ticket.copyWith(
                        attachmentsCount: _attachments.length);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lampiran berhasil dihapus'),
                      backgroundColor: AppColors.successAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus lampiran'),
                      backgroundColor: AppColors.error,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  TicketStatus _ticketStatus(String status) {
    switch (status) {
      case 'open':       return TicketStatus.open;
      case 'in_progress':return TicketStatus.inProgress;
      case 'resolved':   return TicketStatus.resolved;
      case 'closed':     return TicketStatus.closed;
      case 'reopened':   return TicketStatus.reopened;
      default:           return TicketStatus.open;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':        return 'Open';
      case 'in_progress': return 'In Progress';
      case 'resolved':    return 'Resolved';
      case 'closed':      return 'Closed';
      case 'reopened':    return 'Reopened';
      default:            return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':        return AppColors.primary;
      case 'in_progress': return AppColors.warningAccent;
      case 'resolved':    return AppColors.successAccent;
      case 'closed':      return AppColors.onSurfaceVariant;
      case 'reopened':    return AppColors.tertiary;
      default:            return AppColors.primary;
    }
  }

  PriorityLevel _priorityLevel(String priority) {
    switch (priority) {
      case 'low':      return PriorityLevel.low;
      case 'medium':   return PriorityLevel.medium;
      case 'high':     return PriorityLevel.high;
      case 'critical': return PriorityLevel.critical;
      default:         return PriorityLevel.low;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority) {
      case 'low':      return 'Low';
      case 'medium':   return 'Medium';
      case 'high':     return 'High';
      case 'critical': return 'Critical';
      default:         return priority;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'hardware': return 'Hardware';
      case 'software': return 'Software';
      case 'network':  return 'Network';
      case 'other':    return 'Lainnya';
      default:         return cat;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'hardware': return Icons.computer_rounded;
      case 'software': return Icons.apps_rounded;
      case 'network':  return Icons.wifi_rounded;
      case 'other':    return Icons.more_horiz_rounded;
      default:         return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timeline = _timeline;
    final comments = _comments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _ticket.ticketNumber,
          style: AppTheme().headlineSmall.copyWith(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          if (_authService.currentUser
                  ?.hasPermission(UserPermission.canDeleteTicket) ??
              false)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_rounded, size: 22),
              tooltip: 'Hapus Tiket',
            ),
          if (_authService.currentUser
                  ?.hasPermission(UserPermission.canAssignTickets) ??
              false)
            IconButton(
              onPressed: () {
                showAssignTicketDialog(
                  context: context,
                  currentAssigneeId: _ticket.assigneeId,
                  onAssign: _handleAssign,
                );
              },
              icon: const Icon(Icons.person_add_rounded, size: 22),
              tooltip: 'Assign Tiket',
            ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status & Priority Header ──────────────────────────────
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceContainerLowest,
                    padding:
                        const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusBadge(
                              text: _statusLabel(_ticket.status),
                              status: _ticketStatus(_ticket.status),
                            ),
                            const SizedBox(width: 8),
                            PriorityBadge(
                              text: _priorityLabel(_ticket.priority),
                              priority: _priorityLevel(_ticket.priority),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _ticket.title,
                          style: AppTheme().headlineMedium.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _categoryIcon(_ticket.category),
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _categoryLabel(_ticket.category),
                              style: AppTheme().bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time_rounded,
                                size: 16,
                                color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(_ticket.createdAt),
                              style: AppTheme().bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── People ───────────────────────────────────────────────
                  GestureDetector(
                    onTap: () {
                      if (_authService.currentUser?.hasPermission(
                              UserPermission.canAssignTickets) ??
                          false) {
                        showAssignTicketDialog(
                          context: context,
                          currentAssigneeId: _ticket.assigneeId,
                          onAssign: _handleAssign,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      color: AppColors.surfaceContainerLowest,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _PersonInfo(
                              label: 'Pelapor',
                              name: _ticket.reporterName,
                              avatar: _ticket.reporterAvatar,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.divider,
                          ),
                          Expanded(
                            child: _PersonInfo(
                              label: 'Ditangani Oleh',
                              name: _ticket.assigneeName ??
                                  'Belum di-assign',
                              avatar: _ticket.assigneeAvatar,
                              showAssignHint: _authService.currentUser
                                      ?.hasPermission(
                                          UserPermission.canAssignTickets) ??
                                  false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Description ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceContainerLowest,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deskripsi',
                          style: AppTheme().labelCaps.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _ticket.description,
                          style: AppTheme().bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        if (_attachments.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ..._attachments.map((attachment) => Container(
                                margin:
                                    const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  // Solid canvas — no glow, no opacity
                                  color: AppColors.canvas,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        // primaryFixed = lightest primary
                                        // tint token — solid, no opacity
                                        color: AppColors.primaryFixed,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        attachment.isImage
                                            ? Icons.image_rounded
                                            : Icons
                                                .attach_file_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            attachment.fileName,
                                            style: AppTheme()
                                                .bodyMedium
                                                .copyWith(
                                                  color: AppColors
                                                      .onSurface,
                                                ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            attachment.fileSizeDisplay,
                                            style: AppTheme()
                                                .labelSmall
                                                .copyWith(
                                                  color: AppColors
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_authService.currentUser
                                            ?.hasPermission(UserPermission
                                                .canDeleteTicket) ??
                                        false)
                                      IconButton(
                                        onPressed: () =>
                                            _showDeleteAttachmentDialog(
                                                attachment),
                                        icon: const Icon(
                                            Icons.delete_rounded,
                                            size: 18),
                                        color: AppColors.error,
                                        tooltip: 'Hapus Lampiran',
                                      ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Status update buttons ─────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: StatusUpdateButtons(
                      currentStatus: _ticket.status,
                      onStatusUpdate: _handleStatusUpdate,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Timeline ─────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceContainerLowest,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timeline',
                          style: AppTheme().labelCaps.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CompactTimeline(
                          items: timeline
                              .map((item) => TimelineItem(
                                    title: item.description,
                                    description:
                                        '${item.actorName} • '
                                        '${_formatDate(item.createdAt)}',
                                    dotColor:
                                        _statusColor(item.status),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Comments ─────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    color: AppColors.surfaceContainerLowest,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Komentar',
                              style: AppTheme().labelCaps.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                // primaryContainer solid token — was
                                // AppColors.primarySurface (deleted)
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${comments.length}',
                                style: AppTheme().labelSmall.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, idx) {
                            final c = comments[idx];
                            final isHelpdesk =
                                c.authorRole == 'helpdesk';
                            final isOutgoing = c.authorName ==
                                _authService.currentUser?.name;

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16),
                              child: MessageBubble(
                                message: c.body,
                                timestamp:
                                    '${c.authorName} • '
                                    '${_timeAgo(c.createdAt)}',
                                isOutgoing: isOutgoing,
                                avatar: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    // Solid tint tokens — no opacity
                                    color: isHelpdesk
                                        ? AppColors.surfaceContainerLow
                                        : AppColors.primaryFixed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      c.authorAvatar,
                                      style: AppTheme()
                                          .labelSmall
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isHelpdesk
                                                ? AppColors.successAccent
                                                : AppColors.primary,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── Comment input bar ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            color: AppColors.surfaceContainerLowest,
            child: MessageInput(
              controller: _commentController,
              hint: 'Tulis komentar...',
              onSend: _isSubmittingComment ? null : _submitComment,
              onAttach: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PersonInfo
// ─────────────────────────────────────────────────────────────────────────────
class _PersonInfo extends StatelessWidget {
  final String label;
  final String name;
  final String? avatar;
  final bool showAssignHint;

  const _PersonInfo({
    required this.label,
    required this.name,
    this.avatar,
    this.showAssignHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme().labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                // primaryFixed = lightest primary tint (solid)
                // surfaceContainerHigh = solid medium neutral for unset
                color: avatar != null
                    ? AppColors.primaryFixed
                    : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  avatar ?? '?',
                  style: AppTheme().labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: avatar != null
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: AppTheme().bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showAssignHint) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.edit_rounded,
                size: 12,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}