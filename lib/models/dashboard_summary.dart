import 'teacher_model.dart';
import 'student_model.dart';

class ActivityLogModel {
  final int id;
  final String module;
  final String action;
  final String description;
  final String? recordId;
  final String createdAt;

  ActivityLogModel({
    required this.id,
    required this.module,
    required this.action,
    required this.description,
    this.recordId,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as int,
      module: json['module']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      recordId: json['record_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class DashboardSummary {
  final int totalTeachers;
  final int totalStudents;
  final List<TeacherModel> recentTeachers;
  final List<StudentModel> recentStudents;
  final List<ActivityLogModel> recentActivities;

  DashboardSummary({
    required this.totalTeachers,
    required this.totalStudents,
    required this.recentTeachers,
    required this.recentStudents,
    required this.recentActivities,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final teachersList = (json['recentTeachers'] as List<dynamic>?)
            ?.map((e) => TeacherModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final studentsList = (json['recentStudents'] as List<dynamic>?)
            ?.map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final activitiesList = (json['recentActivities'] as List<dynamic>?)
            ?.map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DashboardSummary(
      totalTeachers: json['totalTeachers'] as int? ?? 0,
      totalStudents: json['totalStudents'] as int? ?? 0,
      recentTeachers: teachersList,
      recentStudents: studentsList,
      recentActivities: activitiesList,
    );
  }
}
