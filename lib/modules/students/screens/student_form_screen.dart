import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/picked_media_file.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/image_picker_box.dart';
import '../services/student_service.dart';

class StudentFormScreen extends StatefulWidget {
  final int? editStudentId;

  const StudentFormScreen({super.key, this.editStudentId});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _studentIdCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _schoolNameCtrl = TextEditingController();
  final _schoolAddressCtrl = TextEditingController();
  final _rollNumberCtrl = TextEditingController();
  final _admissionNoCtrl = TextEditingController();
  final _admissionDateCtrl = TextEditingController();
  final _academicSessionCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _udiseCtrl = TextEditingController();
  final _headmasterNameCtrl = TextEditingController();

  // Dropdown values
  String? _selectedGender = 'Male';
  String? _selectedBloodGroup = 'B+';
  String? _selectedClass = 'Class 8';
  String? _selectedSection = 'A';

  // Files
  PickedMediaFile? _photoFile;
  PickedMediaFile? _signatureFile;
  PickedMediaFile? _sealFile;

  // Existing remote paths (in case of edit)
  String? _existingPhotoPath;
  String? _existingSignaturePath;
  String? _existingSealPath;

  bool _isLoading = false;
  bool _isFetchingInitial = false;

  @override
  void initState() {
    super.initState();
    if (widget.editStudentId != null) {
      _loadExistingStudent(widget.editStudentId!);
    } else {
      // Defaults
      _academicSessionCtrl.text = '${DateTime.now().year}-${DateTime.now().year + 1}';
      _admissionDateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _stateCtrl.text = 'Bihar';
      _districtCtrl.text = 'Patna';
    }
  }

