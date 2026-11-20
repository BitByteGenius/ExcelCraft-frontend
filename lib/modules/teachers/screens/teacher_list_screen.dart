import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../models/teacher_model.dart';
import '../../../models/school_model.dart';
import '../services/teacher_service.dart';
import '../../excel_export/services/excel_export_service.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  // Mode: null means viewing all schools; non-null means drilling into a specific school
  SchoolSummaryModel? _selectedSchool;

  // School directory state
  final TextEditingController _schoolSearchCtrl = TextEditingController();
  List<SchoolSummaryModel> _schools = [];
  bool _isLoadingSchools = true;

  // Teacher list state (within selected school or flat view)
  final TextEditingController _teacherSearchCtrl = TextEditingController();
  String _selectedDesignation = '';
  List<TeacherModel> _teachers = [];
  bool _isLoadingTeachers = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  @override
  void dispose() {
    _schoolSearchCtrl.dispose();
    _teacherSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSchools() async {
    setState(() => _isLoadingSchools = true);
    final res = await TeacherService.fetchSchoolsSummary(
      search: _schoolSearchCtrl.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoadingSchools = false;
        _schools = res.data ?? [];
      });
    }
  }

  Future<void> _fetchTeachers({int page = 1}) async {
    setState(() => _isLoadingTeachers = true);

    final res = await TeacherService.fetchTeachers(
      school: _selectedSchool?.schoolName ?? '',
      search: _teacherSearchCtrl.text.trim(),
      designation: _selectedDesignation,
      page: page,
      limit: 50,
    );

    if (mounted) {
      setState(() {
        _isLoadingTeachers = false;
        if (res.success && res.data != null) {
          _teachers = res.data!;
          _currentPage = res.pagination?['page'] as int? ?? 1;
          _totalPages = res.pagination?['totalPages'] as int? ?? 1;
          _totalCount = res.pagination?['total'] as int? ?? 0;
        } else {
          _teachers = [];
        }
      });
    }
  }

  void _selectSchool(SchoolSummaryModel school) {
    setState(() {
      _selectedSchool = school;
      _teacherSearchCtrl.clear();
      _selectedDesignation = '';
    });
    _fetchTeachers(page: 1);
  }

  void _backToSchools() {
    setState(() {
      _selectedSchool = null;
      _teachers.clear();
    });
    _fetchSchools();
  }

  Future<void> _confirmDelete(TeacherModel teacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to permanently delete teacher "${teacher.fullName}" (${teacher.teacherId}) from "${teacher.schoolName}"?\n\nThis will also remove all associated photographs and signatures.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && teacher.id != null) {
      final res = await TeacherService.deleteTeacher(teacher.id!);
      if (mounted) {
        if (res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Teacher ${teacher.fullName} deleted successfully.'),
              backgroundColor: AppColors.success,
            ),
          );
          _fetchTeachers(page: _currentPage);
          _fetchSchools(); // refresh counts
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res.message ?? 'Failed to delete record'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb Navigation & Top Action Bar
          _buildTopNavigationBar(),
          const SizedBox(height: 16),

          // Main Content: Either Schools Directory OR School Teachers Roster
          Expanded(
            child: _selectedSchool == null
                ? _buildSchoolsDirectoryView()
                : _buildSchoolTeachersRosterView(),
          ),
        ],
      ),
    );
  }

  /// Top Navigation Bar with Breadcrumbs & Action Buttons
  Widget _buildTopNavigationBar() {
    final nav = context.read<NavigationProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (_selectedSchool != null) ...[
            InkWell(
              onTap: _backToSchools,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
                    SizedBox(width: 6),
                    Text('All Schools', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedSchool != null
                      ? _selectedSchool!.schoolName
                      : 'Schools Faculty Directory',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedSchool != null
                      ? 'UDISE: ${_selectedSchool!.udiseCode} • $_totalCount Registered Teachers'
                      : '${_schools.length} Institutions Registered with Faculty Records',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Export Button for School
          if (_selectedSchool != null) ...[
            ElevatedButton.icon(
              onPressed: () => ExcelExportService.downloadSchoolTeacherExcel(context, _selectedSchool!.schoolName),
              icon: const Icon(Icons.table_view_rounded, size: 16),
              label: const Text('Export School Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Quick Add Teacher / Batch Button
          ElevatedButton.icon(
            onPressed: () {
              nav.clearEditSelections();
              nav.navigateTo(AppTab.teacherAdd);
            },
            icon: const Icon(Icons.person_add_alt_1, size: 16),
            label: const Text('+ Add Teacher'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          ),
        ],
      ),
    );
  }

  /// LEVEL 1: Schools Directory Cards View
  Widget _buildSchoolsDirectoryView() {
    return Column(
      children: [
        // Responsive School Search Filter
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _schoolSearchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by School Name, UDISE Code, or District...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _schoolSearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _schoolSearchCtrl.clear();
                              _fetchSchools();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _fetchSchools(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _fetchSchools,
                child: const Text('Search'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _schoolSearchCtrl.clear();
                  _fetchSchools();
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Schools Cards Grid / List
        Expanded(
          child: _isLoadingSchools
              ? const Center(child: CircularProgressIndicator())
              : _schools.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 54, color: AppColors.textMuted),
                          const SizedBox(height: 14),
                          const Text(
                            'No schools found in database',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Register teachers in batch to populate schools directory automatically.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              final nav = context.read<NavigationProvider>();
                              nav.clearEditSelections();
                              nav.navigateTo(AppTab.teacherAdd);
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Teachers Now'),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive grid: 2 columns on wide screens, 1 on narrow
                        final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                        final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

                        return ListView.builder(
                          itemCount: (_schools.length / crossAxisCount).ceil(),
                          itemBuilder: (ctx, rowIndex) {
                            final startIndex = rowIndex * crossAxisCount;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(crossAxisCount, (colIndex) {
                                  final idx = startIndex + colIndex;
                                  if (idx >= _schools.length) {
                                    return SizedBox(width: itemWidth);
                                  }
                                  final school = _schools[idx];
                                  return SizedBox(
                                    width: itemWidth,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: colIndex < crossAxisCount - 1 ? 16 : 0,
                                      ),
                                      child: _buildSchoolCard(school),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  /// Individual School Card
  Widget _buildSchoolCard(SchoolSummaryModel school) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _selectSchool(school),
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.account_balance, color: AppColors.accent, size: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            school.schoolName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  'UDISE: ${school.udiseCode}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                              if (school.districtName.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${school.districtName}, ${school.state}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Faculty Count Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people, size: 14, color: Color(0xFF0F766E)),
                          const SizedBox(width: 4),
                          Text(
                            '${school.teacherCount} Teachers',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),

                // Card Footer with Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (school.headmasterName.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings_outlined, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Principal: ${school.headmasterName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),

                    Row(
                      children: [
                        // Quick Export Excel button right on school card
                        OutlinedButton.icon(
                          onPressed: () => ExcelExportService.downloadSchoolTeacherExcel(context, school.schoolName),
                          icon: const Icon(Icons.file_download, size: 14, color: Color(0xFF0F766E)),
                          label: const Text('Export Excel', style: TextStyle(fontSize: 11, color: Color(0xFF0F766E))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            side: const BorderSide(color: Color(0xFF0F766E)),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // View Teachers button
                        ElevatedButton.icon(
                          onPressed: () => _selectSchool(school),
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text('View Teachers', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// LEVEL 2: School Teachers Roster Data Table View
  Widget _buildSchoolTeachersRosterView() {
    final nav = context.read<NavigationProvider>();

    return Column(
      children: [
        // Responsive Filters Bar without any pixel overflow
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Search Input
                  SizedBox(
                    width: constraints.maxWidth > 700 ? 280 : constraints.maxWidth,
                    child: TextField(
                      controller: _teacherSearchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search Name, ID, Mobile, or Subject...',
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                        suffixIcon: _teacherSearchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _teacherSearchCtrl.clear();
                                  _fetchTeachers(page: 1);
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _fetchTeachers(page: 1),
                    ),
                  ),

                  // Designation Dropdown
                  SizedBox(
                    width: constraints.maxWidth > 700 ? 220 : constraints.maxWidth,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDesignation.isEmpty ? null : _selectedDesignation,
                      hint: const Text('All Designations', style: TextStyle(fontSize: 12)),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All Designations')),
                        ...AppConstants.teacherDesignations.map(
                          (d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => _selectedDesignation = val ?? '');
                        _fetchTeachers(page: 1);
                      },
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                    ),
                  ),

                  // Filter Buttons
                  ElevatedButton(
                    onPressed: () => _fetchTeachers(page: 1),
                    child: const Text('Filter'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _teacherSearchCtrl.clear();
                      setState(() => _selectedDesignation = '');
                      _fetchTeachers(page: 1);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Teachers Data Table Container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _isLoadingTeachers
                ? const Center(child: CircularProgressIndicator())
                : _teachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              'No teachers found for "${_selectedSchool?.schoolName ?? ""}"',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {
                                nav.clearEditSelections();
                                nav.navigateTo(AppTab.teacherAdd);
                              },
                              child: const Text('Add Teachers to this School'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Table Content
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(AppColors.background),
                                  headingRowHeight: 46,
                                  dataRowMinHeight: 62,
                                  dataRowMaxHeight: 62,
                                  columnSpacing: 24,
                                  columns: const [
                                    DataColumn(label: Text('Photo', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Teacher ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Joining Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: _teachers.map((t) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: AppColors.border,
                                            backgroundImage: t.photoPath != null && t.photoPath!.isNotEmpty
                                                ? NetworkImage(ApiEndpoints.resolveUrl(t.photoPath))
                                                : null,
                                            child: (t.photoPath == null || t.photoPath!.isEmpty)
                                                ? const Icon(Icons.person, color: AppColors.textMuted, size: 20)
                                                : null,
                                          ),
                                        ),
                                        DataCell(
                                          Text(t.teacherId, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent)),
                                        ),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(t.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                              Text(
                                                t.fatherName.isNotEmpty ? "Father: ${t.fatherName}" : "DOB: ${t.dob}",
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        DataCell(Text(t.designation, style: const TextStyle(fontSize: 12))),
                                        DataCell(Text(t.subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                        DataCell(Text(t.dateOfJoining.isNotEmpty ? t.dateOfJoining : '-', style: const TextStyle(fontSize: 12))),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(t.mobileNumber, style: const TextStyle(fontSize: 12)),
                                              if (t.email.isNotEmpty)
                                                Text(t.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                            ],
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.badge, size: 18, color: Color(0xFF2563EB)),
                                                tooltip: 'View ID Card',
                                                onPressed: () {
                                                  if (t.id != null) nav.openTeacherCardPreview(t.id!);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF10B981)),
                                                tooltip: 'Edit Teacher',
                                                onPressed: () {
                                                  if (t.id != null) nav.openTeacherEdit(t.id!);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                                tooltip: 'Delete Record',
                                                onPressed: () => _confirmDelete(t),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),

                          // Pagination Footer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Showing ${_teachers.length} of $_totalCount faculty records',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: _currentPage > 1 ? () => _fetchTeachers(page: _currentPage - 1) : null,
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                      child: const Text('Previous'),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Page $_currentPage of $_totalPages',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: _currentPage < _totalPages ? () => _fetchTeachers(page: _currentPage + 1) : null,
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                      child: const Text('Next'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
}
