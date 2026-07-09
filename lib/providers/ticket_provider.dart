import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../models/role_model.dart';
import '../services/ticket_service.dart';

class TicketProvider with ChangeNotifier {
  final TicketService _ticketService = TicketService();

  List<TicketModel> _tickets = [];
  Map<String, int> _stats = {'open': 0, 'in_progress': 0, 'closed': 0, 'assigned': 0};
  Map<String, dynamic>? _pagination;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;

  // Keep track of active query filters
  UserRole? _activeUserRole;
  String? _activeSearchQuery;
  String? _activeStatus;
  String? _activeCategory;
  String? _activePriority;
  String? _activeAssigneeId;
  int _activePage = 1;
  int _activeLimit = 20;

  List<TicketModel> get tickets => _tickets;
  Map<String, int> get stats => _stats;
  Map<String, dynamic>? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Active filter getters
  UserRole? get activeUserRole => _activeUserRole;
  String? get activeSearchQuery => _activeSearchQuery;
  String? get activeStatus => _activeStatus;
  String? get activeCategory => _activeCategory;
  String? get activePriority => _activePriority;
  String? get activeAssigneeId => _activeAssigneeId;
  int get activePage => _activePage;

  void updateFilters({
    UserRole? userRole,
    String? searchQuery,
    String? status,
    String? category,
    String? priority,
    String? assigneeId,
    int? page,
    int? limit,
  }) {
    _activeUserRole = userRole ?? _activeUserRole;
    _activeSearchQuery = searchQuery ?? _activeSearchQuery;
    _activeStatus = status ?? _activeStatus;
    _activeCategory = category ?? _activeCategory;
    _activePriority = priority ?? _activePriority;
    _activeAssigneeId = assigneeId ?? _activeAssigneeId;
    _activePage = page ?? _activePage;
    _activeLimit = limit ?? _activeLimit;
  }

  void clearFilters() {
    _activeSearchQuery = null;
    _activeStatus = null;
    _activeCategory = null;
    _activePriority = null;
    _activeAssigneeId = null;
    _activePage = 1;
  }

  Future<void> loadTickets({
    bool silent = false,
    UserRole? userRole,
    String? searchQuery,
    String? status,
    String? category,
    String? priority,
    String? assigneeId,
    int? page,
    int? limit,
  }) async {
    updateFilters(
      userRole: userRole,
      searchQuery: searchQuery,
      status: status,
      category: category,
      priority: priority,
      assigneeId: assigneeId,
      page: page,
      limit: limit,
    );

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _ticketService.getTickets(
        userRole: _activeUserRole,
        searchQuery: _activeSearchQuery == 'all' ? null : _activeSearchQuery,
        status: _activeStatus == 'all' ? null : _activeStatus,
        category: _activeCategory == 'all' ? null : _activeCategory,
        priority: _activePriority == 'all' ? null : _activePriority,
        assigneeId: _activeAssigneeId == 'all' ? null : _activeAssigneeId,
        page: _activePage,
        limit: _activeLimit,
      );

      _tickets = response['tickets'] as List<TicketModel>? ?? [];
      _pagination = response['pagination'] as Map<String, dynamic>?;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadStats({bool silent = false, UserRole? userRole}) async {
    _activeUserRole = userRole ?? _activeUserRole;

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final statsMap = await _ticketService.getTicketStats(userRole: _activeUserRole);
      _stats = statsMap;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<TicketModel?> createTicket({
    required String title,
    required String category,
    required String priority,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ticket = await _ticketService.createTicket(
        title: title,
        category: category,
        priority: priority,
        description: description,
      );
      
      _isLoading = false;
      if (ticket != null) {
        // Reload ticket list & stats
        await Future.wait([
          loadTickets(silent: true),
          loadStats(silent: true),
        ]);
      }
      notifyListeners();
      return ticket;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      final success = await _ticketService.updateTicketStatus(ticketId, newStatus);
      if (success) {
        await Future.wait([
          loadTickets(silent: true),
          loadStats(silent: true),
        ]);
      }
      return success;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  Future<bool> acceptTicket(String ticketId) async {
    try {
      final success = await _ticketService.acceptTicket(ticketId);
      if (success) {
        await Future.wait([
          loadTickets(silent: true),
          loadStats(silent: true),
        ]);
      }
      return success;
    } catch (e) {
      print('Error accepting ticket: $e');
      return false;
    }
  }

  Future<bool> finishTicket(String ticketId) async {
    try {
      final success = await _ticketService.finishTicket(ticketId);
      if (success) {
        await Future.wait([
          loadTickets(silent: true),
          loadStats(silent: true),
        ]);
      }
      return success;
    } catch (e) {
      print('Error finishing ticket: $e');
      return false;
    }
  }

  Future<bool> assignTicket(String ticketId, String assigneeId) async {
    try {
      final success = await _ticketService.assignTicket(ticketId, assigneeId);
      if (success) {
        await Future.wait([
          loadTickets(silent: true),
          loadStats(silent: true),
        ]);
      }
      return success;
    } catch (e) {
      print('Error assigning ticket: $e');
      return false;
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    try {
      final success = await _ticketService.deleteTicket(ticketId);
      if (success) {
        await Future.wait([
          loadTickets(silent: true),
          loadStats(silent: true),
        ]);
      }
      return success;
    } catch (e) {
      print('Error deleting ticket: $e');
      return false;
    }
  }

  void startPeriodicFetch() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadTickets(silent: true);
      loadStats(silent: true);
    });
  }

  void stopPeriodicFetch() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    stopPeriodicFetch();
    super.dispose();
  }
}
