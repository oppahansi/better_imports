// Dart Imports
import 'dart:io';

// Package Imports
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:dart_style/dart_style.dart';

// Project Imports
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/constants.dart';
import 'package:better_imports/src/file_path_collector_result.dart';
import 'package:better_imports/src/import_type.dart';
import 'package:better_imports/src/log.dart';
import 'package:better_imports/src/sorted_result.dart';

List<SortedResult> sort(FilePathCollectorResult collectorResult, Cfg cfg) {
  var results = <SortedResult>[];

  for (var path in collectorResult.filteredPaths) {
    var sortedResult = _sortFile(path, collectorResult, cfg);

    if (sortedResult.changed && !cfg.dryRun) {
      sortedResult.file.writeAsStringSync(sortedResult.sortedContent);
    }

    results.add(sortedResult);
  }

  return results;
}

SortedResult _sortFile(
  String path,
  FilePathCollectorResult collectorResult,
  Cfg cfg,
) {
  log.fine("┠─ Sorting file: $path");

  var raw = File(path).readAsStringSync();
  var rawUnit = parseString(content: raw).unit;

  if (rawUnit.directives.isEmpty) {
    return SortedResult(
      file: File(path),
      sortedContent: raw,
      changed: false,
    );
  }

  var lastDirective = rawUnit.directives.last.toString();
  var directiveEndIndex = raw.indexOf(lastDirective) + lastDirective.length;

  var directives = raw.substring(0, directiveEndIndex);
  var rawWithoutDirectives = raw.substring(directiveEndIndex);

  var directivesUnit = parseString(content: directives).unit;

  var directivesToComments = <ImportType, Map<String, List<String>>>{};

  _initDirectivesToComments(directivesToComments);
  _fillDirectivesToComments(
      directivesUnit, directivesToComments, collectorResult, cfg);

  var sortedDirectives = _sortDirectives(path, directivesToComments, cfg);

  var formatter = DartFormatter();

  var sortedContent = formatter.format(sortedDirectives) +
      rawWithoutDirectives.substring(1, rawWithoutDirectives.length);

  if (_areImportsEmpty(directivesToComments)) {
    return SortedResult(
      file: File(path),
      sortedContent: raw,
      changed: false,
    );
  }

  if (cfg.dartFmt) {
    sortedContent = formatter.format(sortedContent);
  }

  return SortedResult(
    file: File(path),
    sortedContent: sortedContent,
    changed: raw.compareTo(sortedContent) != 0,
  );
}

void _initDirectivesToComments(
    Map<ImportType, Map<String, List<String>>> directivesToComments) {
  log.fine("┠─ Initializing directives types to directives and comments..");

  directivesToComments.putIfAbsent(ImportType.library, () => {});
  directivesToComments.putIfAbsent(ImportType.dart, () => {});
  directivesToComments.putIfAbsent(ImportType.flutter, () => {});
  directivesToComments.putIfAbsent(ImportType.package, () => {});
  directivesToComments.putIfAbsent(ImportType.project, () => {});
  directivesToComments.putIfAbsent(ImportType.relative, () => {});
  directivesToComments.putIfAbsent(ImportType.part, () => {});
}

void _fillDirectivesToComments(
  CompilationUnit unit,
  Map<ImportType, Map<String, List<String>>> directivesToComments,
  FilePathCollectorResult collectorResult,
  Cfg cfg,
) {
  log.fine("┠─ Filling directive types to directives and comments..");

  for (var directive in unit.directives) {
    var directiveValue = directive.toString();
    var directiveType = _getDirectiveType(directiveValue, collectorResult, cfg);
    var directiveComments = directivesToComments[directiveType];

    directiveComments!.putIfAbsent(directiveValue, () => <String>[]);

    Token? beginToken = directive.beginToken;

    if (directive is ImportDirective) {
      if (beginToken.lexeme.startsWith("///")) {
        _extractDocCommentsFromImportDirective(directive, directiveComments);
      } else {
        _extractPrecedingCommentsFromImportDirective(
            directive, directiveComments);
      }
    } else if (directive is LibraryDirective) {
      if (beginToken.lexeme.startsWith("///")) {
        _extractDocCommentsFromLibraryDirective(directive, directiveComments);
      } else {
        _extractPrecedingCommentsFromLibraryDirective(
            directive, directiveComments);
      }
    } else if (directive is PartDirective) {
      if (beginToken.lexeme.startsWith("///")) {
        _extractDocCommentsFromPartDirective(directive, directiveComments);
      } else {
        _extractPrecedingCommentsFromPartDirective(
            directive, directiveComments);
      }
    }
  }
}

