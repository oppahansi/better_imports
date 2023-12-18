// Dart Imports
import 'dart:io';

// Package Imports
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dart_style/dart_style.dart';

// Project Imports
import "package:better_imports/lib.dart";

enum ImportType {
  dart,
  flutter,
  package,
  project,
}

class Sorter {
  final _formatter = DartFormatter();

  final List<String> _paths;
  final Cfg _cfg;

  final _original = <String>[];
  final _importTypeToDirectives = <ImportType, Map<String, List<String>>>{};

  var _emptyLinesInImports = 0;
  var _positionInFile = 0;

  Sorter({required List<String> paths, required Cfg cfg})
      : _cfg = cfg,
        _paths = paths;

  List<SortedResult> sort() {
    var results = <SortedResult>[];

    for (var path in _paths) {
      var result = _sortFile(path);

      if (result.changed) {
        result.file.writeAsStringSync(result.sorted);
      }

      results.add(result);
    }

    return results;
  }

  SortedResult _sortFile(String path) {
    _reset();
    _initInputTypeMap();

    var file = File(path);
    _original.addAll(file.readAsLinesSync());

    var parseResult = parseString(content: file.readAsStringSync());
    var unit = parseResult.unit;

    _extractImports(unit);

    var sorted = _getSorted();
    sorted.add("");

    var originalString =
        _formatter.format(_original.join(Platform.lineTerminator));
    var sortedString = _formatter.format(sorted.join(Platform.lineTerminator));

    return SortedResult(
      file: file,
      sorted: sortedString,
      changed: originalString != sortedString,
    );
  }

  void _reset() {
    _emptyLinesInImports = 0;
    _positionInFile = 0;
    _original.clear();
    _importTypeToDirectives.clear();
  }

  void _initInputTypeMap() {
    _importTypeToDirectives.putIfAbsent(ImportType.dart, () => {});
    _importTypeToDirectives.putIfAbsent(ImportType.flutter, () => {});
    _importTypeToDirectives.putIfAbsent(ImportType.package, () => {});
    _importTypeToDirectives.putIfAbsent(ImportType.project, () => {});
  }

  void _extractImports(CompilationUnit unit) {
    for (var directive in unit.directives) {
      if (directive is! ImportDirective) {
        continue;
      }

      var importType = _getImportType(directive.toString());
      var inputTypeEntry = _importTypeToDirectives[importType];

      inputTypeEntry!.putIfAbsent(directive.toString(), () => <String>[]);

      dynamic beginToken = directive.beginToken;

      _positionInFile = _original.indexWhere(
          (element) => element.contains("import"), _positionInFile);

      if (beginToken.lexeme.startsWith("///")) {
        _extractDocComments(beginToken, inputTypeEntry, directive);
      } else {
        _extractPrecedingComments(directive, inputTypeEntry);
      }

      _positionInFile++;
      _countFollowingEmptyLines();
    }
  }

  ImportType _getImportType(String importLine) {
    if (importLine.contains('dart:')) {
      return ImportType.dart;
    } else if (importLine.contains('package:flutter')) {
      return ImportType.flutter;
    } else if (importLine.contains('package:${_cfg.projectName}')) {
      return ImportType.project;
    } else if (!importLine.contains('package:')) {
      return ImportType.project;
    } else {
      return ImportType.package;
    }
  }

  void _extractDocComments(beginToken, Map<String, List<String>> inputTypeEntry,
      ImportDirective directive) {
    while (beginToken != null) {
      if (!_isImportComment(beginToken.lexeme)) {
        inputTypeEntry[directive.toString()]!.add(beginToken.lexeme);
      }

      _positionInFile++;
      while (_positionInFile > 0 && _original[_positionInFile].isEmpty) {
        _emptyLinesInImports++;
        _positionInFile++;
      }

      beginToken = beginToken.next;
    }
  }

  void _extractPrecedingComments(
      ImportDirective directive, Map<String, List<String>> inputTypeEntry) {
    dynamic precedingComment = directive.beginToken.precedingComments;

    if (precedingComment != null) {
      while (precedingComment != null) {
        if (precedingComment.type == TokenType.MULTI_LINE_COMMENT) {
          while (!_original[_positionInFile].contains("/*")) {
            _positionInFile--;
          }

          while (!_original[_positionInFile].contains("*/")) {
            inputTypeEntry[directive.toString()]!
                .add(_original[_positionInFile]);
            _positionInFile++;
          }

          inputTypeEntry[directive.toString()]!.add(_original[_positionInFile]);
          precedingComment = precedingComment.next;
        } else {
          inputTypeEntry[directive.toString()]!.add(precedingComment.value());
          precedingComment = precedingComment.next;
        }
      }
    }
  }

  void _countFollowingEmptyLines() {
    while (_positionInFile > 0 && _original[_positionInFile].isEmpty) {
      _emptyLinesInImports++;
      _positionInFile++;
    }
  }

