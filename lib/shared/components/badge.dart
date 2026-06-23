import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Priority Badge matching style-guide.html
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
    Color bgColor;
    Color textColor;

    switch (priority) {
      case PriorityLevel.critical:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.onErrorContainer;
        break;
      case PriorityLevel.high:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.onErrorContainer;
        break;
      case PriorityLevel.medium:
        bgColor = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        break;
      case PriorityLevel.low:
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          overflow: TextOverflow.ellipsis,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

enum PriorityLevel { critical, high, medium, low }

/// Status Badge for ticket workflows adhering to the flat visual scale
class StatusBadge extends StatelessWidget {
  final String text;
  final TicketStatus status;

  const StatusBadge({super.key, required this.text, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case TicketStatus.open:
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
        break;
      case TicketStatus.inProgress:
        bgColor = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        break;
      case TicketStatus.resolved:
        bgColor = AppColors.tertiaryContainer;
        textColor = AppColors.onTertiaryContainer;
        break;
      case TicketStatus.closed:
        bgColor = AppColors.surfaceContainerHigh;
        textColor = AppColors.onSurfaceVariant;
        break;
      case TicketStatus.reopened:
        bgColor = AppColors.tertiaryContainer;
        textColor = AppColors.onTertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

enum TicketStatus { open, inProgress, resolved, closed, reopened }

/// Flat Custom Badge for dynamic assignments
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
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor ?? AppColors.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Solid/Flat Chip-style Badge for tags or filter controls (no shadows/borders)
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
    final effectiveBgColor =
        backgroundColor ??
        (isSelected
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerLow);

    final effectiveTextColor =
        textColor ??
        (isSelected
            ? AppColors.onPrimaryContainer
            : AppColors.onSurfaceVariant);

    return RawChip(
      label: Text(label),
      avatar: icon != null
          ? Icon(icon, size: 14, color: effectiveTextColor)
          : null,
      onPressed: onTap,
      backgroundColor: effectiveBgColor,
      selectedColor: AppColors.primaryContainer,
      selected: isSelected, // Fixed parameter mapping here
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      selectedShadowColor: Colors.transparent,
      side: BorderSide.none,
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
