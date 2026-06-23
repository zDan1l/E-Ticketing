import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_colors.dart';

/// Flat Timeline Feeds container wrapper
class Timeline extends StatelessWidget {
  final List<TimelineItem> items;
  final bool reverse;

  const Timeline({
    super.key,
    required this.items,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    final orderedItems = reverse ? items.reversed.toList() : items;

    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 8),
      child: Stack(
        children: [
          // Flat vertical track rule
          Positioned(
            left: 11,
            top: 8,
            bottom: 8,
            child: Container(
              width: 2,
              color: AppColors.outlineVariant.withOpacity(0.3),
            ),
          ),
          ...orderedItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isFirst = index == 0;
            final isLast = index == orderedItems.length - 1;

            return TimelineItemWidget(
              item: item,
              isFirst: isFirst,
              isLast: isLast,
            );
          }).toList(),
        ],
      ),
    );
  }
}

class TimelineItemWidget extends StatelessWidget {
  final TimelineItem item;
  final bool isFirst;
  final bool isLast;

  const TimelineItemWidget({
    super.key,
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 16,
        top: isFirst ? 0 : 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 4),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: item.dotColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: item.titleColor ?? AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurface,
                  ),
                ),
                if (item.timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.timestamp!,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineItem {
  final String title;
  final String description;
  final String? timestamp;
  final Color dotColor;
  final Color? titleColor;

  TimelineItem({
    required this.title,
    required this.description,
    this.timestamp,
    this.dotColor = AppColors.primary,
    this.titleColor,
  });

  factory TimelineItem.success({
    required String title,
    required String description,
    String? timestamp,
  }) {
    return TimelineItem(
      title: title,
      description: description,
      timestamp: timestamp,
      dotColor: AppColors.successAccent,
      titleColor: AppColors.primary,
    );
  }

  factory TimelineItem.primary({
    required String title,
    required String description,
    String? timestamp,
  }) {
    return TimelineItem(
      title: title,
      description: description,
      timestamp: timestamp,
      dotColor: AppColors.primary,
      titleColor: AppColors.onSurfaceVariant,
    );
  }

  factory TimelineItem.neutral({
    required String title,
    required String description,
    String? timestamp,
  }) {
    return TimelineItem(
      title: title,
      description: description,
      timestamp: timestamp,
      dotColor: AppColors.outlineVariant,
      titleColor: AppColors.onSurfaceVariant,
    );
  }
}

/// Compact dynamic timeline node block
class CompactTimeline extends StatelessWidget {
  final List<TimelineItem> items;

  const CompactTimeline({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == items.length - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: item.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (item.timestamp != null)
                        Text(
                          item.timestamp!,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.only(left: 3, top: 4, bottom: 8),
                child: Container(
                  width: 2,
                  height: 8,
                  color: AppColors.outlineVariant.withOpacity(0.3),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}