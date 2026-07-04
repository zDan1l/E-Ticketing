import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/config/app_config.dart';
import '../core/config/http_client.dart';
import '../models/role_model.dart';

/// Authentication Service
/// Handles all authentication operations using REST API
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpClient _httpClient = HttpClient();

  // Current user state
  UserModel? _currentUser;

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _accessToken != null;

  // Get access token
  String? _accessToken;

  // Get current user ID
  String? get currentUserId => _currentUser?.id;

  // Get current user email
  String? get currentUserEmail => _currentUser?.email;

  // Get current user role
  UserRole? get currentUserRole => _currentUser?.role;

  /// Initialize auth service - try to load saved user from local storage
  Future<void> initialize() async {
    await _loadSavedUser();
  }

  /// Load saved user from SharedPreferences
  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(AppConfig.keyAccessToken);
      final userId = prefs.getString(AppConfig.keyUserId);
      final userRole = prefs.getString(AppConfig.keyUserRole);
      final userName = prefs.getString(AppConfig.keyUserName);
      final userEmail = prefs.getString(AppConfig.keyUserEmail);
      final userAvatar = prefs.getString(AppConfig.keyUserAvatar);

      if (accessToken != null && userId != null && userName != null) {
        _accessToken = accessToken;
        _currentUser = UserModel(
          id: userId,
          name: userName,
          email: userEmail ?? '',
          avatar: userAvatar ?? userName.substring(0, 1).toUpperCase(),
          role: UserRole.fromString(userRole ?? 'user'),
        );
        _httpClient.setAccessToken(accessToken);
      }
    } catch (e) {
      print('Error loading saved user: $e');
    }
  }

  /// Save user session to SharedPreferences
  Future<void> _saveUserSession({
    required String accessToken,
    required String? refreshToken,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.keyAccessToken, accessToken);
      if (refreshToken != null) {
        await prefs.setString(AppConfig.keyRefreshToken, refreshToken);
      }
      await prefs.setString(AppConfig.keyUserId, user.id);
      await prefs.setString(AppConfig.keyUserRole, user.role.value);
      await prefs.setString(AppConfig.keyUserName, user.name);
      await prefs.setString(AppConfig.keyUserEmail, user.email);
      await prefs.setString(AppConfig.keyUserAvatar, user.avatar);
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  /// Clear user session from SharedPreferences
  Future<void> _clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.keyAccessToken);
      await prefs.remove(AppConfig.keyRefreshToken);
      await prefs.remove(AppConfig.keyUserId);
      await prefs.remove(AppConfig.keyUserRole);
      await prefs.remove(AppConfig.keyUserName);
      await prefs.remove(AppConfig.keyUserEmail);
      await prefs.remove(AppConfig.keyUserAvatar);
    } catch (e) {
      print('Error clearing user session: $e');
    }
  }

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _httpClient.post(
        '${AppConfig.authPath}/register',
        body: {
          'email': email,
          'password': password,
          'full_name': fullName ?? email.split('@')[0],
        },
        requireAuth: false,
      );

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final user = UserModel(
          id: userData['id'].toString(),
          name: userData['name'] as String? ?? fullName ?? email.split('@')[0],
          email: userData['email'] as String? ?? email,
          avatar: userData['avatar'] as String? ?? fullName?.substring(0, 1).toUpperCase() ?? 'U',
          role: UserRole.fromString(userData['role'] as String? ?? 'user'),
        );

        // Save session
        await _saveUserSession(
          accessToken: response['data']['access_token'] as String,
          refreshToken: response['data']['refresh_token'] as String?,
          user: user,
        );

        // Update state
        _accessToken = response['data']['access_token'] as String;
        _currentUser = user;
        _httpClient.setAccessToken(_accessToken);

        return {
          'success': true,
          'message': 'Account created successfully',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create account',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error signing up: ${e.toString()}',
      };
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.post(
        '${AppConfig.authPath}/login',
        body: {
          'email': email,
          'password': password,
        },
        requireAuth: false,
      );

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final user = UserModel(
          id: userData['id'].toString(),
          name: userData['name'] as String? ?? 'User',
          email: userData['email'] as String? ?? email,
          avatar: userData['avatar'] as String? ?? 'U',
          role: UserRole.fromString(userData['role'] as String? ?? 'user'),
        );

        // Save session
        await _saveUserSession(
          accessToken: response['data']['access_token'] as String,
          refreshToken: response['data']['refresh_token'] as String?,
          user: user,
        );

        // Update state
        _accessToken = response['data']['access_token'] as String;
        _currentUser = user;
        _httpClient.setAccessToken(_accessToken);

        return {
          'success': true,
          'message': 'Signed in successfully',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Invalid email or password',
        };
      }
    } on ApiException catch (e) {
      // Log detailed error information
      print('Login Error - Status: ${e.statusCode}, Message: ${e.message}');
      if (e.errors != null) {
        print('Validation Errors: ${e.errors}');
      }
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      print('Unexpected Login Error: ${e.toString()}');
      print('Error Type: ${e.runtimeType}');
      return {
        'success': false,
        'message': 'Error signing in: ${e.toString()}',
      };
    }
  }

  /// Sign out
  Future<Map<String, dynamic>> signOut() async {
    try {
      // Call logout endpoint if we have a token
      if (_accessToken != null) {
        try {
          await _httpClient.post('${AppConfig.authPath}/logout');
        } catch (e) {
          print('Error calling logout endpoint: $e');
          // Continue with local logout even if API call fails
        }
      }

      // Clear local session
      await _clearUserSession();
      _accessToken = null;
      _currentUser = null;
      _httpClient.clearAccessToken();

      return {
        'success': true,
        'message': 'Signed out successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error signing out: ${e.toString()}',
      };
    }
  }

  /// Send password reset email
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _httpClient.post(
        '${AppConfig.authPath}/forgot-password',
        body: {'email': email},
        requireAuth: false,
      );

      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending reset email: ${e.toString()}',
      };
    }
  }

  /// Update password
  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _httpClient.post(
        '${AppConfig.authPath}/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return {
        'success': true,
        'message': 'Password updated successfully',
      };
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating password: ${e.toString()}',
      };
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _httpClient.get('${AppConfig.usersPath}/profile');

      return response['data'] as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (avatar != null) body['avatar'] = avatar;

      final response = await _httpClient.patch(
        '${AppConfig.usersPath}/profile',
        body: body,
      );

      if (response['success'] == true) {
        // Update current user
        if (_currentUser != null) {
          _currentUser = UserModel(
            id: _currentUser!.id,
            name: fullName ?? _currentUser!.name,
            email: _currentUser!.email,
            avatar: avatar ?? _currentUser!.avatar,
            role: _currentUser!.role,
            isActive: _currentUser!.isActive,
          );

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          if (fullName != null) {
            await prefs.setString(AppConfig.keyUserName, fullName);
          }
          if (avatar != null) {
            await prefs.setString(AppConfig.keyUserAvatar, avatar);
          }
        }

        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update profile',
        };
      }
    } on ApiException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating profile: ${e.toString()}',
      };
    }
  }

  /// Upload profile avatar
  Future<Map<String, dynamic>> uploadAvatar(XFile file) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}${AppConfig.usersPath}/profile/avatar');
      final request = http.MultipartRequest('POST', uri);

      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      request.headers['Accept'] = 'application/json';

      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: file.name,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final Map<String, dynamic> responseData = _httpClient.parseResponse(responseBody);

      if (responseData['success'] == true) {
        final userData = responseData['data'] as Map<String, dynamic>;
        final newAvatar = userData['avatar'] as String;

        // Update current user locally
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(avatar: newAvatar);

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.keyUserAvatar, newAvatar);
        }

        return {
          'success': true,
          'message': 'Avatar updated successfully',
          'avatar': newAvatar,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to upload avatar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading avatar: ${e.toString()}',
      };
    }
  }

  /// Delete profile avatar
  Future<Map<String, dynamic>> deleteAvatar() async {
    try {
      final response = await _httpClient.delete('${AppConfig.usersPath}/profile/avatar');

      if (response['success'] == true) {
        final userData = response['data'] as Map<String, dynamic>;
        final newAvatar = userData['avatar'] as String;

        // Update current user locally
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(avatar: newAvatar);

          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.keyUserAvatar, newAvatar);
        }

        return {
          'success': true,
          'message': 'Avatar deleted successfully',
          'avatar': newAvatar,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete avatar',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting avatar: ${e.toString()}',
      };
    }
  }

  /// Refresh user data from API
  Future<void> refreshUserData() async {
    if (isAuthenticated) {
      await _loadSavedUser();
    }
  }
}
