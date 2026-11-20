import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/picked_media_file.dart';
import '../../../models/student_model.dart';

class StudentService {
  static Future<ApiResponse<List<StudentModel>>> fetchStudents({
    String search = '',
    String school = '',
    String className = '',
    String section = '',
    int page = 1,
    int limit = 50,
  }) async {
    final queryParams = {
      if (search.isNotEmpty) 'search': search,
      if (school.isNotEmpty) 'school': school,
      if (className.isNotEmpty) 'className': className,
      if (section.isNotEmpty) 'section': section,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return ApiService.get<List<StudentModel>>(
      ApiEndpoints.students,
      queryParams: queryParams,
      fromJsonData: (data) => (data as List<dynamic>)
          .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<StudentModel?> fetchStudentById(int id) async {
    final response = await ApiService.get<StudentModel>(
      ApiEndpoints.studentById(id),
      fromJsonData: (data) => StudentModel.fromJson(data as Map<String, dynamic>),
    );
    return response.data;
  }

  static Future<ApiResponse<StudentModel>> saveStudent({
    int? id,
    required Map<String, String> fields,
    PickedMediaFile? photoFile,
    PickedMediaFile? signatureFile,
    PickedMediaFile? sealFile,
  }) async {
    final files = <String, PickedMediaFile?>{
      if (photoFile != null) 'student_photo': photoFile,
      if (signatureFile != null) 'headmaster_signature': signatureFile,
      if (sealFile != null) 'official_seal': sealFile,
    };

    final isEdit = id != null;
    final url = isEdit ? ApiEndpoints.studentById(id) : ApiEndpoints.students;

    return ApiService.postMultipart<StudentModel>(
      url,
      fields: fields,
      files: files,
      isPut: isEdit,
      fromJsonData: (data) => StudentModel.fromJson(data as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<void>> deleteStudent(int id) async {
    return ApiService.delete(ApiEndpoints.studentById(id));
  }
}
