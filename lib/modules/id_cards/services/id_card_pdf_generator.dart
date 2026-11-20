import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/api_endpoints.dart';
import '../../../models/teacher_model.dart';
import '../../../models/student_model.dart';

class IdCardPdfGenerator {
  static Future<Uint8List?> _fetchImageBytes(String? relativeOrAbsoluteUrl) async {
    if (relativeOrAbsoluteUrl == null || relativeOrAbsoluteUrl.isEmpty) return null;
    try {
      final resolvedUrl = ApiEndpoints.resolveUrl(relativeOrAbsoluteUrl);
      final res = await http.get(Uri.parse(resolvedUrl)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return res.bodyBytes;
      }
    } catch (_) {}
    return null;
  }

  /// Generate Teacher ID Card PDF (Front and Back)
  static Future<Uint8List> generateTeacherCardPdf(TeacherModel teacher) async {
    final pdf = pw.Document();

    final photoBytes = await _fetchImageBytes(teacher.photoPath);
    final sigBytes = await _fetchImageBytes(teacher.headmasterSignaturePath);
    final sealBytes = await _fetchImageBytes(teacher.officialSealPath);

    final photoImage = photoBytes != null ? pw.MemoryImage(photoBytes) : null;
    final sigImage = sigBytes != null ? pw.MemoryImage(sigBytes) : null;
    final sealImage = sealBytes != null ? pw.MemoryImage(sealBytes) : null;

    // Standard CR80 Card Size in Points: 242.64 pt x 153.07 pt
    final cardFormat = PdfPageFormat(242.64, 153.07, marginAll: 6);

    // Front Side
    pdf.addPage(
      pw.Page(
        pageFormat: cardFormat,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.blueGrey800, width: 1),
            ),
            child: pw.Column(
              children: [
                // Card Top Banner
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF1E293B),
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(7),
                      topRight: pw.Radius.circular(7),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        teacher.schoolName.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        maxLines: 1,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'STAFF IDENTITY CARD • UDISE: ${teacher.udiseCode}',
                        style: const pw.TextStyle(
                          color: PdfColor.fromInt(0xFF93C5FD),
                          fontSize: 5.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Card Body
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left photo & ID
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 45,
                              height: 55,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              ),
                              child: photoImage != null
                                  ? pw.Image(photoImage, fit: pw.BoxFit.cover)
                                  : pw.Center(
                                      child: pw.Text('PHOTO', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                                    ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                              decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFF2563EB),
                                borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                              ),
                              child: pw.Text(
                                teacher.teacherId,
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 6, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        pw.SizedBox(width: 8),

                        // Right details
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                teacher.fullName,
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F172A)),
                              ),
                              pw.Text(
                                '${teacher.designation} (${teacher.subject})',
                                style: const pw.TextStyle(fontSize: 6.5, color: PdfColor.fromInt(0xFF2563EB)),
                              ),
                              pw.SizedBox(height: 3),
                              _cardField('DOB', teacher.dob),
                              _cardField('Blood Group', teacher.bloodGroup),
                              _cardField('Mobile', teacher.mobileNumber),
                              _cardField('Joining', teacher.dateOfJoining),
                              _cardField('Qual.', teacher.qualification),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Bottom Footer
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF1F5F9),
                    borderRadius: pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(7),
                      bottomRight: pw.Radius.circular(7),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('District: ${teacher.districtName}, ${teacher.state}', style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey700)),
                      if (sigImage != null)
                        pw.Container(
                          height: 14,
                          child: pw.Image(sigImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 4.5, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Back Side
    pdf.addPage(
      pw.Page(
        pageFormat: cardFormat,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.blueGrey800, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: const PdfColor.fromInt(0xFF334155),
                  child: pw.Text(
                    'FACULTY DETAILS & VERIFICATION',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 6.5, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _cardField("Father's Name", teacher.fatherName),
                        _cardField("Mother's Name", teacher.motherName),
                        _cardField('Email', teacher.email),
                        _cardField('Res. Address', teacher.residentialAddress),
                        _cardField('School Address', teacher.schoolAddress),
                        pw.Spacer(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            if (sealImage != null)
                              pw.Container(width: 28, height: 28, child: pw.Image(sealImage, fit: pw.BoxFit.contain))
                            else
                              pw.Container(width: 28, height: 28),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                if (sigImage != null)
                                  pw.Container(height: 16, width: 45, child: pw.Image(sigImage, fit: pw.BoxFit.contain)),
                                pw.Text(teacher.headmasterName, style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold)),
                                pw.Text('Headmaster / Principal', style: const pw.TextStyle(fontSize: 4.5, color: PdfColors.grey700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(2),
                  color: const PdfColor.fromInt(0xFF1E293B),
                  child: pw.Text(
                    'If found, please return to the school administration office.',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 4.5),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generate Student ID Card PDF (Front and Back)
  static Future<Uint8List> generateStudentCardPdf(StudentModel student) async {
    final pdf = pw.Document();

    final photoBytes = await _fetchImageBytes(student.photoPath);
    final sigBytes = await _fetchImageBytes(student.headmasterSignaturePath);
    final sealBytes = await _fetchImageBytes(student.officialSealPath);

    final photoImage = photoBytes != null ? pw.MemoryImage(photoBytes) : null;
    final sigImage = sigBytes != null ? pw.MemoryImage(sigBytes) : null;
    final sealImage = sealBytes != null ? pw.MemoryImage(sealBytes) : null;

    final cardFormat = PdfPageFormat(242.64, 153.07, marginAll: 6);

    // Front Side
    pdf.addPage(
      pw.Page(
        pageFormat: cardFormat,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFF0F766E), width: 1),
            ),
            child: pw.Column(
              children: [
                // Top Banner
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF0F766E),
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(7),
                      topRight: pw.Radius.circular(7),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        student.schoolName.toUpperCase(),
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                        maxLines: 1,
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        'STUDENT IDENTITY CARD • SESSION ${student.academicSession}',
                        style: const pw.TextStyle(color: PdfColor.fromInt(0xFFCCFBF1), fontSize: 5.5),
                      ),
                    ],
                  ),
                ),

                // Card Body
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Left photo & ID
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 45,
                              height: 55,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                              ),
                              child: photoImage != null
                                  ? pw.Image(photoImage, fit: pw.BoxFit.cover)
                                  : pw.Center(
                                      child: pw.Text('PHOTO', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                                    ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                              decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFF0F766E),
                                borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                              ),
                              child: pw.Text(
                                student.studentId ?? student.admissionNumber,
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 6, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        pw.SizedBox(width: 8),

                        // Right details
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                student.fullName,
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F172A)),
                              ),
                              pw.Text(
                                'Class: ${student.className ?? "-"}  |  Sec: ${student.section ?? "-"}  |  Roll: ${student.rollNumber ?? "-"}',
                                style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0F766E)),
                              ),
                              pw.SizedBox(height: 3),
                              _cardField("Father's Name", student.fatherName),
                              _cardField('DOB', student.dob),
                              _cardField('Blood Group', student.bloodGroup ?? '-'),
                              _cardField('Admission No.', student.admissionNumber),
                              _cardField('Contact', student.mobileNumber),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card Footer
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF1F5F9),
                    borderRadius: pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(7),
                      bottomRight: pw.Radius.circular(7),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('UDISE: ${student.udiseCode} • ${student.districtName}', style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey700)),
                      if (sigImage != null)
                        pw.Container(
                          height: 14,
                          child: pw.Image(sigImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Text('Principal Signatory', style: const pw.TextStyle(fontSize: 4.5, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Back Side
    pdf.addPage(
      pw.Page(
        pageFormat: cardFormat,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFF0F766E), width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: const PdfColor.fromInt(0xFF134E4A),
                  child: pw.Text(
                    'STUDENT EMERGENCY & RESIDENTIAL DETAILS',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 6.5, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _cardField("Mother's Name", student.motherName),
                        _cardField('Emergency Contact', student.mobileNumber),
                        _cardField('Res. Address', student.residentialAddress),
                        _cardField('School Address', student.schoolAddress),
                        pw.Spacer(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            if (sealImage != null)
                              pw.Container(width: 28, height: 28, child: pw.Image(sealImage, fit: pw.BoxFit.contain))
                            else
                              pw.Container(width: 28, height: 28),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                if (sigImage != null)
                                  pw.Container(height: 16, width: 45, child: pw.Image(sigImage, fit: pw.BoxFit.contain)),
                                pw.Text(student.headmasterName ?? 'Principal', style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold)),
                                pw.Text('Headmaster / Principal', style: const pw.TextStyle(fontSize: 4.5, color: PdfColors.grey700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(2),
                  color: const PdfColor.fromInt(0xFF0F766E),
                  child: pw.Text(
                    'Card is property of the school. If found please hand over to school office.',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 4.5),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _cardField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 48,
            child: pw.Text('$label:', style: pw.TextStyle(fontSize: 5.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 5.5, color: PdfColors.black), maxLines: 1),
          ),
        ],
      ),
    );
  }
}
