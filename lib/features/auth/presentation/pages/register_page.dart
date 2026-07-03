import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registrasi berhasil! Silakan login.',
                style: const TextStyle(color: AppColors.onBackground),
              ),
              backgroundColor: AppColors.successAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Registrasi gagal'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.bgDarkGradient : AppColors.bgLightGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Form(
                    key: _formKey,
                    child: GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              ClayIconButton(
                                icon: Icons.arrow_back_ios_new_rounded,
                                onPressed: () => Navigator.pop(context),
                                size: 36,
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Hero illustration
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppColors.glowShadow,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.primaryContainer,
                                    child: const Icon(
                                      Icons.person_add_rounded,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Buat Akun Baru ✨',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daftar untuk mulai menggunakan layanan helpdesk',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          StyledInput(
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              if (v.length < 3) return 'Minimal 3 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          StyledInput(
                            label: 'Email',
                            hint: 'Masukkan email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!v.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          StyledInput(
                            label: 'Password',
                            hint: 'Minimal 8 karakter',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixIconPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (v.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          StyledInput(
                            label: 'Konfirmasi Password',
                            hint: 'Ulangi password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixIconPressed: () {
                              setState(() => _obscureConfirm = !_obscureConfirm);
                            },
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Konfirmasi password tidak boleh kosong';
                              }
                              if (v != _passwordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ClayButton(
                              text: _isLoading ? 'Memuat...' : 'Daftar',
                              onPressed: _isLoading ? null : _handleRegister,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'Masuk',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
