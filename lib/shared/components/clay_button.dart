import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Flat Pill Button from style-guide.html
/// Solid background styling without shadows or gradients
class ClayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSecondary;
  final bool isOutlined;
  final bool isGhost;
  final IconData? icon;
  final double? width;
  final double? height;

  const ClayButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isGhost = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ??
        (isSecondary ? AppColors.secondaryContainer : AppColors.primary);

    final effectiveTextColor = textColor ??
        (isSecondary ? AppColors.onSecondaryContainer : AppColors.onPrimary);

    // Common text & icon child configuration
    final contentChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    if (isGhost) {
      return SizedBox(
        width: width,
        height: height,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: contentChild,
        ),
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            side: const BorderSide(color: AppColors.primary, width: 2),
            textStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: contentChild,
        ),
      );
    }

    // Standard Solid Button Style
    final isDefaultPrimary = backgroundColor == null && !isSecondary;
    
    Widget buttonWidget = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: (isDefaultPrimary || isSecondary) && onPressed != null
            ? Colors.transparent
            : (onPressed == null ? AppColors.disabled.withValues(alpha: 0.12) : effectiveBackgroundColor),
        foregroundColor: onPressed == null ? AppColors.disabled : effectiveTextColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      child: contentChild,
    );

    if (onPressed != null) {
      if (isDefaultPrimary) {
        buttonWidget = Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: AppColors.glowShadow,
          ),
          child: buttonWidget,
        );
      } else if (isSecondary) {
        buttonWidget = Container(
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: AppColors.softShadow,
          ),
          child: buttonWidget,
        );
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: buttonWidget,
    );
  }
}