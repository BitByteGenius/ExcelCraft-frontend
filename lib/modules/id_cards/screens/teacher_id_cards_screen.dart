import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../models/teacher_model.dart';
import '../../teachers/services/teacher_service.dart';
import '../services/id_card_pdf_generator.dart';

class TeacherIdCardsScreen extends StatefulWidget {
  final int? initialTeacherId;

  const TeacherIdCardsScreen({super.key, this.initialTeacherId});

  @override
  State<TeacherIdCardsScreen> createState() => _TeacherIdCardsScreenState();
}

class _TeacherIdCardsScreenState extends State<TeacherIdCardsScreen> {
  List<TeacherModel> _teachers = [];
  TeacherModel? _selectedTeacher;
  bool _isLoadingTeachers = true;
  Uint8List? _generatedPdfBytes;
  bool _isGeneratingCard = false;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final res = await TeacherService.fetchTeachers(limit: 500);
    if (mounted) {
      setState(() {
        _teachers = res.data ?? [];
        _isLoadingTeachers = false;

        final targetId = widget.initialTeacherId ?? context.read<NavigationProvider>().selectedTeacherIdForCard;
        if (targetId != null) {
          final found = _teachers.where((t) => t.id == targetId).firstOrNull;
          if (found != null) {
            _selectedTeacher = found;
            _generatePdf(found);
          }
        } else if (_teachers.isNotEmpty) {
          _selectedTeacher = _teachers.first;
          _generatePdf(_teachers.first);
        }
      });
    }
  }

  Future<void> _generatePdf(TeacherModel teacher) async {
    setState(() => _isGeneratingCard = true);
    final pdfBytes = await IdCardPdfGenerator.generateTeacherCardPdf(teacher);
    if (mounted) {
      setState(() {
        _generatedPdfBytes = pdfBytes;
        _isGeneratingCard = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge, size: 28, color: AppColors.accent),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Faculty ID Card Generator & Printing Hub',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Select teacher to preview, print, or download official dual-sided ID cards with QR/photo verification.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Select Teacher Dropdown
                _isLoadingTeachers
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<TeacherModel>(
                          initialValue: _selectedTeacher,
                          hint: const Text('Select Teacher', style: TextStyle(fontSize: 13)),
                          items: _teachers.map((t) {
                            return DropdownMenuItem<TeacherModel>(
                              value: t,
                              child: Text(
                                '${t.fullName} (${t.teacherId})',
                                style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                              ),
                            );
                          }).toList(),
                          onChanged: (teacher) {
                            if (teacher != null) {
                              setState(() => _selectedTeacher = teacher);
                              _generatePdf(teacher);
                            }
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            prefixIcon: Icon(Icons.person, size: 18),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Live Card Preview Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isGeneratingCard
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Rendering CR80 ID Card Template with High-Res Images...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : _generatedPdfBytes == null
                      ? const Center(
                          child: Text('Please select a teacher to generate ID card', style: TextStyle(color: AppColors.textMuted)),
                        )
                      : PdfPreview(
                          build: (format) => _generatedPdfBytes!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          allowPrinting: true,
                          allowSharing: true,
                          pdfFileName: 'Teacher_ID_${_selectedTeacher?.teacherId ?? "Card"}.pdf',
                          previewPageMargin: const EdgeInsets.all(16),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
