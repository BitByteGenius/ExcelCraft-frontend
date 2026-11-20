import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../utils/picked_media_file.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? pagination;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.pagination,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data)? fromJsonData,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonData != null
          ? fromJsonData(json['data'])
          : json['data'] as T?,
      pagination: json['pagination'] as Map<String, dynamic>?,
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}

class ApiService {
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<bool> checkBackendHealth() async {
    try {
      final res = await http.get(Uri.parse(ApiEndpoints.health)).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJsonData,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(timeoutDuration);
      final json = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(json, fromJsonData);
      } else {
        return ApiResponse<T>(
          success: false,
          message: json['message'] ?? 'Request failed (${response.statusCode})',
          errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network error or backend unreachable: $e',
      );
    }
  }

  static Future<ApiResponse<T>> postMultipart<T>(
    String url, {
    required Map<String, String> fields,
    Map<String, PickedMediaFile?>? files,
    T Function(dynamic)? fromJsonData,
    bool isPut = false,
  }) async {
    try {
      final request = http.MultipartRequest(
        isPut ? 'PUT' : 'POST',
        Uri.parse(url),
      );

      // Add fields
      request.fields.addAll(fields);

      // Add files via memory bytes - fully cross-platform (Web & Desktop)
      if (files != null) {
        for (final entry in files.entries) {
          if (entry.value != null && entry.value!.bytes.isNotEmpty) {
            final multipartFile = http.MultipartFile.fromBytes(
              entry.key,
              entry.value!.bytes,
              filename: entry.value!.name,
            );
            request.files.add(multipartFile);
          }
        }
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      final json = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(json, fromJsonData);
      } else {
        return ApiResponse<T>(
          success: false,
          message: json['message'] ?? 'Operation failed (${response.statusCode})',
          errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network or server error: $e',
      );
    }
  }

  static Future<ApiResponse<T>> delete<T>(
    String url, {
    T Function(dynamic)? fromJsonData,
  }) async {
    try {
      final response = await http.delete(Uri.parse(url), headers: _headers).timeout(timeoutDuration);
      final json = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.fromJson(json, fromJsonData);
      } else {
        return ApiResponse<T>(
          success: false,
          message: json['message'] ?? 'Delete failed (${response.statusCode})',
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: 'Network or server error: $e',
      );
    }
  }
}
