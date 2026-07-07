import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notifService = NotificationService();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _refreshTimer;
  bool _isInitialized = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationProvider() {
    _initLocalNotifications();
  }

  Future<void> _initLocalNotifications() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotificationsPlugin.initialize(initializationSettings);
      
      // Request permission for Android 13+
      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'eticketing_channel',
        'E-Ticketing Notifications',
        channelDescription: 'Notifications for ticket updates',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
      
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _localNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final notifs = await _notifService.getNotifications();
      final count = await _notifService.getUnreadNotificationsCount();

      // Check for new unread notifications to trigger local push alert
      if (_notifications.isNotEmpty && notifs.isNotEmpty) {
        final existingIds = _notifications.map((n) => n.id).toSet();
        for (var notif in notifs) {
          if (!notif.isRead && !existingIds.contains(notif.id)) {
            // Trigger local notification
            showLocalNotification(
              id: notif.id.hashCode,
              title: notif.title,
              body: notif.body,
              payload: notif.ticketId,
            );
          }
        }
      }

      _notifications = notifs;
      _unreadCount = count;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> markAsRead(String notifId) async {
    try {
      final success = await _notifService.markNotificationAsRead(notifId);
      if (success) {
        // Optimistic state update
        final index = _notifications.indexWhere((n) => n.id == notifId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            type: _notifications[index].type,
            title: _notifications[index].title,
            body: _notifications[index].body,
            ticketId: _notifications[index].ticketId,
            isRead: true,
            createdAt: _notifications[index].createdAt,
          );
          _unreadCount = (_unreadCount - 1).clamp(0, 999);
          notifyListeners();
        }
        // Force refresh data in background
        loadNotifications(silent: true);
      }
      return success;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _notifService.markAllAsRead();
      _isLoading = false;
      if (success) {
        _notifications = _notifications.map((n) => NotificationModel(
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          ticketId: n.ticketId,
          isRead: true,
          createdAt: n.createdAt,
        )).toList();
        _unreadCount = 0;
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNotification(String notifId) async {
    try {
      final success = await _notifService.deleteNotification(notifId);
      if (success) {
        _notifications.removeWhere((n) => n.id == notifId);
        // Refresh count from backend
        loadNotifications(silent: true);
      }
      return success;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  void startPeriodicFetch() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      loadNotifications(silent: true);
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
