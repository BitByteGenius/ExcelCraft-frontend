class StudentModel {
  final int? id;
  final String? studentId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final String dob;
  final String gender;
  final String? bloodGroup;
  final String? photoPath;
  final String mobileNumber;
  final String residentialAddress;
  final String schoolName;
  final String schoolAddress;
  final String? className;
  final String? section;
  final String? rollNumber;
  final String admissionNumber;
  final String admissionDate;
  final String academicSession;
  final String blockName;
  final String districtName;
  final String state;
  final String udiseCode;
  final String? headmasterName;
  final String? headmasterSignaturePath;
  final String? officialSealPath;
  final String? createdAt;
  final String? updatedAt;

  StudentModel({
    this.id,
    this.studentId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.dob,
    required this.gender,
    this.bloodGroup,
    this.photoPath,
    required this.mobileNumber,
    required this.residentialAddress,
    required this.schoolName,
    required this.schoolAddress,
    this.className,
    this.section,
    this.rollNumber,
    required this.admissionNumber,
    required this.admissionDate,
    required this.academicSession,
    required this.blockName,
    required this.districtName,
    required this.state,
    required this.udiseCode,
    this.headmasterName,
    this.headmasterSignaturePath,
    this.officialSealPath,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int?,
      studentId: json['student_id']?.toString(),
      fullName: json['full_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString(),
      photoPath: json['photo_path']?.toString(),
      mobileNumber: json['mobile_number']?.toString() ?? '',
      residentialAddress: json['residential_address']?.toString() ?? '',
      schoolName: json['school_name']?.toString() ?? '',
      schoolAddress: json['school_address']?.toString() ?? '',
      className: json['class_name']?.toString(),
      section: json['section']?.toString(),
      rollNumber: json['roll_number']?.toString(),
      admissionNumber: json['admission_number']?.toString() ?? '',
      admissionDate: json['admission_date']?.toString() ?? '',
      academicSession: json['academic_session']?.toString() ?? '',
      blockName: json['block_name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      udiseCode: json['udise_code']?.toString() ?? '',
      headmasterName: json['headmaster_name']?.toString(),
      headmasterSignaturePath: json['headmaster_signature_path']?.toString(),
      officialSealPath: json['official_seal_path']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, String> toFormFields() {
    return {
      if (studentId != null && studentId!.isNotEmpty) 'student_id': studentId!,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'dob': dob,
      'gender': gender,
      'blood_group': bloodGroup ?? '',
      'mobile_number': mobileNumber,
      'residential_address': residentialAddress,
      'school_name': schoolName,
      'school_address': schoolAddress,
      'class_name': className ?? '',
      'section': section ?? '',
      'roll_number': rollNumber ?? '',
      'admission_number': admissionNumber,
      'admission_date': admissionDate,
      'academic_session': academicSession,
      'block_name': blockName,
      'district_name': districtName,
      'state': state,
      'udise_code': udiseCode,
      'headmaster_name': headmasterName ?? '',
    };
  }
}
