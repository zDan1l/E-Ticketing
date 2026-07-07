import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

enum CustomSnackBarType { success, error, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required CustomSnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any currently showing snackbars to prevent overlapping
    ScaffoldMessenger.of(context).clearSnackBars();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;
    List<BoxShadow> shadow;
    Color borderColor;

    switch (type) {
      case CustomSnackBarType.success:
        // Background is light green (successAccent). Text/icon is very dark forest green for high contrast.
        backgroundColor = AppColors.successAccent;
        textColor = const Color(0xFF0C3D10); // Deep dark forest green (accessible contrast)
        iconColor = const Color(0xFF0C3D10);
        icon = Icons.check_circle_rounded;
        borderColor = const Color(0xFF0C3D10).withValues(alpha: 0.15);
        shadow = [
          BoxShadow(
            color: const Color(0xFF0C3D10).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
        break;
      case CustomSnackBarType.error:
        // Background is deep red. Text/icon is white for high contrast.
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.error_rounded;
        borderColor = Colors.white.withValues(alpha: 0.15);
        shadow = [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
        break;
      case CustomSnackBarType.info:
        backgroundColor = isDark ? const Color(0xFF2E2E2E) : Colors.white;
        textColor = isDark ? Colors.white : AppColors.onSurface;
        iconColor = AppColors.primary;
        icon = Icons.info_rounded;
        borderColor = isDark 
            ? AppColors.outlineVariant.withValues(alpha: 0.15) 
            : AppColors.outlineVariant.withValues(alpha: 0.5);
        shadow = AppColors.softShadow;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: shadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message: message, type: CustomSnackBarType.success, duration: duration);
  }

  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message: message, type: CustomSnackBarType.error, duration: duration);
  }

  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message: message, type: CustomSnackBarType.info, duration: duration);
  }
}

extension CustomSnackBarBuildContextExtension on BuildContext {
  void showSuccessSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    CustomSnackBar.showSuccess(this, message, duration: duration);
  }

  void showErrorSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    CustomSnackBar.showError(this, message, duration: duration);
  }

  void showInfoSnackBar(String message, {Duration duration = const Duration(seconds: 3)}) {
    CustomSnackBar.showInfo(this, message, duration: duration);
  }
}
