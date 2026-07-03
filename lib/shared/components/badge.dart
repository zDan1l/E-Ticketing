import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Priority Badge with clean tag style, border, and colored indicator dot
class PriorityBadge extends StatelessWidget {
  final String text;
  final PriorityLevel priority;

  const PriorityBadge({super.key, required this.text, required this.priority});

  factory PriorityBadge.critical({String text = 'CRITICAL'}) {
    return PriorityBadge(text: text, priority: PriorityLevel.critical);
  }

  factory PriorityBadge.high({String text = 'HIGH'}) {
    return PriorityBadge(text: text, priority: PriorityLevel.high);
  }

  factory PriorityBadge.medium({String text = 'MEDIUM'}) {
    return PriorityBadge(text: text, priority: PriorityLevel.medium);
  }

  factory PriorityBadge.low({String text = 'LOW'}) {
    return PriorityBadge(text: text, priority: PriorityLevel.low);
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor;

    switch (priority) {
      case PriorityLevel.critical:
        baseColor = AppColors.primary;
        break;
      case PriorityLevel.high:
        baseColor = AppColors.primary;
        break;
      case PriorityLevel.medium:
        baseColor = const Color(0xFF6B7280);
        break;
      case PriorityLevel.low:
        baseColor = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: baseColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

enum PriorityLevel { critical, high, medium, low }

/// Status Badge with clean tag style, border, and colored status indicator dot
class StatusBadge extends StatelessWidget {
  final String text;
  final TicketStatus status;

  const StatusBadge({super.key, required this.text, required this.status});

  @override
  Widget build(BuildContext context) {
    Color baseColor;

    switch (status) {
      case TicketStatus.open:
        baseColor = AppColors.primary;
        break;
      case TicketStatus.inProgress:
        baseColor = const Color(0xFF6B7280);
        break;
      case TicketStatus.closed:
        baseColor = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: baseColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

enum TicketStatus { open, inProgress, closed }

/// Custom Badge for roles andinternal access markers
class CustomBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color? textColor;

  const CustomBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor ?? backgroundColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Dynamic Chip-style Badge with premium click feedback
class ChipBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isSelected;

  const ChipBadge({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ??
        (isSelected
            ? AppColors.primary
            : AppColors.surfaceContainerLow);

    final effectiveTextColor = textColor ??
        (isSelected
            ? AppColors.onPrimary
            : AppColors.onSurfaceVariant);

    return RawChip(
      label: Text(label),
      avatar: icon != null
          ? Icon(icon, size: 14, color: effectiveTextColor)
          : null,
      onPressed: onTap,
      backgroundColor: effectiveBgColor,
      selectedColor: effectiveBgColor,
      selected: isSelected,
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      side: isSelected 
          ? BorderSide.none 
          : const BorderSide(color: AppColors.outlineVariant, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: effectiveTextColor,
        letterSpacing: 0.5,
      ),
    );
  }
}
