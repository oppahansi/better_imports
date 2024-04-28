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
import 'package:better_imports/src/directive_type.dart';
import 'package:better_imports/src/directives_sorter.dart' as sorter;
import 'package:better_imports/src/file_paths.dart';
import 'package:better_imports/src/log.dart';
import 'package:better_imports/src/sorted_result.dart';

List<SortedResult> sort(FilePaths collectorResult, Cfg cfg) {
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

SortedResult _sortFile(String path, FilePaths collectorResult, Cfg cfg) {
  log.fine("┠─ Sorting file: $path");

  var fileContent = File(path).readAsStringSync();
  var compilationUnit = parseString(content: fileContent).unit;

  if (compilationUnit.directives.isEmpty) {
    return SortedResult(
      file: File(path),
      sortedContent: fileContent,
      changed: false,
    );
  }

  var lastDirective = compilationUnit.directives.last.toString();
  var directiveEndIndex =
      fileContent.indexOf(lastDirective) + lastDirective.length;

  var directivesContent = fileContent.substring(0, directiveEndIndex);
  var directivesCompilationUnit = parseString(content: directivesContent).unit;

  var remainingContent = fileContent.substring(directiveEndIndex);

  var directivesWithComments = <DirectiveType, Map<String, List<String>>>{};

  _initDirectivesToComments(directivesWithComments);
  _fillDirectivesToComments(
      directivesCompilationUnit, directivesWithComments, collectorResult, cfg);

  var sortedDirectives = sorter.sort(path, directivesWithComments, cfg);

  var formatter = DartFormatter();

  var sortedContent = formatter.format(sortedDirectives) +
      remainingContent.substring(1, remainingContent.length);

  if (_areImportsEmpty(directivesWithComments)) {
    return SortedResult(
      file: File(path),
      sortedContent: fileContent,
      changed: false,
    );
  }

  if (cfg.dartFmt) {
    sortedContent = formatter.format(sortedContent);
  }

  return SortedResult(
    file: File(path),
    sortedContent: sortedContent,
    changed: fileContent.compareTo(sortedContent) != 0,
  );
}

void _initDirectivesToComments(
    Map<DirectiveType, Map<String, List<String>>> directivesToComments) {
  log.fine("┠─ Initializing directives types to directives and comments..");

  directivesToComments.putIfAbsent(DirectiveType.library, () => {});
  directivesToComments.putIfAbsent(DirectiveType.dart, () => {});
  directivesToComments.putIfAbsent(DirectiveType.flutter, () => {});
  directivesToComments.putIfAbsent(DirectiveType.package, () => {});
  directivesToComments.putIfAbsent(DirectiveType.project, () => {});
  directivesToComments.putIfAbsent(DirectiveType.relative, () => {});
  directivesToComments.putIfAbsent(DirectiveType.part, () => {});
}

void _fillDirectivesToComments(
  CompilationUnit unit,
  Map<DirectiveType, Map<String, List<String>>> directivesToComments,
  FilePaths collectorResult,
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

DirectiveType _getDirectiveType(
  String directiveValue,
  FilePaths collectorResult,
  Cfg cfg,
) {
  if (directiveValue.contains("library")) {
    return DirectiveType.library;
  } else if (directiveValue.contains("part")) {
    return DirectiveType.part;
  } else if (directiveValue.contains('dart:')) {
    return DirectiveType.dart;
  } else if (directiveValue.contains('package:flutter')) {
    return DirectiveType.flutter;
  } else if (directiveValue.contains('package:${cfg.projectName}')) {
    return DirectiveType.project;
  } else if (!directiveValue.contains('package:')) {
    var fileName = _extractFileName(directiveValue);
    var filePath =
        collectorResult.allPaths.firstWhere((path) => path.contains(fileName));

    if (filePath.contains("lib/")) {
      return DirectiveType.project;
    } else {
      return DirectiveType.relative;
    }
  } else {
    return DirectiveType.package;
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
  return comment == Constants.dartComment ||
      comment == Constants.flutterComment ||
      comment == Constants.packageComment ||
      comment == Constants.projectComment ||
      comment == Constants.relativeComment;
}

bool _areImportsEmpty(
    Map<DirectiveType, Map<String, List<String>>> directives) {
  for (var importType in directives.keys) {
    var entry = directives[importType];

    if (entry!.isNotEmpty) {
      return false;
    }
  }

  return true;
}
