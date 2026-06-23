import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';
import '../core/config/app_config.dart';
import '../core/config/http_client.dart';

/// Attachment Service
/// Handles all attachment operations using REST API
class AttachmentService {
  static final AttachmentService _instance = AttachmentService._internal();
  factory AttachmentService() => _instance;
  AttachmentService._internal();

  final HttpClient _httpClient = HttpClient();

  /// Upload attachment to ticket
  Future<AttachmentModel?> uploadAttachment(String ticketId, File file) async {
    try {
      // Create multipart request
      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.ticketsPath}/$ticketId/attachments');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final token = await _httpClient.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await streamedResponse.stream.bytesToString();

      // Parse response
      final Map<String, dynamic> responseData = _httpClient.parseResponse(response);

      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        return AttachmentModel(
          id: data['id']?.toString() ?? '',
          fileName: data['file_name'] as String? ?? '',
          filePath: data['file_path'] as String? ?? '',
          fileSize: data['file_size'] as int? ?? 0,
          mimeType: data['mime_type'] as String? ?? '',
          createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }

      return null;
    } catch (e) {
      print('Error uploading attachment: $e');
      return null;
    }
  }

  /// Get attachments for ticket (this is also in ticket service, keeping for convenience)
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

  /// Get full file URL for download/viewing
  String getFileUrl(String filePath) {
    // If the filePath already starts with http, return as is
    if (filePath.startsWith('http')) {
      return filePath;
    }
    // Otherwise, construct the full URL
    return '${AppConfig.baseUrl}$filePath';
  }

  /// Check if file type is supported for upload
  bool isSupportedFileType(String fileName) {
    final supportedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'txt', 'pdf', 'doc', 'docx'];
    final extension = fileName.split('.').last.toLowerCase();
    return supportedExtensions.contains(extension);
  }

  /// Check if file size is within limit (5MB)
  bool isValidFileSize(int fileSize) {
    return fileSize <= 5 * 1024 * 1024; // 5MB
  }

  /// Get supported file types for display
  List<String> getSupportedFileTypes() {
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'txt', 'pdf', 'doc', 'docx'];
  }
}