ImportType _getDirectiveType(
  String directive,
  FilePathCollectorResult collectorResult,
  Cfg cfg,
) {
  if (directive.contains("library")) {
    return ImportType.library;
  } else if (directive.contains("part")) {
    return ImportType.part;
  } else if (directive.contains('dart:')) {
    return ImportType.dart;
  } else if (directive.contains('package:flutter')) {
    return ImportType.flutter;
  } else if (directive.contains('package:${cfg.projectName}')) {
    return ImportType.project;
  } else if (!directive.contains('package:')) {
    var fileName = _extractFileName(directive);
    var filePath =
        collectorResult.allPaths.firstWhere((path) => path.contains(fileName));

    if (filePath.contains("lib/")) {
      return ImportType.project;
    } else {
      return ImportType.relative;
    }
  } else {
    return ImportType.package;
  }
}

String _extractFileName(String import) {
  Uri uri = Uri.parse(_extractPathFromImport(import));
  return uri.pathSegments.last;
}

String _extractPathFromImport(String importStatement) {
  var matches = RegExp(r"'([^']*)'").allMatches(importStatement);
  return matches.first.group(1) ?? '';
}

void _extractDocCommentsFromLibraryDirective(
  LibraryDirective directive,
  Map<String, List<String>> inputTypeEntry,
) {
  log.fine("┠── Extracting doc comments..");

  _extractDocComments(
      directive.toString(), directive.beginToken, inputTypeEntry);
}

void _extractDocCommentsFromImportDirective(
  ImportDirective directive,
  Map<String, List<String>> inputTypeEntry,
) {
  log.fine("┠── Extracting doc comments..");

  _extractDocComments(
      directive.toString(), directive.beginToken, inputTypeEntry);
}

void _extractDocCommentsFromPartDirective(
  PartDirective directive,
  Map<String, List<String>> inputTypeEntry,
) {
  log.fine("┠── Extracting doc comments..");

  _extractDocComments(
      directive.toString(), directive.beginToken, inputTypeEntry);
}

void _extractDocComments(
  String directiveValue,
  Token? beginToken,
  Map<String, List<String>> directiveToComments,
) {
  while (beginToken != null) {
    if (!_isImportComment(beginToken.lexeme)) {
      directiveToComments[directiveValue]!.add(beginToken.lexeme);
    }

    beginToken = beginToken.next;
  }
}

void _extractPrecedingCommentsFromImportDirective(
  ImportDirective directive,
  Map<String, List<String>> directiveToComments,
) {
  log.fine("┠── Extracting preceding comments..");

  dynamic precedingComment = directive.beginToken.precedingComments;

  if (precedingComment == null) {
    return;
  }

  _extractPrecedingComments(
      precedingComment, directiveToComments, directive.toString());
}

void _extractPrecedingCommentsFromLibraryDirective(
  LibraryDirective directive,
  Map<String, List<String>> directiveToComments,
) {
  log.fine("┠── Extracting preceding comments..");

  dynamic precedingComment = directive.beginToken.precedingComments;

  if (precedingComment == null) {
    return;
  }

  _extractPrecedingComments(
      precedingComment, directiveToComments, directive.toString());
}

void _extractPrecedingCommentsFromPartDirective(
  PartDirective directive,
  Map<String, List<String>> directiveToComments,
) {
  log.fine("┠── Extracting preceding comments..");

  Token? precedingComment = directive.beginToken.precedingComments;

  if (precedingComment == null) {
    return;
  }

  _extractPrecedingComments(
      precedingComment, directiveToComments, directive.toString());
}

void _extractPrecedingComments(
  Token? precedingComment,
  Map<String, List<String>> directiveToComments,
  String directiveValue,
) {
  while (precedingComment != null) {
    if (!_isImportComment(precedingComment.toString())) {
      directiveToComments[directiveValue]!.add(precedingComment.toString());
    }

    precedingComment = precedingComment.next;
  }
}

bool _isImportComment(String comment) {
  return comment == Constants.dartImportsComment ||
      comment == Constants.flutterImportsComment ||
      comment == Constants.packageImportsComment ||
      comment == Constants.projectImportsComment ||
      comment == Constants.relativeProjectImportsComment;
}

