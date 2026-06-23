import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Flat Linear Progress Bar component matching style-guide.html
class ProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final String? label;

  const ProgressBar({
    super.key,
    required this.value,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 8.0;
    final effectiveBgColor = backgroundColor ?? AppColors.surfaceContainerHigh;
    final effectiveProgressColor = progressColor ?? AppColors.successAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: effectiveProgressColor,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Flat Circular Progress Indicator matching your brand style sheet
class CircularProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final double? size;
  final double strokeWidth;
  final String? centerText;

  const CircularProgress({
    super.key,
    required this.value,
    this.backgroundColor,
    this.progressColor,
    this.size,
    this.strokeWidth = 8,
    this.centerText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = size ?? 80.0;
    final effectiveBgColor = backgroundColor ?? AppColors.surfaceContainerHigh;
    final effectiveProgressColor = progressColor ?? AppColors.primary;

    return SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: effectiveBgColor,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveBgColor),
            ),
          ),
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
            ),
          ),
          if (centerText != null)
            Text(
              centerText!,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}

/// Flat Metric/Stat Panel (Shadows replaced by fine subtle inline outline bounds)
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = backgroundColor ?? AppColors.secondaryContainer;
    final effectiveIconColor = iconColor ?? AppColors.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: effectiveBgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(icon, color: effectiveIconColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Flat Workflow Milestone Step Item List
class ProgressSteps extends StatelessWidget {
  final List<StepItem> steps;
  final int currentStep;

  const ProgressSteps({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == steps.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: AppColors.onPrimary,
                            size: 18,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCurrent
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: isCompleted || isCurrent
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (step.description != null)
                        Text(
                          step.description!,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 4, bottom: 12),
                child: Container(
                  width: 2,
                  height: 16,
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class StepItem {
  final String title;
  final String? description;

  StepItem({required this.title, this.description});
}
