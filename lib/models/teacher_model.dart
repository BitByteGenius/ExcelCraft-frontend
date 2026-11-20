class TeacherModel {
  final int? id;
  final String teacherId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String mobileNumber;
  final String? alternateNumber;
  final String email;
  final String residentialAddress;
  final String? photoPath;
  final String schoolName;
  final String schoolAddress;
  final String designation;
  final String subject;
  final String dateOfJoining;
  final String blockName;
  final String districtName;
  final String state;
  final String udiseCode;
  final String qualification;
  final String headmasterName;
  final String? headmasterSignaturePath;
  final String? officialSealPath;
  final String? createdAt;
  final String? updatedAt;

  TeacherModel({
    this.id,
    required this.teacherId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.mobileNumber,
    this.alternateNumber,
    required this.email,
    required this.residentialAddress,
    this.photoPath,
    required this.schoolName,
    required this.schoolAddress,
    required this.designation,
    required this.subject,
    required this.dateOfJoining,
    required this.blockName,
    required this.districtName,
    required this.state,
    required this.udiseCode,
    required this.qualification,
    required this.headmasterName,
    this.headmasterSignaturePath,
    this.officialSealPath,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as int?,
      teacherId: json['teacher_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      bloodGroup: json['blood_group']?.toString() ?? '',
      mobileNumber: json['mobile_number']?.toString() ?? '',
      alternateNumber: json['alternate_number']?.toString(),
      email: json['email']?.toString() ?? '',
      residentialAddress: json['residential_address']?.toString() ?? '',
      photoPath: json['photo_path']?.toString(),
      schoolName: json['school_name']?.toString() ?? '',
      schoolAddress: json['school_address']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      dateOfJoining: json['date_of_joining']?.toString() ?? '',
      blockName: json['block_name']?.toString() ?? '',
      districtName: json['district_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      udiseCode: json['udise_code']?.toString() ?? '',
      qualification: json['qualification']?.toString() ?? '',
      headmasterName: json['headmaster_name']?.toString() ?? '',
      headmasterSignaturePath: json['headmaster_signature_path']?.toString(),
      officialSealPath: json['official_seal_path']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, String> toFormFields() {
    return {
      'teacher_id': teacherId,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'dob': dob,
      'gender': gender,
      'blood_group': bloodGroup,
      'mobile_number': mobileNumber,
      'alternate_number': alternateNumber ?? '',
      'email': email,
      'residential_address': residentialAddress,
      'school_name': schoolName,
      'school_address': schoolAddress,
      'designation': designation,
      'subject': subject,
      'date_of_joining': dateOfJoining,
      'block_name': blockName,
      'district_name': districtName,
      'state': state,
      'udise_code': udiseCode,
      'qualification': qualification,
      'headmaster_name': headmasterName,
    };
  }
}
