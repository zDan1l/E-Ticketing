import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/role_model.dart';
import '../../services/auth_service.dart';
import '../components/components.dart';

class StatusUpdateButtons extends StatelessWidget {
  final String currentStatus;
  final Function(String) onStatusUpdate;

  const StatusUpdateButtons({
    super.key,
    required this.currentStatus,
    required this.onStatusUpdate,
  });

  List<String> _getAvailableStatuses(UserRole role) {
    switch (role) {
      case UserRole.user:
        if (currentStatus == 'closed' || currentStatus == 'resolved') {
          return ['reopened'];
        }
        return [];
      case UserRole.helpdesk:
        switch (currentStatus) {
          case 'open':
            return ['in_progress', 'resolved'];
          case 'in_progress':
            return ['open', 'resolved', 'closed'];
          case 'resolved':
            return ['in_progress', 'closed', 'reopened'];
          case 'closed':
            return ['reopened'];
          case 'reopened':
            return ['open', 'in_progress', 'resolved'];
          default:
            return [];
        }
      case UserRole.admin:
        switch (currentStatus) {
          case 'open':
            return ['in_progress', 'resolved', 'closed'];
          case 'in_progress':
            return ['open', 'resolved', 'closed'];
          case 'resolved':
            return ['in_progress', 'closed', 'reopened'];
          case 'closed':
            return ['reopened'];
          case 'reopened':
            return ['open', 'in_progress', 'resolved', 'closed'];
          default:
            return [];
        }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.primary;
      case 'in_progress':
        return AppColors.warningAccent;
      case 'resolved':
        return AppColors.tertiary;
      case 'closed':
        return AppColors.outline;
      case 'reopened':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  String _getStatusButtonLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'reopened':
        return 'Reopen';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.inbox_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'resolved':
        return Icons.check_circle_outline_rounded;
      case 'closed':
        return Icons.archive_outlined;
      case 'reopened':
        return Icons.refresh_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final currentUser = authService.currentUser;
    final userRole = currentUser?.role ?? UserRole.user;

    final availableStatuses = _getAvailableStatuses(userRole);

    if (availableStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return StyledCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.update_rounded,
                  color: AppColors.onPrimaryContainer,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'UPDATE STATUS',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableStatuses.map((status) {
              final statusColor = _getStatusColor(status);
              return InkWell(
                onTap: () => onStatusUpdate(status),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(status),
                        color: statusColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusButtonLabel(status).toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
