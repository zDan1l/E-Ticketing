import '../models/ticket_model.dart';
import '../models/role_model.dart';
import '../core/config/app_config.dart';
import '../core/config/http_client.dart';

/// Ticket Service
/// Handles all ticket operations using REST API
class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final HttpClient _httpClient = HttpClient();

  /// Get all tickets with pagination and filtering
  ///
  /// IMPORTANT: Backend MUST filter tickets based on authenticated user:
  /// - For role 'user': return only tickets where reporter_id == current_user_id
  /// - For role 'helpdesk': return only tickets where assignee_id == current_user_id
  /// - For role 'admin': return all tickets
  ///
  /// User ID should be extracted from JWT token on server, NOT from client params
  Future<Map<String, dynamic>> getTickets({
    UserRole? userRole,
    String? searchQuery,
    String? status,
    String? category,
    String? priority,
    String? assigneeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        if (userRole != null) 'role': userRole.value.toLowerCase(), // ✅ Send lowercase
        if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
        if (priority != null) 'priority': priority,
        if (assigneeId != null) 'assignee_id': assigneeId,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      print('🎫 TicketService: Fetching tickets with params: $queryParams');

      final response = await _httpClient.get(
        AppConfig.ticketsPath,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🎫 TicketService: Response success = ${response['success']}');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;

        // Handle v2.0.0 paginated format
        if (data != null && data.containsKey('tickets')) {
          final List<dynamic> ticketsJson = data['tickets'] as List<dynamic>? ?? [];
          final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

          print('🎫 TicketService: Paginated format, ${ticketsJson.length} tickets');

          return {
            'tickets': ticketsJson
                .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
                .toList(),
            'pagination': pagination,
          };
        }

        // Handle legacy format (backward compatibility)
        final List<dynamic> ticketsJson = data != null
            ? (data as List<dynamic>? ?? [])
            : (response['data'] as List<dynamic>? ?? []);

        print('🎫 TicketService: Legacy format, ${ticketsJson.length} tickets');

        return {
          'tickets': ticketsJson
              .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
              .toList(),
          'pagination': null,
        };
      }

      print('❌ TicketService: Response failed, returning empty list');
      return {'tickets': <TicketModel>[], 'pagination': null};
    } catch (e) {
      print('❌ TicketService: Error getting tickets: $e');
      return {'tickets': <TicketModel>[], 'pagination': null};
    }
  }

  /// Get a specific ticket by ID
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await _httpClient.get('${AppConfig.ticketsPath}/$ticketId');

      if (response['success'] == true) {
        return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error getting ticket: $e');
      return null;
    }
  }

  /// Create a new ticket
  Future<TicketModel?> createTicket({
    required String title,
    required String category,
    required String priority,
    required String description,
  }) async {
    try {
      print('🎫 TicketService: Creating ticket - $title');

      final response = await _httpClient.post(
        AppConfig.ticketsPath,
        body: {
          'title': title,
          'category': category,
          'priority': priority,
          'description': description,
        },
      );

      print('🎫 TicketService: Create response success = ${response['success']}');

      if (response['success'] == true) {
        final ticket = TicketModel.fromJson(response['data'] as Map<String, dynamic>);
        print('✅ TicketService: Ticket created successfully - ${ticket.ticketNumber}');
        return ticket;
      }

      print('❌ TicketService: Create ticket failed');
      return null;
    } catch (e) {
      print('❌ TicketService: Error creating ticket: $e');
      return null;
    }
  }

  /// Update ticket status
  Future<bool> updateTicketStatus(String ticketId, String newStatus) async {
    try {
      final response = await _httpClient.patch(
        '${AppConfig.ticketsPath}/$ticketId/status',
        body: {'status': newStatus},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error updating ticket status: $e');
      return false;
    }
  }

  /// Assign ticket to helpdesk
  Future<bool> assignTicket(String ticketId, String assigneeId) async {
    try {
      final response = await _httpClient.patch(
        '${AppConfig.ticketsPath}/$ticketId/assign',
        body: {'assignee_id': assigneeId},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error assigning ticket: $e');
      return false;
    }
  }

  /// Get ticket statistics
  Future<Map<String, int>> getTicketStats({UserRole? userRole}) async {
    try {
      final queryParams = userRole != null ? {'role': userRole.value.toLowerCase()} : null;

      print('📊 TicketService: Fetching stats with params: $queryParams');

      final response = await _httpClient.get(
        '${AppConfig.ticketsPath}/stats',
        queryParams: queryParams,
      );

      print('📊 TicketService: Stats response success = ${response['success']}');

      if (response['success'] == true) {
        final statsJson = response['data'] as Map<String, dynamic>?;
        if (statsJson != null) {
          print('📊 TicketService: Stats data = $statsJson');
          return statsJson.map((key, value) => MapEntry(key, value as int? ?? 0));
        }
      }

      print('❌ TicketService: Failed to get stats, returning defaults');
      return {
        'open': 0,
        'in_progress': 0,
        'resolved': 0,
        'closed': 0,
      };
    } catch (e) {
      print('❌ TicketService: Error getting stats: $e');
      return {
        'open': 0,
        'in_progress': 0,
        'resolved': 0,
        'closed': 0,
      };
    }
  }

  /// Get comments for a ticket
  Future<List<CommentModel>> getCommentsForTicket(String ticketId) async {
    try {
      final response = await _httpClient.get('${AppConfig.ticketsPath}/$ticketId/comments');

      if (response['success'] == true) {
        final List<dynamic> commentsJson = response['data'] as List<dynamic>? ?? [];
        return commentsJson.map((json) {
          final comment = json as Map<String, dynamic>;
          return CommentModel(
            id: comment['id']?.toString() ?? '',
            body: comment['body'] as String? ?? '',
            authorName: comment['author_name'] as String? ?? 'Unknown',
            authorRole: comment['author_role'] as String? ?? 'user',
            authorAvatar: comment['author_avatar'] as String? ?? '?',
            createdAt: DateTime.tryParse(comment['created_at'] as String? ?? '') ?? DateTime.now(),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  /// Add comment to ticket
  ///
  /// IMPORTANT: Backend MUST validate permissions:
  /// - For role 'user': can only comment on own tickets (reporter_id == current_user_id)
  /// - For role 'helpdesk': can only comment on assigned tickets (assignee_id == current_user_id)
  /// - For role 'admin': can comment on any ticket
  ///
  /// Return 403 Forbidden if validation fails
  Future<bool> addComment(String ticketId, String body) async {
    try {
      final response = await _httpClient.post(
        '${AppConfig.ticketsPath}/$ticketId/comments',
        body: {'body': body},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  /// Get timeline for a ticket
  Future<List<TicketTimeline>> getTimelineForTicket(String ticketId) async {
    try {
      final response = await _httpClient.get('${AppConfig.ticketsPath}/$ticketId/timeline');

      if (response['success'] == true) {
        final List<dynamic> timelineJson = response['data'] as List<dynamic>? ?? [];
        return timelineJson.map((json) {
          final timeline = json as Map<String, dynamic>;
          return TicketTimeline(
            action: timeline['action'] as String? ?? 'unknown',
            status: timeline['status'] as String? ?? 'open',
            description: timeline['description'] as String? ?? '',
            actorName: timeline['actor_name'] as String? ?? 'Unknown',
            createdAt: DateTime.tryParse(timeline['created_at'] as String? ?? '') ?? DateTime.now(),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error getting timeline: $e');
      return [];
    }
  }

  /// Delete ticket (Admin only)
  Future<bool> deleteTicket(String ticketId) async {
    try {
      final response = await _httpClient.delete('${AppConfig.ticketsPath}/$ticketId');
      return response['success'] == true;
    } catch (e) {
      print('Error deleting ticket: $e');
      return false;
    }
  }

  /// Get attachments for a ticket
  Future<List<AttachmentModel>> getAttachmentsForTicket(String ticketId) async {
    try {
      final response = await _httpClient.get('${AppConfig.ticketsPath}/$ticketId/attachments');

      if (response['success'] == true) {
        final List<dynamic> attachmentsJson = response['data'] as List<dynamic>? ?? [];
        return attachmentsJson.map((json) {
          final attachment = json as Map<String, dynamic>;
          return AttachmentModel(
            id: attachment['id']?.toString() ?? '',
            fileName: attachment['file_name'] as String? ?? '',
            filePath: attachment['file_path'] as String? ?? '',
            fileSize: attachment['file_size'] as int? ?? 0,
            mimeType: attachment['mime_type'] as String? ?? '',
            createdAt: DateTime.tryParse(attachment['created_at'] as String? ?? '') ?? DateTime.now(),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('Error getting attachments: $e');
      return [];
    }
  }

  /// Delete attachment (Admin or owner only)
  Future<bool> deleteAttachment(String ticketId, String attachmentId) async {
    try {
      final response = await _httpClient.delete(
        '${AppConfig.ticketsPath}/$ticketId/attachments/$attachmentId',
      );
      return response['success'] == true;
    } catch (e) {
      print('Error deleting attachment: $e');
      return false;
    }
  }
}
