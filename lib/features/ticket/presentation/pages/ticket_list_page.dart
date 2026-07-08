import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/ticket_model.dart';
import '../../../../models/role_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/ticket_provider.dart';
import '../../../../services/user_api_service.dart';
import '../../../../shared/components/components.dart';
import '../../../../shared/widgets/main_navigation.dart';

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
  String? _selectedAssigneeId; // Admin only: filter by helpdesk assignee
  List<UserModel> _helpdeskList = [];

  final List<Map<String, dynamic>> _filters = [
    {'key': 'all', 'label': 'Semua'},
    {'key': 'open', 'label': 'Open'},
    {'key': 'in_progress', 'label': 'In Progress'},
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

  final UserApiService _userApiService = UserApiService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Load helpdesk list for admin filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _loadTickets();
      if (authProvider.currentUserRole == UserRole.admin) {
        _loadHelpdeskStaff();
      }

      // Check if there's a search query from navigation
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

  Future<void> _loadHelpdeskStaff() async {
    final staff = await _userApiService.getHelpdeskStaff();
    if (mounted) {
      setState(() => _helpdeskList = staff);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await ticketProvider.loadTickets(
      userRole: authProvider.currentUserRole,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      status: _selectedFilter != 'all' ? _selectedFilter : null,
      category: _selectedCategory != 'all' ? _selectedCategory : null,
      priority: _selectedPriority != 'all' ? _selectedPriority : null,
      assigneeId: _selectedAssigneeId,
    );
  }

  List<TicketModel> get _filteredTickets {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    var tickets = ticketProvider.tickets;

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

    // Note: assignee filter is applied server-side via _loadTickets()

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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final tickets = _filteredTickets;
    final isAdmin = authProvider.currentUserRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(
          isAdmin ? 'Semua Tiket' : 'Tiket Saya',
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
          const SizedBox(width: 12),
        ],
      ),
      body: ticketProvider.isLoading
          ? const FullPageLoading(message: 'Memuat tiket...')
          : Column(
              children: [
                // Unified Filter Container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search bar with StyledInput
                      Padding(
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
                      
                      // Status filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = _selectedFilter == filter['key'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildTabBadge(
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
                      
                      // Admin only: Helpdesk assignee filter
                      if (isAdmin && _helpdeskList.isNotEmpty) ...[
                        const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.support_agent_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Filter Helpdesk Staff:',
                                style: AppTheme().bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          child: Row(
                            children: [
                              // "Semua" chip
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildTabBadge(
                                  label: 'Semua Staff',
                                  isSelected: _selectedAssigneeId == null,
                                  onTap: () {
                                    setState(() => _selectedAssigneeId = null);
                                    _loadTickets();
                                  },
                                ),
                              ),
                              ..._helpdeskList.map((helpdesk) {
                                final isSelected = _selectedAssigneeId == helpdesk.id;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildTabBadge(
                                    label: helpdesk.name,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() => _selectedAssigneeId =
                                          isSelected ? null : helpdesk.id);
                                      _loadTickets();
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],

                      // Active Category / Priority Filters (if any)
                      if (_selectedCategory != 'all' || _selectedPriority != 'all') ...[
                        const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Filter Aktif:',
                                style: AppTheme().bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_selectedCategory != 'all')
                                _buildActiveFilterBadge(
                                  label: _getCategoryLabel(_selectedCategory),
                                  onTap: () {
                                    setState(() => _selectedCategory = 'all');
                                    _loadTickets();
                                  },
                                ),
                              if (_selectedPriority != 'all')
                                _buildActiveFilterBadge(
                                  label: 'Prioritas: ${_getPriorityLabel(_selectedPriority)}',
                                  onTap: () {
                                    setState(() => _selectedPriority = 'all');
                                    _loadTickets();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Error message (placed outside the unified filter container)
                if (ticketProvider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ticketProvider.errorMessage!,
                            style: AppTheme().bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.sort_rounded,
                          size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Terbaru',
                        style: AppTheme().bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tickets list
                Expanded(
                  child: tickets.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            return _TicketCard(
                              ticket: ticket,
                              onTap: () async {
                                final result = await Navigator.of(context).pushNamed(
                                  '/ticket-detail',
                                  arguments: ticket,
                                );
                                if (result == true && mounted) {
                                  context.showSuccessSnackBar('Tiket berhasil dihapus');
                                  final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
                                  mainNavState?.setIndex(0);
                                }
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

  Widget _buildEmptyState() {
    // Check if filtering is active
    final isFiltering = _selectedFilter != 'all' ||
        _selectedCategory != 'all' ||
        _selectedPriority != 'all' ||
        _selectedAssigneeId != null ||
        _searchQuery.isNotEmpty;

    if (isFiltering) {
      return EmptyStates.noSearchResults(
        onClear: () {
          setState(() {
            _selectedFilter = 'all';
            _selectedCategory = 'all';
            _selectedPriority = 'all';
            _selectedAssigneeId = null;
            _searchQuery = '';
            _searchController.clear();
          });
          _loadTickets();
        },
      );
    }

    return EmptyStates.noTickets(
      onCreate: () {
        Navigator.of(context).pushNamed('/create-ticket');
      },
    );
  }

  Widget _buildTabBadge({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterBadge({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
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
      case 'closed':
        return TicketStatus.closed;
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
      case 'closed':
        return 'Closed';
      default:
        return status;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return StyledCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  PriorityBadge(
                    text: ticket.priority.toUpperCase(),
                    priority: _priorityLevel(ticket.priority),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TKT-${ticket.ticketNumber}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              StatusBadge(
                text: _statusLabel(ticket.status),
                status: _ticketStatus(ticket.status),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ticket.title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.onSurface,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _getCategoryLabel(ticket.category),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            width: double.infinity,
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08) 
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _IconCount(
                icon: Icons.chat_bubble_outline_rounded,
                count: ticket.commentsCount,
              ),
              const SizedBox(width: 10),
              _IconCount(
                icon: Icons.attach_file_rounded,
                count: ticket.attachmentsCount,
              ),
              const Spacer(),
              if (ticket.assigneeName != null) ...[
                UserAvatar(
                  avatar: ticket.assigneeAvatar,
                  name: ticket.assigneeName,
                  size: 28,
                  fontSize: 10,
                  textColor: Colors.white,
                  backgroundColor: AppColors.primaryContainer,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                const SizedBox(width: 10),
              ],
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeAgo(ticket.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11),
                  ),
                ],
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
    final Color baseColor = const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: baseColor),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Private Top-level Helpers
String _getCategoryLabel(String cat) {
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

String _getPriorityLabel(String priority) {
  switch (priority.toLowerCase()) {
    case 'low':
      return 'Low';
    case 'medium':
      return 'Medium';
    case 'high':
      return 'High';
    case 'critical':
      return 'Critical';
    default:
      return priority;
  }
}
