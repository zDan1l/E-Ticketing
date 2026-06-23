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
          ? const Center(
              child: CircularProgress(value: 0.3, size: 48, strokeWidth: 4),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat pengguna',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ClayButton(
                      text: 'Coba Lagi',
                      onPressed: _loadUsers,
                      icon: Icons.refresh_rounded,
                    ),
                  ],
                ),
              ),
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
                              onTap: () {
                                // TODO: Navigate to user details or actions
                              },
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
                color: AppColors.secondaryContainer.withValues(alpha: 0.2),
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
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerHigh,
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
                      : AppColors.onSurfaceVariant,
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
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      textColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    CustomBadge(
                      text: user.isActive ? 'AKTIF' : 'NONAKTIF',
                      backgroundColor: user.isActive
                          ? AppColors.successAccent.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      textColor: user.isActive
                          ? AppColors.tertiaryContainer
                          : AppColors.error,
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
