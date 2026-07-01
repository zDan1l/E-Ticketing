import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Flat Circular Icon Button from style-guide.html
class ClayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const ClayIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? Colors.white;

    // Auto-detect appropriate icon color based on background
    Color effectiveIconColor;
    if (iconColor != null) {
      effectiveIconColor = iconColor!;
    } else if (backgroundColor != null) {
      // If background is primary, tertiary, or similar dark color, use white
      if (_isDarkBackground(backgroundColor!)) {
        effectiveIconColor = AppColors.onPrimary; // White
      } else {
        effectiveIconColor = AppColors.primary;
      }
    } else {
      effectiveIconColor = AppColors.primary;
    }

    final effectiveSize = size ?? 48.0;

    return Tooltip(
      message: tooltip ?? '',
      child: SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: Material(
          color: effectiveBgColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: effectiveSize * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Check if background is dark enough to require white text/icon
  bool _isDarkBackground(Color color) {
    // Primary (#3D31A3), Tertiary (#213F8E), Error (#BA1A1A), etc.
    return color == AppColors.primary ||
        color == AppColors.tertiary ||
        color == AppColors.error ||
        color == AppColors.onSurface ||
        color.value < 0xFF800000; // Dark colors in general
  }
}

/// Flat FAB Button (no drop shadows or layers)
class ClayFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;

  const ClayFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.error;
    final effectiveIconColor = iconColor ?? Colors.white;

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: effectiveBgColor,
      foregroundColor: effectiveIconColor,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      shape: const CircleBorder(),
      child: Icon(icon),
    );
  }
}

/// Dynamic Tooling Toolbar Bar Button Component
class SurfaceIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isActive;

  const SurfaceIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: isActive
              ? AppColors.primaryContainer.withValues(alpha: 0.12)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Icon(
                icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom Utility Navigation Tab Action Button
class NavIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const NavIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
