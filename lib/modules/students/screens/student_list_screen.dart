import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../models/student_model.dart';
import '../services/student_service.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedClass = '';
  String _selectedSection = '';
  List<StudentModel> _students = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents({int page = 1}) async {
    setState(() => _isLoading = true);

    final res = await StudentService.fetchStudents(
      search: _searchController.text.trim(),
      className: _selectedClass,
      section: _selectedSection,
      page: page,
      limit: 25,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _students = res.data!;
          _currentPage = res.pagination?['page'] as int? ?? 1;
          _totalPages = res.pagination?['totalPages'] as int? ?? 1;
          _totalCount = res.pagination?['total'] as int? ?? 0;
        } else {
          _students = [];
        }
      });
    }
  }

  Future<void> _confirmDelete(StudentModel student) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to permanently delete student "${student.fullName}" (${student.studentId ?? student.admissionNumber})?\n\nThis will also remove all associated photographs and signatures from storage.',
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

    if (confirmed == true && student.id != null) {
      final res = await StudentService.deleteStudent(student.id!);
      if (mounted) {
        if (res.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student ${student.fullName} deleted successfully.'),
              backgroundColor: AppColors.success,
            ),
          );
          _fetchStudents(page: _currentPage);
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
    final nav = context.read<NavigationProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(16),
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
                      width: constraints.maxWidth > 800 ? 300 : constraints.maxWidth,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Name, ID, Admission No, or Mobile...',
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _fetchStudents();
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _fetchStudents(),
                      ),
                    ),

                    // Class Filter Dropdown
                    SizedBox(
                      width: constraints.maxWidth > 800 ? 150 : (constraints.maxWidth - 12) / 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedClass.isEmpty ? null : _selectedClass,
                        isExpanded: true,
                        isDense: true,
                        hint: const Text('All Classes', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All Classes', overflow: TextOverflow.ellipsis)),
                          ...AppConstants.classes.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedClass = val ?? '');
                          _fetchStudents();
                        },
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      ),
                    ),

                    // Section Filter Dropdown
                    SizedBox(
                      width: constraints.maxWidth > 800 ? 110 : (constraints.maxWidth - 12) / 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSection.isEmpty ? null : _selectedSection,
                        isExpanded: true,
                        isDense: true,
                        hint: const Text('Section', style: TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('All', overflow: TextOverflow.ellipsis)),
                          ...AppConstants.sections.map(
                            (s) => DropdownMenuItem(value: s, child: Text('Sec $s', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedSection = val ?? '');
                          _fetchStudents();
                        },
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      ),
                    ),

                    // Search & Reset Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => _fetchStudents(),
                          child: const Text('Search'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _selectedClass = '';
                              _selectedSection = '';
                            });
                            _fetchStudents();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),

                    // Add New Student Button
                    ElevatedButton.icon(
                      onPressed: () {
                        nav.clearEditSelections();
                        nav.navigateTo(AppTab.studentAdd);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Student'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Data Table Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.school_outlined, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text('No students found matching criteria', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  nav.clearEditSelections();
                                  nav.navigateTo(AppTab.studentAdd);
                                },
                                child: const Text('Register First Student'),
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
                                      DataColumn(label: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Class & Section', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Roll No.', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Admission No.', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('School & Session', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: _students.map((s) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: AppColors.border,
                                              backgroundImage: s.photoPath != null && s.photoPath!.isNotEmpty
                                                  ? NetworkImage(ApiEndpoints.resolveUrl(s.photoPath))
                                                  : null,
                                              child: (s.photoPath == null || s.photoPath!.isEmpty)
                                                  ? const Icon(Icons.person, color: AppColors.textMuted, size: 20)
                                                  : null,
                                            ),
                                          ),
                                          DataCell(
                                            Text(s.studentId ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent)),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                                Text('Father: ${s.fatherName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.background,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.border),
                                              ),
                                              child: Text('${s.className ?? "-"} (${s.section ?? "-"})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                            ),
                                          ),
                                          DataCell(Text(s.rollNumber ?? '-', style: const TextStyle(fontSize: 12))),
                                          DataCell(Text(s.admissionNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(s.schoolName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                Text('Session: ${s.academicSession}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(s.mobileNumber, style: const TextStyle(fontSize: 12))),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.badge, size: 18, color: Color(0xFF2563EB)),
                                                  tooltip: 'View ID Card',
                                                  onPressed: () {
                                                    if (s.id != null) nav.openStudentCardPreview(s.id!);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFF10B981)),
                                                  tooltip: 'Edit Student',
                                                  onPressed: () {
                                                    if (s.id != null) nav.openStudentEdit(s.id!);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                                  tooltip: 'Delete Record',
                                                  onPressed: () => _confirmDelete(s),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    runSpacing: 10,
                                    spacing: 12,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Showing ${_students.length} of $_totalCount student records',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OutlinedButton(
                                            onPressed: _currentPage > 1 ? () => _fetchStudents(page: _currentPage - 1) : null,
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
                                            onPressed: _currentPage < _totalPages ? () => _fetchStudents(page: _currentPage + 1) : null,
                                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                            child: const Text('Next'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
