// Dart Imports
import 'dart:io';

class SortedResult {
  final File file;
  final String sorted;
  final bool changed;

  SortedResult({
    required this.file,
    required this.sorted,
    required this.changed,
  });

  @override
  String toString() {
    return '''
    SortedResult {
      file: $file
      changed: $changed
    }
    ''';
  }
}
