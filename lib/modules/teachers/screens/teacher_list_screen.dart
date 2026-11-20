import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../models/teacher_model.dart';
import '../services/teacher_service.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDesignation = '';
  List<TeacherModel> _teachers = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers({int page = 1}) async {
    setState(() => _isLoading = true);

    final res = await TeacherService.fetchTeachers(
      search: _searchController.text.trim(),
      designation: _selectedDesignation,
      page: page,
      limit: 25,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
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

  Future<void> _confirmDelete(TeacherModel teacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to permanently delete teacher "${teacher.fullName}" (${teacher.teacherId})?\n\nThis will also remove all associated photographs and signatures from storage.',
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
            child: Row(
              children: [
                // Search Input
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by Name, Teacher ID, Mobile, or UDISE...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _fetchTeachers();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _fetchTeachers(),
                  ),
                ),
                const SizedBox(width: 14),

                // Designation Filter Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDesignation.isEmpty ? null : _selectedDesignation,
                    hint: const Text('All Designations', style: TextStyle(fontSize: 13)),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('All Designations')),
                      ...AppConstants.teacherDesignations.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedDesignation = val ?? '');
                      _fetchTeachers();
                    },
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
                const SizedBox(width: 14),

                // Search & Reset Buttons
                ElevatedButton(
                  onPressed: () => _fetchTeachers(),
                  child: const Text('Search'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _selectedDesignation = '');
                    _fetchTeachers();
                  },
                  child: const Text('Reset'),
                ),
                const Spacer(),

                // Add New Teacher Button
                ElevatedButton.icon(
                  onPressed: () {
                    nav.clearEditSelections();
                    nav.navigateTo(AppTab.teacherAdd);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Teacher'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                ),
              ],
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
                  : _teachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_search_outlined, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text('No teachers found matching criteria', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  nav.clearEditSelections();
                                  nav.navigateTo(AppTab.teacherAdd);
                                },
                                child: const Text('Register First Teacher'),
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
                                      DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('School & UDISE', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                                Text('DOB: ${t.dob} (${t.gender})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(t.designation, style: const TextStyle(fontSize: 13))),
                                          DataCell(Text(t.subject, style: const TextStyle(fontSize: 13))),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(t.schoolName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                                Text('UDISE: ${t.udiseCode}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(t.mobileNumber, style: const TextStyle(fontSize: 12)),
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
                                    'Showing ${_teachers.length} of $_totalCount teacher records',
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
      ),
    );
  }
}
