import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/ticket_model.dart';
import '../../../../models/role_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/ticket_provider.dart';
import '../../../../services/user_api_service.dart';
import '../../../../shared/widgets/main_navigation.dart';

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
  final UserApiService _userApiService = UserApiService();

  bool _isLoading = true;
  Map<String, dynamic>? _adminStats;
  String _selectedFilter = 'semua';
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
      final userRole = authProvider.currentUserRole;

      // Determine ticket limit based on user role
      // - User biasa: lihat semua tiket mereka sendiri (10 tiket terbaru)
      // - Helpdesk: lihat tiket yang di-assign ke mereka (5 tiket terbaru)
      // - Admin: tidak menggunakan dashboard ini (punya admin dashboard sendiri)
      final ticketLimit = userRole == UserRole.user ? 10 : 5;

      final futures = <Future>[
        ticketProvider.loadStats(userRole: userRole, silent: true),
        ticketProvider.loadTickets(
          userRole: userRole,
          limit: ticketLimit,
          silent: true,
        ),
      ];

      if (userRole == UserRole.admin) {
        futures.add(_userApiService.getDashboardStats());
      }

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          if (userRole == UserRole.admin && results.length > 2) {
            _adminStats = results[2] as Map<String, dynamic>?;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.role ?? UserRole.user;

    if (_isLoading || ticketProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          bottom: false,
          child: _buildLoadingSkeleton(),
        ),
      );
    }

    final stats = ticketProvider.stats;
    final recentTickets = ticketProvider.tickets;
    final totalTickets =
        (stats['open'] ?? 0) +
        (stats['in_progress'] ?? 0) +
        (stats['closed'] ?? 0);

    // Filter tickets locally based on horizontal chips selection
    final filteredTickets = recentTickets.where((ticket) {
      if (_selectedFilter == 'semua') return true;
      return ticket.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── TOP NAVIGATION ROW ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.containerPadding,
                    AppTheme.containerPadding - 8,
                    AppTheme.containerPadding,
                    8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTimeBasedGreeting(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Dashboard Layanan',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ClayIconButton(
                            icon: Icons.refresh_rounded,
                            backgroundColor: AppColors.surfaceContainerLowest,
                            iconColor: AppColors.onSurfaceVariant,
                            size: 40,
                            onPressed: _loadData,
                            tooltip: 'Refresh',
                          ),
                          const SizedBox(width: 8),
                          ClayIconButton(
                            icon: Icons.settings_rounded,
                            backgroundColor: AppColors.surfaceContainerLowest,
                            iconColor: AppColors.onSurfaceVariant,
                            size: 40,
                            onPressed: () {
                              context.findAncestorStateOfType<MainNavigationState>()?.setIndex(4);
                            },
                            tooltip: 'Pengaturan',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── HERO WELCOME CARD ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.containerPadding,
                    vertical: 12,
                  ),
                  child: _buildHeroWelcomeCard(context, currentUser),
                ),
              ),

              // ── SEARCH INTERFACE ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.containerPadding,
                    8,
                    AppTheme.containerPadding,
                    16,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.containerPadding,
                      vertical: 8,
                    ),
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.error),
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

              // ── STATS SECTION HEADER ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.containerPadding,
                    16,
                    AppTheme.containerPadding,
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Statistik Anda',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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

              // ── DYNAMIC METRICS SECTIONS ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.containerPadding,
                  ),
                  child: _buildStatsSection(context, userRole, stats, totalTickets),
                ),
              ),

              // ── ADMIN OPERATIONAL OPERATIONS BLOCK ───────────────────────────
              if (userRole == UserRole.admin) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.containerPadding,
                      20,
                      AppTheme.containerPadding,
                      12,
                    ),
                    child: Text(
                      'Panel Kontrol',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.containerPadding,
                    ),
                    child: _buildAdminConsoleGrid(context),
                  ),
                ),
              ],

              // ── RECENT TICKETS SECTION HEADER ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.containerPadding,
                    20,
                    AppTheme.containerPadding,
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiket Terbaru',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed('/ticket-list'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lihat Semua',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Horizontal filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildFilterChips(),
                ),
              ),

              // Tickets list
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
                    : filteredTickets.isEmpty
                        ? SliverToBoxAdapter(
                            child: Card(
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.filter_list_off_rounded,
                                        size: 40,
                                        color: AppColors.outline.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak Ada Tiket ditemukan',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tidak ada tiket terdaftar dengan status "${_selectedFilter.toUpperCase()}" saat ini.',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final ticket = filteredTickets[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecentTicketCard(
                                  ticket: ticket,
                                  onTap: () async {
                                    final result = await Navigator.of(
                                      context,
                                    ).pushNamed('/ticket-detail', arguments: ticket);
                                    if (result == true && mounted) {
                                      context.showSuccessSnackBar('Tiket berhasil dihapus');
                                    }
                                    _loadData();
                                  },
                                ),
                              );
                            }, childCount: filteredTickets.length),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi ☀️';
    } else if (hour < 15) {
      return 'Selamat Siang 🌤️';
    } else if (hour < 18) {
      return 'Selamat Sore ⛅';
    } else {
      return 'Selamat Malam 🌙';
    }
  }

  Widget _buildHeroWelcomeCard(BuildContext context, UserModel? user) {
    final role = user?.role ?? UserRole.user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.findAncestorStateOfType<MainNavigationState>()?.setIndex(4);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      UserAvatar(
                        avatar: user?.avatar,
                        name: user?.name,
                        size: 56,
                        fontSize: 20,
                        backgroundColor: Colors.white,
                        textColor: AppColors.primary,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 3),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, Selamat Datang!',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.name ?? 'Pengguna',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                ),
                child: Text(
                  _getRoleLabel(role).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 18),
          _buildHeroAction(context, role),
        ],
      ),
    );
  }

  Widget _buildHeroAction(BuildContext context, UserRole role) {
    if (role == UserRole.user) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Mengalami kendala teknis? Laporkan masalah Anda kepada tim dukungan kami sekarang.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/create-ticket');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 16),
                SizedBox(width: 4),
                Text(
                  'Buat Tiket',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (role == UserRole.helpdesk) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Bantu selesaikan kendala pengguna hari ini untuk menjaga standar performa layanan bantuan.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/ticket-list');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_rounded, size: 16),
                SizedBox(width: 4),
                Text(
                  'Antrean',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Admin
      return Row(
        children: [
          Expanded(
            child: Text(
              'Pantau kesehatan sistem infrastruktur, logs audit, serta statistik tiket secara komprehensif.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/admin-dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart_rounded, size: 16),
                SizedBox(width: 4),
                Text(
                  'Analitik',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildStatsSection(
    BuildContext context,
    UserRole role,
    Map<String, int> stats,
    int totalTickets,
  ) {
    if (role == UserRole.user) {
      final activeTickets = (stats['open'] ?? 0) + (stats['in_progress'] ?? 0);
      final closedTickets = stats['closed'] ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SLA / Progress Card
          StyledCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Penyelesaian Tiket Anda',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '$closedTickets dari $totalTickets Selesai',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressBar(
                  value: totalTickets > 0 ? closedTickets / totalTickets : 0.0,
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ],
            ),
          ),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Tiket Aktif',
                  value: '$activeTickets',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Selesai',
                  value: '$closedTickets',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.successAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Total',
                  value: '$totalTickets',
                  icon: Icons.folder_open_rounded,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (role == UserRole.helpdesk) {
      final assigned = stats['assigned'] ?? 0;
      final open = stats['open'] ?? 0;
      final inProgress = stats['in_progress'] ?? 0;
      final closed = stats['closed'] ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SLA / Progress Card
          StyledCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pencapaian SLA Resolusi',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '$closed dari $totalTickets Selesai',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressBar(
                  value: totalTickets > 0 ? closed / totalTickets : 0.0,
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ],
            ),
          ),
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Tugas Saya',
                  value: '$assigned',
                  icon: Icons.assignment_ind_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Antrean Baru',
                  value: '$open',
                  icon: Icons.info_outline_rounded,
                  color: AppColors.statusOpen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Sedang Diproses',
                  value: '$inProgress',
                  icon: Icons.access_time_rounded,
                  color: AppColors.statusInProgress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Tuntas Selesai',
                  value: '$closed',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.successAccent,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Admin Role
      final total = totalTickets;
      final open = stats['open'] ?? 0;
      final inProgress = stats['in_progress'] ?? 0;
      final closed = stats['closed'] ?? 0;

      // Admin stats from UserApiService
      final totalUsers = _adminStats?['users']?['total'] ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tickets SLA / Progress Card
          StyledCard(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Penyelesaian Tiket Global',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '$closed / $total Selesai',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProgressBar(
                  value: total > 0 ? closed / total : 0.0,
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              ],
            ),
          ),
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Total Tiket',
                  value: '$total',
                  icon: Icons.confirmation_number_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Total Pengguna',
                  value: '$totalUsers',
                  icon: Icons.people_rounded,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Tiket Baru',
                  value: '$open',
                  icon: Icons.info_outline_rounded,
                  color: AppColors.statusOpen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  context,
                  title: 'Diproses',
                  value: '$inProgress',
                  icon: Icons.access_time_rounded,
                  color: AppColors.statusInProgress,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildMiniStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StyledCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminConsoleGrid(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildAdminGridCard(
          context,
          label: 'Kelola Pengguna',
          subtitle: 'Daftar & edit akses',
          icon: Icons.people_rounded,
          color: AppColors.primary,
          route: '/user-management',
        ),
        _buildAdminGridCard(
          context,
          label: 'Log Aktivitas',
          subtitle: 'Audit logs infra',
          icon: Icons.history_rounded,
          color: const Color(0xFF6B7280),
          route: '/activity-logs',
        ),
        _buildAdminGridCard(
          context,
          label: 'Statistik Admin',
          subtitle: 'Metrik menyeluruh',
          icon: Icons.dashboard_rounded,
          color: AppColors.tertiary,
          route: '/admin-dashboard',
        ),
        _buildAdminGridCard(
          context,
          label: 'Pengaturan Profil',
          subtitle: 'Konfigurasi admin',
          icon: Icons.manage_accounts_rounded,
          color: AppColors.secondary,
          route: '/profile',
        ),
      ],
    );
  }

  Widget _buildAdminGridCard(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        if (route == '/profile') {
          context.findAncestorStateOfType<MainNavigationState>()?.setIndex(4);
        } else {
          Navigator.of(context).pushNamed(route);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: StyledCard(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.outline,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    color: isDark ? Colors.white60 : AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filterOptions = [
      {
        'label': 'Semua',
        'value': 'semua',
        'icon': Icons.clear_all_rounded,
        'color': AppColors.primary,
      },
      {
        'label': 'Baru',
        'value': 'open',
        'icon': Icons.info_outline_rounded,
        'color': AppColors.statusOpen,
      },
      {
        'label': 'Diproses',
        'value': 'in_progress',
        'icon': Icons.sync_rounded,
        'color': AppColors.statusInProgress,
      },
      {
        'label': 'Selesai',
        'value': 'closed',
        'icon': Icons.check_circle_outline_rounded,
        'color': AppColors.successAccent,
      },
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerPadding),
        itemCount: filterOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          final isSelected = _selectedFilter == option['value'];
          final iconData = option['icon'] as IconData;
          final color = option['color'] as Color;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedFilter = option['value'] as String;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    option['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                  UserAvatar(
                    avatar: ticket.assigneeAvatar,
                    name: ticket.assigneeName,
                    size: 28,
                    fontSize: 10,
                    textColor: Colors.white,
                    backgroundColor: AppColors.primaryContainer,
                    border: Border.all(color: Colors.white, width: 1.5),
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
