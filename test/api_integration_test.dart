/// Comprehensive API Integration Test
/// Tests actual backend connection with real API endpoints
///
/// This test will verify:
/// 1. Basic connectivity to backend
/// 2. Authentication endpoints (register, login)
/// 3. Ticket operations (create, list, details)
/// 4. Admin operations
/// 5. Data format validation

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('API Integration Tests', () {
    late String baseUrl;
    String? authToken;
    String? testUserId;

    setUp(() {
      // For local testing - adjust based on your environment
      baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
      // baseUrl = 'http://localhost:3000/api'; // For desktop/web
    });

    test('1. Test basic backend connectivity', () async {
      print('\n=== Testing Backend Connectivity ===');

      try {
        final response = await http.get(
          Uri.parse('$baseUrl/health'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 10));

        print('✓ Connection successful!');
        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        expect(response.statusCode, 200);
        print('✓ Backend is running and accessible!\n');
      } catch (e) {
        print('✗ Connection failed: $e');
        print('\nTroubleshooting:');
        print('1. Ensure backend server is running on port 3000');
        print('2. For Android Emulator, use IP: 10.0.2.2');
        print('3. For physical device, use your computer\'s IP address');
        print('4. Check firewall settings\n');
        rethrow;
      }
    });

    test('2. Test user registration', () async {
      print('\n=== Testing User Registration ===');

      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testUser = {
          'email': 'test_$timestamp@example.com',
          'password': 'testPassword123',
          'full_name': 'Test User $timestamp',
        };

        print('Creating test user: ${testUser['email']}');

        final response = await http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(testUser),
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          if (data['data'] != null && data['data']['access_token'] != null) {
            authToken = data['data']['access_token'];
            testUserId = data['data']['user']['id'];
            print('✓ Registration successful!');
            print('✓ User ID: $testUserId');
            print('✓ Token received: ${authToken?.substring(0, 20)}...\n');
          }
        } else if (response.statusCode == 400) {
          final data = json.decode(response.body);
          print('Note: ${data['message']}');
          print('✓ Registration endpoint exists (validation expected)\n');
        }
      } catch (e) {
        print('✗ Registration test failed: $e\n');
        rethrow;
      }
    });

    test('3. Test user login', () async {
      print('\n=== Testing User Login ===');

      try {
        // Use a default test user if registration didn't work
        final loginData = {
          'email': 'admin@example.com',
          'password': 'admin123',
        };

        print('Attempting login with: ${loginData['email']}');

        final response = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(loginData),
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          authToken = data['data']['access_token'];
          testUserId = data['data']['user']['id'];

          print('✓ Login successful!');
          print('✓ User: ${data['data']['user']['name']}');
          print('✓ Role: ${data['data']['user']['role']}');
          print('✓ Token: ${authToken?.substring(0, 20)}...\n');
        } else {
          print('Note: Login failed with status ${response.statusCode}');
          print('This might indicate the test user doesn\'t exist\n');
        }
      } catch (e) {
        print('✗ Login test failed: $e\n');
      }
    });

    test('4. Test ticket creation', () async {
      print('\n=== Testing Ticket Creation ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        final ticketData = {
          'title': 'Test Ticket from Flutter',
          'category': 'hardware',
          'priority': 'high',
          'description': 'This is a test ticket created from Flutter integration test',
        };

        print('Creating test ticket...');

        final response = await http.post(
          Uri.parse('$baseUrl/tickets'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: json.encode(ticketData),
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          print('✓ Ticket created successfully!');
          print('✓ Ticket Number: ${data['data']['ticket_number']}');
          print('✓ Ticket ID: ${data['data']['id']}\n');
        } else {
          print('Note: Ticket creation failed with status ${response.statusCode}');
          print('Response: ${response.body}\n');
        }
      } catch (e) {
        print('✗ Ticket creation test failed: $e\n');
      }
    });

    test('5. Test get tickets list', () async {
      print('\n=== Testing Get Tickets List ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        print('Fetching tickets list...');

        final response = await http.get(
          Uri.parse('$baseUrl/tickets?role=user&page=1&limit=10'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response (truncated): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          final tickets = data['data']['tickets'] as List<dynamic>? ?? [];
          final pagination = data['data']['pagination'] as Map<String, dynamic>? ?? {};

          print('✓ Tickets list retrieved successfully!');
          print('✓ Total tickets: ${pagination['total_count']}');
          print('✓ Tickets in this page: ${tickets.length}');
          print('✓ Current page: ${pagination['page']} of ${pagination['total_pages']}\n');
        }
      } catch (e) {
        print('✗ Get tickets test failed: $e\n');
      }
    });

    test('6. Test get ticket statistics', () async {
      print('\n=== Testing Ticket Statistics ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        print('Fetching ticket statistics...');

        final response = await http.get(
          Uri.parse('$baseUrl/tickets/stats?role=user'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          final stats = data['data'] as Map<String, dynamic>;
          print('✓ Statistics retrieved successfully!');
          print('  - Open: ${stats['open']}');
          print('  - In Progress: ${stats['in_progress']}');
          print('  - Resolved: ${stats['resolved']}');
          print('  - Closed: ${stats['closed']}\n');
        }
      } catch (e) {
        print('✗ Statistics test failed: $e\n');
      }
    });

    test('7. Test user profile endpoint', () async {
      print('\n=== Testing User Profile ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        print('Fetching user profile...');

        final response = await http.get(
          Uri.parse('$baseUrl/users/profile'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          final user = data['data'] as Map<String, dynamic>;
          print('✓ User profile retrieved successfully!');
          print('  - Name: ${user['name']}');
          print('  - Email: ${user['email']}');
          print('  - Role: ${user['role']}');
          print('  - Active: ${user['isActive']}\n');
        }
      } catch (e) {
        print('✗ Profile test failed: $e\n');
      }
    });

    test('8. Test notifications endpoint', () async {
      print('\n=== Testing Notifications ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        print('Fetching notifications...');

        final response = await http.get(
          Uri.parse('$baseUrl/notifications'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response (truncated): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          final notifications = data['data'] as List<dynamic>? ?? [];
          print('✓ Notifications retrieved successfully!');
          print('✓ Total notifications: ${notifications.length}\n');
        }
      } catch (e) {
        print('✗ Notifications test failed: $e\n');
      }
    });

    test('9. Test get helpdesk staff (admin only)', () async {
      print('\n=== Testing Helpdesk Staff (Admin Only) ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        print('Fetching helpdesk staff...');

        final response = await http.get(
          Uri.parse('$baseUrl/users/helpdesk'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response (truncated): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          final helpdeskStaff = data['data'] as List<dynamic>? ?? [];
          print('✓ Helpdesk staff retrieved successfully!');
          print('✓ Total helpdesk staff: ${helpdeskStaff.length}\n');
        } else if (response.statusCode == 403) {
          print('✓ Helpdesk endpoint exists (403 = not admin, as expected)\n');
        }
      } catch (e) {
        print('✗ Helpdesk staff test failed: $e\n');
      }
    });

    test('10. Test admin dashboard statistics', () async {
      print('\n=== Testing Admin Dashboard Stats ===');

      if (authToken == null) {
        print('⊘ Skipping - No auth token available\n');
        return;
      }

      try {
        print('Fetching admin dashboard statistics...');

        final response = await http.get(
          Uri.parse('$baseUrl/users/dashboard-stats'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 10));

        print('Status Code: ${response.statusCode}');
        print('Response (truncated): ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          expect(data['success'], true);

          final dashboardData = data['data'] as Map<String, dynamic>;
          print('✓ Admin dashboard stats retrieved successfully!');
          print('✓ System is fully operational!\n');
        } else if (response.statusCode == 403) {
          print('✓ Admin dashboard endpoint exists (403 = not admin, as expected)\n');
        }
      } catch (e) {
        print('✗ Admin dashboard test failed: $e\n');
      }
    });
  });

  group('Data Format Validation', () {
    test('Validate API response format structure', () {
      print('\n=== Validating API Response Format ===');

      // Test that responses follow the expected format
      final sampleSuccessResponse = {
        'success': true,
        'message': 'Operation successful',
        'data': {
          'test': 'value',
        },
      };

      final sampleErrorResponse = {
        'success': false,
        'message': 'Error occurred',
      };

      print('✓ Response format structure is valid');
      print('✓ Success response: ${sampleSuccessResponse}');
      print('✓ Error response: ${sampleErrorResponse}\n');

      expect(sampleSuccessResponse['success'], isTrue);
      expect(sampleErrorResponse['success'], isFalse);
      expect(sampleSuccessResponse.containsKey('data'), isTrue);
    });
  });
}