String _sortDirectives(
  String path,
  Map<ImportType, Map<String, List<String>>> directivesToComments,
  Cfg cfg,
) {
  var sortedDirectives = "";
  var projectDirectives = directivesToComments[ImportType.project]!;
  var convertedProjectDirectives =
      _convertProjectImports(path, projectDirectives, cfg);

  var libraryDirectives = directivesToComments[ImportType.library]!;

  sortedDirectives =
      _addDirectivesAndComments(sortedDirectives, libraryDirectives, "", cfg);

  var dartDirectives = directivesToComments[ImportType.dart]!;

  sortedDirectives = _addDirectivesAndComments(
      sortedDirectives, dartDirectives, Constants.dartImportsComment, cfg);

  var flutterDirectives = directivesToComments[ImportType.flutter]!;

  sortedDirectives = _addDirectivesAndComments(sortedDirectives,
      flutterDirectives, Constants.flutterImportsComment, cfg);

  var packageDirectives = directivesToComments[ImportType.package]!;

  sortedDirectives = _addDirectivesAndComments(sortedDirectives,
      packageDirectives, Constants.packageImportsComment, cfg);

  sortedDirectives = _addDirectivesAndComments(sortedDirectives,
      convertedProjectDirectives, Constants.projectImportsComment, cfg);

  var relativeDirectives = directivesToComments[ImportType.relative]!;

  sortedDirectives = _addDirectivesAndComments(sortedDirectives,
      relativeDirectives, Constants.relativeProjectImportsComment, cfg);

  var partDirectives = directivesToComments[ImportType.part]!;

  sortedDirectives =
      _addDirectivesAndComments(sortedDirectives, partDirectives, "", cfg);

  return sortedDirectives;
}

String _addDirectivesAndComments(
  String sortedDirectives,
  Map<String, List<String>> directives,
  String directiveTypeComment,
  Cfg cfg,
) {
  if (directives.isNotEmpty) {
    sortedDirectives += "\n";

    if (cfg.comments && directiveTypeComment.isNotEmpty) {
      sortedDirectives += "$directiveTypeComment\n";
    }

    for (var directive in directives.keys) {
      var comments = directives[directive]!;

      for (var comment in comments) {
        sortedDirectives += "$comment\n";
      }

      sortedDirectives += "$directive\n";
    }
  }

  return sortedDirectives;
}

Map<String, List<String>> _convertProjectImports(
  String path,
  Map<String, List<String>> projectDirectives,
  Cfg cfg,
) {
  log.fine("┠── Processing project imports..");

  var newProjectImports = <String, List<String>>{};

  for (var directiveValue in projectDirectives.keys) {
    var convertedDirectiveValue = "";

    if (cfg.relative) {
      convertedDirectiveValue =
          _convertToRelativeProjectImport(path, directiveValue, cfg);
    } else {
      convertedDirectiveValue =
          _convertToPackageProjectImport(path, directiveValue, cfg);
    }

    newProjectImports.putIfAbsent(
        convertedDirectiveValue, () => projectDirectives[directiveValue]!);
  }

  return newProjectImports;
}

String _convertToPackageProjectImport(
  String path,
  String directiveValue,
  Cfg cfg,
) {
  log.fine("┠─── Converting to project import..");

  if (directiveValue.startsWith("import 'package:${cfg.projectName}")) {
    return directiveValue;
  }

  if (!directiveValue.contains("lib")) {
    directiveValue = directiveValue.replaceFirst("lib/", "");
  }

  if (directiveValue.contains("..")) {
    return directiveValue.replaceFirst("..", "package:${cfg.projectName}");
  } else {
    return directiveValue.replaceFirst(
        "import '", "import 'package:${cfg.projectName}/");
  }
}

String _convertToRelativeProjectImport(
  String path,
  String importLine,
  Cfg cfg,
) {
  log.fine("┠─── Converting to relative project import..");

  if (importLine.contains("..")) {
    return importLine;
  }

  if (importLine.contains("'package:${cfg.projectName}")) {
    if (!path.contains("lib")) {
      return importLine.replaceFirst("package:${cfg.projectName}", "../lib");
    } else {
      return importLine.replaceFirst("package:${cfg.projectName}", "..");
    }
  }

  return importLine;
}

bool _areImportsEmpty(Map<ImportType, Map<String, List<String>>> directives) {
  for (var importType in directives.keys) {
    var entry = directives[importType];

    if (entry!.isNotEmpty) {
      return false;
    }
  }

  return true;
}
