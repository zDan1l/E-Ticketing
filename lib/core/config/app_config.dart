import 'dart:io' show Platform;

/// Application Configuration
/// Base URL and other configuration settings for the app
class AppConfig {
  // Base API URL - Read from environment or use default
  // For development, defaults to localhost
  // In production, this should be set via environment variable
  //
  // For Android Emulator: Use 10.0.2.2 instead of localhost
  // For iOS Simulator: localhost works fine
  // For Physical Device: Use your computer's IP address
  // For Desktop (Windows/Mac/Linux): localhost works fine
  // For Web: localhost works fine
  static String get baseUrl {
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

    // Otherwise, use platform-specific default
    // Safely check platform to avoid "unsupported operation" errors
    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 for localhost
        // For physical Android device, user should set API_BASE_URL via --dart-define
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        // iOS Simulator can use localhost
        // For physical iOS device, user should set API_BASE_URL via --dart-define
        return 'http://localhost:3000';
      }
      // For Desktop (Windows/Mac/Linux) - localhost works fine
      // For Web in browser - need to use actual IP if running on different device
      return 'http://localhost:3000';
    } catch (e) {
      // Fallback for platforms that don't support Platform (like web)
      // Web on same machine: localhost works
      // Web on different device: user must set API_BASE_URL via --dart-define
      return 'http://localhost:3000';
    }
  }

  // API Base URL (for compatibility)
  static String get apiBaseUrl {
    // Check if environment variable is set
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      String url = envBaseUrl;
      if (!url.endsWith('/api') && !url.endsWith('/api/')) {
        url = url.endsWith('/') ? '${url}api' : '$url/api';
      }
      return url;
    }

    // Otherwise, use platform-specific default
    // Safely check platform to avoid "unsupported operation" errors
    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 for localhost
        // For physical Android device, user should set API_BASE_URL via --dart-define
        return 'http://10.0.2.2:3000/api';
      } else if (Platform.isIOS) {
        // iOS Simulator can use localhost
        // For physical iOS device, user should set API_BASE_URL via --dart-define
        return 'http://localhost:3000/api';
      }
      // For Desktop (Windows/Mac/Linux) - localhost works fine
      // For Web in browser - need to use actual IP if running on different device
      return 'http://localhost:3000/api';
    } catch (e) {
      // Fallback for platforms that don't support Platform (like web)
      // Web on same machine: localhost works
      // Web on different device: user must set API_BASE_URL via --dart-define
      return 'http://localhost:3000/api';
    }
  }

  // API Endpoints
  static const String authPath = '/auth';
  static const String ticketsPath = '/tickets';
  static const String usersPath = '/users';
  static const String notificationsPath = '/notifications';
  static const String commentsPath = '/comments';

  // Main API base URL with /api prefix
  static String get _apiBaseUrl {
    // Check if environment variable is set
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      String url = envBaseUrl;
      if (!url.endsWith('/api') && !url.endsWith('/api/')) {
        url = url.endsWith('/') ? '${url}api' : '$url/api';
      }
      return url;
    }

    // Otherwise, use platform-specific default
    // Safely check platform to avoid "unsupported operation" errors
    try {
      if (Platform.isAndroid) {
        // Android Emulator uses 10.0.2.2 for localhost
        // For physical Android device, user should set API_BASE_URL via --dart-define
        return 'http://10.0.2.2:3000/api';
      } else if (Platform.isIOS) {
        // iOS Simulator can use localhost
        // For physical iOS device, user should set API_BASE_URL via --dart-define
        return 'http://localhost:3000/api';
      }
      // For Desktop (Windows/Mac/Linux) - localhost works fine
      // For Web in browser - need to use actual IP if running on different device
      return 'http://localhost:3000/api';
    } catch (e) {
      // Fallback for platforms that don't support Platform (like web)
      // Web on same machine: localhost works
      // Web on different device: user must set API_BASE_URL via --dart-define
      return 'http://localhost:3000/api';
    }
  }

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
