import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

/// Application Configuration
/// Base URL and other configuration settings for the app
class AppConfig {
  static String _activeBaseUrl = '';
  static String _activeApiBaseUrl = '';

  /// Check if ngrok is online and reachable, otherwise fall back to localhost defaults.
  static Future<void> findActiveBaseUrl() async {
    const ngrokUrl = 'https://celena-draughtiest-marylee.ngrok-free.dev';
    
    try {
      // Perform a quick connectivity test to ngrok endpoint (e.g. login endpoint)
      final uri = Uri.parse('$ngrokUrl/api/auth/login');
      final response = await http.get(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
      ).timeout(const Duration(milliseconds: 2000));

      // Any HTTP response below 500 status code means the server is reachable and active.
      if (response.statusCode >= 200 && response.statusCode < 500) {
        _activeBaseUrl = ngrokUrl;
        _activeApiBaseUrl = '$ngrokUrl/api';
        print('🔌 Connected to ngrok endpoint: $ngrokUrl');
        return;
      }
    } catch (e) {
      print('🔌 ngrok endpoint check failed: $e');
    }

    // Fallback to defaults
    _activeBaseUrl = _getDefaultBaseUrl();
    _activeApiBaseUrl = _getDefaultApiBaseUrl();
    print('🔌 Fallback to localhost endpoint: $_activeBaseUrl');
  }

  static String _getDefaultBaseUrl() {
    // Check if environment variable is set
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      String url = envBaseUrl;
      if (url.endsWith('/api/')) {
        url = url.substring(0, url.length - 5);
      } else if (url.endsWith('/api')) {
        url = url.substring(0, url.length - 4);
      }
      return url;
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 for localhost
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        // iOS Simulator can use localhost
        return 'http://localhost:3000';
      }
      return 'http://localhost:3000';
    } catch (e) {
      return 'http://localhost:3000';
    }
  }

  static String _getDefaultApiBaseUrl() {
    // Check if environment variable is set
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      String url = envBaseUrl;
      if (!url.endsWith('/api') && !url.endsWith('/api/')) {
        url = url.endsWith('/') ? '${url}api' : '$url/api';
      }
      return url;
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      } else if (Platform.isIOS) {
        return 'http://localhost:3000/api';
      }
      return 'http://localhost:3000/api';
    } catch (e) {
      return 'http://localhost:3000/api';
    }
  }

  // Base API URL - Read from environment or use default
  static String get baseUrl {
    if (_activeBaseUrl.isEmpty) {
      _activeBaseUrl = _getDefaultBaseUrl();
    }
    return _activeBaseUrl;
  }

  // API Base URL (for compatibility)
  static String get apiBaseUrl {
    if (_activeApiBaseUrl.isEmpty) {
      _activeApiBaseUrl = _getDefaultApiBaseUrl();
    }
    return _activeApiBaseUrl;
  }

  // API Endpoints
  static const String authPath = '/auth';
  static const String ticketsPath = '/tickets';
  static const String usersPath = '/users';
  static const String notificationsPath = '/notifications';
  static const String commentsPath = '/comments';

  // Main API base URL with /api prefix (for compatibility)
  static String get _apiBaseUrl => apiBaseUrl;

  // Full endpoint URLs
  static String get authUrl => '$apiBaseUrl$authPath';
  static String get ticketsUrl => '$apiBaseUrl$ticketsPath';
  static String get usersUrl => '$apiBaseUrl$usersPath';
  static String get notificationsUrl => '$apiBaseUrl$notificationsPath';
  static String get commentsUrl => '$apiBaseUrl$commentsPath';

  // Request timeout in milliseconds
  // Reduced timeout to prevent app from hanging
  static const int connectionTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 10000; // 10 seconds

  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserAvatar = 'user_avatar';
}