  List<String> _getSorted() {
    if (_areImportsEmpty) {
      return _original;
    }

    var sorted = List<String>.from(_original);

    _removeImportTypeCommentsInDirectives(_importTypeToDirectives);
    _removeOldImports(sorted);
    _removeImportTypeComments(sorted);
    _removeEmptyLines(sorted);
    _processProjectImports();
    _insertOrganizedImports(sorted);

    return sorted;
  }

  void _removeImportTypeCommentsInDirectives(
      Map<ImportType, Map<String, List<String>>> directives) {
    for (var importType in directives.keys) {
      var entry = directives[importType];

      for (var import in entry!.keys) {
        var importLines = entry[import]!;

        importLines.removeWhere((element) => _isImportComment(element));
      }
    }
  }

  void _removeImportTypeComments(List<String> sorted) {
    sorted.removeWhere((element) => _isImportComment(element));
  }

  bool _isImportComment(String comment) {
    return comment == Constants.dartImportsComment ||
        comment == Constants.flutterImportsComment ||
        comment == Constants.packageImportsComment ||
        comment == Constants.projectImportsComment;
  }

  void _removeEmptyLines(List<String> sorted) {
    for (var i = 0; i < _emptyLinesInImports; i++) {
      sorted.removeAt(0);
    }
  }

  void _insertOrganizedImports(List<String> sorted) {
    _importTypeToDirectives.keys.toList().reversed.forEach((importType) {
      var entry = _importTypeToDirectives[importType];
      var importLines = entry!.keys.toList();
      importLines.sort();
      importLines = importLines.reversed.toList();

      if (importLines.isNotEmpty) {
        var comments = entry.values.toList().reversed.toList();

        for (var i = 0; i < importLines.length; i++) {
          var importLine = importLines[i];
          var formattedImport = _formatter.format(importLine);

          var lines = formattedImport.split("\n").reversed.toList();

          for (var line in lines) {
            if (line.trim().isEmpty) {
              continue;
            }

            sorted.insert(0, line);
          }

          var commentList = comments[i].reversed.toList();
          for (var comment in commentList) {
            sorted.insert(0, comment);
          }
        }

        if (_cfg.comments) {
          var comment = _getImportTypeComment(importType);
          sorted.insert(0, comment);
        }

        sorted.insert(0, '');
      }
    });

    sorted.removeAt(0);
  }

  String _getImportTypeComment(ImportType importType) {
    switch (importType) {
      case ImportType.dart:
        return Constants.dartImportsComment;
      case ImportType.flutter:
        return Constants.flutterImportsComment;
      case ImportType.package:
        return Constants.packageImportsComment;
      case ImportType.project:
        return Constants.projectImportsComment;
      default:
        return '';
    }
  }

  void _removeOldImports(List<String> sorted) {
    for (var importType in _importTypeToDirectives.keys) {
      var entry = _importTypeToDirectives[importType];

      for (var import in entry!.keys) {
        var importLines = entry[import]!;
        var formattedImport = _formatter.format(import);
        var lines = formattedImport.split("\n").reversed.toList();

        for (var line in lines) {
          if (line.trim().isEmpty) {
            continue;
          }

          sorted.remove(line);
        }

        for (var line in importLines) {
          sorted.remove(line);
        }
      }
    }
  }

  void _processProjectImports() {
    var projectImports = _importTypeToDirectives[ImportType.project];
    var newProjectImports = <String, List<String>>{};

    for (var import in projectImports!.keys) {
      var importLines = projectImports[import]!;

      var newImportLines = <String>[];

      for (var line in importLines) {
        if (!line.contains("import 'package:${_cfg.projectName}")) {
          newImportLines.add(_convertToProjectImport(line));
        } else {
          newImportLines.add(line);
        }
      }

      var projectImport = import;
      if (!projectImport.contains("import 'package:${_cfg.projectName}") ||
          !projectImport.contains("package:")) {
        projectImport = _convertToProjectImport(projectImport);
      }

      newProjectImports.putIfAbsent(projectImport, () => newImportLines);
    }

    _importTypeToDirectives[ImportType.project] = newProjectImports;
  }

  String _convertToProjectImport(String importLine) {
    if (importLine.startsWith("import 'package:${_cfg.projectName}")) {
      return importLine;
    }

    if (!importLine.contains("lib")) {
      importLine = importLine.replaceFirst("lib/", "");
    }

    if (importLine.contains("..")) {
      return importLine.replaceFirst("..", "package:${_cfg.projectName}");
    } else {
      return importLine.replaceFirst(
          "import '", "import 'package:${_cfg.projectName}/");
    }
  }

  bool get _areImportsEmpty {
    for (var importType in _importTypeToDirectives.keys) {
      var entry = _importTypeToDirectives[importType];

      if (entry!.isNotEmpty) {
        return false;
      }
    }

    return true;
  }
}

class SortedResult {
  final File file;
  final String sorted;
  final bool changed;

  SortedResult({
    required this.file,
    required this.sorted,
    required this.changed,
  });
}
