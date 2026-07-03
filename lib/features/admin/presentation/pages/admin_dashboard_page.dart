import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/role_model.dart';
import '../../../../models/ticket_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/user_api_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../shared/components/components.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AuthService _authService = AuthService();
  final UserApiService _userApiService = UserApiService();
  final TicketService _ticketService = TicketService();

  bool _isLoading = true;
  Map<String, dynamic>? _dashboardStats;
  String? _errorMessage;
  List<TicketModel> _latestTickets = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _userApiService.getDashboardStats(),
        _ticketService.getTickets(userRole: UserRole.admin, status: 'open', limit: 5),
      ]);

      if (mounted) {
        final stats = results[0];
        final ticketsResponse = results[1] as Map<String, dynamic>;
        final tickets = ticketsResponse['tickets'] as List<TicketModel>? ?? [];

        setState(() {
          _dashboardStats = stats is Map<String, dynamic> ? stats : null;
          _latestTickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat statistik: ${e.toString()}';
          _isLoading = false;
          _latestTickets = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if current user is admin
    if (_authService.currentUser?.role != UserRole.admin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Dashboard Admin'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Akses Ditolak',
                style: AppTheme().headlineSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hanya administrator yang dapat mengakses halaman ini',
                style: AppTheme().bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Dashboard Admin',
          style: AppTheme().headlineSmall,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadDashboardStats,
            icon: const Icon(Icons.refresh_rounded, size: 22),
          ),
        ],
      ),
      body: _isLoading
          ? const FullPageLoading(message: 'Memuat statistik admin...')
          : _errorMessage != null
              ? EmptyStates.serverError(
                  onRetry: _loadDashboardStats,
                )
              : _dashboardStats == null
                  ? EmptyStates.noData(
                      title: 'Tidak ada data',
                      subtitle: 'Statistik admin belum tersedia',
                      onRefresh: _loadDashboardStats,
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tickets Section
                          _buildSectionTitle('Statistik Tiket'),
                          const SizedBox(height: 12),
                          _buildTicketStats(),
                          const SizedBox(height: 24),

                          // Users Section
                          _buildSectionTitle('Statistik Pengguna'),
                          const SizedBox(height: 12),
                          _buildUserStats(),
                          const SizedBox(height: 24),

                          // System Section
                          _buildSectionTitle('Statistik Sistem'),
                          const SizedBox(height: 12),
                          _buildSystemStats(),
                          const SizedBox(height: 32),

                          // Latest Tickets Section
                          _buildSectionTitle('Tiket Terbaru'),
                          const SizedBox(height: 12),
                          _buildLatestTickets(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme().headlineSmall.copyWith(
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildTicketStats() {
    final tickets = _dashboardStats!['tickets'] as Map<String, dynamic>? ?? {};

    final total = tickets['total'] as int? ?? 0;
    final open = tickets['open'] as int? ?? 0;
    final inProgress = tickets['in_progress'] as int? ?? 0;
    final closed = tickets['closed'] as int? ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Tiket',
                value: '$total',
                color: AppColors.primary,
                icon: Icons.confirmation_number_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Open',
                value: '$open',
                color: AppColors.statusOpen,
                icon: Icons.info_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'In Progress',
                value: '$inProgress',
                color: AppColors.statusInProgress,
                icon: Icons.access_time_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Closed',
                value: '$closed',
                color: AppColors.statusClosed,
                icon: Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserStats() {
    final users = _dashboardStats!['users'] as Map<String, dynamic>? ?? {};

    final total = users['total'] as int? ?? 0;
    final active = users['active'] as int? ?? 0;
    final inactive = users['inactive'] as int? ?? 0;
    final byRole = users['by_role'] as Map<String, dynamic>? ?? {};
    final userCount = byRole['user'] as int? ?? 0;
    final helpdeskCount = byRole['helpdesk'] as int? ?? 0;
    final adminCount = byRole['admin'] as int? ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Pengguna',
                value: '$total',
                color: AppColors.primary,
                icon: Icons.people_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Aktif',
                value: '$active',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Nonaktif',
                value: '$inactive',
                color: AppColors.error,
                icon: Icons.cancel_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoleStatCard(
                title: 'User',
                value: '$userCount',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleStatCard(
                title: 'Helpdesk',
                value: '$helpdeskCount',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RoleStatCard(
                title: 'Admin',
                value: '$adminCount',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemStats() {
    final system = _dashboardStats!['system'] as Map<String, dynamic>? ?? {};

    final totalComments = system['total_comments'] as int? ?? 0;
    final totalAttachments = system['total_attachments'] as int? ?? 0;
    final totalNotifications = system['total_notifications'] as int? ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Komentar',
                value: '$totalComments',
                color: AppColors.info,
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Lampiran',
                value: '$totalAttachments',
                color: AppColors.success,
                icon: Icons.attach_file_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Total Notifikasi',
                value: '$totalNotifications',
                color: AppColors.priorityHigh,
                icon: Icons.notifications_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLatestTickets() {
    if (_latestTickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_rounded,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada tiket',
                style: AppTheme().bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _latestTickets.map((ticket) => _LatestTicketCard(ticket: ticket)).toList(),
    );
  }
}

class _LatestTicketCard extends StatelessWidget {
  final TicketModel ticket;

  const _LatestTicketCard({required this.ticket});

  TicketStatus _ticketStatus(String status) {
    switch (status) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  PriorityLevel _priorityLevel(String priority) {
    switch (priority) {
      case 'low':
        return PriorityLevel.low;
      case 'medium':
        return PriorityLevel.medium;
      case 'high':
        return PriorityLevel.high;
      case 'critical':
        return PriorityLevel.critical;
      default:
        return PriorityLevel.low;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'hardware':
        return '🖥️ Hardware';
      case 'software':
        return '💿 Software';
      case 'network':
        return '🌐 Network';
      case 'other':
        return '📋 Lainnya';
      default:
        return cat;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/ticket-detail',
          arguments: ticket,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PriorityBadge(
                  text: ticket.priority.toUpperCase(),
                  priority: _priorityLevel(ticket.priority),
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.ticketNumber,
                  style: AppTheme().labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                StatusBadge(
                  text: _statusLabel(ticket.status),
                  status: _ticketStatus(ticket.status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.title,
              style: AppTheme().bodyLarge.copyWith(
                color: AppColors.onSurface,
                height: 1.3,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _categoryLabel(ticket.category),
              style: AppTheme().bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  ticket.reporterName,
                  style: AppTheme().bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  _timeAgo(ticket.createdAt),
                  style: AppTheme().labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTheme().displayLarge.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme().labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _RoleStatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme().headlineMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme().labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
