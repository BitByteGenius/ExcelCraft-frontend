import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/excel_export_service.dart';

class ExcelExportScreen extends StatefulWidget {
  const ExcelExportScreen({super.key});

  @override
  State<ExcelExportScreen> createState() => _ExcelExportScreenState();
}

class _ExcelExportScreenState extends State<ExcelExportScreen> {
  bool _isExportingTeacher = false;
  bool _isExportingStudent = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'Professional Excel Workbooks Generator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Export database records into standalone formatted Excel (.xlsx) files with actual embedded photos and signatures.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Highlighting Feature Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct Binary Image Embedding Guarantee',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Photographs and signatures are encoded directly inside the OpenXML package. They will remain visible on any computer even without internet or network access.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Two Export Cards (Teacher & Student)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher Export Card
              Expanded(
                child: _exportCard(
                  title: 'Teacher Excel Workbook',
                  subtitle: 'Includes all 25 faculty attributes, embedded passport photo, and headmaster signature',
                  icon: Icons.person_pin_rounded,
                  badge: 'Faculty Roster',
                  accentColor: const Color(0xFF2563EB),
                  columns: const [
                    'Teacher ID',
                    'Embedded Photograph',
                    'Full Name & Parents',
                    'DOB, Gender & Blood Group',
                    'Contact & Email',
                    'Residential Address',
                    'School & Address',
                    'Designation & Subject',
                    'Joining Date & UDISE',
                    'Qualification & State',
                    'Embedded Headmaster Signature',
                  ],
                  isLoading: _isExportingTeacher,
                  onExport: () async {
                    setState(() => _isExportingTeacher = true);
                    await ExcelExportService.downloadTeacherExcel(context);
                    if (mounted) setState(() => _isExportingTeacher = false);
                  },
                ),
              ),

              const SizedBox(width: 20),

              // Student Export Card
              Expanded(
                child: _exportCard(
                  title: 'Student Excel Workbook',
                  subtitle: 'Includes 25 student metrics, embedded candidate photo, roll numbers, and admission info',
                  icon: Icons.school_rounded,
                  badge: 'Student Register',
                  accentColor: const Color(0xFF10B981),
                  columns: const [
                    'Student ID',
                    'Embedded Photograph',
                    'Full Name & Parents',
                    'DOB & Gender',
                    'Guardian Mobile & Address',
                    'Class, Section & Roll No',
                    'Admission No. & Date',
                    'Academic Session',
                    'School Name & UDISE',
                    'Block, District & State',
                    'Embedded Headmaster Signature',
                  ],
                  isLoading: _isExportingStudent,
                  onExport: () async {
                    setState(() => _isExportingStudent = true);
                    await ExcelExportService.downloadStudentExcel(context);
                    if (mounted) setState(() => _isExportingStudent = false);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _exportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
    required Color accentColor,
    required List<String> columns,
    required bool isLoading,
    required VoidCallback onExport,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: accentColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Included Excel Columns:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...columns.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: accentColor),
                    const SizedBox(width: 8),
                    Text(c, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onExport,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(isLoading ? 'Generating Excel...' : 'Generate & Export .XLSX'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
