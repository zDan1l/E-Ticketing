import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/ticket_model.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/user_api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DashboardPage — Enhanced UI with Unsplash illustrations and loading states
// ─────────────────────────────────────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  static final GlobalKey<_DashboardPageState> dashboardKey =
      GlobalKey<_DashboardPageState>();

  const DashboardPage({super.key});

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

      // Determine ticket limit based on user role
      // - User biasa: lihat semua tiket mereka sendiri (10 tiket terbaru)
      // - Helpdesk: lihat tiket yang di-assign ke mereka (5 tiket terbaru)
      // - Admin: tidak menggunakan dashboard ini (punya admin dashboard sendiri)
      final ticketLimit = userRole == UserRole.user ? 10 : 5;

      final futures = <Future>[
        _ticketService.getTicketStats(userRole: userRole),
        _ticketService.getTickets(
          userRole: userRole,
          limit: ticketLimit,
        ),
      ];

      if (userRole == UserRole.admin) {
        futures.add(_userApiService.getDashboardStats());
      }

      final results = await Future.wait(futures);

      if (mounted) {
        final ticketsResponse = results[1] as Map<String, dynamic>;
        final tickets = ticketsResponse['tickets'] as List<TicketModel>? ?? [];

        setState(() {
          _stats = results[0] as Map<String, int>;
          // Use appropriate ticket limit based on user role
          _recentTickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
          _isLoading = false;
          _stats = {'open': 0, 'in_progress': 0, 'closed': 0};
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
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: _buildLoadingSkeleton(),
        ),
      );
    }

    final stats =
        _stats ?? {'open': 0, 'in_progress': 0, 'closed': 0};
    final recentTickets = _recentTickets;
    final totalTickets =
        (stats['open'] ?? 0) +
        (stats['in_progress'] ?? 0) +
        (stats['closed'] ?? 0);

    return Scaffold(
      backgroundColor: AppColors.canvas, //
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── TOP NAVIGATION ROW ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.containerPadding, //
                  AppTheme.containerPadding,
                  AppTheme.containerPadding,
                  AppTheme.stackGap,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.softShadow,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                currentUser?.avatar ?? '?',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            CustomBadge(
                              text: _getRoleLabel(currentUser?.role),
                              backgroundColor: AppColors.primary,
                              textColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                    ClayIconButton(
                      icon: Icons.settings_rounded,
                      backgroundColor: AppColors.surfaceContainerLowest, //
                      iconColor: AppColors.onSurfaceVariant, //
                      size: 44,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                      tooltip: 'Settings',
                    ),
                  ],
                ),
              ),
            ),

            // ── HERO TEXT BLOCK ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.containerPadding,
                  8,
                  AppTheme.containerPadding,
                  AppTheme.stackGap,
                ), //
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-Tickets',
                            style: Theme.of(context).textTheme.displayLarge, //
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pusat Bantuan Digital',
                            style: Theme.of(context).textTheme.bodyMedium, //
                          ),
                        ],
                      ),
                    ),
                    ClayIconButton(
                      icon: Icons.auto_graph_rounded,
                      backgroundColor: AppColors.surfaceContainerLowest, //
                      iconColor: AppColors.primary, //
                      size: 44,
                      onPressed: () {},
                      tooltip: 'Statistics',
                    ),
                  ],
                ),
              ),
            ),

            // ── SEARCH INTERFACE ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerPadding,
                ), //
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

            if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.containerPadding,
                    AppTheme.stackGap,
                    AppTheme.containerPadding,
                    0,
                  ), //
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusDefault,
                      ),
                      border: Border.all(
                        color: AppColors.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ), //
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.error), //
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 16),
                          onPressed: _loadData,
                          color: AppColors.error, //
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── STATS GRID HEADER ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.containerPadding,
                  28,
                  AppTheme.containerPadding,
                  12,
                ), //
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistik',
                      style: Theme.of(context).textTheme.headlineSmall, //
                    ),
                    ChipBadge(
                      label: 'REALTIME',
                      backgroundColor: AppColors.primaryContainer,
                      textColor: AppColors.onPrimaryContainer,
                      isSelected: true,
                    ),
                  ],
                ),
              ),
            ),

            // ── BENTO METRIC SECTIONS ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.containerPadding,
                ), //
                child: Column(
                  children: [
                    BentoCard(
                      label: 'Pencapaian Target Dukungan',
                      value:
                          '${stats['closed'] ?? 0} / $totalTickets Tiket Selesai',
                      icon: Icons.confirmation_number_outlined,
                      backgroundColor: AppColors.primary, //
                      textColor: AppColors.onPrimary, //
                      footer: ProgressBar(
                        value: totalTickets > 0
                            ? (stats['closed'] ?? 0) / totalTickets
                            : 0.0,
                        progressColor: AppColors.onPrimary,
                        backgroundColor: AppColors.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: BentoCard(
                            label: 'OPEN',
                            value: '${stats['open'] ?? 0}',
                            icon: Icons.info_outline_rounded,
                            backgroundColor: AppColors.statusOpen, //
                            textColor: AppColors.onPrimary, //
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BentoCard(
                            label: 'PROGRESS',
                            value: '${stats['in_progress'] ?? 0}',
                            icon: Icons.access_time_rounded,
                            backgroundColor: AppColors.statusInProgress, //
                            textColor: AppColors.onPrimary, //
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: BentoCard(
                            label: 'CLOSED',
                            value: '${stats['closed'] ?? 0}',
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: AppColors.statusClosed, //
                            textColor: AppColors.onSurface, //
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BentoCard(
                            label: 'TOTAL TIKET',
                            value: '$totalTickets',
                            icon: Icons.format_list_numbered_rounded,
                            backgroundColor: AppColors.surfaceContainerHigh, //
                            textColor: AppColors.onSurface, //
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── ADMIN CONSOLE OPERATIONS BLOCK ───────────────────────────────
            // ── ADMIN CONSOLE OPERATIONS BLOCK ───────────────────────────────
            if (_authService.currentUser?.role == UserRole.admin) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.containerPadding,
                    32,
                    AppTheme.containerPadding,
                    16,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Admin',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.containerPadding,
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/user-management'),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        child: const StatCard(
                          label: 'Kelola Pengguna',
                          value:
                              'Daftar akun dan konfigurasi hak akses internal',
                          icon: Icons.people_rounded,
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/activity-logs'),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        child: const StatCard(
                          label: 'Log Aktivitas',
                          value:
                              'Pelacakan audit sistem infrastruktur operasional',
                          icon: Icons.history_rounded,
                          backgroundColor: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/admin-dashboard'),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusDefault,
                        ),
                        child: const StatCard(
                          label: 'Statistik Admin',
                          value:
                              'Metrik agregasi menyeluruh dan visualisasi performa',
                          icon: Icons.dashboard_rounded,
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── RECENT TICKETS ACTIVITY FEEDS ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.containerPadding,
                  32,
                  AppTheme.containerPadding,
                  16,
                ), //
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                    ), //
                  ),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiket Terbaru',
                        style: Theme.of(context).textTheme.headlineSmall, //
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/ticket-list'),
                        child: Text(
                          'Lihat Semua',
                          style: Theme.of(context).textTheme.labelMedium, //
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.containerPadding,
                0,
                AppTheme.containerPadding,
                120,
              ),
              sliver: recentTickets.isEmpty
                  ? SliverToBoxAdapter(
                      child: EmptyStates.noTickets(
                        onCreate: () {
                          Navigator.of(context).pushNamed('/create-ticket');
                        },
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ticket = recentTickets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecentTicketCard(
                            ticket: ticket,
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushNamed('/ticket-detail', arguments: ticket);
                            },
                          ),
                        );
                      }, childCount: recentTickets.length),
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

  /// Loading skeleton for dashboard
  Widget _buildLoadingSkeleton() {
    return CustomScrollView(
      slivers: [
        // Header skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.containerPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _ShimmerCircle(size: 48),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerLine(width: 100, height: 16),
                        const SizedBox(height: 8),
                        _ShimmerLine(width: 60, height: 12),
                      ],
                    ),
                  ],
                ),
                _ShimmerCircle(size: 44),
              ],
            ),
          ),
        ),
        // Hero text skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.containerPadding,
              8,
              AppTheme.containerPadding,
              AppTheme.stackGap,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerLine(width: 120, height: 32),
                const SizedBox(height: 8),
                _ShimmerLine(width: 150, height: 14),
              ],
            ),
          ),
        ),
        // Search skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.containerPadding,
            ),
            child: _ShimmerContainer(height: 52, borderRadius: 16),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        // Stats skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.containerPadding,
            ),
            child: const StatsShimmer(count: 4),
          ),
        ),
      ],
    );
  }
}

// Loading skeleton components
class _ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const _ShimmerContainer({
    this.width,
    this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainerLow,
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;

  const _ShimmerLine({this.width, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return _ShimmerContainer(
      width: width != null ? (width! > 1 ? width! * 300 : width!) : null,
      height: height,
      borderRadius: 4,
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainerLow,
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
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}d lalu';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return StyledCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'TKT-${ticket.ticketNumber}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              StatusBadge(
                text: _ticketStatus(ticket.status).name,
                status: _ticketStatus(ticket.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            ticket.title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.onSurface,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            ticket.description,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            width: double.infinity,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08) 
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        ticket.assigneeAvatar ?? '?',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (ticket.commentsCount > 0) ...[
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 14,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.commentsCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (ticket.attachmentsCount > 0) ...[
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 14,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.attachmentsCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(ticket.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
