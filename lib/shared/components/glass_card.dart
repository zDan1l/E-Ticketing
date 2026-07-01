import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Flat structural Card replacing Glassmorphism configurations
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget cardChild = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        border:
            border ??
            Border.all(
              color: isDark
                  ? AppColors.outlineVariant.withValues(alpha: 0.2)
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
        color: isDark ? const Color(0xFF2E2E2E) : Colors.white,
        // Add subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      cardChild = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: cardChild,
        ),
      );
    }

    return cardChild;
  }
}

/// Standard flat card without depth shadows
class StyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? glowColor;
  final bool hasBorder;
  final bool hasShadow;

  const StyledCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.glowColor,
    this.hasBorder = true,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardContent = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder
            ? Border.all(
                color: isDark
                    ? AppColors.outlineVariant.withValues(alpha: 0.2)
                    : AppColors.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
        // Add subtle shadow for depth
        boxShadow: hasShadow || onTap != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Flat Bento-style Card layout
class BentoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? footer;
  final VoidCallback? onTap;

  const BentoCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.footer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.onPrimary;

    return Container(
      width: double.infinity,
      // Enforces clean flat clipping onto your 16px border radius scale
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (icon != null)
                Positioned(
                  bottom: -24,
                  right: -24,
                  child: Icon(
                    icon,
                    size: 96,
                    color: effectiveTextColor.withValues(alpha: 0.1),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: effectiveTextColor.withValues(alpha: 0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: effectiveTextColor,
                        letterSpacing: -0.01,
                      ),
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 12),
                      footer!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
