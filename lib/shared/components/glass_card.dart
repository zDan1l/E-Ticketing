import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Real Glassmorphism Card with Backdrop Filter blur and soft shadow depth
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
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget cardChild = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: AppColors.softShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              border: border ??
                  Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
              color: isDark
                  ? const Color(0xFF1E1E2F).withValues(alpha: 0.65)
                  : Colors.white.withValues(alpha: 0.65),
            ),
            child: child,
          ),
        ),
      ),
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

/// Standard premium card with elevation depth
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
    this.hasShadow = true,
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
        color: isDark ? const Color(0xFF232230) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasBorder
            ? Border.all(
                color: isDark
                    ? AppColors.outlineVariant.withValues(alpha: 0.12)
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              )
            : null,
        boxShadow: hasShadow || onTap != null
            ? AppColors.premiumShadow
            : AppColors.softShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Bento-style Card layout with functional gradient backgrounds
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
    final effectiveTextColor = textColor ?? Colors.white;

    // Map solid background colors to premium gradients
    Gradient? cardGradient;
    Color cardBgColor = backgroundColor ?? AppColors.primary;
    
    if (backgroundColor == AppColors.primary) {
      cardGradient = AppColors.primaryGradient;
    } else if (backgroundColor == AppColors.statusOpen) {
      cardGradient = AppColors.infoGradient;
    } else if (backgroundColor == AppColors.statusInProgress) {
      cardGradient = AppColors.warningGradient;
    } else if (backgroundColor == AppColors.statusClosed) {
      cardGradient = AppColors.successGradient;
    } else if (backgroundColor == AppColors.surfaceContainerHigh || backgroundColor == AppColors.canvas) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      cardBgColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF1EDEC);
    } else if (backgroundColor != null) {
      cardBgColor = backgroundColor!;
    } else {
      cardGradient = AppColors.primaryGradient;
    }

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardGradient == null ? cardBgColor : null,
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (icon != null)
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Icon(
                    icon,
                    size: 90,
                    color: effectiveTextColor.withValues(alpha: 0.12),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: effectiveTextColor.withValues(alpha: 0.75),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: effectiveTextColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: 14),
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
