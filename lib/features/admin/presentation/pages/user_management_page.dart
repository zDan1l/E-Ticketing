import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/role_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/user_api_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AuthService _authService = AuthService();
  final UserApiService _userApiService = UserApiService();

  bool _isLoading = true;
  List<UserModel> _users = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _userApiService.getAllUsers();

      if (mounted) {
        setState(() {
          _users = response['users'] as List<UserModel>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat pengguna: ${e.toString()}';
          _isLoading = false;
          _users = [];
        });
      }
    }
  }

  void _showUserActions(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceContainerLowest : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: user.isActive 
                          ? AppColors.primary.withValues(alpha: 0.1) 
                          : Colors.grey.withValues(alpha: 0.1),
                      child: Text(
                        user.avatar,
                        style: TextStyle(
                          color: user.isActive ? AppColors.primary : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white60 : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'TINDAKAN ADMIN',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                    user.isActive ? Icons.block_flipped : Icons.check_circle_outline_rounded,
                    color: user.isActive ? const Color(0xFF6B7280) : AppColors.primary,
                  ),
                  title: Text(
                    user.isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    user.isActive 
                        ? 'Pengguna tidak akan bisa masuk ke aplikasi' 
                        : 'Pengguna akan bisa masuk ke aplikasi kembali',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleUserStatus(user);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
                  title: Text(
                    'Ubah Peran Pengguna',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Peran saat ini: ${user.role.label}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRoleSelectionDialog(user);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    setState(() => _isLoading = true);
    final success = await _userApiService.updateUserStatus(user.id, !user.isActive);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pengguna ${user.name} berhasil diperbarui'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadUsers();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui status pengguna'),
            backgroundColor: const Color(0xFF6B7280),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRoleSelectionDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Pilih Peran Baru',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              return ListTile(
                title: Text(role.label),
                leading: Radio<UserRole>(
                  value: role,
                  groupValue: user.role,
                  onChanged: (newRole) {
                    Navigator.pop(context);
                    if (newRole != null && newRole != user.role) {
                      _changeUserRole(user, newRole);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _changeUserRole(UserModel user, UserRole role) async {
    setState(() => _isLoading = true);
    final success = await _userApiService.updateUserRole(user.id, role.name);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Peran pengguna ${user.name} berhasil diubah menjadi ${role.label}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadUsers();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengubah peran pengguna'),
            backgroundColor: const Color(0xFF6B7280),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          'User Management',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.01,
          ),
        ),
        actions: [
          if (currentUser?.role == UserRole.admin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClayIconButton(
                icon: Icons.refresh_rounded,
                backgroundColor: AppColors.surfaceContainerHigh,
                iconColor: AppColors.primary,
                size: 40,
                onPressed: _loadUsers,
                tooltip: 'Refresh',
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const FullPageLoading(message: 'Memuat daftar pengguna...')
          : _errorMessage != null
          ? EmptyStates.serverError(
              onRetry: _loadUsers,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_users.length} Pengguna Terdaftar',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _users.isEmpty
                      ? _EmptyState(onRefresh: _loadUsers)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                          itemCount: _users.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _UserCard(
                              user: user,
                              onTap: () => _showUserActions(user),
                            );
                          },
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: AppColors.secondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada pengguna',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data pengguna akan muncul di sini',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
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
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: user.isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : const Color(0xFF6B7280).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.avatar,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: user.isActive
                      ? AppColors.primary
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CustomBadge(
                      text: user.role.label,
                      backgroundColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      text: user.isActive ? 'AKTIF' : 'NONAKTIF',
                      backgroundColor: user.isActive
                          ? AppColors.primary
                          : const Color(0xFF6B7280),
                      textColor: user.isActive
                          ? AppColors.primary
                          : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.onSurfaceVariant,
            size: 24,
          ),
        ],
      ),
    );
  }
}
