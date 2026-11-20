class SchoolSummaryModel {
  final String schoolName;
  final String udiseCode;
  final String districtName;
  final String state;
  final String headmasterName;
  final int teacherCount;

  SchoolSummaryModel({
    required this.schoolName,
    required this.udiseCode,
    required this.districtName,
    required this.state,
    required this.headmasterName,
    required this.teacherCount,
  });

  factory SchoolSummaryModel.fromJson(Map<String, dynamic> json) {
    return SchoolSummaryModel(
      schoolName: json['school_name']?.toString() ?? '',
      udiseCode: json['udise_code']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      headmasterName: json['headmaster_name']?.toString() ?? '',
      teacherCount: json['teacher_count'] as int? ?? 0,
    );
  }
}