  Future<void> _loadExistingStudent(int id) async {
    setState(() => _isFetchingInitial = true);
    final student = await StudentService.fetchStudentById(id);
    if (student != null && mounted) {
      setState(() {
        _studentIdCtrl.text = student.studentId ?? '';
        _fullNameCtrl.text = student.fullName;
        _fatherNameCtrl.text = student.fatherName;
        _motherNameCtrl.text = student.motherName;
        _dobCtrl.text = student.dob;
        _selectedGender = student.gender;
        _selectedBloodGroup = student.bloodGroup;
        _mobileCtrl.text = student.mobileNumber;
        _addressCtrl.text = student.residentialAddress;
        _schoolNameCtrl.text = student.schoolName;
        _schoolAddressCtrl.text = student.schoolAddress;
        _selectedClass = student.className;
        _selectedSection = student.section;
        _rollNumberCtrl.text = student.rollNumber ?? '';
        _admissionNoCtrl.text = student.admissionNumber;
        _admissionDateCtrl.text = student.admissionDate;
        _academicSessionCtrl.text = student.academicSession;
        _blockCtrl.text = student.blockName;
        _districtCtrl.text = student.districtName;
        _stateCtrl.text = student.state;
        _udiseCtrl.text = student.udiseCode;
        _headmasterNameCtrl.text = student.headmasterName ?? '';

        _existingPhotoPath = student.photoPath;
        _existingSignaturePath = student.headmasterSignaturePath;
        _existingSealPath = student.officialSealPath;
      });
    }
    setState(() => _isFetchingInitial = false);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 12));
    if (controller.text.isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct validation errors before saving.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fields = {
      'student_id': _studentIdCtrl.text.trim(),
      'full_name': _fullNameCtrl.text.trim(),
      'father_name': _fatherNameCtrl.text.trim(),
      'mother_name': _motherNameCtrl.text.trim(),
      'dob': _dobCtrl.text.trim(),
      'gender': _selectedGender ?? 'Male',
      'blood_group': _selectedBloodGroup ?? '',
      'mobile_number': _mobileCtrl.text.trim(),
      'residential_address': _addressCtrl.text.trim(),
      'school_name': _schoolNameCtrl.text.trim(),
      'school_address': _schoolAddressCtrl.text.trim(),
      'class_name': _selectedClass ?? '',
      'section': _selectedSection ?? '',
      'roll_number': _rollNumberCtrl.text.trim(),
      'admission_number': _admissionNoCtrl.text.trim(),
      'admission_date': _admissionDateCtrl.text.trim(),
      'academic_session': _academicSessionCtrl.text.trim(),
      'block_name': _blockCtrl.text.trim(),
      'district_name': _districtCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'udise_code': _udiseCtrl.text.trim(),
      'headmaster_name': _headmasterNameCtrl.text.trim(),
    };

    final res = await StudentService.saveStudent(
      id: widget.editStudentId,
      fields: fields,
      photoFile: _photoFile,
      signatureFile: _signatureFile,
      sealFile: _sealFile,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (res.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.editStudentId != null
                  ? 'Student updated successfully!'
                  : 'Student registered successfully with ID: ${res.data?.studentId ?? ""}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        final nav = context.read<NavigationProvider>();
        nav.clearEditSelections();
        nav.navigateTo(AppTab.studentList);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'An error occurred while saving student data.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final isEdit = widget.editStudentId != null;

    if (_isFetchingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Student Record' : 'Register New Student',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEdit
                          ? 'Modify student details and update photograph/signature'
                          : 'Enter complete personal, academic and school information',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        nav.clearEditSelections();
                        nav.navigateTo(AppTab.studentList);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      label: isEdit ? 'Update Student' : 'Save Student Record',
                      icon: Icons.save_rounded,
                      isLoading: _isLoading,
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card 1: Personal Information
            _sectionCard(
              title: '1. Personal Information',
              subtitle: 'Student identity, parents name, contact and passport photograph',
              icon: Icons.person_outline_rounded,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ImagePickerBox(
                          label: 'Student Photograph',
                          selectedFile: _photoFile,
                          existingPath: _existingPhotoPath,
                          onImageSelected: (f) => setState(() => _photoFile = f),
                          width: 150,
                          height: 180,
                          isRequired: true,
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _studentIdCtrl,
                                  label: 'Student ID (Optional)',
                                  hint: isEdit ? null : 'Leave blank for auto-generation',
                                  readOnly: isEdit,
                                  prefixIcon: Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: _fullNameCtrl,
                                  label: 'Student Full Name',
                                  isRequired: true,
                                  prefixIcon: Icons.person,
                                  validator: (v) => Validators.requiredField(v, 'Student Name'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _fatherNameCtrl,
                                  label: "Father's Name",
                                  isRequired: true,
                                  validator: (v) => Validators.requiredField(v, "Father's Name"),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: _motherNameCtrl,
                                  label: "Mother's Name",
                                  isRequired: true,
                                  validator: (v) => Validators.requiredField(v, "Mother's Name"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickDate(_dobCtrl),
                                  child: IgnorePointer(
                                    child: CustomTextField(
                                      controller: _dobCtrl,
                                      label: 'Date of Birth (YYYY-MM-DD)',
                                      isRequired: true,
                                      prefixIcon: Icons.calendar_today,
                                      validator: (v) => Validators.requiredField(v, 'Date of Birth'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomDropdown<String>(
                                  label: 'Gender',
                                  value: _selectedGender,
                                  isRequired: true,
                                  items: AppConstants.genders
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedGender = v),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomDropdown<String>(
                                  label: 'Blood Group (Optional)',
                                  value: _selectedBloodGroup,
                                  items: AppConstants.bloodGroups
                                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedBloodGroup = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _mobileCtrl,
                        label: 'Guardian Contact Number',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android,
                        validator: (v) => Validators.mobile(v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _addressCtrl,
                        label: 'Complete Residential Address',
                        isRequired: true,
                        prefixIcon: Icons.home_outlined,
                        validator: (v) => Validators.requiredField(v, 'Residential Address'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card 2: Academic Information
            _sectionCard(
              title: '2. Academic Information',
              subtitle: 'School admission, current standard, roll number and academic session',
              icon: Icons.school_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _schoolNameCtrl,
                        label: 'School Name',
                        isRequired: true,
                        prefixIcon: Icons.account_balance_outlined,
                        validator: (v) => Validators.requiredField(v, 'School Name'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _schoolAddressCtrl,
                        label: 'School Address',
                        isRequired: true,
                        prefixIcon: Icons.location_on_outlined,
                        validator: (v) => Validators.requiredField(v, 'School Address'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        label: 'Class (Optional)',
                        value: _selectedClass,
                        items: AppConstants.classes
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClass = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDropdown<String>(
                        label: 'Section (Optional)',
                        value: _selectedSection,
                        items: AppConstants.sections
                            .map((s) => DropdownMenuItem(value: s, child: Text('Section $s')))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSection = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _rollNumberCtrl,
                        label: 'Roll Number (Optional)',
                        prefixIcon: Icons.format_list_numbered,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _admissionNoCtrl,
                        label: 'Admission Number',
                        isRequired: true,
                        prefixIcon: Icons.confirmation_number_outlined,
                        validator: (v) => Validators.requiredField(v, 'Admission Number'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(_admissionDateCtrl),
                        child: IgnorePointer(
                          child: CustomTextField(
                            controller: _admissionDateCtrl,
                            label: 'Admission Date (YYYY-MM-DD)',
                            isRequired: true,
                            prefixIcon: Icons.calendar_month_outlined,
                            validator: (v) => Validators.requiredField(v, 'Admission Date'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _academicSessionCtrl,
                        label: 'Academic Session',
                        hint: 'e.g., 2026-2027',
                        isRequired: true,
                        prefixIcon: Icons.timelapse,
                        validator: (v) => Validators.requiredField(v, 'Academic Session'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card 3: School Information & Authorization
            _sectionCard(
              title: '3. School Information & Authorization',
              subtitle: 'Block, district, UDISE code and headmaster authorization',
              icon: Icons.verified_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _blockCtrl,
                        label: 'Block Name',
                        isRequired: true,
                        validator: (v) => Validators.requiredField(v, 'Block Name'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _districtCtrl,
                        label: 'District Name',
                        isRequired: true,
                        validator: (v) => Validators.requiredField(v, 'District Name'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _stateCtrl,
                        label: 'State',
                        isRequired: true,
                        validator: (v) => Validators.requiredField(v, 'State'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _udiseCtrl,
                        label: 'UDISE Code',
                        isRequired: true,
                        prefixIcon: Icons.tag,
                        validator: (v) => Validators.udiseCode(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _headmasterNameCtrl,
                  label: 'Headmaster / Principal Name (Optional)',
                  prefixIcon: Icons.admin_panel_settings_outlined,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ImagePickerBox(
                        label: 'Headmaster Signature (Optional)',
                        selectedFile: _signatureFile,
                        existingPath: _existingSignaturePath,
                        onImageSelected: (f) => setState(() => _signatureFile = f),
                        width: double.infinity,
                        height: 130,
                        helperText: 'Transparent PNG or JPG signature image',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ImagePickerBox(
                        label: 'Official School Seal (Optional)',
                        selectedFile: _sealFile,
                        existingPath: _existingSealPath,
                        onImageSelected: (f) => setState(() => _sealFile = f),
                        width: double.infinity,
                        height: 130,
                        helperText: 'Circular seal or stamp image',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Bottom Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    nav.clearEditSelections();
                    nav.navigateTo(AppTab.studentList);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 14),
                CustomButton(
                  label: isEdit ? 'Update Student' : 'Save Student Record',
                  icon: Icons.check_circle_outline,
                  isLoading: _isLoading,
                  onPressed: _submitForm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.success),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
