// Dart Imports
import 'dart:io';

// Project Imports
import 'package:better_imports/config/config.dart';
import 'package:better_imports/extensions/extensions.dart';
import 'package:better_imports/utils/utils.dart';

class Sorter {
  final List<String> paths;
  final Cfg cfg;

  final dartImports = <ImportLine>[];
  final flutterImports = <ImportLine>[];
  final packageImports = <ImportLine>[];
  final relativeProjectImports = <ImportLine>[];
  final projectImports = <ImportLine>[];
  final toBeRemoved = <String>[];

  final original = <String>[];

  var emptyLinesInImports = 0;

  Sorter({required this.paths, required this.cfg});

  List<String> sort() {
    var results = <String>[];

    for (var path in paths) {
      var result = _sortFile(path);

      if (result.changed) {
        result.file.writeAsStringSync(
            "${result.sorted.join(Platform.lineTerminator)}${Platform.lineTerminator}");

        results.add(result.file.name);
      }
    }

    return results;
  }

  SortedFileEntity _sortFile(String path) {
    _reset();

    var file = File(path);
    original.addAll(file.readAsLinesSync());

    if (cfg.comments) {
      _addImportComments();
    }

    bool inImportSection = true;

    for (var i = 0; i < original.length; i++) {
      var line = original[i];

      if (!line.startsWith("import") && inImportSection) {
        if (_startsWithComment(line)) {
          continue;
        }

        if (line.isEmpty) {
          emptyLinesInImports++;
          continue;
        }

        inImportSection = false;
        continue;
      }

      if (inImportSection) {
        var importLine = _extractImport(i, original);
        var importSet = importLine.importLines.toSet();

        if (importSet.first.contains('dart:')) {
          if (!dartImports.contains(importLine)) {
            dartImports.add(importLine);
          }
        } else if (importSet.first.contains('package:flutter/')) {
          if (!flutterImports.contains(importLine)) {
            flutterImports.add(importLine);
          }
        } else if (importSet.first.contains('package:${cfg.projectName}/')) {
          if (!projectImports.contains(importLine)) {
            projectImports.add(importLine);
          }
        } else if (importSet.first.contains('package:')) {
          if (!packageImports.contains(importLine)) {
            packageImports.add(importLine);
          }
        } else {
          if (!relativeProjectImports.contains(importLine)) {
            relativeProjectImports.add(importLine);
          }
        }

        i = importLine.endIndex;
        continue;
      }
    }

    var sorted = _getSorted();

    return SortedFileEntity(
      file: file,
      original: original,
      sorted: sorted,
      changed: !_listEquals(original, sorted),
    );
  }

  bool _startsWithComment(String line) {
    var isComment = false;

    if (!isComment && line == Constants.dartImportsComment) {
      isComment = !isComment;
    } else if (!isComment && line == Constants.flutterImportsComment) {
      isComment = !isComment;
    } else if (!isComment && line == Constants.packageImportsComment) {
      isComment = !isComment;
    } else if (!isComment && line == Constants.projectImportsComment) {
      isComment = !isComment;
    } else if (!isComment && line == Constants.relativeProjectImportsComment) {
      isComment = !isComment;
    }

    return isComment;
  }

  void _addImportComments() {
    dartImports.add(
      ImportLine(importLines: [Constants.dartImportsComment], endIndex: 0),
    );
    flutterImports.add(
      ImportLine(importLines: [Constants.flutterImportsComment], endIndex: 0),
    );
    packageImports.add(
      ImportLine(importLines: [Constants.packageImportsComment], endIndex: 0),
    );
    projectImports.add(
      ImportLine(importLines: [Constants.projectImportsComment], endIndex: 0),
    );
    relativeProjectImports.add(
      ImportLine(
          importLines: [Constants.relativeProjectImportsComment], endIndex: 0),
    );
  }

  void _reset() {
    original.clear();
    dartImports.clear();
    flutterImports.clear();
    packageImports.clear();
    projectImports.clear();
    relativeProjectImports.clear();
    toBeRemoved.clear();
    emptyLinesInImports = 0;
  }

