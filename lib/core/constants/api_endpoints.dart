class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:5050';
  
  // Health
  static const String health = '$baseUrl/api/health';
  
  // Dashboard
  static const String dashboard = '$baseUrl/api/dashboard';
  
  // Teachers
  static const String teachers = '$baseUrl/api/teachers';
  static String teacherById(int id) => '$baseUrl/api/teachers/$id';
  
  // Students
  static const String students = '$baseUrl/api/students';
  static String studentById(int id) => '$baseUrl/api/students/$id';
  
  // Excel Exports
  static const String exportTeachers = '$baseUrl/api/export/teachers';
  static const String exportStudents = '$baseUrl/api/export/students';
  
  // ID Cards
  static String teacherCard(int id) => '$baseUrl/api/id-cards/teacher/$id';
  static String studentCard(int id) => '$baseUrl/api/id-cards/student/$id';

  // Storage resolution
  static String resolveUrl(String? relativeOrAbsolute) {
    if (relativeOrAbsolute == null || relativeOrAbsolute.isEmpty) return '';
    if (relativeOrAbsolute.startsWith('http')) return relativeOrAbsolute;
    
    // Normalize path separators
    final normalized = relativeOrAbsolute.replaceAll(r'\', '/');
    final storageIdx = normalized.indexOf('storage/');
    if (storageIdx != -1) {
      final sub = normalized.substring(storageIdx);
      return '$baseUrl/$sub';
    }
    return '$baseUrl/$normalized';
  }
}
