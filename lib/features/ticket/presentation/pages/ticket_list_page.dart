import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dummy_data.dart';
import '../../../../models/ticket_model.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  String _selectedFilter = 'all';
  final List<Map<String, dynamic>> _filters = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'open', 'label': 'Open'},
    {'key': 'in_progress', 'label': 'In Progress'},
    {'key': 'resolved', 'label': 'Resolved'},
    {'key': 'closed', 'label': 'Closed'},
  ];

  List<TicketModel> get _filteredTickets {
    if (_selectedFilter == 'all') return DummyData.tickets;
    return DummyData.tickets
        .where((t) => t.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _filteredTickets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tiket Saya',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = filter['key']);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          filter['label'],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Ticket count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  '${tickets.length} tiket ditemukan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(Icons.sort_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Terbaru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Tickets list
          Expanded(
            child: tickets.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TicketCard(
                          ticket: ticket,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/ticket-detail',
                              arguments: ticket,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inbox_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ada tiket',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tiket dengan filter ini belum tersedia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return AppColors.statusOpen;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'resolved':
        return AppColors.statusResolved;
      case 'closed':
        return AppColors.statusClosed;
      case 'reopened':
        return AppColors.statusReopened;
      default:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(String status) {
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
        return 'Reopened';
      default:
        return status;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'low':
        return AppColors.priorityLow;
      case 'medium':
        return AppColors.priorityMedium;
      case 'high':
        return AppColors.priorityHigh;
      case 'critical':
        return AppColors.priorityCritical;
      default:
        return AppColors.textTertiary;
    }
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'hardware':
        return '🖥️ Hardware';
      case 'software':
        return '💿 Software';
      case 'network':
        return '🌐 Network';
      case 'other':
        return '📋 Lainnya';
      default:
        return cat;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  @override
  Widget build(BuildContext context) {
    final sColor = _statusColor(ticket.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Priority dot + ticket number
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _priorityColor(ticket.priority),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.ticketNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(ticket.status),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              ticket.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Category
            Text(
              _categoryLabel(ticket.category),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            // Divider
            Container(
              height: 1,
              color: AppColors.divider,
            ),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                // Comments
                _IconCount(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: ticket.commentsCount,
                ),
                const SizedBox(width: 16),
                _IconCount(
                  icon: Icons.attach_file_rounded,
                  count: ticket.attachmentsCount,
                ),
                const Spacer(),
                // Assignee
                if (ticket.assigneeName != null) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ticket.assigneeAvatar ?? '',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  _timeAgo(ticket.createdAt),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCount extends StatelessWidget {
  final IconData icon;
  final int count;

  const _IconCount({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
