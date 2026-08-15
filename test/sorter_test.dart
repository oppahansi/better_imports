// Dart Imports
import 'dart:io';

// Package Imports
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/src/arg_parser.dart';
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/directive_type.dart';
import 'package:better_imports/src/directives_sorter.dart' as directive_sorter;
import 'package:better_imports/src/file_paths_collector.dart';
import 'package:better_imports/src/files_sorter.dart';

// Relative Project Imports
import '../res/sorter_fixtures.dart';

void main() {
  group("Sorter Tests.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFile);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test(
      "Default config. Make sure collector and sorter return the same amount.",
      () {
        var argResult = argParser.parse([]);
        var cfg = Cfg(argResult);
        cfg.dryRun = true;

        var collector = FilePathsCollector(cfg: cfg);
        var collected = collector.collect();

        var sorted = sort(collected, cfg);

        expect(collected.filtered.length, sorted.length);
      },
    );

    test("Sorting file. With comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.dartFmt = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);
      expect(sorted.first.sorted, sortedFileWithComments);
    });

    test("Sorting file. No comments.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.comments = false;
      cfg.dartFmt = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileNoComments);
    });

    test("Sorting file. Relative Imports.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.relative = true;
      cfg.dartFmt = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileWithCommentsRelative);
    });

    test("Sorting file. Test files keep package imports in relative mode.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);
      cfg.relative = true;

      final directivesWithComments = {
        DirectiveType.library: <String, List<String>>{},
        DirectiveType.dart: <String, List<String>>{},
        DirectiveType.flutter: <String, List<String>>{},
        DirectiveType.package: <String, List<String>>{},
        DirectiveType.project: {
          "import 'package:${cfg.projectName}/src/cfg.dart'": <String>[],
          "import 'package:${cfg.projectName}/test/fixtures/test_helper.dart'":
              <String>[],
        },
        DirectiveType.relative: <String, List<String>>{},
        DirectiveType.export: <String, List<String>>{},
        DirectiveType.part: <String, List<String>>{},
      };

      final sorted = directive_sorter.sort(
        "test/sorter_test.dart",
        directivesWithComments,
        cfg,
      );

      expect(
        sorted,
        contains("import 'package:${cfg.projectName}/src/cfg.dart'"),
      );
      expect(sorted, contains("import 'fixtures/test_helper.dart'"));
      expect(sorted, isNot(contains("import '../lib/src/cfg.dart'")));
    });

    test("Sorting file. Exports remain below imports.", () {
      final file = File("res/exports_unsorted.dart");
      file.writeAsStringSync("""
import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../clock.dart';
import '../hashing.dart';
import 'database.dart';
import 'sentence_record.dart';
import 'sort_direction.dart';

export 'sort_direction.dart';
""");

      try {
        final argResult = argParser.parse([]);
        final cfg = Cfg(argResult);
        cfg.folders = ["res"];
        cfg.files = ["exports_unsorted.dart"];
        cfg.comments = false;

        final collector = FilePathsCollector(cfg: cfg);
        final collected = collector.collect();

        final sorted = sort(collected, cfg);

        expect(sorted.length, 1);
        expect(
          sorted.first.sorted,
          contains("import 'package:drift/drift.dart';"),
        );
        expect(sorted.first.sorted, contains("export 'sort_direction.dart';"));
        expect(
          sorted.first.sorted.indexOf("export 'sort_direction.dart';"),
          greaterThan(
            sorted.first.sorted.indexOf("import 'sort_direction.dart';"),
          ),
        );
      } finally {
        file.deleteSync();
      }
    });

    test("Sorting file. Invalid Dart files are skipped without crashing.", () {
      final invalidFile = File("res/invalid_sorter.dart");
      invalidFile.writeAsStringSync("""
class Example {
  final final value = 1;
}
""");

      try {
        final argResult = argParser.parse([]);
        final cfg = Cfg(argResult);
        cfg.folders = ["res"];
        cfg.files = ["invalid_sorter.dart"];

        final collector = FilePathsCollector(cfg: cfg);
        final collected = collector.collect();

        expect(() => sort(collected, cfg), returnsNormally);
        expect(collected.filtered, hasLength(1));
        expect(invalidFile.readAsStringSync(), contains("final final value"));
      } finally {
        invalidFile.deleteSync();
      }
    });

    test("Sorting file. Complies with directives_ordering linter rule.", () {
      final unsorted = """
import 'package:test/test.dart';
import 'dart:io';
import 'package:analyzer/dart/ast/ast.dart';
import 'dart:async';

void main() {}
""";
      final file = File("res/unsorted_directives.dart");
      file.writeAsStringSync(unsorted);

      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);
      cfg.folders = ["res"];
      cfg.files = ["unsorted_directives.dart"];
      cfg.comments = false;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, 1);
      final sortedContent = sorted.first.sorted;
      file.writeAsStringSync(sortedContent);

      final analysisOptions = File("res/analysis_options.yaml");
      analysisOptions.writeAsStringSync("""
linter:
  rules:
    - directives_ordering
""");

      final result = Process.runSync('dart', ['analyze', file.path]);

      expect(
        result.stdout.toString().contains('directives_ordering'),
        isFalse,
        reason:
            'The sorted file should not violate directives_ordering.\nAnalyzer output: ${result.stdout}',
      );

      file.deleteSync();
      analysisOptions.deleteSync();
    });
  });

  group("Sorter Tests. Multiline with show. Issue #4", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFileIssue4);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Multiline with show.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.dartFmt = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileIssue4);
    });
  });

  group("Sorter Tests. Multilines after directives.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFileMultiline);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Multiline with show.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileMultiline);
    });
  });

  group("Sorter Tests. Extra long directives.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(unsortedFileLongDirectives);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Extra long directives.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.dartFmt = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileLongDirectives);
    });
  });

  group("Sorter Tests. Barrel file.", () {
    setUp(() {
      File("res/unsorted.dart").writeAsStringSync(barrelFileFixture);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Barrel file.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, barrelFileFixture);
    });
  });
  group("Sorter Tests. Nested relative imports.", () {
    final nestedFileDir = Directory("lib/folder_a/folder_b/folder_d");
    final nestedFile = File("${nestedFileDir.path}/current_file.dart");
    final folderA = Directory("lib/folder_a");

    setUp(() {
      if (folderA.existsSync()) {
        folderA.deleteSync(recursive: true);
      }
      nestedFileDir.createSync(recursive: true);
      nestedFile.writeAsStringSync(unsortedNestedRelativeFile);
    });

    tearDown(() {
      if (folderA.existsSync()) {
        folderA.deleteSync(recursive: true);
      }
    });

    test("Sorting file. Nested relative import.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["lib/folder_a"];
      cfg.files = ["current_file.dart"];
      cfg.relative = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, 1);
      expect(sorted.first.sorted, sortedNestedRelativeFile);
    });
  });

  group("Sorter Tests. Long package import converted to relative.", () {
    setUp(() {
      File(
        "res/unsorted.dart",
      ).writeAsStringSync(unsortedFileLongPackageImport);
    });

    tearDown(() {
      File("res/unsorted.dart").delete();
    });

    test("Sorting file. Long package import converted to relative.", () {
      var argResult = argParser.parse([]);
      var cfg = Cfg(argResult);

      cfg.folders = ["test", "res", "lib"];
      cfg.files = ["unsorted.dart"];
      cfg.relative = true;

      var collector = FilePathsCollector(cfg: cfg);
      var collected = collector.collect();

      var sorted = sort(collected, cfg);

      expect(sorted.length, collected.filtered.length);

      expect(sorted.first.sorted, sortedFileLongPackageImport);
    });
  });
}
