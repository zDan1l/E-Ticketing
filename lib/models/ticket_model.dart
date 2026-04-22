class TicketModel {
  final String id;
  final String ticketNumber;
  final String title;
  final String category;
  final String priority;
  final String status;
  final String description;
  final String reporterName;
  final String reporterAvatar;
  final String? assigneeName;
  final String? assigneeAvatar;
  final int commentsCount;
  final int attachmentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.description,
    required this.reporterName,
    required this.reporterAvatar,
    this.assigneeName,
    this.assigneeAvatar,
    this.commentsCount = 0,
    this.attachmentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}

class TicketTimeline {
  final String action;
  final String status;
  final String description;
  final String actorName;
  final DateTime createdAt;

  TicketTimeline({
    required this.action,
    required this.status,
    required this.description,
    required this.actorName,
    required this.createdAt,
  });
}

class CommentModel {
  final String id;
  final String body;
  final String authorName;
  final String authorRole;
  final String authorAvatar;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.body,
    required this.authorName,
    required this.authorRole,
    required this.authorAvatar,
    required this.createdAt,
  });
}
