import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;
import '../constants/app_colors.dart';
import '../constants/api_endpoints.dart';
import '../utils/picked_media_file.dart';

class ImagePickerBox extends StatelessWidget {
  final String label;
  final PickedMediaFile? selectedFile;
  final String? existingPath;
  final ValueChanged<PickedMediaFile?> onImageSelected;
  final double width;
  final double height;
  final bool isRequired;
  final String helperText;

  const ImagePickerBox({
    super.key,
    required this.label,
    required this.selectedFile,
    this.existingPath,
    required this.onImageSelected,
    this.width = 160,
    this.height = 180,
    this.isRequired = false,
    this.helperText = 'JPG, JPEG, PNG only',
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.single;
        Uint8List? bytes = picked.bytes;
        if (!kIsWeb && bytes == null && picked.path != null) {
          bytes = io.File(picked.path!).readAsBytesSync();
        }

        if (bytes != null) {
          onImageSelected(
            PickedMediaFile(
              name: picked.name,
              bytes: bytes,
              path: kIsWeb ? null : picked.path,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPickedImage = selectedFile != null && selectedFile!.bytes.isNotEmpty;
    final hasRemoteImage = existingPath != null && existingPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (hasPickedImage || hasRemoteImage) ? AppColors.accent : AppColors.border,
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasPickedImage)
                Image.memory(
                  selectedFile!.bytes,
                  fit: BoxFit.contain,
                )
              else if (hasRemoteImage)
                Image.network(
                  ApiEndpoints.resolveUrl(existingPath),
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Center(
                    child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 36),
                  ),
                )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Image',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        helperText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pickImage(context),
                  ),
                ),
              ),
              if (hasPickedImage || hasRemoteImage)
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: () => onImageSelected(null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
