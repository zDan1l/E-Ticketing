import '../models/role_model.dart';
import '../core/config/app_config.dart';
import '../core/config/http_client.dart';

/// User API Service
/// Handles user-related operations using REST API
class UserApiService {
  static final UserApiService _instance = UserApiService._internal();
  factory UserApiService() => _instance;
  UserApiService._internal();

  final HttpClient _httpClient = HttpClient();

  /// Get all helpdesk staff
  Future<List<UserModel>> getHelpdeskStaff() async {
    try {
      print('📡 Fetching helpdesk staff from ${AppConfig.usersPath}/helpdesk');

      final response = await _httpClient.get(
        '${AppConfig.usersPath}/helpdesk',
      );

      print('📡 Helpdesk response: ${response['success']}, data: ${response['data']}');

      if (response['success'] == true) {
        final List<dynamic> usersJson = response['data'] as List<dynamic>? ?? [];

        print('📡 Parsing ${usersJson.length} helpdesk users');

        final users = usersJson.map((json) {
          final user = json as Map<String, dynamic>;
          return UserModel(
            id: user['id']?.toString() ?? '',
            name: user['name'] as String? ?? 'Unknown',
            email: user['email'] as String? ?? '',
            avatar: user['avatar'] as String? ?? '?',
            role: UserRole.fromString(user['role'] as String? ?? 'helpdesk'),
            isActive: user['is_active'] as bool? ?? true,
          );
        }).toList();

        print('📡 Successfully loaded ${users.length} helpdesk staff');
        return users;
      } else {
        print('❌ Failed to get helpdesk staff: ${response['message']}');
        return [];
      }
    } catch (e) {
      print('❌ Exception getting helpdesk staff: $e');
      return [];
    }
  }

  /// Get helpdesk by ID
  Future<UserModel?> getHelpdeskById(String helpdeskId) async {
    try {
      final response = await _httpClient.get('${AppConfig.usersPath}/$helpdeskId');

      if (response['success'] == true) {
        final user = response['data'] as Map<String, dynamic>;
        return UserModel(
          id: user['id']?.toString() ?? '',
          name: user['name'] as String? ?? 'Unknown',
          email: user['email'] as String? ?? '',
          avatar: user['avatar'] as String? ?? '?',
          role: UserRole.fromString(user['role'] as String? ?? 'helpdesk'),
          isActive: user['is_active'] as bool? ?? true,
        );
      }

      return null;
    } catch (e) {
      print('Error getting helpdesk by ID: $e');
      return null;
    }
  }

  /// Get all users (admin only) with pagination and filters
  Future<Map<String, dynamic>> getAllUsers({
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        if (role != null) 'role': role,
        if (isActive != null) 'is_active': isActive.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '${AppConfig.usersPath}/all',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;

        // Handle paginated format
        if (data != null && data.containsKey('users')) {
          final List<dynamic> usersJson = data['users'] as List<dynamic>? ?? [];
          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

          return {
            'users': usersJson.map((json) {
              final user = json as Map<String, dynamic>;
              return UserModel(
                id: user['id']?.toString() ?? '',
                name: user['name'] as String? ?? 'Unknown',
                email: user['email'] as String? ?? '',
                avatar: user['avatar'] as String? ?? '?',
                role: UserRole.fromString(user['role'] as String? ?? 'user'),
                isActive: user['isActive'] as bool? ?? true,
              );
            }).toList(),
            'pagination': pagination,
          };
        }

        // Handle legacy format (backward compatibility)
        final List<dynamic> usersJson = data != null
            ? (data as List<dynamic>? ?? [])
            : [];

        return {
          'users': usersJson.map((json) {
            final user = json as Map<String, dynamic>;
            return UserModel(
              id: user['id']?.toString() ?? '',
              name: user['name'] as String? ?? 'Unknown',
              email: user['email'] as String? ?? '',
              avatar: user['avatar'] as String? ?? '?',
              role: UserRole.fromString(user['role'] as String? ?? 'user'),
              isActive: user['isActive'] as bool? ?? true,
            );
          }).toList(),
          'pagination': null,
        };
      }

      return {'users': <UserModel>[], 'pagination': null};
    } catch (e) {
      print('Error getting all users: $e');
      return {'users': <UserModel>[], 'pagination': null};
    }
  }

  /// Update user status (admin only)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      final response = await _httpClient.patch(
        '${AppConfig.usersPath}/$userId/status',
        body: {'is_active': isActive},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  /// Update user role (admin only)
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      final response = await _httpClient.patch(
        '${AppConfig.usersPath}/$userId/role',
        body: {'role': newRole},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error updating user role: $e');
      return false;
    }
  }

  /// Get admin dashboard statistics (admin only)
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final response = await _httpClient.get('${AppConfig.usersPath}/dashboard-stats');

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      }

      return null;
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return null;
    }
  }

  /// Get user activity logs (admin only)
  Future<Map<String, dynamic>?> getActivityLogs({
    String? userId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        if (userId != null) 'user_id': userId,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '${AppConfig.usersPath}/activity-logs',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;

        // Handle paginated format
        if (data != null && data.containsKey('activities')) {
          final List<dynamic> activitiesJson = data['activities'] as List<dynamic>? ?? [];
          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

          return {
            'activities': activitiesJson.map((json) {
              final activity = json as Map<String, dynamic>;
              return {
                'id': activity['id']?.toString() ?? '',
                'action': activity['action'] as String? ?? 'unknown',
                'description': activity['description'] as String? ?? '',
                'actor_name': activity['actor_name'] as String? ?? 'Unknown',
                'ticket_number': activity['ticket_number'] as String?,
                'created_at': DateTime.tryParse(activity['created_at'] as String? ?? '') ?? DateTime.now(),
              };
            }).toList(),
            'pagination': pagination,
          };
        }
      }

      return null;
    } catch (e) {
      print('Error getting activity logs: $e');
      return null;
    }
  }

  /// Create new user (admin only)
  Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _httpClient.post(
        AppConfig.usersPath,
        body: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return {
        'success': response['success'] == true,
        'message': response['message'] as String? ?? '',
        'user': response['success'] == true && response['data'] != null
            ? UserModel(
                id: (response['data'] as Map<String, dynamic>)['id']?.toString() ?? '',
                name: (response['data'] as Map<String, dynamic>)['name'] as String? ?? '',
                email: (response['data'] as Map<String, dynamic>)['email'] as String? ?? '',
                avatar: (response['data'] as Map<String, dynamic>)['avatar'] as String? ?? '?',
                role: UserRole.fromString((response['data'] as Map<String, dynamic>)['role'] as String? ?? 'user'),
                isActive: (response['data'] as Map<String, dynamic>)['isActive'] as bool? ?? true,
              )
            : null,
      };
    } catch (e) {
      print('Error creating user: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  /// Update user name and/or email (admin only)
  Future<Map<String, dynamic>> updateUser(
    String userId, {
    String? fullName,
    String? email,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (email != null) body['email'] = email;

      final response = await _httpClient.patch(
        '${AppConfig.usersPath}/$userId',
        body: body,
      );
      return {
        'success': response['success'] == true,
        'message': response['message'] as String? ?? '',
      };
    } catch (e) {
      print('Error updating user: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }

  /// Delete user (admin only) — returns 409 if user has tickets
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      final response = await _httpClient.delete(
        '${AppConfig.usersPath}/$userId',
      );
      return {
        'success': response['success'] == true,
        'message': response['message'] as String? ?? '',
      };
    } catch (e) {
      print('Error deleting user: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi'};
    }
  }
}
