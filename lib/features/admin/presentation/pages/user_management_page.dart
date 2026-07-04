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
  String _selectedRoleFilter = 'all';

  final List<Map<String, String>> _roleFilters = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'user', 'label': 'User'},
    {'key': 'helpdesk', 'label': 'Helpdesk'},
    {'key': 'admin', 'label': 'Admin'},
  ];

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
      final response = await _userApiService.getAllUsers(
        role: _selectedRoleFilter != 'all' ? _selectedRoleFilter : null,
      );

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
    final currentUser = _authService.currentUser;
    final isSelf = currentUser?.id == user.id;

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
                // Edit user
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
                  title: Text(
                    'Edit Pengguna',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                  subtitle: const Text('Ubah nama dan email', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditUserDialog(user);
                  },
                ),
                const Divider(height: 1),
                // Toggle status
                if (!isSelf)
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
                if (!isSelf) const Divider(height: 1),
                // Change role
                if (!isSelf)
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
                    subtitle: Text('Peran saat ini: ${user.role.label}',
                        style: const TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      _showRoleSelectionDialog(user);
                    },
                  ),
                if (!isSelf) const Divider(height: 1),
                // Delete user
                if (!isSelf)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: Text(
                      'Hapus Pengguna',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Tidak dapat dihapus jika memiliki tiket',
                      style: TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteUserDialog(user);
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
            backgroundColor: Color(0xFF6B7280),
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
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
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
            content: Text('Peran ${user.name} berhasil diubah menjadi ${role.label}'),
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
            backgroundColor: Color(0xFF6B7280),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showCreateUserDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'user';
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            'Tambah Pengguna Baru',
            style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledInput(
                  hint: 'Nama Lengkap',
                  controller: nameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                StyledInput(
                  hint: 'Email',
                  controller: emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                StyledInput(
                  hint: 'Password (min. 8 karakter)',
                  controller: passwordCtrl,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword,
                  suffixIcon: obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  onSuffixIconPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                ),
                const SizedBox(height: 16),
                Text(
                  'PERAN',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final role in ['user', 'helpdesk', 'admin'])
                      ChipBadge(
                        label: role[0].toUpperCase() + role.substring(1),
                        isSelected: selectedRole == role,
                        onTap: () => setDialogState(() => selectedRole = role),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final result = await _userApiService.createUser(
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  role: selectedRole,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['success'] == true
                        ? 'Pengguna berhasil ditambahkan'
                        : result['message'] as String? ?? 'Gagal menambahkan pengguna'),
                    backgroundColor: result['success'] == true ? AppColors.primary : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (result['success'] == true) _loadUsers();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Pengguna',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StyledInput(
              hint: 'Nama Lengkap',
              controller: nameCtrl,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            StyledInput(
              hint: 'Email',
              controller: emailCtrl,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final result = await _userApiService.updateUser(
                user.id,
                fullName: nameCtrl.text.trim() != user.name ? nameCtrl.text.trim() : null,
                email: emailCtrl.text.trim() != user.email ? emailCtrl.text.trim() : null,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['success'] == true
                      ? 'Data pengguna berhasil diperbarui'
                      : result['message'] as String? ?? 'Gagal memperbarui data'),
                  backgroundColor: result['success'] == true ? AppColors.primary : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              if (result['success'] == true) _loadUsers();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Pengguna',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengguna "${user.name}"?\n\n'
          'Pengguna yang memiliki tiket tidak dapat dihapus. Pertimbangkan untuk menonaktifkan akun sebagai gantinya.',
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final result = await _userApiService.deleteUser(user.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['success'] == true
                      ? 'Pengguna berhasil dihapus'
                      : result['message'] as String? ?? 'Gagal menghapus pengguna'),
                  backgroundColor: result['success'] == true ? AppColors.primary : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              if (result['success'] == true) _loadUsers();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
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
      floatingActionButton: currentUser?.role == UserRole.admin
          ? FloatingActionButton.extended(
              onPressed: _showCreateUserDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text(
                'Tambah User',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: _isLoading
          ? const FullPageLoading(message: 'Memuat daftar pengguna...')
          : _errorMessage != null
              ? EmptyStates.serverError(onRetry: _loadUsers)
              : Column(
                  children: [
                    // Role filter chips
                    Container(
                      color: AppColors.background,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Row(
                          children: _roleFilters.map((f) {
                            final isSelected = _selectedRoleFilter == f['key'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ChipBadge(
                                label: f['label']!,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() => _selectedRoleFilter = f['key']!);
                                  _loadUsers();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.people_rounded, color: AppColors.primary, size: 20),
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
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: _users.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
              child: const Icon(Icons.people_rounded, color: AppColors.secondary, size: 40),
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
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClayButton(text: 'Refresh', onPressed: onRefresh, icon: Icons.refresh_rounded),
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
                  color: user.isActive ? AppColors.primary : const Color(0xFF6B7280),
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
                      backgroundColor: user.isActive ? AppColors.primary : const Color(0xFF6B7280),
                      textColor: user.isActive ? AppColors.primary : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant, size: 24),
        ],
      ),
    );
  }
}
