import '../models/notification_model.dart';
import '../core/config/app_config.dart';
import '../core/config/http_client.dart';

/// Notification Service
/// Handles all notification operations using REST API
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final HttpClient _httpClient = HttpClient();

  /// Get notifications for current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _httpClient.get(AppConfig.notificationsPath);

      if (response['success'] == true) {
        final List<dynamic> notificationsJson = response['data'] as List<dynamic>? ?? [];
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _httpClient.patch(
        '${AppConfig.notificationsPath}/$notificationId/read',
      );

      return response['success'] == true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _httpClient.patch(
        '${AppConfig.notificationsPath}/mark-all-read',
      );

      return response['success'] == true;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _httpClient.get('${AppConfig.notificationsPath}/unread-count');

      if (response['success'] == true) {
        return response['data'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _httpClient.delete(
        '${AppConfig.notificationsPath}/$notificationId',
      );

      return response['success'] == true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}
