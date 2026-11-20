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

class TeacherEntryItem {
  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController fatherNameCtrl = TextEditingController();
  final TextEditingController motherNameCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController altMobileCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController subjectCtrl = TextEditingController();
  final TextEditingController dojCtrl = TextEditingController();
  final TextEditingController qualificationCtrl = TextEditingController();

  String selectedGender = 'Male';
  String selectedBloodGroup = 'O+';
  String selectedDesignation = 'Assistant Teacher';

  PickedMediaFile? photoFile;
  String? existingPhotoPath;

  void dispose() {
    fullNameCtrl.dispose();
    fatherNameCtrl.dispose();
    motherNameCtrl.dispose();
    dobCtrl.dispose();
    mobileCtrl.dispose();
    altMobileCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    subjectCtrl.dispose();
    dojCtrl.dispose();
    qualificationCtrl.dispose();
  }

  Map<String, String> toMap() {
    return {
      'full_name': fullNameCtrl.text.trim(),
      'father_name': fatherNameCtrl.text.trim(),
      'mother_name': motherNameCtrl.text.trim(),
      'dob': dobCtrl.text.trim(),
      'gender': selectedGender,
      'blood_group': selectedBloodGroup,
      'mobile_number': mobileCtrl.text.trim(),
      'alternate_number': altMobileCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'residential_address': addressCtrl.text.trim(),
      'designation': selectedDesignation,
      'subject': subjectCtrl.text.trim(),
      'date_of_joining': dojCtrl.text.trim(),
      'qualification': qualificationCtrl.text.trim(),
    };
  }
}

class TeacherFormScreen extends StatefulWidget {
  final int? editTeacherId;

  const TeacherFormScreen({super.key, this.editTeacherId});

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common School & Authorization Controllers (Shared for all teachers in batch)
  final _schoolNameCtrl = TextEditingController();
  final _schoolAddressCtrl = TextEditingController();
  final _udiseCtrl = TextEditingController();
  final _blockCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _headmasterNameCtrl = TextEditingController();

  PickedMediaFile? _signatureFile;
  PickedMediaFile? _sealFile;
  String? _existingSignaturePath;
  String? _existingSealPath;

  // Single edit teacher ID controller
  final _teacherIdCtrl = TextEditingController();

  // List of teachers being prepared in this batch
  final List<TeacherEntryItem> _teacherItems = [];

  bool _isLoading = false;
  bool _isFetchingInitial = false;

  bool get isEdit => widget.editTeacherId != null;

  @override
  void initState() {
    super.initState();
    // Default initial school location
    _stateCtrl.text = 'Bihar';
    _districtCtrl.text = 'Patna';
    _blockCtrl.text = 'Patna Sadar';

    if (isEdit) {
      _loadExistingTeacher(widget.editTeacherId!);
    } else {
      // Start with 1 teacher row ready for input
      _addNewTeacherRow();
    }
  }

