import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../shared/components/components.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final TicketService _ticketService = TicketService();

  Map<String, int>? _ticketStats;
  int _totalTickets = 0;

  @override
  void initState() {
    super.initState();
    _authService.initialize();
    _loadTicketStats();
  }

  Future<void> _loadTicketStats() async {
    try {
      final stats = await _ticketService.getTicketStats(
        userRole: _authService.currentUserRole,
      );

      if (mounted) {
        setState(() {
          _ticketStats = stats;
          _totalTickets = (stats['open'] ?? 0) +
              (stats['in_progress'] ?? 0) +
              (stats['resolved'] ?? 0) +
              (stats['closed'] ?? 0);
        });
      }
    } catch (e) {
      // Keep defaults on error
    }
  }

  void _showRoleSwitcher() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Switch Role (Development)',
          style: AppTheme().headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            final isSelected = _authService.currentUser?.role == role;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  role.label,
                  style: AppTheme().bodyLarge.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                leading: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                  size: 24,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Role switching disabled in API mode'),
                      backgroundColor: AppColors.onSurface,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          ClayButton(
            text: 'Close',
            isGhost: true,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      // Top row
                      Row(
                        children: [
                          Text(
                            'Profil',
                            style: AppTheme().headlineMedium.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.onPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: AppColors.onPrimary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _authService.currentUser?.avatar ?? '?',
                            style: AppTheme().displayLarge.copyWith(
                              fontSize: 32,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _authService.currentUser?.name ?? 'Guest',
                        style: AppTheme().headlineMedium.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _authService.currentUser?.email ?? '',
                        style: AppTheme().bodyMedium.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _authService.currentUser?.role.label ?? 'User',
                          style: AppTheme().labelCaps.copyWith(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Stats summary with StyledCard
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: StyledCard(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'Total Tiket',
                        value: '$_totalTickets',
                      ),
                    ),
                    _vDivider(),
                    Expanded(
                      child: _StatItem(
                        label: 'Aktif',
                        value: '${(_ticketStats?['open'] ?? 0) + (_ticketStats?['in_progress'] ?? 0)}',
                      ),
                    ),
                    _vDivider(),
                    Expanded(
                      child: _StatItem(
                        label: 'Selesai',
                        value: '${(_ticketStats?['resolved'] ?? 0) + (_ticketStats?['closed'] ?? 0)}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Menu List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akun',
                    style: AppTheme().labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profil',
                        subtitle: 'Ubah nama dan foto profil',
                        onTap: () {
                          Navigator.of(context).pushNamed('/edit-profile');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Ganti Password',
                        subtitle: 'Perbarui kata sandi Anda',
                        onTap: () {
                          Navigator.of(context).pushNamed('/change-password');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan',
                    style: AppTheme().labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Tema Gelap',
                        subtitle: 'Sesuaikan tampilan aplikasi',
                        trailing: Switch(
                          value: themeNotifier.isDark,
                          onChanged: (v) {
                            setState(() {
                              themeNotifier.toggleTheme();
                            });
                          },
                          activeTrackColor: AppColors.primaryContainer,
                          activeThumbColor: AppColors.primary,
                        ),
                        onTap: () {
                          setState(() {
                            themeNotifier.toggleTheme();
                          });
                        },
                      ),
                      _MenuItem(
                        icon: Icons.network_check_rounded,
                        title: 'Test Koneksi API',
                        subtitle: 'Verifikasi koneksi backend',
                        onTap: () {
                          Navigator.of(context).pushNamed('/connection-test');
                        },
                      ),
                      // Admin menu - only show for admin users
                      if (_authService.currentUser?.role == UserRole.admin)
                        _MenuItem(
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Kelola Pengguna',
                          subtitle: 'Kelola pengguna dan akses',
                          onTap: () {
                            Navigator.of(context).pushNamed('/user-management');
                          },
                        ),
                      if (_authService.currentUser?.role == UserRole.admin)
                        _MenuItem(
                          icon: Icons.people_outline_rounded,
                          title: 'Daftar Helpdesk',
                          subtitle: 'Lihat staff helpdesk',
                          onTap: () {
                            Navigator.of(context).pushNamed('/helpdesk-list');
                          },
                        ),
                      if (_authService.currentUser?.role == UserRole.admin)
                        _MenuItem(
                          icon: Icons.history_rounded,
                          title: 'Aktivitas Sistem',
                          subtitle: 'Lihat log aktivitas',
                          onTap: () {
                            Navigator.of(context).pushNamed('/activity-logs');
                          },
                        ),
                      if (_authService.currentUser?.role == UserRole.admin)
                        _MenuItem(
                          icon: Icons.dashboard_rounded,
                          title: 'Statistik Admin',
                          subtitle: 'Statistik sistem lengkap',
                          onTap: () {
                            Navigator.of(context).pushNamed('/admin-dashboard');
                          },
                        ),
                      _MenuItem(
                        icon: Icons.swap_horiz_rounded,
                        title: 'Switch Role',
                        subtitle: 'Development & Testing',
                        onTap: _showRoleSwitcher,
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifikasi',
                        subtitle: 'Atur preferensi notifikasi',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        title: 'Bahasa',
                        subtitle: 'Bahasa Indonesia',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lainnya',
                    style: AppTheme().labelCaps.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan & FAQ',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Aplikasi',
                        subtitle: 'Versi 1.0.0',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Logout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Logout',
                          style: AppTheme().headlineSmall,
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin keluar?',
                          style: AppTheme().bodyMedium,
                        ),
                        actions: [
                          ClayButton(
                            text: 'Batal',
                            isGhost: true,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          ClayButton(
                            text: 'Logout',
                            backgroundColor: AppColors.onSurface,
                            textColor: AppColors.surface,
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await _authService.signOut();
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed('/login');
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded,
                      size: 20),
                  label: Text(
                    'Logout',
                    style: AppTheme().bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                  ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 32, color: AppColors.outlineVariant);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme().displayLarge.copyWith(
            fontSize: 24,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme().labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (idx < items.length - 1)
                const Divider(height: 1, indent: 56, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.onSurface, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme().bodyLarge.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTheme().labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
