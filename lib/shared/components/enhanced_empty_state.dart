import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'clay_button.dart';

/// Enhanced Empty State with Unsplash Illustration
class EnhancedEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateType type;

  const EnhancedEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.fallbackIcon,
    this.actionLabel,
    this.onAction,
    this.type = EmptyStateType.general,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            _buildIllustration(),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: AppTheme().headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: AppTheme().bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ClayButton(
                text: actionLabel!,
                onPressed: onAction,
                icon: _getActionIcon(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIllustration();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    }
    return _buildFallbackIllustration();
  }

  Widget _buildFallbackIllustration() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Icon(
        fallbackIcon ?? _getFallbackIcon(),
        size: 64,
        color: _getIconColor(),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case EmptyStateType.tickets:
        return AppColors.primaryContainer;
      case EmptyStateType.notifications:
        return AppColors.tertiaryContainer;
      case EmptyStateType.search:
        return AppColors.secondaryContainer;
      case EmptyStateType.error:
        return AppColors.errorContainer;
      case EmptyStateType.success:
        return AppColors.primaryContainer;
      default:
        return AppColors.surfaceContainerLow;
    }
  }

  Color _getBorderColor() {
    switch (type) {
      case EmptyStateType.tickets:
        return AppColors.primary;
      case EmptyStateType.notifications:
        return AppColors.tertiary;
      case EmptyStateType.search:
        return AppColors.secondary;
      case EmptyStateType.error:
        return AppColors.error;
      case EmptyStateType.success:
        return AppColors.successAccent;
      default:
        return AppColors.outlineVariant;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case EmptyStateType.tickets:
        return AppColors.primary;
      case EmptyStateType.notifications:
        return AppColors.tertiary;
      case EmptyStateType.search:
        return AppColors.secondary;
      case EmptyStateType.error:
        return AppColors.error;
      case EmptyStateType.success:
        return AppColors.successAccent;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _getFallbackIcon() {
    switch (type) {
      case EmptyStateType.tickets:
        return Icons.inbox_rounded;
      case EmptyStateType.notifications:
        return Icons.notifications_off_outlined;
      case EmptyStateType.search:
        return Icons.search_off_rounded;
      case EmptyStateType.error:
        return Icons.error_outline_rounded;
      case EmptyStateType.success:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  IconData? _getActionIcon() {
    switch (type) {
      case EmptyStateType.tickets:
        return Icons.add_rounded;
      case EmptyStateType.search:
        return Icons.refresh_rounded;
      case EmptyStateType.error:
        return Icons.refresh_rounded;
      default:
        return null;
    }
  }
}

/// Empty State Types with Preset Configurations
enum EmptyStateType {
  general,
  tickets,
  notifications,
  search,
  error,
  success,
}

/// Preset Empty State Configurations
class EmptyStates {
  /// Empty state for ticket list
  static Widget noTickets({VoidCallback? onCreate}) {
    return EnhancedEmptyState(
      type: EmptyStateType.tickets,
      title: 'Belum Ada Tiket',
      subtitle: 'Anda belum memiliki tiket. Buat tiket baru untuk melaporkan masalah.',
      actionLabel: onCreate != null ? 'Buat Tiket Baru' : null,
      onAction: onCreate,
      imageUrl: 'https://images.unsplash.com/photo-1557435068-722abc137d6f?w=400&q=80',
    );
  }

  /// Empty state for search results
  static Widget noSearchResults({VoidCallback? onClear}) {
    return EnhancedEmptyState(
      type: EmptyStateType.search,
      title: 'Tidak Ditemukan',
      subtitle: 'Tiket dengan kata kunci tersebut tidak tersedia. Coba kata kunci lain.',
      actionLabel: onClear != null ? 'Hapus Filter' : null,
      onAction: onClear,
      imageUrl: 'https://images.unsplash.com/photo-1544526936-935a00bce7b4?w=400&q=80',
    );
  }

  /// Empty state for notifications
  static Widget noNotifications() {
    return EnhancedEmptyState(
      type: EmptyStateType.notifications,
      title: 'Belum Ada Notifikasi',
      subtitle: 'Notifikasi akan muncul di sini ketika ada aktivitas terkait tiket Anda.',
      imageUrl: 'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=400&q=80',
    );
  }

  /// Empty state for network error
  static Widget networkError({VoidCallback? onRetry}) {
    return EnhancedEmptyState(
      type: EmptyStateType.error,
      title: 'Koneksi Bermasalah',
      subtitle: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda dan coba lagi.',
      actionLabel: onRetry != null ? 'Coba Lagi' : null,
      onAction: onRetry,
      fallbackIcon: Icons.wifi_off_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&q=80',
    );
  }

  /// Empty state for server error
  static Widget serverError({VoidCallback? onRetry}) {
    return EnhancedEmptyState(
      type: EmptyStateType.error,
      title: 'Terjadi Kesalahan',
      subtitle: 'Server sedang mengalami gangguan. Silakan coba lagi nanti.',
      actionLabel: onRetry != null ? 'Coba Lagi' : null,
      onAction: onRetry,
      fallbackIcon: Icons.cloud_off_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400&q=80',
    );
  }

  /// Empty state for no data
  static Widget noData({
    required String title,
    String? subtitle,
    VoidCallback? onRefresh,
  }) {
    return EnhancedEmptyState(
      type: EmptyStateType.general,
      title: title,
      subtitle: subtitle ?? 'Data belum tersedia saat ini.',
      actionLabel: onRefresh != null ? 'Refresh' : null,
      onAction: onRefresh,
      imageUrl: 'https://images.unsplash.com/photo-1544526936-935a00bce7b4?w=400&q=80',
    );
  }

  /// Success state
  static Widget success({
    required String title,
    String? subtitle,
    VoidCallback? onContinue,
  }) {
    return EnhancedEmptyState(
      type: EmptyStateType.success,
      title: title,
      subtitle: subtitle,
      actionLabel: onContinue != null ? 'Lanjut' : null,
      onAction: onContinue,
      imageUrl: 'https://images.unsplash.com/photo-1551434664-9e19a41b5056?w=400&q=80',
    );
  }
}

/// Compact Empty State for Cards/Sections
class CompactEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const CompactEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_rounded,
            size: 48,
            color: AppColors.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme().bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ClayButton(
              text: actionLabel!,
              onPressed: onAction,
              isGhost: true,
            ),
          ],
        ],
      ),
    );
  }
}
