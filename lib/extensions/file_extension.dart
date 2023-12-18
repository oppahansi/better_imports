// Dart Imports
import 'dart:io';

extension FileSystemEntityExtension on FileSystemEntity {
  bool get isFile {
    return this is File;
  }

  bool get isDirectory {
    return this is Directory;
  }

  String get name {
    return path.split(Platform.pathSeparator).last;
  }
}
