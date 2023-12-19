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

      print(sortedResult.formattedContent);

      if (sortedResult.changed) {
        sortedResult.file.writeAsStringSync(sortedResult.formattedContent);
      }

      results.add(sortedResult);
    }

    return results;
  }

  SortedResult _sortFile(String path) {
    _reset();
    _initInputTypeMap();

    var file = File(path);
    _originalLines.addAll(file.readAsLinesSync());
    _sortedLines.addAll(_originalLines);

    var parseResult = parseString(content: file.readAsStringSync());
    var unit = parseResult.unit;

    _buildImportTypeToImportAndCommentsMap(unit);
    _sort();

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
    _sortedLines.clear();
    _originalLines.clear();
    _emptyLinesInImports = 0;
    _currentPositionInImports = 0;
    _importTypeToImportAndComments.clear();
  }

  void _initInputTypeMap() {
    _importTypeToImportAndComments.putIfAbsent(ImportType.dart, () => {});
    _importTypeToImportAndComments.putIfAbsent(ImportType.flutter, () => {});
    _importTypeToImportAndComments.putIfAbsent(ImportType.package, () => {});
    _importTypeToImportAndComments.putIfAbsent(ImportType.project, () => {});
  }

  void _buildImportTypeToImportAndCommentsMap(CompilationUnit unit) {
    for (var directive in unit.directives) {
      if (directive is! ImportDirective) {
        continue;
      }

      var importType = _getImportTypeByDirective(directive.toString());
      var importToComments = _importTypeToImportAndComments[importType];

      importToComments!.putIfAbsent(directive.toString(), () => <String>[]);

      Token? beginToken = directive.beginToken;

      _currentPositionInImports = _originalLines.indexWhere(
        (element) => element.contains("import"),
        _currentPositionInImports,
      );

      if (beginToken.lexeme.startsWith("///")) {
        _extractDocComments(beginToken, importToComments, directive);
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
    Token? beginToken,
    Map<String, List<String>> inputTypeEntry,
    ImportDirective directive,
  ) {
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
    while (_currentPositionInImports > 0 &&
        _originalLines[_currentPositionInImports].isEmpty) {
      _emptyLinesInImports++;
      _currentPositionInImports++;
    }
  }

  void _sort() {
    _removeImportTypeCommentsInDirectives();
    _removeOldImports();
    _removeImportTypeComments();
    _removeEmptyLines();
    _processProjectImports();
    _insertOrganizedImports();
  }

  void _removeImportTypeCommentsInDirectives() {
    for (var importType in _importTypeToImportAndComments.keys) {
      var importToComments = _importTypeToImportAndComments[importType];

      for (var comment in importToComments!.keys) {
        var commentLines = importToComments[comment]!;

        commentLines.removeWhere((element) => _isImportComment(element));
      }
    }
  }

  void _removeOldImports() {
    for (var importType in _importTypeToImportAndComments.keys) {
      var entry = _importTypeToImportAndComments[importType];

      for (var import in entry!.keys) {
        var importLines = entry[import]!;
        var formattedImport = _formatter.format(import);
        var lines = formattedImport.split("\n").reversed.toList();

        for (var line in lines) {
          if (line.trim().isEmpty) {
            continue;
          }

          _sortedLines.remove(line);
        }

        for (var line in importLines) {
          _sortedLines.remove(line);
        }
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
    _sortedLines.removeWhere((element) => _isImportComment(element));
  }

  void _removeEmptyLines() {
    for (var i = 0; i < _emptyLinesInImports; i++) {
      _sortedLines.removeAt(0);
    }
  }

  void _insertOrganizedImports() {
    _sortedLines.insert(0, '');

    _importTypeToImportAndComments.keys.toList().reversed.forEach((importType) {
      var entry = _importTypeToImportAndComments[importType];
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

            _sortedLines.insert(0, line);
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
}
