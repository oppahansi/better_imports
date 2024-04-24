// Dart Imports
import 'dart:io';

class SortedResult {
  final File file;
  final String sortedContent;
  final bool changed;

  SortedResult({
    required this.file,
    required this.sortedContent,
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
