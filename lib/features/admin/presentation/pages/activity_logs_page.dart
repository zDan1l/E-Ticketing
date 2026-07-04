import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/user_api_service.dart';

class ActivityLogsPage extends StatefulWidget {
  const ActivityLogsPage({super.key});

  @override
  State<ActivityLogsPage> createState() => _ActivityLogsPageState();
}

class _ActivityLogsPageState extends State<ActivityLogsPage> {
  final AuthService _authService = AuthService();
  final UserApiService _userApiService = UserApiService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _pagination;
  String? _errorMessage;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = page;
    });

    try {
      final response = await _userApiService.getActivityLogs(page: page);

      if (response != null && mounted) {
        setState(() {
          _activities = response['activities'] as List<Map<String, dynamic>>? ?? [];
          _pagination = response['pagination'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat aktivitas';
          _activities = [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat aktivitas: ${e.toString()}';
          _activities = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          'Activity Logs',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          ClayIconButton(
            icon: Icons.refresh_rounded,
            onPressed: () => _loadActivities(page: 1),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const FullPageLoading(message: 'Memuat log aktivitas...')
          : _errorMessage != null
              ? EmptyStates.serverError(
                  onRetry: () => _loadActivities(page: 1),
                )
              : Column(
                  children: [
                    // Activity count
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_activities.length} Aktivitas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    // Activity list or empty state
                    Expanded(
                      child: _activities.isEmpty
                          ? _EmptyState(
                              onRefresh: () => _loadActivities(page: 1))
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                              itemCount: _activities.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                return _ActivityCard(
                                  activity: _activities[index],
                                );
                              },
                            ),
                    ),
                    // Pagination
                    if (_pagination != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_pagination?['has_prev_page'] == true)
                              ClayIconButton(
                                icon: Icons.chevron_left,
                                onPressed: () => _loadActivities(page: _currentPage - 1),
                                tooltip: 'Previous page',
                              ),
                            Text(
                              'Halaman $_currentPage',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_pagination?['has_next_page'] == true)
                              ClayIconButton(
                                icon: Icons.chevron_right,
                                onPressed: () => _loadActivities(page: _currentPage + 1),
                                tooltip: 'Next page',
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum ada aktivitas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Aktivitas sistem akan muncul di sini',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ClayButton(
                text: 'Refresh',
                onPressed: onRefresh,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityCard({required this.activity});

  String _formatDate(DateTime dt) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'created':
        return AppColors.statusOpen;
      case 'status_changed':
        return AppColors.statusInProgress;
      case 'assigned':
        return AppColors.primary;
      case 'comment_added':
        return AppColors.successAccent;
      case 'closed':
        return AppColors.statusClosed;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _getActionLabel(String action) {
    switch (action) {
      case 'created':
        return 'Tiket Dibuat';
      case 'status_changed':
        return 'Status Diubah';
      case 'assigned':
        return 'Tiket Ditugaskan';
      case 'comment_added':
        return 'Komentar Ditambahkan';
      case 'closed':
        return 'Tiket Ditutup';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = activity['action'] as String? ?? 'unknown';
    final color = _getActionColor(action);
    final createdAt = activity['created_at'] as DateTime? ?? DateTime.now();
    final ticketNumber = activity['ticket_number'] as String?;

    return StyledCard(
      padding: const EdgeInsets.all(18),
      glowColor: AppColors.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Action badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getActionLabel(action),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Spacer(),
              // Time
              Text(
                _timeAgo(createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Description
          Text(
            activity['description'] as String? ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (ticketNumber != null) ...[
            const SizedBox(height: 10),
            // Ticket reference
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_number_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ticketNumber,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            decoration: const BoxDecoration(
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 12),
          // Actor info
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                activity['actor_name'] as String? ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
