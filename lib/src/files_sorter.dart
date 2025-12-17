// Dart Imports
import 'dart:io';

// Package Imports
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';

// Project Imports
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/directive_type.dart';
import 'package:better_imports/src/directives_extractor.dart' as extractor;
import 'package:better_imports/src/directives_sorter.dart' as sorter;
import 'package:better_imports/src/file_paths.dart';
import 'package:better_imports/src/log.dart';
import 'package:better_imports/src/sorted_result.dart';

List<SortedResult> sort(FilePaths filePaths, Cfg cfg) {
  var results = <SortedResult>[];

  for (var path in filePaths.filtered) {
    var result = _sortFile(path, filePaths, cfg);

    if (result.changed && !cfg.dryRun) {
      result.file.writeAsStringSync(result.sorted);
    }

    results.add(result);
  }

  return results;
}

SortedResult _sortFile(String path, FilePaths filePaths, Cfg cfg) {
  log.fine("┠─ Sorting file: $path");

  var code = File(path).readAsStringSync();
  var compiledCode = parseString(content: code).unit;

  if (compiledCode.directives.isEmpty) {
    return SortedResult(file: File(path), sorted: code, changed: false);
  }

  // Skip barrel files (files that only contain exports and optional library directive)
  if (_isBarrelFile(compiledCode)) {
    log.fine("┠─ Detected barrel file. Skipping processing: $path");
    return SortedResult(file: File(path), sorted: code, changed: false);
  }

  var formatter = DartFormatter(
    languageVersion: Version.parse(cfg.sdkVersionForParsing),
  );

  var directivesEndIndex = compiledCode.directives.last.end;
  var directivesCode = code.substring(0, directivesEndIndex);
  var compiledDirectives =
      parseString(content: directivesCode, throwIfDiagnostics: false).unit;
  var directivesWithComments = extractor.extract(
    compiledDirectives,
    filePaths,
    cfg,
  );

  var sortedDirectives = sorter.sort(path, directivesWithComments, cfg);
  var remainingCode = code.substring(directivesEndIndex + 1);
  var sortedCode =
      formatter.format(sortedDirectives).trimLeft() + remainingCode;

  if (_areImportsEmpty(directivesWithComments)) {
    return SortedResult(file: File(path), sorted: code, changed: false);
  }

  return SortedResult(
    file: File(path),
    sorted: sortedCode,
    changed: code.compareTo(sortedCode) != 0,
  );
}

bool _isBarrelFile(CompilationUnit unit) {
  final directives = unit.directives;
  if (directives.isEmpty) return false;

  final hasExport = directives.any((d) => d is ExportDirective);
  if (!hasExport) return false;

  final onlyExportsAndLibrary =
      directives.every((d) => d is ExportDirective || d is LibraryDirective);

  final hasDeclarations = unit.declarations.isNotEmpty;

  return onlyExportsAndLibrary && !hasDeclarations;
}

bool _areImportsEmpty(
  Map<DirectiveType, Map<String, List<String>>> directives,
) {
  for (var importType in directives.keys) {
    var entry = directives[importType];

    if (entry!.isNotEmpty) {
      return false;
    }
  }

  return true;
}
