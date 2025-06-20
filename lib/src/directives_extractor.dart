// Package Imports
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

// Project Imports
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/constants.dart';
import 'package:better_imports/src/directive_type.dart';
import 'package:better_imports/src/file_paths.dart';
import 'package:better_imports/src/log.dart';

Map<DirectiveType, Map<String, List<String>>> extract(
  CompilationUnit compiledDirectives,
  FilePaths filePaths,
  Cfg cfg,
) {
  var directivesToComments = <DirectiveType, Map<String, List<String>>>{};

  _initDirectivesToComments(directivesToComments);
  _fillDirectivesToComments(
    compiledDirectives,
    directivesToComments,
    filePaths,
    cfg,
  );

  return directivesToComments;
}

void _initDirectivesToComments(
  Map<DirectiveType, Map<String, List<String>>> directivesToComments,
) {
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
  CompilationUnit compiledDirectives,
  Map<DirectiveType, Map<String, List<String>>> directivesToComments,
  FilePaths filePaths,
  Cfg cfg,
) {
  log.fine("┠─ Filling directive types to directives and comments..");

  for (var directive in compiledDirectives.directives) {
    var directiveValue = directive.toString();
    var directiveType = _getDirectiveType(directiveValue, filePaths, cfg);
    var directiveComments = directivesToComments[directiveType];

    directiveComments!.putIfAbsent(directiveValue, () => <String>[]);

    Token? beginToken = directive.beginToken;

    if (directive is ImportDirective) {
      if (beginToken.lexeme.startsWith("///")) {
        _extractDocCommentsFromImportDirective(directive, directiveComments);
      } else {
        _extractPrecedingCommentsFromImportDirective(
          directive,
          directiveComments,
        );
      }
    } else if (directive is LibraryDirective) {
      if (beginToken.lexeme.startsWith("///")) {
        _extractDocCommentsFromLibraryDirective(directive, directiveComments);
      } else {
        _extractPrecedingCommentsFromLibraryDirective(
          directive,
          directiveComments,
        );
      }
    } else if (directive is PartDirective) {
      if (beginToken.lexeme.startsWith("///")) {
        _extractDocCommentsFromPartDirective(directive, directiveComments);
      } else {
        _extractPrecedingCommentsFromPartDirective(
          directive,
          directiveComments,
        );
      }
    }
  }
}

DirectiveType _getDirectiveType(
  String directiveValue,
  FilePaths filePaths,
  Cfg cfg,
) {
  if (directiveValue.contains("library")) {
    return DirectiveType.library;
  } else if (directiveValue.contains("part")) {
    return DirectiveType.part;
  } else if (directiveValue.contains('dart:')) {
    return DirectiveType.dart;
  } else if (directiveValue.contains('package:flutter/')) {
    return DirectiveType.flutter;
  } else if (directiveValue.contains('package:${cfg.projectName}')) {
    return DirectiveType.project;
  } else if (!directiveValue.contains('package:')) {
    var fileName = _extractFileName(directiveValue);
    var filePath = filePaths.all.firstWhere((path) => path.contains(fileName));

    if (filePath.contains("lib/")) {
      return DirectiveType.project;
    } else {
      return DirectiveType.relative;
    }
  } else {
    return DirectiveType.package;
  }
}

String _extractFileName(String directiveValue) {
  Uri uri = Uri.parse(_extractPathFromImport(directiveValue));
  return uri.pathSegments.last;
}

String _extractPathFromImport(String directiveValue) {
  var matches = RegExp(r"'([^']*)'").allMatches(directiveValue);
  return matches.first.group(1) ?? '';
}

void _extractDocCommentsFromLibraryDirective(
  LibraryDirective directive,
  Map<String, List<String>> directiveComments,
) {
  log.fine("┠── Extracting doc comments..");

  _extractDocComments(
    directive.toString(),
    directive.beginToken,
    directiveComments,
  );
}

void _extractDocCommentsFromImportDirective(
  ImportDirective directive,
  Map<String, List<String>> directiveComments,
) {
  log.fine("┠── Extracting doc comments..");

  _extractDocComments(
    directive.toString(),
    directive.beginToken,
    directiveComments,
  );
}

void _extractDocCommentsFromPartDirective(
  PartDirective directive,
  Map<String, List<String>> directiveComments,
) {
  log.fine("┠── Extracting doc comments..");

  _extractDocComments(
    directive.toString(),
    directive.beginToken,
    directiveComments,
  );
}

void _extractDocComments(
  String directiveValue,
  Token? beginToken,
  Map<String, List<String>> directiveComments,
) {
  while (beginToken != null) {
    if (!_isImportComment(beginToken.lexeme)) {
      directiveComments[directiveValue]!.add(beginToken.lexeme);
    }

    beginToken = beginToken.next;
  }
}

void _extractPrecedingCommentsFromImportDirective(
  ImportDirective directive,
  Map<String, List<String>> directiveComments,
) {
  log.fine("┠── Extracting preceding comments..");

  dynamic precedingComment = directive.beginToken.precedingComments;

  if (precedingComment == null) {
    return;
  }

  _extractPrecedingComments(
    precedingComment,
    directiveComments,
    directive.toString(),
  );
}

void _extractPrecedingCommentsFromLibraryDirective(
  LibraryDirective directive,
  Map<String, List<String>> directiveComments,
) {
  log.fine("┠── Extracting preceding comments..");

  dynamic precedingComment = directive.beginToken.precedingComments;

  if (precedingComment == null) {
    return;
  }

  _extractPrecedingComments(
    precedingComment,
    directiveComments,
    directive.toString(),
  );
}

void _extractPrecedingCommentsFromPartDirective(
  PartDirective directive,
  Map<String, List<String>> directiveComments,
) {
  log.fine("┠── Extracting preceding comments..");

  Token? precedingComment = directive.beginToken.precedingComments;

  if (precedingComment == null) {
    return;
  }

  _extractPrecedingComments(
    precedingComment,
    directiveComments,
    directive.toString(),
  );
}

void _extractPrecedingComments(
  Token? precedingComment,
  Map<String, List<String>> directiveComments,
  String directiveValue,
) {
  while (precedingComment != null) {
    if (!_isImportComment(precedingComment.toString())) {
      directiveComments[directiveValue]!.add(precedingComment.toString());
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
