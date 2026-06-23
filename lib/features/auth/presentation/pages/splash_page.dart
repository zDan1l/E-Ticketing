import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashPage
//
// Changes from original:
//   • Removed gradient background (AppColors.primaryGradient deleted).
//     Background is now solid AppColors.primary.
//   • Removed Colors.white.withOpacity(0.85) — subtitle now uses
//     AppColors.onPrimaryContainer (a solid warm lavender that reads well
//     on the primary bg and carries the same "softer white" intent).
//   • Removed AppColors.white.withValues(alpha: 0.7) on the progress
//     indicator — replaced with AppColors.onPrimaryContainer solid.
// ─────────────────────────────────────────────────────────────────────────────

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _logoController.forward().then((_) {
      _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        if (_authService.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Solid primary fill — no gradient
        color: AppColors.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // Logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        // Solid white container — no shadow
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.confirmation_number_rounded,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            // App name + tagline
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text(
                      'HelpDesk',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.surfaceContainerLowest,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'E-Ticketing System',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        // Solid onPrimaryContainer (warm lavender) — no opacity
                        color: AppColors.onPrimaryContainer,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 3),
            // Loading indicator
            FadeTransition(
              opacity: _textOpacity,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  // Solid onPrimaryContainer — no opacity blend
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}