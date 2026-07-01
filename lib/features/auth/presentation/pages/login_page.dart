import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LoginPage
//
// Changes from original:
//   • Logo container used AppColors.primaryGradient (deleted).
//     Replaced with solid AppColors.primary fill.
//   • Scaffold backgroundColor changed from Colors.white to
//     AppColors.surfaceContainerLowest (same value, but uses the token).
// ─────────────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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

    if (_authService.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/main');
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          final message = result['message'] ?? 'Login failed';

          if (const bool.fromEnvironment('dart.vm.product') == false) {
            print('=== LOGIN FAILED ===');
            print('Email: ${_emailController.text.trim()}');
            print('Error: $message');
            print('Full Result: $result');
            print('====================');

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Login Error - Debug Info'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Email: ${_emailController.text.trim()}'),
                      const SizedBox(height: 8),
                      Text('Error Message: $message'),
                      const SizedBox(height: 16),
                      const Text('Troubleshooting Tips:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('1. Check if backend is running on port 3000'),
                      const Text('2. Verify API URL in app_config.dart'),
                      const Text(
                          '3. Test with Postman: http://localhost:3000/api/auth/login'),
                      const Text('4. Check console for detailed error logs'),
                      const SizedBox(height: 16),
                      const Text(
                        'See TROUBLESHOOTING_LOGIN.md for more info',
                        style: TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Token instead of Colors.white literal
      backgroundColor: AppColors.surfaceContainerLowest,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Hero illustration
                      Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1551434678-e076c223a692?w=400&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to logo if image fails
                              return Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.confirmation_number_rounded,
                                  color: AppColors.onPrimary,
                                  size: 36,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'Selamat Datang! 👋',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Masuk ke akun Anda untuk melanjutkan',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Email field
                      StyledInput(
                        label: 'Email',
                        hint: 'Masukkan email Anda',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!value.contains('@')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password field
                      StyledInput(
                        label: 'Password',
                        hint: 'Masukkan password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixIconPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/forgot-password');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lupa Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Primary login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ClayButton(
                          text: _isLoading ? 'Memuat...' : 'Masuk',
                          onPressed: _isLoading ? null : _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Divider
                      Row(
                        children: [
                          const Expanded(
                              child: Divider(color: AppColors.outlineVariant)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'atau',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Google login button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ClayButton(
                          text: 'Masuk dengan Google',
                          onPressed: () {},
                          isOutlined: true,
                          icon: Icons.g_mobiledata,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/register');
                            },
                            child: Text(
                              'Daftar Sekarang',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
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