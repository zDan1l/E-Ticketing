import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/ticket_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../shared/components/components.dart';

class TicketListPage extends StatefulWidget {
  const TicketListPage({super.key});

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  String _selectedFilter = 'all';
  String _selectedCategory = 'all';
  String _selectedPriority = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _filters = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'open', 'label': 'Open'},
    {'key': 'in_progress', 'label': 'In Progress'},
    {'key': 'resolved', 'label': 'Resolved'},
    {'key': 'closed', 'label': 'Closed'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'label': 'Semua Kategori'},
    {'key': 'hardware', 'label': 'Hardware'},
    {'key': 'software', 'label': 'Software'},
    {'key': 'network', 'label': 'Network'},
    {'key': 'other', 'label': 'Lainnya'},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'key': 'all', 'label': 'Semua Priority'},
    {'key': 'low', 'label': 'Low'},
    {'key': 'medium', 'label': 'Medium'},
    {'key': 'high', 'label': 'High'},
    {'key': 'critical', 'label': 'Critical'},
  ];

  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<TicketModel> _allTickets = [];
  Map<String, dynamic>? _pagination;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTickets();

    // Check if there's a search query from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['searchQuery'] != null) {
        setState(() {
          _searchQuery = args['searchQuery'] as String;
          _searchController.text = _searchQuery;
        });
        _loadTickets();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _ticketService.getTickets(
        userRole: _authService.currentUserRole,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        status: _selectedFilter != 'all' ? _selectedFilter : null,
        category: _selectedCategory != 'all' ? _selectedCategory : null,
        priority: _selectedPriority != 'all' ? _selectedPriority : null,
      );

      if (mounted) {
        setState(() {
          _allTickets = response['tickets'] as List<TicketModel>? ?? [];
          _pagination = response['pagination'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat tiket: ${e.toString()}';
          _isLoading = false;
          _allTickets = [];
        });
      }
    }
  }

  List<TicketModel> get _filteredTickets {
    var tickets = _allTickets;

    // Apply status filter
    if (_selectedFilter != 'all') {
      tickets = tickets.where((t) => t.status == _selectedFilter).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'all') {
      tickets = tickets.where((t) => t.category == _selectedCategory).toList();
    }

    // Apply priority filter
    if (_selectedPriority != 'all') {
      tickets = tickets.where((t) => t.priority == _selectedPriority).toList();
    }

    return tickets;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Tiket',
          style: AppTheme().headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category filter
              Text(
                'Kategori',
                style: AppTheme().labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['key'];
                  return ChipBadge(
                    label: cat['label'],
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedCategory = cat['key']);
                      Navigator.pop(context);
                      _loadTickets();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Priority filter
              Text(
                'Priority',
                style: AppTheme().labelCaps.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _priorities.map((pri) {
                  final isSelected = _selectedPriority == pri['key'];
                  return ChipBadge(
                    label: pri['label'],
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedPriority = pri['key']);
                      Navigator.pop(context);
                      _loadTickets();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Reset button
              Center(
                child: ClayButton(
                  text: 'Reset Filter',
                  icon: Icons.refresh,
                  isGhost: true,
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'all';
                      _selectedPriority = 'all';
                    });
                    Navigator.pop(context);
                    _loadTickets();
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          ClayButton(
            text: 'Tutup',
            isGhost: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _filteredTickets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tiket Saya',
          style: AppTheme().headlineSmall,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list_rounded, size: 22),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: _loadTickets,
            icon: const Icon(Icons.refresh_rounded, size: 22),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : Column(
              children: [
                // Search bar with StyledInput
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: StyledInput(
                    hint: 'Cari tiket...',
                    controller: _searchController,
                    prefixIcon: Icons.search_rounded,
                    onSubmitted: (query) {
                      setState(() => _searchQuery = query);
                      _loadTickets();
                    },
                    onChanged: (value) {
                      setState(() {}); // Update UI for clear button
                    },
                    suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
                    onSuffixIconPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      _loadTickets();
                    },
                  ),
                ),
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme().bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Filter chips with ChipBadge
                Container(
                  color: AppColors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter == filter['key'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChipBadge(
                            label: filter['label'],
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter['key'];
                              });
                              _loadTickets();
                            },
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
                        style: AppTheme().bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.sort_rounded,
                          size: 18, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Terbaru',
                        style: AppTheme().bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tickets list
                Expanded(
                  child: tickets.isEmpty
                      ? _EmptyState(onRefresh: _loadTickets)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            return _TicketCard(
                              ticket: ticket,
                              onTap: () async {
                                await Navigator.of(context).pushNamed(
                                  '/ticket-detail',
                                  arguments: ticket,
                                );
                                // Refresh ticket list when returning from detail page
                                // to show any status updates
                                _loadTickets();
                              },
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
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada tiket',
              style: AppTheme().headlineSmall.copyWith(
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tiket dengan filter ini belum tersedia',
              style: AppTheme().bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClayButton(
              text: 'Refresh',
              icon: Icons.refresh,
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const _TicketCard({required this.ticket, required this.onTap});

  TicketStatus _ticketStatus(String status) {
    switch (status) {
      case 'open':
        return TicketStatus.open;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      case 'reopened':
        return TicketStatus.reopened;
      default:
        return TicketStatus.open;
    }
  }

  PriorityLevel _priorityLevel(String priority) {
    switch (priority) {
      case 'low':
        return PriorityLevel.low;
      case 'medium':
        return PriorityLevel.medium;
      case 'high':
        return PriorityLevel.high;
      case 'critical':
        return PriorityLevel.critical;
      default:
        return PriorityLevel.low;
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
    return StyledCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Priority dot + ticket number
              PriorityBadge(
                text: ticket.priority.toUpperCase(),
                priority: _priorityLevel(ticket.priority),
              ),
              const SizedBox(width: 10),
              Text(
                ticket.ticketNumber,
                style: AppTheme().labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              StatusBadge(
                text: _statusLabel(ticket.status),
                status: _ticketStatus(ticket.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Title
          Text(
            ticket.title,
            style: AppTheme().bodyLarge.copyWith(
              color: AppColors.onSurface,
              height: 1.3,
              letterSpacing: -0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          // Category
          Text(
            _categoryLabel(ticket.category),
            style: AppTheme().bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            decoration: const BoxDecoration(
              color: AppColors.outlineVariant,
            ),
          ),
          const SizedBox(height: 14),
          // Footer
          Row(
            children: [
              // Comments
              _IconCount(
                icon: Icons.chat_bubble_outline_rounded,
                count: ticket.commentsCount,
              ),
              const SizedBox(width: 12),
              // Attachments
              _IconCount(
                icon: Icons.attach_file_rounded,
                count: ticket.attachmentsCount,
              ),
              const Spacer(),
              // Assignee
              if (ticket.assigneeName != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ticket.assigneeAvatar ?? '',
                      style: AppTheme().labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _timeAgo(ticket.createdAt),
                style: AppTheme().labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
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
    final Color color = icon == Icons.chat_bubble_outline_rounded
        ? AppColors.primary
        : AppColors.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: AppTheme().labelSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
