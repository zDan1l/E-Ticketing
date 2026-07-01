class TicketModel {
  final String id;
  final String ticketNumber;
  final String title;
  final String category;
  final String priority;
  final String status;
  final String description;
  final String reporterId;
  final String reporterName;
  final String reporterAvatar;
  final String? assigneeId;
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
    required this.reporterId,
    required this.reporterName,
    required this.reporterAvatar,
    this.assigneeId,
    this.assigneeName,
    this.assigneeAvatar,
    this.commentsCount = 0,
    this.attachmentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAssigned => assigneeId != null;
  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get isReopened => status == 'reopened';

  // JSON serialization for API integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketNumber': ticketNumber,
      'title': title,
      'category': category,
      'priority': priority,
      'status': status,
      'description': description,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterAvatar': reporterAvatar,
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'assigneeAvatar': assigneeAvatar,
      'commentsCount': commentsCount,
      'attachmentsCount': attachmentsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      reporterId: json['reporter_id'] as String,
      reporterName: json['reporter_name'] as String,
      reporterAvatar: json['reporter_avatar'] as String,
      assigneeId: json['assignee_id'] as String?,
      assigneeName: json['assignee_name'] as String?,
      assigneeAvatar: json['assignee_avatar'] as String?,
      commentsCount: json['comments_count'] as int? ?? 0,
      attachmentsCount: json['attachments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  TicketModel copyWith({
    String? id,
    String? ticketNumber,
    String? title,
    String? category,
    String? priority,
    String? status,
    String? description,
    String? reporterId,
    String? reporterName,
    String? reporterAvatar,
    String? assigneeId,
    String? assigneeName,
    String? assigneeAvatar,
    int? commentsCount,
    int? attachmentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketModel(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      description: description ?? this.description,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reporterAvatar: reporterAvatar ?? this.reporterAvatar,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatar: assigneeAvatar ?? this.assigneeAvatar,
      commentsCount: commentsCount ?? this.commentsCount,
      attachmentsCount: attachmentsCount ?? this.attachmentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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

class AttachmentModel {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final DateTime createdAt;

  AttachmentModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.createdAt,
  });

  String get fileSizeDisplay {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isImage => mimeType.startsWith('image/');
  String get fileExtension => fileName.split('.').last.toLowerCase();

  /// Get full URL for downloading/viewing this attachment
  String get url {
    if (filePath.startsWith('http')) {
      return filePath;
    }
    // In production, this should use: AttachmentService().getFileUrl(filePath)
    // For now, return the relative path and let the service handle it
    return filePath;
  }
}
