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

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.currentUser;
    final userRole = currentUser?.role ?? UserRole.user;
    final isAssignedToMe = ticket.assigneeId == currentUser?.id;

    // Show actions only for helpdesk assigned to this ticket and when ticket is in progress
    if (userRole != UserRole.helpdesk || !isAssignedToMe || !ticket.isInProgress) {
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
                child: const Icon(
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
          _buildActionButton(context),
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
            backgroundColor: const Color(0xFF2E7D32),
            textColor: Colors.white,
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
    final isSuccess = color == AppColors.successAccent;
    final bgColor = isSuccess ? const Color(0xFF2E7D32) : color.withValues(alpha: 0.1);
    final borderColor = isSuccess ? const Color(0xFF1B5E20) : color.withValues(alpha: 0.5);
    final textColor = isSuccess ? Colors.white : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
