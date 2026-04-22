class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final String? ticketId;
  final String? ticketNumber;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    this.ticketId,
    this.ticketNumber,
    required this.createdAt,
  });
}
