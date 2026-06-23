import 'package:flutter/material.dart';
import '../../../../shared/components/components.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/ticket_service.dart';
import '../../../../services/user_api_service.dart';
import '../../../../services/notification_service.dart';

/// Connection Test Page
/// Provides a simple interface to test backend connectivity and API endpoints
class ConnectionTestPage extends StatefulWidget {
  const ConnectionTestPage({super.key});

  @override
  State<ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<ConnectionTestPage> {
  final AuthService _authService = AuthService();
  final TicketService _ticketService = TicketService();
  final UserApiService _userApiService = UserApiService();

  bool _isTesting = false;
  List<TestResult> _results = [];
  String? _overallStatus;

  Future<void> _runConnectionTests() async {
    setState(() {
      _isTesting = true;
      _results = [];
      _overallStatus = 'Testing...';
    });

    // Test 1: Basic Connectivity
    await _testBasicConnectivity();

    // Test 2: Authentication
    await _testAuthentication();

    // Test 3: Ticket Operations
    await _testTicketOperations();

    // Test 4: User Management (Admin)
    await _testUserManagement();

    // Test 5: Notifications
    await _testNotifications();

    setState(() {
      _isTesting = false;
      _overallStatus = _getOverallStatus();
    });
  }

  Future<void> _testBasicConnectivity() async {
    try {
      // Use a simple HTTP call to test connectivity
      final response = await _authService.signIn(
        email: 'test@connection.com',
        password: 'test123',
      );

      _addResult('Basic Connectivity', false, 'Server is running (login endpoint exists)');
    } catch (e) {
      if (e.toString().contains('TimeoutException') || e.toString().contains('Connection refused')) {
        _addResult('Basic Connectivity', false, 'Backend server not running on ${AppConfig.apiBaseUrl}');
      } else {
        _addResult('Basic Connectivity', false, 'Server error: ${e.toString()}');
      }
    }
  }

  Future<void> _testAuthentication() async {
    try {
      // Test login with provided credentials
      final response = await _authService.signIn(
        email: 'admin@company.com',
        password: 'admin123',
      );

      if (response['success'] == true && _authService.currentUser != null) {
        _addResult('Authentication', true, 'Login successful as ${_authService.currentUser?.role.value}');
      } else {
        _addResult('Authentication', false, 'Login failed - check credentials');
      }
    } catch (e) {
      _addResult('Authentication', false, 'Auth error: ${e.toString()}');
    }
  }

  Future<void> _testTicketOperations() async {
    if (_authService.currentUser == null) {
      _addResult('Ticket Operations', false, 'Skipped - requires authentication');
      return;
    }

    try {
      // Test getting ticket statistics
      final stats = await _ticketService.getTicketStats(
        userRole: _authService.currentUserRole,
      );

      final totalTickets = (stats['open'] ?? 0) +
          (stats['in_progress'] ?? 0) +
          (stats['resolved'] ?? 0) +
          (stats['closed'] ?? 0);

      _addResult('Ticket Statistics', true, 'Retrieved $totalTickets tickets');
    } catch (e) {
      _addResult('Ticket Operations', false, 'Ticket ops error: ${e.toString()}');
    }
  }

  Future<void> _testUserManagement() async {
    if (_authService.currentUser?.role.value != 'ADMIN') {
      _addResult('User Management', false, 'Skipped - requires admin role');
      return;
    }

    try {
      // Test getting helpdesk staff
      final helpdesk = await _userApiService.getHelpdeskStaff();
      _addResult('User Management', true, 'Retrieved ${helpdesk.length} helpdesk staff');
    } catch (e) {
      _addResult('User Management', false, 'User management error: ${e.toString()}');
    }
  }

  Future<void> _testNotifications() async {
    if (_authService.currentUser == null) {
      _addResult('Notifications', false, 'Skipped - requires authentication');
      return;
    }

    try {
      // Create notification service instance to test
      final notificationService = NotificationService();
      final unreadCount = await notificationService.getUnreadNotificationsCount();
      _addResult('Notifications', true, 'Retrieved $unreadCount unread notifications');
    } catch (e) {
      _addResult('Notifications', false, 'Notifications error: ${e.toString()}');
    }
  }

  void _addResult(String testName, bool success, String message) {
    setState(() {
      _results.add(TestResult(
        name: testName,
        success: success,
        message: message,
        timestamp: DateTime.now(),
      ));
    });
  }

  String _getOverallStatus() {
    if (_results.isEmpty) return 'No tests completed';
    final successCount = _results.where((r) => r.success).length;
    final total = _results.length;

    if (successCount == total) {
      return '✓ All tests passed!';
    } else if (successCount == 0) {
      return '✗ All tests failed';
    } else {
      return '⚠ $successCount/$total tests passed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'API Connection Test',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current API Configuration
            StyledCard(
              padding: const EdgeInsets.all(16),
              glowColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _ConfigRow('Base URL', AppConfig.apiBaseUrl),
                  const SizedBox(height: 8),
                  _ConfigRow('Auth Path', '${AppConfig.apiBaseUrl}/auth'),
                  const SizedBox(height: 8),
                  _ConfigRow('Tickets Path', '${AppConfig.apiBaseUrl}/tickets'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Overall Status
            if (_overallStatus != null)
              StyledCard(
                padding: const EdgeInsets.all(16),
                glowColor: _overallStatus!.contains('✓') ? AppColors.successAccent : AppColors.error,
                child: Row(
                  children: [
                    Icon(
                      _overallStatus!.contains('✓') ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: _overallStatus!.contains('✓') ? AppColors.successAccent : AppColors.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _overallStatus!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_overallStatus != null) const SizedBox(height: 20),

            // Test Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ClayButton(
                text: _isTesting ? 'Testing Connection...' : 'Run Connection Tests',
                icon: _isTesting ? null : Icons.network_check_rounded,
                onPressed: _isTesting ? null : _runConnectionTests,
              ),
            ),
            const SizedBox(height: 24),

            // Test Results
            if (_results.isNotEmpty) ...[
              Text(
                'Test Results',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ..._results.map((result) => _ResultCard(result: result)),
              const SizedBox(height: 32),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 64,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Press the button above to test API connection',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tests will verify:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text('• Backend connectivity'),
                      Text('• Authentication flow'),
                      Text('• Ticket operations'),
                      Text('• User management'),
                      Text('• Notifications'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _ConfigRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          ':',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final TestResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return StyledCard(
      padding: const EdgeInsets.all(16),
      glowColor: result.success ? AppColors.successAccent : AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: result.success ? AppColors.successAccent : AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.success ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatTime(result.timestamp),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  return '${diff.inHours}h ago';
}

class TestResult {
  final String name;
  final bool success;
  final String message;
  final DateTime timestamp;

  TestResult({
    required this.name,
    required this.success,
    required this.message,
    required this.timestamp,
  });
}
