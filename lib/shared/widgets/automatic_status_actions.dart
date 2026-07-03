import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/role_model.dart';
import '../../models/ticket_model.dart';
import '../../services/auth_service.dart';
import '../components/components.dart';

class AutomaticStatusActions extends StatelessWidget {
  final TicketModel ticket;
  final Function() onActionComplete;

  const AutomaticStatusActions({
    super.key,
    required this.ticket,
    required this.onActionComplete,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.primary;
      case 'in_progress':
        return AppColors.warningAccent;
      case 'closed':
        return AppColors.successAccent;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'open':
        return Icons.inbox_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'closed':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getStatusButtonLabel(String status) {
    switch (status) {
      case 'open':
        return 'Menunggu Assign';
      case 'in_progress':
        return 'Sedang Diproses';
      case 'closed':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final userRole = currentUser?.role ?? UserRole.user;
    final isAssignedToMe = ticket.assigneeId == currentUser?.id;

    // Show actions only for helpdesk assigned to this ticket
    if (userRole != UserRole.helpdesk || !isAssignedToMe) {
      return const SizedBox.shrink();
    }

    // Don't show any buttons if ticket is already closed
    if (ticket.isClosed) {
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
                  Icons.bolt_rounded,
                  color: AppColors.onPrimaryContainer,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AKSI OTOMATIS',
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
          Row(
            children: [
              // Current status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(ticket.status).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(ticket.status),
                      color: _getStatusColor(ticket.status),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusButtonLabel(ticket.status).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(ticket.status),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action button based on current status
              Expanded(
                child: _buildActionButton(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (ticket.isInProgress) {
      // Show "Selesaikan" button for In Progress tickets
      return _ActionButton(
        label: 'Selesaikan',
        icon: Icons.done_all_rounded,
        color: AppColors.successAccent,
        onTap: () => _showFinishDialog(context),
      );
    }

    return const SizedBox.shrink();
  }

  void _showFinishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selesaikan Tiket'),
        content: const Text('Status tiket akan otomatis berubah menjadi "Closed"'),
        actions: [
          ClayButton(
            text: 'Batal',
            isGhost: true,
            onPressed: () => Navigator.pop(context),
          ),
          ClayButton(
            text: 'Selesaikan',
            backgroundColor: AppColors.successAccent,
            textColor: AppColors.onBackground,
            onPressed: () {
              Navigator.pop(context);
              onActionComplete();
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
