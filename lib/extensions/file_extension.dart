// Dart Imports
import 'dart:io';

extension FileSystemEntityExtension on FileSystemEntity {
  String get name {
    return path.split(Platform.pathSeparator).last;
  }
}
