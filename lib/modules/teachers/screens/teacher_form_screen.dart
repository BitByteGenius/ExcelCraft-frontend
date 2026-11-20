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
import '../services/teacher_service.dart';

class TeacherFormScreen extends StatefulWidget {
  final int? editTeacherId;

  const TeacherFormScreen({super.key, this.editTeacherId});

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _teacherIdCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _motherNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _altMobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _schoolNameCtrl = TextEditingController();
  final _schoolAddressCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _dojCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _udiseCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _headmasterNameCtrl = TextEditingController();

  // Dropdown values
  String? _selectedGender = 'Male';
  String? _selectedBloodGroup = 'O+';
  String? _selectedDesignation = 'Assistant Teacher';

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
    if (widget.editTeacherId != null) {
      _loadExistingTeacher(widget.editTeacherId!);
    } else {
      // Defaults
      _stateCtrl.text = 'Bihar';
      _districtCtrl.text = 'Patna';
    }
  }

  Future<void> _loadExistingTeacher(int id) async {
    setState(() => _isFetchingInitial = true);
    final teacher = await TeacherService.fetchTeacherById(id);
    if (teacher != null && mounted) {
      setState(() {
        _teacherIdCtrl.text = teacher.teacherId;
        _fullNameCtrl.text = teacher.fullName;
        _fatherNameCtrl.text = teacher.fatherName;
        _motherNameCtrl.text = teacher.motherName;
        _dobCtrl.text = teacher.dob;
        _selectedGender = teacher.gender;
        _selectedBloodGroup = teacher.bloodGroup;
        _mobileCtrl.text = teacher.mobileNumber;
        _altMobileCtrl.text = teacher.alternateNumber ?? '';
        _emailCtrl.text = teacher.email;
        _addressCtrl.text = teacher.residentialAddress;
        _schoolNameCtrl.text = teacher.schoolName;
        _schoolAddressCtrl.text = teacher.schoolAddress;
        _selectedDesignation = teacher.designation;
        _subjectCtrl.text = teacher.subject;
        _dojCtrl.text = teacher.dateOfJoining;
        _blockCtrl.text = teacher.blockName;
        _districtCtrl.text = teacher.districtName;
        _stateCtrl.text = teacher.state;
        _udiseCtrl.text = teacher.udiseCode;
        _qualificationCtrl.text = teacher.qualification;
        _headmasterNameCtrl.text = teacher.headmasterName;

        _existingPhotoPath = teacher.photoPath;
        _existingSignaturePath = teacher.headmasterSignaturePath;
        _existingSealPath = teacher.officialSealPath;
      });
    }
    setState(() => _isFetchingInitial = false);
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 25));
    if (controller.text.isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
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
      'teacher_id': _teacherIdCtrl.text.trim(),
      'full_name': _fullNameCtrl.text.trim(),
      'father_name': _fatherNameCtrl.text.trim(),
      'mother_name': _motherNameCtrl.text.trim(),
      'dob': _dobCtrl.text.trim(),
      'gender': _selectedGender ?? 'Male',
      'blood_group': _selectedBloodGroup ?? 'O+',
      'mobile_number': _mobileCtrl.text.trim(),
      'alternate_number': _altMobileCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'residential_address': _addressCtrl.text.trim(),
      'school_name': _schoolNameCtrl.text.trim(),
      'school_address': _schoolAddressCtrl.text.trim(),
      'designation': _selectedDesignation ?? 'Assistant Teacher',
      'subject': _subjectCtrl.text.trim(),
      'date_of_joining': _dojCtrl.text.trim(),
      'block_name': _blockCtrl.text.trim(),
      'district_name': _districtCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'udise_code': _udiseCtrl.text.trim(),
      'qualification': _qualificationCtrl.text.trim(),
      'headmaster_name': _headmasterNameCtrl.text.trim(),
    };

    final res = await TeacherService.saveTeacher(
      id: widget.editTeacherId,
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
              widget.editTeacherId != null
                  ? 'Teacher updated successfully!'
                  : 'Teacher registered successfully with ID: ${res.data?.teacherId ?? ""}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        final nav = context.read<NavigationProvider>();
        nav.clearEditSelections();
        nav.navigateTo(AppTab.teacherList);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message ?? 'An error occurred while saving teacher data.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();
    final isEdit = widget.editTeacherId != null;

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
                      isEdit ? 'Edit Teacher Record' : 'Register New Teacher',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEdit
                          ? 'Modify details and replace photograph or signature'
                          : 'Enter complete 25-point personal, professional and authorization details',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        nav.clearEditSelections();
                        nav.navigateTo(AppTab.teacherList);
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      label: isEdit ? 'Update Teacher' : 'Save Teacher Record',
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
              subtitle: 'Candidate biological identity, contact information, and photograph',
              icon: Icons.badge_outlined,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photos & Signatures column
                    Column(
                      children: [
                        ImagePickerBox(
                          label: 'Teacher Photograph',
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

                    // Inputs columns
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _teacherIdCtrl,
                                  label: 'Teacher ID',
                                  hint: isEdit ? null : 'Leave blank for auto-generation',
                                  readOnly: isEdit,
                                  prefixIcon: Icons.fingerprint,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: _fullNameCtrl,
                                  label: 'Full Name',
                                  isRequired: true,
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) => Validators.requiredField(v, 'Full Name'),
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
                                  label: 'Blood Group',
                                  value: _selectedBloodGroup,
                                  isRequired: true,
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
                        label: 'Mobile Number',
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android,
                        validator: (v) => Validators.mobile(v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _altMobileCtrl,
                        label: 'Alternate Contact Number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        isRequired: true,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (v) => Validators.email(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressCtrl,
                  label: 'Complete Residential Address',
                  isRequired: true,
                  maxLines: 2,
                  prefixIcon: Icons.home_outlined,
                  validator: (v) => Validators.requiredField(v, 'Residential Address'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card 2: Professional Information
            _sectionCard(
              title: '2. Professional Information',
              subtitle: 'School posting, designation, academic subject and state codes',
              icon: Icons.work_outline,
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
                  controller: _schoolAddressCtrl,
                  label: 'School Address',
                  isRequired: true,
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => Validators.requiredField(v, 'School Address'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        label: 'Designation',
                        value: _selectedDesignation,
                        isRequired: true,
                        items: AppConstants.teacherDesignations
                            .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedDesignation = v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _subjectCtrl,
                        label: 'Subject',
                        isRequired: true,
                        validator: (v) => Validators.requiredField(v, 'Subject'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(_dojCtrl),
                        child: IgnorePointer(
                          child: CustomTextField(
                            controller: _dojCtrl,
                            label: 'Date of Joining (YYYY-MM-DD)',
                            isRequired: true,
                            prefixIcon: Icons.event,
                            validator: (v) => Validators.requiredField(v, 'Date of Joining'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        controller: _qualificationCtrl,
                        label: 'Qualification',
                        hint: 'e.g., M.Sc, B.Ed',
                        isRequired: true,
                        validator: (v) => Validators.requiredField(v, 'Qualification'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Card 3: Authorization Information
            _sectionCard(
              title: '3. Authorization Information',
              subtitle: 'Headmaster approval, digital signature, and official seal',
              icon: Icons.verified_outlined,
              children: [
                CustomTextField(
                  controller: _headmasterNameCtrl,
                  label: 'Headmaster / Principal Name',
                  isRequired: true,
                  prefixIcon: Icons.admin_panel_settings_outlined,
                  validator: (v) => Validators.requiredField(v, 'Headmaster Name'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ImagePickerBox(
                        label: 'Headmaster Signature',
                        selectedFile: _signatureFile,
                        existingPath: _existingSignaturePath,
                        onImageSelected: (f) => setState(() => _signatureFile = f),
                        width: double.infinity,
                        height: 130,
                        isRequired: true,
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
                        helperText: 'Circular seal or stamp stamp image',
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
                    nav.navigateTo(AppTab.teacherList);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 14),
                CustomButton(
                  label: isEdit ? 'Update Teacher' : 'Save Teacher Record',
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
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.accent),
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
