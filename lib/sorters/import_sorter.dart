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

  final List<String> _unsortedFilePaths;
  final Cfg _cfg;

  final _originalLines = <String>[];
  final _sortedLines = <String>[];
  final _importTypeToImportAndComments =
      <ImportType, Map<String, List<String>>>{};

  var _emptyLinesInImports = 0;
  var _currentPositionInImports = 0;

  Sorter({required List<String> paths, required Cfg cfg})
      : _cfg = cfg,
        _unsortedFilePaths = paths;

  List<SortedResult> sort() {
    var results = <SortedResult>[];

    for (var path in _unsortedFilePaths) {
      var sortedResult = _sortFile(path);

      if (sortedResult.changed) {
        sortedResult.file.writeAsStringSync(sortedResult.formattedContent);
      }

      results.add(sortedResult);
    }

    return results;
  }

  SortedResult _sortFile(String path) {
    log.fine("┠─ Sorting file: $path");

    _reset();
    _initInputTypeMap();

    var file = File(path);
    _originalLines.addAll(file.readAsLinesSync());
    _sortedLines.addAll(List.from(_originalLines));

    var parseResult = parseString(content: file.readAsStringSync());
    var unit = parseResult.unit;

    _fillingImportTypeToImportAndCommentsMap(unit);

    _rebuildSortedLines();

    var originalString =
        _formatter.format(_originalLines.join(Platform.lineTerminator));

    if (_areImportsEmpty) {
      return SortedResult(
        file: file,
        formattedContent: originalString,
        changed: false,
      );
    }

    var sortedString =
        _formatter.format(_sortedLines.join(Platform.lineTerminator));

    return SortedResult(
      file: file,
      formattedContent: sortedString,
      changed: originalString != sortedString,
    );
  }

  void _reset() {
    log.fine("┠─ Resetting sorter..");

    _sortedLines.clear();
    _originalLines.clear();
    _emptyLinesInImports = 0;
    _currentPositionInImports = 0;
    _importTypeToImportAndComments.clear();
  }

  void _initInputTypeMap() {
    log.fine("┠─ Initializing import types map..");

    _importTypeToImportAndComments.putIfAbsent(ImportType.dart, () => {});
    _importTypeToImportAndComments.putIfAbsent(ImportType.flutter, () => {});
    _importTypeToImportAndComments.putIfAbsent(ImportType.package, () => {});
    _importTypeToImportAndComments.putIfAbsent(ImportType.project, () => {});
  }

  void _fillingImportTypeToImportAndCommentsMap(CompilationUnit unit) {
    log.fine("┠─ Filling import types map..");

    for (var directive in unit.directives) {
      if (directive is! ImportDirective) {
        continue;
      }

      var import = directive.toString();
      var importType = _getImportTypeByDirective(import);
      var importToComments = _importTypeToImportAndComments[importType];
      var formattedImport = _formatter.format(import);
      var formattedImportLines = formattedImport.split("\n");

      formattedImportLines.removeWhere((element) => element.trim().isEmpty);

      if (formattedImportLines.length > 1) {
        _currentPositionInImports += formattedImportLines.length - 1;
      }

      importToComments!.putIfAbsent(import, () => <String>[]);

      Token? beginToken = directive.beginToken;

      _currentPositionInImports = _originalLines.indexWhere(
        (element) => element.contains("import"),
        _currentPositionInImports,
      );

      if (beginToken.lexeme.startsWith("///")) {
        _extractDocComments(directive, importToComments);
      } else {
        _extractPrecedingComments(directive, importToComments);
      }

      _currentPositionInImports++;
      _countFollowingEmptyLines();
    }
  }

  ImportType _getImportTypeByDirective(String importLine) {
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

  void _extractDocComments(
    ImportDirective directive,
    Map<String, List<String>> inputTypeEntry,
  ) {
    log.fine("┠── Extracting doc comments..");

    Token? beginToken = directive.beginToken;

    while (beginToken != null) {
      if (!_isImportComment(beginToken.lexeme)) {
        inputTypeEntry[directive.toString()]!.add(beginToken.lexeme);
      }

      _currentPositionInImports++;
      while (_currentPositionInImports > 0 &&
          _originalLines[_currentPositionInImports].isEmpty) {
        _emptyLinesInImports++;
        _currentPositionInImports++;
      }

      beginToken = beginToken.next;
    }
  }

  void _extractPrecedingComments(
    ImportDirective directive,
    Map<String, List<String>> inputTypeEntry,
  ) {
    log.fine("┠── Extracting preceding comments..");

    dynamic precedingComment = directive.beginToken.precedingComments;

    if (precedingComment == null) {
      return;
    }

    while (precedingComment != null) {
      if (precedingComment.type == TokenType.MULTI_LINE_COMMENT) {
        while (!_originalLines[_currentPositionInImports].contains("/*")) {
          _currentPositionInImports--;
        }

        while (!_originalLines[_currentPositionInImports].contains("*/")) {
          inputTypeEntry[directive.toString()]!.add(
            _originalLines[_currentPositionInImports],
          );

          _currentPositionInImports++;
        }

        inputTypeEntry[directive.toString()]!.add(
          _originalLines[_currentPositionInImports],
        );

        precedingComment = precedingComment.next;
      } else {
        inputTypeEntry[directive.toString()]!.add(precedingComment.value());
        precedingComment = precedingComment.next;
      }
    }
  }

  void _countFollowingEmptyLines() {
    log.fine("┠── Counting following empty lines..");

    while (_currentPositionInImports > 0 &&
        _originalLines[_currentPositionInImports].isEmpty) {
      _emptyLinesInImports++;
      _currentPositionInImports++;
    }
  }

  void _rebuildSortedLines() {
    log.fine("┠─ Rebuilding sorted lines..");

    _removeImportTypeCommentsInDirectives();
    _removeOldImports();
    _removeImportTypeComments();
    _removeEmptyLines();
    _processProjectImports();
    _insertSortedImports();
  }

  void _removeImportTypeCommentsInDirectives() {
    log.fine("┠── Removing import type comments in directives..");

    for (var importType in _importTypeToImportAndComments.keys) {
      var importToComments = _importTypeToImportAndComments[importType];

      for (var comment in importToComments!.keys) {
        var commentLines = importToComments[comment]!;

        commentLines.removeWhere((element) => _isImportComment(element));
      }
    }
  }

  void _removeOldImports() {
    log.fine("┠── Removing old imports..");

    for (var importType in _importTypeToImportAndComments.keys) {
      var importToComments = _importTypeToImportAndComments[importType];

      for (var import in importToComments!.keys) {
        var formattedImportLines =
            _formatter.format(import).split("\n").reversed.toList();

        formattedImportLines.removeWhere((element) => element.trim().isEmpty);

        var commentLines = importToComments[import]!;

        _sortedLines.retainWhere((line) {
          if (line.isNotEmpty) {
            for (var importLine in formattedImportLines) {
              if (importLine.trim().isEmpty) {
                continue;
              }

              if (line.contains(importLine.trimRight())) {
                return false;
              }
            }
          }

          return true;
        });

        _sortedLines.retainWhere((line) => !commentLines.contains(line));
      }
    }
  }

  bool _isImportComment(String comment) {
    return comment == Constants.dartImportsComment ||
        comment == Constants.flutterImportsComment ||
        comment == Constants.packageImportsComment ||
        comment == Constants.projectImportsComment;
  }

  void _removeImportTypeComments() {
    log.fine("┠── Removing import type comments..");

    _sortedLines.retainWhere((element) => !_isImportComment(element));
  }

  void _removeEmptyLines() {
    log.fine("┠── Removing empty lines..");

    for (var i = 0; i < _emptyLinesInImports; i++) {
      _sortedLines.removeAt(0);
    }
  }

  void _insertSortedImports() {
    log.fine("┠── Inserting sorted imports..");

    _importTypeToImportAndComments.keys.toList().reversed.forEach((importType) {
      var entry = _importTypeToImportAndComments[importType];
      var importLines = entry!.keys.toList();
      importLines.sort();
      importLines = importLines.reversed.toList();

      if (importLines.isNotEmpty) {
        var comments = entry.values.toList().reversed.toList();

        for (var i = 0; i < importLines.length; i++) {
          var importLine = importLines[i];
          var formattedImport = _formatter.format(importLine).trimRight();

          var lines = formattedImport.split("\n").reversed.toList();

          for (var line in lines) {
            if (line.trim().isEmpty) {
              continue;
            }

            _sortedLines.insert(0, line.trimRight());
          }

          var commentList = comments[i].reversed.toList();
          for (var comment in commentList) {
            _sortedLines.insert(0, comment);
          }
        }

        if (_cfg.comments) {
          var comment = _getImportTypeComment(importType);
          _sortedLines.insert(0, comment);
        }

        _sortedLines.insert(0, '');
      }
    });

    _sortedLines.removeAt(0);
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

  void _processProjectImports() {
    log.fine("┠── Processing project imports..");

    var projectImports = _importTypeToImportAndComments[ImportType.project];
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

    _importTypeToImportAndComments[ImportType.project] = newProjectImports;
  }

  String _convertToProjectImport(String importLine) {
    log.fine("┠─── Converting to project import..");

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
    for (var importType in _importTypeToImportAndComments.keys) {
      var entry = _importTypeToImportAndComments[importType];

      if (entry!.isNotEmpty) {
        return false;
      }
    }

    return true;
  }
}

class SortedResult {
  final File file;
  final String formattedContent;
  final bool changed;

  SortedResult({
    required this.file,
    required this.formattedContent,
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
