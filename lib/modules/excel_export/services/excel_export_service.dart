import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' as io;
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_colors.dart';

class ExcelExportService {
  static Future<void> downloadTeacherExcel(BuildContext context) async {
    await _downloadFile(
      context: context,
      url: ApiEndpoints.exportTeachers,
      defaultFileName: 'ExcelCraft_Teachers_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      moduleName: 'Teacher',
    );
  }

  static Future<void> downloadStudentExcel(BuildContext context) async {
    await _downloadFile(
      context: context,
      url: ApiEndpoints.exportStudents,
      defaultFileName: 'ExcelCraft_Students_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      moduleName: 'Student',
    );
  }

  static Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String defaultFileName,
    required String moduleName,
  }) async {
    try {
      if (kIsWeb) {
        // On Web: launch URL directly to trigger browser's native file download
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $moduleName Excel download triggered in your browser.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        return;
      }

      // On Native Desktop (Windows)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('Generating $moduleName Excel with embedded photographs...'),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      final res = await http.get(Uri.parse(url)).timeout(const Duration(minutes: 2));

      if (res.statusCode == 200) {
        io.Directory? downloadDir;
        if (!kIsWeb && io.Platform.isWindows) {
          final userProfile = io.Platform.environment['USERPROFILE'];
          if (userProfile != null) {
            downloadDir = io.Directory('$userProfile\\Downloads');
          }
        }
        downloadDir ??= await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();

        final filePath = '${downloadDir.path}\\$defaultFileName';
        final file = io.File(filePath);
        await file.writeAsBytes(res.bodyBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $moduleName Excel exported to: $filePath'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Open Folder',
                textColor: Colors.white,
                onPressed: () {
                  if (!kIsWeb && io.Platform.isWindows) {
                    io.Process.run('explorer.exe', ['/select,', filePath]);
                  }
                },
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to generate Excel file (HTTP ${res.statusCode})'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting Excel: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}
