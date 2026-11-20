import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/navigation_provider.dart';
import '../../../models/student_model.dart';
import '../../students/services/student_service.dart';
import '../services/id_card_pdf_generator.dart';

class StudentIdCardsScreen extends StatefulWidget {
  final int? initialStudentId;

  const StudentIdCardsScreen({super.key, this.initialStudentId});

  @override
  State<StudentIdCardsScreen> createState() => _StudentIdCardsScreenState();
}

class _StudentIdCardsScreenState extends State<StudentIdCardsScreen> {
  List<StudentModel> _students = [];
  StudentModel? _selectedStudent;
  bool _isLoadingStudents = true;
  Uint8List? _generatedPdfBytes;
  bool _isGeneratingCard = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final res = await StudentService.fetchStudents(limit: 500);
    if (mounted) {
      setState(() {
        _students = res.data ?? [];
        _isLoadingStudents = false;

        final targetId = widget.initialStudentId ?? context.read<NavigationProvider>().selectedStudentIdForCard;
        if (targetId != null) {
          final found = _students.where((s) => s.id == targetId).firstOrNull;
          if (found != null) {
            _selectedStudent = found;
            _generatePdf(found);
          }
        } else if (_students.isNotEmpty) {
          _selectedStudent = _students.first;
          _generatePdf(_students.first);
        }
      });
    }
  }

  Future<void> _generatePdf(StudentModel student) async {
    setState(() => _isGeneratingCard = true);
    final pdfBytes = await IdCardPdfGenerator.generateStudentCardPdf(student);
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
                const Icon(Icons.school, size: 28, color: AppColors.success),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student ID Card Generator & Printing Hub',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Select student to preview, print, or download official dual-sided ID cards with emergency and academic data.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Select Student Dropdown
                _isLoadingStudents
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<StudentModel>(
                          initialValue: _selectedStudent,
                          hint: const Text('Select Student', style: TextStyle(fontSize: 13)),
                          items: _students.map((s) {
                            return DropdownMenuItem<StudentModel>(
                              value: s,
                              child: Text(
                                '${s.fullName} (${s.studentId ?? s.admissionNumber})',
                                style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                              ),
                            );
                          }).toList(),
                          onChanged: (student) {
                            if (student != null) {
                              setState(() => _selectedStudent = student);
                              _generatePdf(student);
                            }
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            prefixIcon: Icon(Icons.school, size: 18),
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
                          Text('Rendering Student ID Card Template...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : _generatedPdfBytes == null
                      ? const Center(
                          child: Text('Please select a student to generate ID card', style: TextStyle(color: AppColors.textMuted)),
                        )
                      : PdfPreview(
                          build: (format) => _generatedPdfBytes!,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          allowPrinting: true,
                          allowSharing: true,
                          pdfFileName: 'Student_ID_${_selectedStudent?.studentId ?? "Card"}.pdf',
                          previewPageMargin: const EdgeInsets.all(16),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
