import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

/// HTTP Client for making API requests
/// Handles common operations like adding headers, error handling, etc.
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  String? _accessToken;

  // Singleton instance for direct use
  static final http.Client _client = http.Client();

  // Set access token for authenticated requests
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  // Get current access token
  String? get accessToken => _accessToken;

  // Get current access token (alias for compatibility)
  Future<String?> getToken() async => _accessToken;

  // Clear access token (on logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  // Parse response from string
  dynamic parseResponse(String responseBody) {
    try {
      return json.decode(responseBody);
    } catch (e) {
      return {'success': false, 'message': 'Failed to parse response'};
    }
  }

  // Get common headers
  Map<String, String> _getHeaders({bool requireAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (requireAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return {'success': true};
        }
        try {
          return json.decode(response.body);
        } catch (e) {
          return {'success': true, 'data': response.body};
        }
      case 204:
        return {'success': true};
      case 400:
        final error = json.decode(response.body);
        throw ApiException(message: error['message'] ?? 'Bad request', statusCode: 400);
      case 401:
        throw ApiException(message: 'Unauthorized - Please login again', statusCode: 401);
      case 403:
        throw ApiException(message: 'Forbidden - You don\'t have permission', statusCode: 403);
      case 404:
        throw ApiException(message: 'Resource not found', statusCode: 404);
      case 422:
        final error = json.decode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Validation error',
          statusCode: 422,
          errors: error['errors'] as Map<String, dynamic>?,
        );
      case 500:
        throw ApiException(message: 'Server error - Please try again later', statusCode: 500);
      default:
        throw ApiException(message: 'Unexpected error occurred', statusCode: response.statusCode);
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint').replace(
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print('🌐 GET: $uri');
        print('🌐 Base URL: ${AppConfig.apiBaseUrl}');
        print('🌐 Endpoint: $endpoint');
        print('🌐 Full URL: $uri');
        print('🌐 Headers: ${_getHeaders(requireAuth: requireAuth)}');
        print('🌐 Auth Token: ${_accessToken != null ? "Present" : "Missing"}');
      }

      final response = await _client
          .get(uri, headers: _getHeaders(requireAuth: requireAuth))
          .timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (kDebugMode) {
        print('🌐 Response Status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          print('🌐 Response Body: ${response.body}');
        } else {
          print('🌐 Error Response: ${response.body}');
        }
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on HttpException catch (e) {
      throw ApiException(message: e.message, statusCode: 0);
    } on TimeoutException catch (e) {
      throw ApiException(message: 'Connection timeout - Please check your internet', statusCode: 0);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in GET request: $e');
        print('❌ Exception type: ${e.runtimeType}');
      }
      throw ApiException(message: 'Failed to fetch API: ${e.toString()}', statusCode: 0);
    }
  }

  // POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      if (kDebugMode) {
        print('POST: $uri');
        print('Body: ${json.encode(body)}');
        print('Headers: ${_getHeaders(requireAuth: requireAuth)}');
      }

      final response = await _client
          .post(
            uri,
            headers: _getHeaders(requireAuth: requireAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on HttpException catch (e) {
      throw ApiException(message: e.message, statusCode: 0);
    } on TimeoutException catch (e) {
      throw ApiException(message: 'Connection timeout - Please check your internet', statusCode: 0);
    } catch (e) {
      if (kDebugMode) {
        print('POST Error: $e');
        print('Error Type: ${e.runtimeType}');
      }
      // Re-throw ApiException as-is
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(message: 'Failed to fetch API: ${e.toString()}', statusCode: 0);
    }
  }

  // PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      if (kDebugMode) {
        print('PUT: $uri');
        print('Body: ${json.encode(body)}');
      }

      final response = await _client
          .put(
            uri,
            headers: _getHeaders(requireAuth: requireAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on HttpException catch (e) {
      throw ApiException(message: e.message, statusCode: 0);
    } on TimeoutException catch (e) {
      throw ApiException(message: 'Connection timeout - Please check your internet', statusCode: 0);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch API: ${e.toString()}', statusCode: 0);
    }
  }

  // PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      if (kDebugMode) {
        print('PATCH: $uri');
        print('Body: ${json.encode(body)}');
      }

      final response = await _client
          .patch(
            uri,
            headers: _getHeaders(requireAuth: requireAuth),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on HttpException catch (e) {
      throw ApiException(message: e.message, statusCode: 0);
    } on TimeoutException catch (e) {
      throw ApiException(message: 'Connection timeout - Please check your internet', statusCode: 0);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch API: ${e.toString()}', statusCode: 0);
    }
  }

  // DELETE request
  Future<dynamic> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');

      if (kDebugMode) {
        print('DELETE: $uri');
      }

      final response = await _client
          .delete(uri, headers: _getHeaders(requireAuth: requireAuth))
          .timeout(
        const Duration(milliseconds: AppConfig.connectionTimeout),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } on HttpException catch (e) {
      throw ApiException(message: e.message, statusCode: 0);
    } on TimeoutException catch (e) {
      throw ApiException(message: 'Connection timeout - Please check your internet', statusCode: 0);
    } catch (e) {
      throw ApiException(message: 'Failed to fetch API: ${e.toString()}', statusCode: 0);
    }
  }
}

/// Custom Exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}
