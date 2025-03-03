// Dart Imports
import 'dart:io';

// Package Imports
import 'package:analyzer/dart/analysis/utilities.dart';
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
  var compiled = parseString(content: code).unit;

  if (compiled.directives.isEmpty) {
    return SortedResult(
      file: File(path),
      sorted: code,
      changed: false,
    );
  }

  var formatter = DartFormatter(languageVersion: Version.parse('2.12.0'));

  var last = compiled.directives.last.toString();
  var lastIndex = last.length > formatter.pageWidth
      ? code.indexOf(last.substring(0, (formatter.pageWidth / 2).toInt()))
      : code.indexOf(last);
  var lastDirectiveEndIndex = code.indexOf(';', lastIndex) + 1;

  var directivesCode = code.substring(0, lastDirectiveEndIndex);
  var compiledDirectives = parseString(content: directivesCode).unit;

  var remainingCode = code.substring(lastDirectiveEndIndex);

  var directivesWithComments =
      extractor.extract(compiledDirectives, filePaths, cfg);

  var sortedDirectives = sorter.sort(path, directivesWithComments, cfg);

  formatter.pageWidth == 80;

  var sortedCode = formatter.format(sortedDirectives) +
      remainingCode.substring(1, remainingCode.length);

  if (_areImportsEmpty(directivesWithComments)) {
    return SortedResult(
      file: File(path),
      sorted: code,
      changed: false,
    );
  }

  if (cfg.dartFmt) {
    sortedCode = formatter.format(sortedCode);
  }

  return SortedResult(
    file: File(path),
    sorted: sortedCode,
    changed: code.compareTo(sortedCode) != 0,
  );
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
