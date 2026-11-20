import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';
import '../../excel_export/services/excel_export_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final summary = await DashboardService.fetchSummary();
    if (mounted) {
      setState(() {
        _summary = summary;
        _isLoading = false;
        if (summary == null) {
          _errorMessage = 'Could not load summary. Please ensure backend server is running.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationProvider>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    title: 'Total Teachers',
                    value: '${_summary?.totalTeachers ?? 0}',
                    subtitle: 'Registered faculty members',
                    icon: Icons.person_outline_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () => nav.navigateTo(AppTab.teacherList),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    title: 'Total Students',
                    value: '${_summary?.totalStudents ?? 0}',
                    subtitle: 'Enrolled student records',
                    icon: Icons.school_outlined,
                    color: const Color(0xFF10B981),
                    onTap: () => nav.navigateTo(AppTab.studentList),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    title: 'Excel Engine',
                    value: 'ExcelJS Active',
                    subtitle: 'Image embedding enabled',
                    icon: Icons.table_chart_outlined,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => nav.navigateTo(AppTab.excelExport),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _metricCard(
                    title: 'Database Storage',
                    value: 'SQLite WAL',
                    subtitle: 'Local persistent storage',
                    icon: Icons.storage_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Operational Actions',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          nav.clearEditSelections();
                          nav.navigateTo(AppTab.teacherAdd);
                        },
                        icon: const Icon(Icons.person_add_alt_1, size: 16),
                        label: const Text('Quick Add Teacher'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          nav.clearEditSelections();
                          nav.navigateTo(AppTab.studentAdd);
                        },
                        icon: const Icon(Icons.school, size: 16),
                        label: const Text('Quick Add Student'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => ExcelExportService.downloadTeacherExcel(context),
                        icon: const Icon(Icons.file_download, size: 16, color: Color(0xFF0F766E)),
                        label: const Text('Export Teachers Excel', style: TextStyle(color: Color(0xFF0F766E))),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => ExcelExportService.downloadStudentExcel(context),
                        icon: const Icon(Icons.file_download, size: 16, color: Color(0xFF0369A1)),
                        label: const Text('Export Students Excel', style: TextStyle(color: Color(0xFF0369A1))),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Teachers & Students Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Teachers
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recently Added Teachers',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            TextButton(
                              onPressed: () => nav.navigateTo(AppTab.teacherList),
                              child: const Text('View All', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(),
                        if ((_summary?.recentTeachers.isEmpty ?? true))
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('No teachers registered yet', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ),
                          )
                        else
                          ..._summary!.recentTeachers.map((t) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                                  backgroundImage: t.photoPath != null && t.photoPath!.isNotEmpty
                                      ? NetworkImage(ApiEndpoints.resolveUrl(t.photoPath))
                                      : null,
                                  child: (t.photoPath == null || t.photoPath!.isEmpty)
                                      ? Text(t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : 'T',
                                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                title: Text(t.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                subtitle: Text('${t.designation} • ${t.subject}', style: const TextStyle(fontSize: 11)),
                                trailing: Text(t.teacherId, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Recent Students
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recently Added Students',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            TextButton(
                              onPressed: () => nav.navigateTo(AppTab.studentList),
                              child: const Text('View All', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(),
                        if ((_summary?.recentStudents.isEmpty ?? true))
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('No students registered yet', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ),
                          )
                        else
                          ..._summary!.recentStudents.map((s) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                  backgroundImage: s.photoPath != null && s.photoPath!.isNotEmpty
                                      ? NetworkImage(ApiEndpoints.resolveUrl(s.photoPath))
                                      : null,
                                  child: (s.photoPath == null || s.photoPath!.isEmpty)
                                      ? Text(s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : 'S',
                                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))
                                      : null,
                                ),
                                title: Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                subtitle: Text('Class: ${s.className ?? '-'} • Sec: ${s.section ?? '-'}', style: const TextStyle(fontSize: 11)),
                                trailing: Text(s.studentId ?? s.admissionNumber, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity Log
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Audit & System Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const Divider(),
                  if (_summary?.recentActivities.isEmpty ?? true)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No activity records found.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    )
                  else
                    ..._summary!.recentActivities.map((act) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(act.module, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(act.description, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                              ),
                              Text(act.createdAt, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
