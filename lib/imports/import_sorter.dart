// Dart Imports
import 'dart:io';

// Project Imports
import 'package:better_imports/config/config.dart';
import 'package:better_imports/extensions/extensions.dart';
import 'package:better_imports/utils/utils.dart';

class Sorter {
  final List<String> paths;
  final Cfg cfg;

  final dartImports = <String>[];
  final flutterImports = <String>[];
  final packageImports = <String>[];
  final relativeProjectImports = <String>[];
  final projectImports = <String>[];
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

        if (importLine.import.contains('dart:')) {
          if (!dartImports.contains(importLine.import)) {
            dartImports.add(importLine.import);
          }
        } else if (importLine.import.contains('package:flutter/')) {
          if (!flutterImports.contains(importLine.import)) {
            flutterImports.add(importLine.import);
          }
        } else if (importLine.import.contains('package:${cfg.projectName}/')) {
          if (!projectImports.contains(importLine.import)) {
            projectImports.add(importLine.import);
          }
        } else if (importLine.import.contains('package:')) {
          if (!packageImports.contains(importLine.import)) {
            packageImports.add(importLine.import);
          }
        } else {
          if (!relativeProjectImports.contains(importLine.import)) {
            relativeProjectImports.add(importLine.import);
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
    dartImports.add(Constants.dartImportsComment);
    flutterImports.add(Constants.flutterImportsComment);
    packageImports.add(Constants.packageImportsComment);
    projectImports.add(Constants.projectImportsComment);
    relativeProjectImports.add(Constants.relativeProjectImportsComment);
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
    var import = "";
    var endIndex = startIndex;

    for (var i = startIndex;; i++) {
      import += original[i];
      endIndex = i;
      toBeRemoved.add(original[i]);

      if (original[i].endsWith(";")) {
        break;
      }

      import += Platform.lineTerminator;
    }

    return ImportLine(
      import: import,
      startIndex: startIndex,
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
      dartImports.sort();
      dartImports.add("");
    }
    if (flutterImports.isNotEmpty) {
      flutterImports.sort();
      flutterImports.add("");
    }
    if (packageImports.isNotEmpty) {
      packageImports.sort();
      packageImports.add("");
    }
    if (projectImports.isNotEmpty) {
      projectImports.sort();
      projectImports.add("");
    }
    if (relativeProjectImports.isNotEmpty) {
      relativeProjectImports.sort();
      relativeProjectImports.add("");
    }

    _removeImports(sorted, toBeRemoved);
    _removeImportLine(sorted, Constants.dartImportsComment);
    _removeImportLine(sorted, Constants.flutterImportsComment);
    _removeImportLine(sorted, Constants.packageImportsComment);
    _removeImportLine(sorted, Constants.projectImportsComment);
    _removeImportLine(sorted, Constants.relativeProjectImportsComment);

    sorted.insertAll(0, relativeProjectImports);
    sorted.insertAll(0, projectImports);
    sorted.insertAll(0, packageImports);
    sorted.insertAll(0, flutterImports);
    sorted.insertAll(0, dartImports);

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
      sorted.removeWhere((element) => element == line);
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
  final String import;
  final int startIndex;
  final int endIndex;

  ImportLine({
    required this.import,
    required this.startIndex,
    required this.endIndex,
  });
}
