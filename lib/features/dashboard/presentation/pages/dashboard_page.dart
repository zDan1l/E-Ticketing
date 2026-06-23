import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/ticket_model.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/user_api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  // GlobalKey to access dashboard state from parent widgets
  static final GlobalKey<_DashboardPageState> dashboardKey =
      GlobalKey<_DashboardPageState>();

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final AuthService _authService = AuthService();
  final TicketService _ticketService = TicketService();
  final UserApiService _userApiService = UserApiService();

  bool _isLoading = true;
  Map<String, int>? _stats;
  List<TicketModel> _recentTickets = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  // Admin-only stats
  Map<String, dynamic>? _adminStats;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void refreshDashboard() {
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userRole = _authService.currentUserRole;
      print('🔍 Dashboard: Loading data for role: ${userRole?.value}');

      // Load stats and tickets in parallel
      final futures = <Future>[
        _ticketService.getTicketStats(userRole: userRole),
        _ticketService.getTickets(userRole: userRole),
      ];

      // Load admin stats in parallel if admin
      if (userRole == UserRole.admin) {
        futures.add(_userApiService.getDashboardStats());
      }

      final results = await Future.wait(futures);

      if (mounted) {
        final ticketsResponse = results[1] as Map<String, dynamic>;
        final tickets = ticketsResponse['tickets'] as List<TicketModel>? ?? [];

        print('📊 Dashboard: Stats = ${results[0]}');
        print('🎫 Dashboard: Total tickets received = ${tickets.length}');

        setState(() {
          _stats = results[0] as Map<String, int>;
          _recentTickets = tickets.take(3).toList();
          if (userRole == UserRole.admin && results.length > 2) {
            _adminStats = results[2] as Map<String, dynamic>?;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Dashboard: Error loading data = $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
          _isLoading = false;
          _stats = {'open': 0, 'in_progress': 0, 'resolved': 0, 'closed': 0};
          _recentTickets = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surfaceBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final stats = _stats ?? {'open': 0, 'in_progress': 0, 'resolved': 0, 'closed': 0};
    final recentTickets = _recentTickets;
    final totalTickets = (stats['open'] ?? 0) +
        (stats['in_progress'] ?? 0) +
        (stats['resolved'] ?? 0) +
        (stats['closed'] ?? 0);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Info
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              currentUser?.avatar ?? '?',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser?.name ?? 'Guest',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            CustomBadge(
                              text: _getRoleLabel(currentUser?.role),
                              backgroundColor: AppColors.primaryContainer,
                              textColor: AppColors.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Settings Button
                    ClayIconButton(
                      icon: Icons.settings_rounded,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ),

            // Hero Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-Tickets',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pusat Bantuan Digital',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    // Stats Icon Button
                    ClayIconButton(
                      icon: Icons.auto_graph_rounded,
                      onPressed: () {},
                      tooltip: 'Statistics',
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StyledInput(
                  hint: 'Cari kendala anda...',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      Navigator.of(context).pushNamed(
                        '/ticket-list',
                        arguments: {'searchQuery': query},
                      );
                    }
                  },
                ),
              ),
            ),

            // Error Message (if any)
            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme().labelSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 16),
                          onPressed: _loadData,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Statistics Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistik',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ChipBadge(
                      label: 'REALTIME',
                      backgroundColor: AppColors.primaryContainer.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Grid — white cards with colored icon accents
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        accentColor: AppColors.statusOpen,
                        icon: Icons.info_outline_rounded,
                        label: 'OPEN',
                        count: stats['open'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        accentColor: AppColors.statusInProgress,
                        icon: Icons.access_time_rounded,
                        label: 'PROGRESS',
                        count: stats['in_progress'] ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        accentColor: AppColors.successAccent,
                        icon: Icons.check_circle_outline_rounded,
                        label: 'RESOLVED',
                        count: stats['resolved'] ?? 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        accentColor: AppColors.primary,
                        icon: Icons.format_list_numbered_rounded,
                        label: 'TOTAL',
                        count: totalTickets,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Admin Quick Actions (only for admin role)
            if (_authService.currentUser?.role == UserRole.admin)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.people_rounded,
                              label: 'Kelola\nPengguna',
                              accentColor: AppColors.tertiary,
                              onTap: () => Navigator.of(context).pushNamed('/user-management'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.history_rounded,
                              label: 'Log\nAktivitas',
                              accentColor: AppColors.secondary,
                              onTap: () => Navigator.of(context).pushNamed('/activity-logs'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.dashboard_rounded,
                              label: 'Statistik\nAdmin',
                              accentColor: AppColors.primary,
                              onTap: () => Navigator.of(context).pushNamed('/admin-dashboard'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Recent Tickets Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiket Terbaru',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/ticket-list');
                      },
                      child: Text(
                        'Lihat Semua',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Tickets List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: recentTickets.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 48,
                                color: AppColors.outline,
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
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ticket = recentTickets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _RecentTicketCard(
                              ticket: ticket,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/ticket-detail',
                                  arguments: ticket,
                                );
                              },
                            ),
                          );
                        },
                        childCount: recentTickets.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(UserRole? role) {
    switch (role) {
      case UserRole.user:
        return 'USER';
      case UserRole.helpdesk:
        return 'HELPDESK';
      case UserRole.admin:
        return 'ADMIN';
      default:
        return 'GUEST';
    }
  }
}

class _StatCard extends StatelessWidget {
  final Color accentColor;
  final IconData icon;
  final String label;
  final int count;

  const _StatCard({
    required this.accentColor,
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.5),
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
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const Spacer(),
              Text(
                '$count',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  height: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const _RecentTicketCard({required this.ticket, required this.onTap});

  TicketStatus _ticketStatus(String status) {
    switch (status) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      case 'reopened':
        return TicketStatus.reopened;
      default:
        return TicketStatus.open;
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
    return StyledCard(
      onTap: onTap,
      glowColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - Status and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                text: _ticketStatus(ticket.status).name.toUpperCase(),
                status: _ticketStatus(ticket.status),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(ticket.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            ticket.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // Bottom row - Ticket number and stats
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Agent info or ticket number
                Row(
                  children: [
                    if (ticket.assigneeName != null) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ticket.assigneeAvatar ?? '?',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${ticket.ticketNumber}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.outline,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '#${ticket.ticketNumber}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ],
                ),
                // Right side - Comments and Attachments
                Row(
                  children: [
                    if (ticket.commentsCount > 0) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.commentsCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (ticket.attachmentsCount > 0) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.attachmentsCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
