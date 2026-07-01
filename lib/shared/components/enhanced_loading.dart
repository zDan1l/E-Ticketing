import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Enhanced Shimmer Loading Skeleton for Cards
class CardShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const CardShimmer({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerContainer(
      width: width,
      height: height ?? 120,
      margin: margin,
      borderRadius: borderRadius,
    );
  }
}

/// Enhanced Shimmer Loading Skeleton for Lists
class ListTileShimmer extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final bool showAvatar;
  final bool showTrailing;
  final int lines;

  const ListTileShimmer({
    super.key,
    this.padding,
    this.showAvatar = true,
    this.showTrailing = true,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAvatar)
            _ShimmerCircle(size: 48),
          if (showAvatar) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerLine(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                for (int i = 1; i < lines; i++) ...[
                  _ShimmerLine(width: 0.7, height: 14),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            const SizedBox(width: 8),
            _ShimmerCircle(size: 32),
          ],
        ],
      ),
    );
  }
}

/// Enhanced Shimmer Loading Skeleton for Stats
class StatsShimmer extends StatelessWidget {
  final int count;

  const StatsShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: count,
      itemBuilder: (context, index) => _ShimmerContainer(
        height: 80,
        borderRadius: 16,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerCircle(size: 32),
              const SizedBox(height: 12),
              _ShimmerLine(width: 0.6, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Internal Shimmer Components

class _ShimmerContainer extends StatefulWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Widget? child;

  const _ShimmerContainer({
    this.width,
    this.height,
    this.margin,
    this.borderRadius = 16,
    this.child,
  });

  @override
  State<_ShimmerContainer> createState() => _ShimmerContainerState();
}

class _ShimmerContainerState extends State<_ShimmerContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _animation.value, -0.5),
              end: Alignment(1 + _animation.value, 0.5),
              colors: const [
                AppColors.surfaceContainerLow,
                AppColors.surfaceContainerHigh,
                AppColors.surfaceContainerLow,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;

  const _ShimmerLine({this.width, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return _ShimmerContainer(
      width: width != null
          ? (width! > 1
              ? width! * 300 // Approximate max width
              : width!)
          : null,
      height: height,
      borderRadius: 4,
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return _ShimmerContainer(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}

/// Full Page Loading State with Illustration
class FullPageLoading extends StatelessWidget {
  final String? message;

  const FullPageLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading illustration
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer.withOpacity(0.3),
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message ?? 'Memuat data...',
            style: AppTheme().bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline Loading State for Cards
class CardInlineLoading extends StatelessWidget {
  final String? message;

  const CardInlineLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme().bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
