import 'dart:io';

enum FileCategory { image, video }

FileCategory getFileCategory(File file) {
  final String fileExt = file.path.split('.').last;
  if (fileExt == "mp4") {
    return FileCategory.video;
  } else {
    return FileCategory.image;
  }
}
