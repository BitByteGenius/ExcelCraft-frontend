import 'dart:convert';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/picked_media_file.dart';
import '../../../models/teacher_model.dart';

class TeacherService {
  static Future<ApiResponse<List<TeacherModel>>> fetchTeachers({
    String search = '',
    String school = '',
    String designation = '',
    String subject = '',
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = {
      if (search.isNotEmpty) 'search': search,
      if (school.isNotEmpty) 'school': school,
      if (designation.isNotEmpty) 'designation': designation,
      if (subject.isNotEmpty) 'subject': subject,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return ApiService.get<List<TeacherModel>>(
      ApiEndpoints.teachers,
      queryParams: queryParams,
      fromJsonData: (data) => (data as List<dynamic>)
          .map((e) => TeacherModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<TeacherModel?> fetchTeacherById(int id) async {
    final response = await ApiService.get<TeacherModel>(
      ApiEndpoints.teacherById(id),
      fromJsonData: (data) => TeacherModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data;
  }

  static Future<ApiResponse<TeacherModel>> saveTeacher({
    int? id,
    required Map<String, String> fields,
    PickedMediaFile? photoFile,
    PickedMediaFile? signatureFile,
    PickedMediaFile? sealFile,
  }) async {
    final files = <String, PickedMediaFile?>{
      if (photoFile != null) 'teacher_photo': photoFile,
      if (signatureFile != null) 'headmaster_signature': signatureFile,
      if (sealFile != null) 'official_seal': sealFile,
    };

    final isEdit = id != null;
    final url = isEdit ? ApiEndpoints.teacherById(id) : ApiEndpoints.teachers;

    return ApiService.postMultipart<TeacherModel>(
      url,
      fields: fields,
      files: files,
      isPut: isEdit,
      fromJsonData: (data) => TeacherModel.fromJson(data as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<TeacherModel>>> saveBatchTeachers({
    required Map<String, String> commonFields,
    required List<Map<String, String>> teachers,
    Map<int, PickedMediaFile?>? teacherPhotos,
    PickedMediaFile? signatureFile,
    PickedMediaFile? sealFile,
  }) async {
    final fields = Map<String, String>.from(commonFields);
    fields['teachers'] = jsonEncode(teachers);

    final files = <String, PickedMediaFile?>{
      if (signatureFile != null) 'headmaster_signature': signatureFile,
      if (sealFile != null) 'official_seal': sealFile,
    };

    if (teacherPhotos != null) {
      teacherPhotos.forEach((idx, photo) {
        if (photo != null) {
          files['teacher_photo_$idx'] = photo;
        }
      });
    }

    return ApiService.postMultipart<List<TeacherModel>>(
      '${ApiEndpoints.teachers}/batch',
      fields: fields,
      files: files,
      fromJsonData: (data) => (data as List<dynamic>)
          .map((e) => TeacherModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<void>> deleteTeacher(int id) async {
    return ApiService.delete(ApiEndpoints.teacherById(id));
  }
}
