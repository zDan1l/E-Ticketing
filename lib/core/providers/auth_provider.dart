import 'package:flutter/foundation.dart';
import '../../services/auth_service.dart';
import '../../models/role_model.dart';

/// AuthProvider - Manages authentication state
/// Wraps AuthService and provides reactive state updates
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Current user state
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get currentUserId => _authService.currentUserId;
  String? get currentUserEmail => _authService.currentUserEmail;
  UserRole? get currentUserRole => _authService.currentUserRole;

  /// Initialize auth provider - load saved user session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _authService.initialize();
    _currentUser = _authService.currentUser;

    _isLoading = false;
    notifyListeners();
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (result['success'] == true) {
        _currentUser = _authService.currentUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String?;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error signing up: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        _currentUser = _authService.currentUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String?;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error signing in: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.signOut();

    if (result['success'] == true) {
      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.resetPassword(email);

    _isLoading = false;
    if (result['success'] == false) {
      _errorMessage = result['message'] as String?;
    }
    notifyListeners();
    return result['success'] == true;
  }

  /// Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    if (result['success'] == false) {
      _errorMessage = result['message'] as String?;
    }
    notifyListeners();
    return result['success'] == true;
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? avatar,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.updateProfile(
      fullName: fullName,
      avatar: avatar,
    );

    if (result['success'] == true) {
      _currentUser = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Upload profile avatar
  Future<bool> uploadAvatar(dynamic file) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.uploadAvatar(file);

    if (result['success'] == true) {
      _currentUser = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete profile avatar
  Future<bool> deleteAvatar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.deleteAvatar();

    if (result['success'] == true) {
      _currentUser = _authService.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String?;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    await _authService.refreshUserData();
    _currentUser = _authService.currentUser;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}