  ImportLine _extractImport(int startIndex, List<String> original) {
    var endIndex = startIndex;
    var importLines = <String>[];

    for (var i = startIndex;; i++) {
      importLines.add(original[i]);
      toBeRemoved.add(original[i]);
      endIndex = i;

      if (original[i].endsWith(";")) {
        break;
      }
    }

    return ImportLine(
      importLines: importLines,
      endIndex: endIndex,
    );
  }

  List<String> _getSorted() {
    var sorted = List<String>.from(original);

    if (cfg.comments) {
      if (dartImports.length == 1) {
        dartImports.clear();
      }
      if (flutterImports.length == 1) {
        flutterImports.clear();
      }
      if (packageImports.length == 1) {
        packageImports.clear();
      }
      if (projectImports.length == 1) {
        projectImports.clear();
      }
      if (relativeProjectImports.length == 1) {
        relativeProjectImports.clear();
      }
    }

    if (dartImports.isNotEmpty) {
      dartImports
          .sort((a, b) => a.importLines.first.compareTo(b.importLines.first));
      dartImports.add(
        ImportLine(importLines: [""], endIndex: 0),
      );
    }
    if (flutterImports.isNotEmpty) {
      flutterImports
          .sort((a, b) => a.importLines.first.compareTo(b.importLines.first));
      flutterImports.add(
        ImportLine(importLines: [""], endIndex: 0),
      );
    }
    if (packageImports.isNotEmpty) {
      packageImports
          .sort((a, b) => a.importLines.first.compareTo(b.importLines.first));
      packageImports.add(
        ImportLine(importLines: [""], endIndex: 0),
      );
    }
    if (projectImports.isNotEmpty) {
      projectImports
          .sort((a, b) => a.importLines.first.compareTo(b.importLines.first));
      projectImports.add(
        ImportLine(importLines: [""], endIndex: 0),
      );
    }
    if (relativeProjectImports.isNotEmpty) {
      relativeProjectImports
          .sort((a, b) => a.importLines.first.compareTo(b.importLines.first));
      relativeProjectImports.add(
        ImportLine(importLines: [""], endIndex: 0),
      );
    }

    _removeImports(sorted, toBeRemoved);
    _removeImportLine(sorted, Constants.dartImportsComment);
    _removeImportLine(sorted, Constants.flutterImportsComment);
    _removeImportLine(sorted, Constants.packageImportsComment);
    _removeImportLine(sorted, Constants.projectImportsComment);
    _removeImportLine(sorted, Constants.relativeProjectImportsComment);

    _insertImports(sorted, relativeProjectImports);
    _insertImports(sorted, projectImports);
    _insertImports(sorted, packageImports);
    _insertImports(sorted, flutterImports);
    _insertImports(sorted, dartImports);

    return sorted;
  }

  void _removeImports(List<String> sorted, List<String> toBeRemoved) {
    for (var removed in toBeRemoved) {
      for (var line in removed.split(Platform.lineTerminator)) {
        _removeImportLine(sorted, line);
      }
    }

    for (var i = 0; i < emptyLinesInImports; i++) {
      _removeImportLine(sorted, "");
    }
  }

  void _removeImportLine(List<String> sorted, String line) {
    if (line.isEmpty) {
      sorted.remove(line);
    } else {
      sorted.removeWhere((element) => element.contains(line));
    }
  }

  _insertImports(List<String> sorted, List<ImportLine> importLines) {
    for (var importLine in importLines.reversed) {
      sorted.insertAll(0, importLine.importLines);
    }
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) {
      return b == null;
    }
    if (b == null || a.length != b.length) {
      return false;
    }
    if (identical(a, b)) {
      return true;
    }
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}

class SortedFileEntity {
  final File file;
  final List<String> original;
  final List<String> sorted;
  final bool changed;

  SortedFileEntity({
    required this.file,
    required this.original,
    required this.sorted,
    required this.changed,
  });
}

class ImportLine {
  final List<String> importLines;
  final int endIndex;

  ImportLine({
    required this.importLines,
    required this.endIndex,
  });
}
