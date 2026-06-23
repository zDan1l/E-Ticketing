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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool? ?? false,
      ticketId: json['ticket_id']?.toString(),
      ticketNumber: json['ticket_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
