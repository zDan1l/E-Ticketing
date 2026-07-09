import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/ticket_model.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/attachment_service.dart';
import 'package:provider/provider.dart';
import '../../../../providers/ticket_provider.dart';
import '../../../../providers/notification_provider.dart';
import '../../../../shared/widgets/assign_ticket_dialog.dart';
import '../../../../shared/widgets/automatic_status_actions.dart';
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
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  final Map<String, Uint8List> _imageBytesCache = {};

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

          // Debug attachment data
          print('Loaded ${_attachments.length} attachments:');
          for (final attachment in _attachments) {
            print('  - ${attachment.fileName}');
            print('    MIME type: ${attachment.mimeType}');
            print('    Is image: ${attachment.isImage}');
            print('    File path: ${attachment.filePath}');
          }
        });
      }
    } catch (e) {
      print('Error loading attachments: $e'); // Debug error
      // Error handling - keep existing data
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

        context.showSuccessSnackBar('Komentar berhasil ditambahkan');
        try {
          Provider.of<NotificationProvider>(context, listen: false).loadNotifications(silent: true);
        } catch (_) {}
      } else {
        context.showErrorSnackBar('Gagal menambahkan komentar');
      }
    }
  }

  Future<Uint8List?> _loadImageBytes(String imageUrl) async {
    if (_imageBytesCache.containsKey(imageUrl)) {
      return _imageBytesCache[imageUrl];
    }

    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _imageBytesCache[imageUrl] = bytes;
        return bytes;
      }
    } catch (e) {
      print('Error loading image: $e');
    }
    return null;
  }

  void _showImageDialog(Uint8List imageBytes, String fileName, String fileUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageBytes: imageBytes,
          fileName: fileName,
          fileUrl: fileUrl,
        ),
      ),
    );
  }

  Future<void> _openAttachment(AttachmentModel attachment) async {
    final fileUrl = AttachmentService().getFileUrl(attachment.filePath);
    final ext = attachment.fileExtension;

    if (attachment.isImage) {
      final bytes = await _loadImageBytes(fileUrl);
      if (bytes != null && mounted) {
        _showImageDialog(bytes, attachment.fileName, fileUrl);
      } else {
        if (mounted) {
          context.showErrorSnackBar('Gagal memuat pratinjau gambar');
        }
      }
    } else if (ext == 'txt' || ext == 'log' || ext == 'json' || ext == 'csv' || ext == 'xml' || ext == 'html') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenTextViewer(
            fileUrl: fileUrl,
            fileName: attachment.fileName,
          ),
        ),
      );
    } else {
      final uri = Uri.parse(fileUrl);
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          throw 'Could not launch $fileUrl';
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('Buka Lampiran', style: AppTheme().headlineSmall),
              content: Text(
                'Tidak dapat membuka "${attachment.fileName}" secara langsung.\n\n'
                'Salin tautan di bawah ini untuk mengunduh melalui browser:',
                style: AppTheme().bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              actions: [
                ClayButton(
                  text: 'Batal',
                  isGhost: true,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                ClayButton(
                  text: 'Salin Tautan',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fileUrl));
                    Navigator.pop(dialogContext);
                    context.showSuccessSnackBar('Tautan berhasil disalin ke clipboard');
                  },
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _imageBytesCache.clear();
    super.dispose();
  }

  void _handleAutomaticAction() async {
    final authService = AuthService();
    final currentUser = authService.currentUser;

    // Only helpdesk can perform automatic actions
    if (currentUser?.role != UserRole.helpdesk) {
      if (mounted) {
        context.showErrorSnackBar('Hanya helpdesk yang dapat melakukan aksi ini', duration: const Duration(seconds: 2));
      }
      return;
    }

    // Check if ticket is assigned to current user
    if (_ticket.assigneeId != currentUser?.id) {
      if (mounted) {
        context.showErrorSnackBar('Tiket ini tidak ditugaskan kepada Anda', duration: const Duration(seconds: 2));
      }
      return;
    }

    // Only allow finish action for In Progress tickets
    if (!_ticket.isInProgress) {
      if (mounted) {
        context.showErrorSnackBar('Hanya tiket dengan status In Progress yang dapat diselesaikan', duration: const Duration(seconds: 2));
      }
      return;
    }

    // Finish ticket action
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final success = await ticketProvider.finishTicket(_ticket.id);

    if (success) {
      setState(() {
        _ticket = _ticket.copyWith(
          status: 'closed',
          updatedAt: DateTime.now(),
        );
      });

      try {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(silent: true);
      } catch (_) {}

      await _loadTimelineAndComments();

      if (mounted) {
        context.showSuccessSnackBar('Tiket berhasil diselesaikan', duration: const Duration(seconds: 2));
      }
    } else {
      if (mounted) {
        context.showErrorSnackBar('Gagal menyelesaikan tiket', duration: const Duration(seconds: 2));
      }
    }
  }

  void _handleAssign(UserModel assignee) async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final success = assignee.id.isEmpty
        ? true
        : await ticketProvider.assignTicket(_ticket.id, assignee.id);

    if (success) {
      setState(() {
        _ticket = _ticket.copyWith(
          assigneeId: assignee.id.isEmpty ? null : assignee.id,
          assigneeName: assignee.id.isEmpty ? null : assignee.name,
          assigneeAvatar: assignee.id.isEmpty ? null : assignee.avatar,
          status: assignee.id.isEmpty ? 'open' : 'in_progress',
          updatedAt: DateTime.now(),
        );
      });

      // Reload timeline and comments to show the assignment entry in the list
      _loadTimelineAndComments();

      if (mounted) {
        context.showSuccessSnackBar(
          assignee.id.isEmpty
              ? 'Tiket berhasil di-unassign'
              : 'Tiket di-assign ke ${assignee.name}',
          duration: const Duration(seconds: 2),
        );
      }
      try {
        Provider.of<NotificationProvider>(context, listen: false).loadNotifications(silent: true);
      } catch (_) {}
    } else {
      if (mounted) {
        context.showErrorSnackBar('Gagal mengassign tiket', duration: const Duration(seconds: 2));
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Tiket', style: AppTheme().headlineSmall),
        content: Text(
          'Apakah Anda yakin ingin menghapus tiket ini? '
          'Tindakan ini tidak dapat dibatalkan.',
          style: AppTheme().bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          ClayButton(
            text: 'Batal',
            isGhost: true,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ClayButton(
            text: 'Hapus',
            backgroundColor: AppColors.error,
            textColor: AppColors.onError,
            onPressed: () async {
              Navigator.pop(dialogContext);
              final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
              final success =
                  await ticketProvider.deleteTicket(_ticket.id);
              if (success) {
                try {
                  Provider.of<NotificationProvider>(context, listen: false).loadNotifications(silent: true);
                } catch (_) {}
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              } else {
                if (mounted) {
                  context.showErrorSnackBar('Gagal menghapus tiket', duration: const Duration(seconds: 2));
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
      builder: (dialogContext) => AlertDialog(
        title: Text('Hapus Lampiran', style: AppTheme().headlineSmall),
        content: Text(
          'Apakah Anda yakin ingin menghapus lampiran '
          '"${attachment.fileName}"?',
          style: AppTheme().bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          ClayButton(
            text: 'Batal',
            isGhost: true,
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ClayButton(
            text: 'Hapus',
            backgroundColor: AppColors.error,
            textColor: AppColors.onError,
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _ticketService.deleteAttachment(
                  _ticket.id, attachment.id);
              if (success) {
                if (mounted) {
                  setState(() {
                    _attachments.remove(attachment);
                    _ticket = _ticket.copyWith(
                        attachmentsCount: _attachments.length);
                  });
                  context.showSuccessSnackBar('Lampiran berhasil dihapus', duration: const Duration(seconds: 2));
                }
              } else {
                if (mounted) {
                  context.showErrorSnackBar('Gagal menghapus lampiran', duration: const Duration(seconds: 2));
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
      case 'closed':     return TicketStatus.closed;
      default:           return TicketStatus.open;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':        return 'Open';
      case 'in_progress': return 'In Progress';
      case 'closed':      return 'Closed';
      default:            return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':        return AppColors.primary;
      case 'in_progress': return AppColors.warningAccent;
      case 'closed':      return AppColors.successAccent;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: StyledCard(
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.zero,
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
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.onSurface,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                _categoryIcon(_ticket.category),
                                size: 16,
                                color: onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _categoryLabel(_ticket.category),
                                style: AppTheme().bodyMedium.copyWith(
                                  color: onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                               Icon(Icons.access_time_rounded,
                                  size: 16,
                                  color: onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(_ticket.createdAt),
                                style: AppTheme().bodyMedium.copyWith(
                                  color: onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── People ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
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
                      child: StyledCard(
                        padding: const EdgeInsets.all(20),
                        margin: EdgeInsets.zero,
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
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.outlineVariant.withValues(alpha: 0.5),
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
                  ),

                  // ── Description & Attachments ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: StyledCard(
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deskripsi',
                            style: AppTheme().labelCaps.copyWith(
                              color: isDark ? Colors.white70 : AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _ticket.description,
                            style: AppTheme().bodyMedium.copyWith(
                              color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                          if (_attachments.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Lampiran (${_attachments.length})',
                              style: AppTheme().labelCaps.copyWith(
                                color: isDark ? Colors.white70 : AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._attachments.where((a) => a.isImage).map((attachment) =>
                                _ImageAttachmentCard(
                                  attachment: attachment,
                                  imageBytesCache: _imageBytesCache,
                                  onLoadImage: _loadImageBytes,
                                  onImageTap: _showImageDialog,
                                  onDelete: () => _showDeleteAttachmentDialog(attachment),
                                  canDelete: _authService.currentUser?.hasPermission(UserPermission.canDeleteTicket) ?? false,
                                  onFallbackTap: () => _openAttachment(attachment),
                                ),
                            ),
                            ..._attachments.where((a) => !a.isImage).map((attachment) =>
                                _FileAttachmentCard(
                                  attachment: attachment,
                                  onTap: () => _openAttachment(attachment),
                                  onDelete: () => _showDeleteAttachmentDialog(attachment),
                                  canDelete: _authService.currentUser?.hasPermission(UserPermission.canDeleteTicket) ?? false,
                                ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Automatic status actions ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AutomaticStatusActions(
                      ticket: _ticket,
                      onActionComplete: _handleAutomaticAction,
                    ),
                  ),

                  // ── Timeline ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: StyledCard(
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Timeline',
                            style: AppTheme().labelCaps.copyWith(
                              color: isDark ? Colors.white70 : AppColors.onSurface,
                              fontWeight: FontWeight.w700,
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
                  ),

                  // ── Comments ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: StyledCard(
                      padding: const EdgeInsets.all(20),
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Komentar',
                                style: AppTheme().labelCaps.copyWith(
                                  color: isDark ? Colors.white70 : AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${comments.length}',
                                  style: const TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, idx) {
                              final c = comments[idx];
                              final isHelpdesk = c.authorRole == 'helpdesk';
                              final isOutgoing = c.authorName == _authService.currentUser?.name;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: MessageBubble(
                                  message: c.body,
                                  timestamp: '${c.authorName} • ${_timeAgo(c.createdAt)}',
                                  isOutgoing: isOutgoing,
                                  avatar: UserAvatar(
                                    avatar: c.authorAvatar,
                                    name: c.authorName,
                                    size: 32,
                                    fontSize: 12,
                                    backgroundColor: isHelpdesk
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.primary.withValues(alpha: 0.1),
                                    textColor: isHelpdesk
                                        ? AppColors.success
                                        : AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
            color: isDark ? const Color(0xFF1E1E2F) : AppColors.surfaceContainerLowest,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          label,
          style: AppTheme().labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserAvatar(
              avatar: avatar,
              name: name,
              size: 28,
              fontSize: 10,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: AppTheme().bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
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
}// ─────────────────────────────────────────────────────────────────────────────
// _ImageAttachmentCard - Widget untuk menampilkan attachment gambar dengan preview
// ─────────────────────────────────────────────────────────────────────────────
class _ImageAttachmentCard extends StatefulWidget {
  final AttachmentModel attachment;
  final Map<String, Uint8List> imageBytesCache;
  final Future<Uint8List?> Function(String imageUrl) onLoadImage;
  final void Function(Uint8List imageBytes, String fileName, String fileUrl) onImageTap;
  final VoidCallback onDelete;
  final bool canDelete;
  final VoidCallback onFallbackTap;

  const _ImageAttachmentCard({
    required this.attachment,
    required this.imageBytesCache,
    required this.onLoadImage,
    required this.onImageTap,
    required this.onDelete,
    required this.canDelete,
    required this.onFallbackTap,
  });

  @override
  State<_ImageAttachmentCard> createState() => _ImageAttachmentCardState();
}

class _ImageAttachmentCardState extends State<_ImageAttachmentCard> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!widget.attachment.isImage) return;

    final attachmentService = AttachmentService();
    final imageUrl = attachmentService.getFileUrl(widget.attachment.filePath);

    print('Loading image from: $imageUrl'); // Debug URL
    print('File path: ${widget.attachment.filePath}'); // Debug file path

    setState(() => _isLoading = true);

    final bytes = await widget.onLoadImage(imageUrl);
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
        _hasError = bytes == null;
      });

      if (bytes == null) {
        print('Failed to load image from: $imageUrl'); // Debug error
      } else {
        print('Successfully loaded image: ${bytes.length} bytes'); // Debug success
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _imageBytes == null) {
      return _FileAttachmentCard(
        attachment: widget.attachment,
        onTap: widget.onFallbackTap,
        onDelete: widget.onDelete,
        canDelete: widget.canDelete,
      );
    }

    final imageUrl = AttachmentService().getFileUrl(widget.attachment.filePath);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          GestureDetector(
            onTap: () => widget.onImageTap(_imageBytes!, widget.attachment.fileName, imageUrl),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surfaceContainerLow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.broken_image, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // File info bar
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.attachment.fileName,
                      style: AppTheme().bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.attachment.fileSizeDisplay,
                      style: AppTheme().labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.canDelete)
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_rounded,
                    size: 18,
                  ),
                  color: AppColors.error,
                  tooltip: 'Hapus Lampiran',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FileAttachmentCard - Widget untuk menampilkan attachment non-gambar
// ─────────────────────────────────────────────────────────────────────────────
class _FileAttachmentCard extends StatelessWidget {
  final AttachmentModel attachment;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool canDelete;

  const _FileAttachmentCard({
    required this.attachment,
    required this.onTap,
    required this.onDelete,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getFileIcon(attachment.fileName),
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.fileName,
                    style: AppTheme().bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    attachment.fileSizeDisplay,
                    style: AppTheme().labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (canDelete)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_rounded,
                  size: 18,
                ),
                color: AppColors.error,
                tooltip: 'Hapus Lampiran',
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FullScreenImageViewer - Halaman peninjau gambar fullscreen interaktif
// ─────────────────────────────────────────────────────────────────────────────
class FullScreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;
  final String fileName;
  final String fileUrl;

  const FullScreenImageViewer({
    super.key,
    required this.imageBytes,
    required this.fileName,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          fileName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Colors.white),
            tooltip: 'Salin Tautan',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fileUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan gambar berhasil disalin ke clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(
            imageBytes,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FullScreenTextViewer - Halaman pembaca file teks fullscreen
// ─────────────────────────────────────────────────────────────────────────────
class FullScreenTextViewer extends StatefulWidget {
  final String fileUrl;
  final String fileName;

  const FullScreenTextViewer({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  State<FullScreenTextViewer> createState() => _FullScreenTextViewerState();
}

class _FullScreenTextViewerState extends State<FullScreenTextViewer> {
  String _content = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadTextContent();
  }

  Future<void> _loadTextContent() async {
    try {
      final response = await http.get(
        Uri.parse(widget.fileUrl),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _content = response.body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.fileName,
          style: AppTheme().headlineSmall.copyWith(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Salin Tautan',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.fileUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan file berhasil disalin ke clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('Gagal memuat isi file'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectionArea(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        _content,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}