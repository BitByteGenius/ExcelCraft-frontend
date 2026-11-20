import 'dart:typed_data';

class PickedMediaFile {
  final String name;
  final Uint8List bytes;
  final String? path;

  PickedMediaFile({
    required this.name,
    required this.bytes,
    this.path,
  });
}