  @override
  void dispose() {
    _schoolNameCtrl.dispose();
    _schoolAddressCtrl.dispose();
    _udiseCtrl.dispose();
    _blockCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _headmasterNameCtrl.dispose();
    _teacherIdCtrl.dispose();

    for (final item in _teacherItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addNewTeacherRow() {
    setState(() {
      final item = TeacherEntryItem();
      // Pre-fill today's date for joining as quick default
      item.dojCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _teacherItems.add(item);
    });
  }

  void _removeTeacherRow(int index) {
    if (_teacherItems.length > 1) {
      setState(() {
        final removed = _teacherItems.removeAt(index);
        removed.dispose();
      });
    }
  }

  Future<void> _loadExistingTeacher(int id) async {
    setState(() => _isFetchingInitial = true);
    final teacher = await TeacherService.fetchTeacherById(id);
    if (teacher != null && mounted) {
      setState(() {
        _teacherIdCtrl.text = teacher.teacherId;
        _schoolNameCtrl.text = teacher.schoolName;
        _schoolAddressCtrl.text = teacher.schoolAddress;
        _blockCtrl.text = teacher.blockName;
        _districtCtrl.text = teacher.districtName;
        _stateCtrl.text = teacher.state;
        _udiseCtrl.text = teacher.udiseCode;
        _headmasterNameCtrl.text = teacher.headmasterName;
        _existingSignaturePath = teacher.headmasterSignaturePath;
        _existingSealPath = teacher.officialSealPath;

        final item = TeacherEntryItem();
        item.fullNameCtrl.text = teacher.fullName;
        item.fatherNameCtrl.text = teacher.fatherName;
        item.motherNameCtrl.text = teacher.motherName;
        item.dobCtrl.text = teacher.dob;
        item.selectedGender = teacher.gender;
        item.selectedBloodGroup = teacher.bloodGroup.isNotEmpty ? teacher.bloodGroup : 'O+';
        item.mobileCtrl.text = teacher.mobileNumber;
        item.altMobileCtrl.text = teacher.alternateNumber ?? '';
        item.emailCtrl.text = teacher.email;
        item.addressCtrl.text = teacher.residentialAddress;
        item.selectedDesignation = teacher.designation;
        item.subjectCtrl.text = teacher.subject;
        item.dojCtrl.text = teacher.dateOfJoining;
        item.qualificationCtrl.text = teacher.qualification;
        item.existingPhotoPath = teacher.photoPath;

        _teacherItems.clear();
        _teacherItems.add(item);
      });
    }
    setState(() => _isFetchingInitial = false);
  }

  Future<void> _pickDateForController(TextEditingController controller, {bool isDob = false}) async {
    DateTime initial = isDob
        ? DateTime.now().subtract(const Duration(days: 365 * 25))
        : DateTime.now();

    if (controller.text.trim().isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text.trim());
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
          content: Text('Please correct highlighted validation errors.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Verify at least one teacher has a full name
    for (int i = 0; i < _teacherItems.length; i++) {
      if (_teacherItems[i].fullNameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Teacher #${i + 1} is missing Full Name.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final commonFields = {
      'school_name': _schoolNameCtrl.text.trim(),
      'school_address': _schoolAddressCtrl.text.trim(),
      'block_name': _blockCtrl.text.trim(),
      'district_name': _districtCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'udise_code': _udiseCtrl.text.trim(),
      'headmaster_name': _headmasterNameCtrl.text.trim(),
    };

    if (isEdit) {
      // Single Teacher Update Mode
      final singleItem = _teacherItems.first;
      final fields = {
        ...commonFields,
        ...singleItem.toMap(),
        'teacher_id': _teacherIdCtrl.text.trim(),
      };

      final res = await TeacherService.saveTeacher(
        id: widget.editTeacherId,
        fields: fields,
        photoFile: singleItem.photoFile,
        signatureFile: _signatureFile,
        sealFile: _sealFile,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Teacher updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          final nav = context.read<NavigationProvider>();
          nav.clearEditSelections();
          nav.navigateTo(AppTab.teacherList);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Failed to update teacher'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } else {
      // Multi-Teacher Batch Mode
      final teachersList = _teacherItems.map((item) => item.toMap()).toList();
      final photosMap = <int, PickedMediaFile?>{};
      for (int i = 0; i < _teacherItems.length; i++) {
        if (_teacherItems[i].photoFile != null) {
          photosMap[i] = _teacherItems[i].photoFile;
        }
      }

      final res = await TeacherService.saveBatchTeachers(
        commonFields: commonFields,
        teachers: teachersList,
        teacherPhotos: photosMap,
        signatureFile: _signatureFile,
        sealFile: _sealFile,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (res.success) {
          final count = res.data?.length ?? _teacherItems.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Successfully saved $count teachers in batch!'),
              backgroundColor: AppColors.success,
            ),
          );
          final nav = context.read<NavigationProvider>();
          nav.clearEditSelections();
          nav.navigateTo(AppTab.teacherList);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Failed to save batch teachers'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();

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
            // Top Navigation / Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Teacher Record' : 'Multi-Teacher Fast Entry Hub',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEdit
                          ? 'Modify details and replace photograph or signature'
                          : 'Enter all teachers at once. School and Headmaster Authorization is filled once at the end.',
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
                    if (!isEdit) ...[
                      ElevatedButton.icon(
                        onPressed: _addNewTeacherRow,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('+ Add Another Teacher'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E)),
                      ),
                      const SizedBox(width: 12),
                    ],
                    CustomButton(
                      label: isEdit
                          ? 'Update Teacher'
                          : 'Save Teacher Records (${_teacherItems.length})',
                      icon: Icons.save_rounded,
                      isLoading: _isLoading,
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Dynamic Teacher Cards List
            ..._teacherItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildTeacherCard(index, item);
            }),

            // Add Another Teacher Button Bar
            if (!isEdit) ...[
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _addNewTeacherRow,
                  icon: const Icon(Icons.person_add_alt_1, size: 18, color: AppColors.accent),
                  label: Text(
                    '+ Add Another Teacher (#${_teacherItems.length + 1})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Section 2: Shared School & Authorization Information (Filled Once)
            _sectionCard(
              title: isEdit
                  ? 'School & Headmaster Authorization'
                  : 'School & Headmaster Authorization (Common For All Teachers)',
              subtitle: 'School posting and digital signature/seal applied to all teachers in this batch',
              icon: Icons.verified_outlined,
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        controller: _schoolAddressCtrl,
                        label: 'School Address (Optional)',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _blockCtrl,
                        label: 'Block Name (Optional)',
                        prefixIcon: Icons.map_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _districtCtrl,
                        label: 'District Name (Optional)',
                        prefixIcon: Icons.holiday_village_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _stateCtrl,
                        label: 'State (Optional)',
                        prefixIcon: Icons.public,
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
                        label: 'Headmaster Signature (Upload Once for all teachers)',
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

            const SizedBox(height: 32),

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
                  label: isEdit
                      ? 'Update Teacher'
                      : 'Save All Teacher Records (${_teacherItems.length})',
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

  Widget _buildTeacherCard(int index, TeacherEntryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with Teacher Number and Remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Teacher #${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.fullNameCtrl.text.isNotEmpty ? item.fullNameCtrl.text : 'Personal & Academic Details',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
              if (_teacherItems.length > 1 && !isEdit)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                  tooltip: 'Remove Teacher #${index + 1}',
                  onPressed: () => _removeTeacherRow(index),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),

          // Teacher fields & Photo layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo column
              ImagePickerBox(
                label: 'Photograph',
                selectedFile: item.photoFile,
                existingPath: item.existingPhotoPath,
                onImageSelected: (f) => setState(() => item.photoFile = f),
                width: 140,
                height: 170,
                isRequired: false,
                helperText: 'JPG / PNG passport photo',
              ),
              const SizedBox(width: 20),

              // Inputs grid
              Expanded(
                child: Column(
                  children: [
                    // Row 1: Full Name, Father's Name, Mother's Name
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: item.fullNameCtrl,
                            label: 'Full Name',
                            isRequired: true,
                            prefixIcon: Icons.person_outline,
                            validator: (v) => Validators.requiredField(v, 'Full Name'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomTextField(
                            controller: item.fatherNameCtrl,
                            label: "Father's Name (Optional)",
                            prefixIcon: Icons.family_restroom,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomTextField(
                            controller: item.motherNameCtrl,
                            label: "Mother's Name (Optional)",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Row 2: Date of Birth (Manual + Calendar), Gender, Blood Group
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: item.dobCtrl,
                            label: 'Date of Birth (YYYY-MM-DD)',
                            hint: 'Type e.g. 1990-05-15 or pick',
                            prefixIcon: Icons.calendar_today_outlined,
                            suffix: IconButton(
                              icon: const Icon(Icons.calendar_month, color: AppColors.accent, size: 20),
                              tooltip: 'Pick from Calendar',
                              onPressed: () => _pickDateForController(item.dobCtrl, isDob: true),
                            ),
                            readOnly: false, // Manual typing allowed!
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomDropdown<String>(
                            label: 'Gender',
                            value: item.selectedGender,
                            items: AppConstants.genders
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => setState(() => item.selectedGender = v ?? 'Male'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomDropdown<String>(
                            label: 'Blood Group (Optional)',
                            value: item.selectedBloodGroup,
                            items: AppConstants.bloodGroups
                                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                .toList(),
                            onChanged: (v) => setState(() => item.selectedBloodGroup = v ?? 'O+'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Row 3: Mobile, Alternate Mobile, Email
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: item.mobileCtrl,
                            label: 'Mobile Number',
                            isRequired: true,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_android,
                            validator: (v) => Validators.mobile(v),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomTextField(
                            controller: item.altMobileCtrl,
                            label: 'Alternate Number (Optional)',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: CustomTextField(
                            controller: item.emailCtrl,
                            label: 'Email (Optional)',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 4: Designation, Subject, Joining Date (Manual + Calendar), Qualification
          Row(
            children: [
              Expanded(
                child: CustomDropdown<String>(
                  label: 'Designation',
                  value: item.selectedDesignation,
                  isRequired: true,
                  items: AppConstants.teacherDesignations
                      .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (v) => setState(() => item.selectedDesignation = v ?? 'Assistant Teacher'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CustomTextField(
                  controller: item.subjectCtrl,
                  label: 'Subject',
                  isRequired: true,
                  hint: 'e.g. Mathematics, Science',
                  prefixIcon: Icons.menu_book,
                  validator: (v) => Validators.requiredField(v, 'Subject'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CustomTextField(
                  controller: item.dojCtrl,
                  label: 'Date of Joining (YYYY-MM-DD)',
                  hint: 'Type e.g. 2018-08-01 or pick',
                  prefixIcon: Icons.event,
                  suffix: IconButton(
                    icon: const Icon(Icons.calendar_month, color: AppColors.accent, size: 20),
                    tooltip: 'Pick from Calendar',
                    onPressed: () => _pickDateForController(item.dojCtrl),
                  ),
                  readOnly: false, // Manual typing allowed!
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CustomTextField(
                  controller: item.qualificationCtrl,
                  label: 'Qualification (Optional)',
                  hint: 'e.g. M.Sc, B.Ed',
                  prefixIcon: Icons.school_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 5: Complete Residential Address
          CustomTextField(
            controller: item.addressCtrl,
            label: 'Complete Residential Address (Optional)',
            hint: 'House/Flat No, Ward, Village/City, Post, Police Station',
            prefixIcon: Icons.home_outlined,
          ),
        ],
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
